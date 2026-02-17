import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/data/drift_db.dart';
import 'package:island/data/message.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/talker.dart';

part 'chat_room.g.dart';

final chatSyncingProvider = NotifierProvider<ChatSyncingNotifier, bool>(
  ChatSyncingNotifier.new,
);

class ChatSyncingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final flashingMessagesProvider =
    NotifierProvider<FlashingMessagesNotifier, Set<String>>(
      FlashingMessagesNotifier.new,
    );

class FlashingMessagesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void update(Set<String> Function(Set<String>) cb) {
    state = cb(state);
  }

  void clear() => state = {};
}

const String _chatSyncCursorStoreKey = 'chat_messages_sync_cursor_ms';

Future<int> _getLatestMessageTimestamp(AppDatabase db) async {
  try {
    final result = await db
        .customSelect(
          'SELECT MAX(created_at) as latest_timestamp FROM chat_messages',
          readsFrom: {db.chatMessages},
        )
        .getSingleOrNull();

    if (result != null) {
      final latestTimestamp = result.read<DateTime?>('latest_timestamp');
      if (latestTimestamp != null) {
        return latestTimestamp.millisecondsSinceEpoch;
      }
    }
  } catch (e) {
    talker.log('Error getting latest message timestamp: $e');
  }
  return 0;
}

/// Global chat sync notifier that syncs messages from all chat rooms
@Riverpod(keepAlive: true)
class ChatGlobalSyncNotifier extends _$ChatGlobalSyncNotifier {
  StreamSubscription? _wsSubscription;

  SnChatMessage? _tryParseChatMessage(dynamic data, {String? context}) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMessage.fromJson(data);
    } catch (e) {
      talker.log('Skipping invalid chat message${context != null ? ' ($context)' : ''}: $e');
      return null;
    }
  }

  SnChatMember? _tryParseChatMember(dynamic data, {String? context}) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMember.fromJson(data);
    } catch (e) {
      talker.log('Skipping invalid chat member${context != null ? ' ($context)' : ''}: $e');
      return null;
    }
  }

  @override
  Future<void> build() async {
    // Set up global WebSocket listener for real-time message handling
    final ws = ref.watch(websocketProvider);
    _wsSubscription = ws.dataStream.listen(_handleWebSocketMessage);

    ref.onDispose(() {
      _wsSubscription?.cancel();
    });
  }

  /// Handle incoming WebSocket messages globally
  Future<void> _handleWebSocketMessage(WebSocketPacket pkt) async {
    if (!pkt.type.startsWith('messages')) return;
    if (['messages.read'].contains(pkt.type)) return;

    final db = ref.read(databaseProvider);
    final currentUserId = ref.read(userInfoProvider).value?.id;

    // Handle typing events
    if (pkt.type == 'messages.typing' && pkt.data?['sender'] != null) {
      final roomId = pkt.data?['room_id'];
      if (roomId == null) return;

      final sender = _tryParseChatMember(
        pkt.data?['sender'],
        context: 'ws typing',
      );
      if (sender == null) return;
      eventBus.fire(
        ChatTypingEvent(roomId: roomId, sender: sender, isTyping: true),
      );
      return;
    }

    // Handle message events
    final message = _tryParseChatMessage(pkt.data, context: 'ws ${pkt.type}');
    if (message == null) return;
    final roomId = message.chatRoomId;

    switch (pkt.type) {
      case 'messages.new':
        {
          var localMessage = LocalChatMessage.fromRemoteMessage(
            message,
            MessageStatus.sent,
          );
          final existingMsg = await _fetchMessageFromDb(db, message.id, roomId);
          if (existingMsg != null) {
            localMessage = _mergeReactionFieldsFromExisting(
              localMessage,
              existingMsg,
            );
          }
          await db.saveMessageWithSender(localMessage);
          eventBus.fire(ChatMessageNewEvent(message));
        }
      case 'messages.update':
      case 'messages.update.links':
        {
          final targetId = pkt.data?['meta']?['message_id'] ?? message.id;
          final existingMsg = await _fetchMessageFromDb(db, targetId, roomId);

          if (existingMsg != null) {
            final existingRemote = existingMsg.toRemoteMessage();
            final mergedMeta = Map<String, dynamic>.of(existingRemote.meta);
            mergedMeta.addAll(message.meta);
            mergedMeta.remove('message_id');

            final updatedRemote = existingRemote.copyWith(
              meta: mergedMeta,
              editedAt: message.createdAt,
            );

            final updatedMessage = LocalChatMessage.fromRemoteMessage(
              updatedRemote,
              existingMsg.status,
            );
            await db.saveMessageWithSender(updatedMessage);
          } else {
            // Message doesn't exist, treat as new
            var localMessage = LocalChatMessage.fromRemoteMessage(
              message,
              MessageStatus.sent,
            );
            final existed = await _fetchMessageFromDb(db, message.id, roomId);
            if (existed != null) {
              localMessage = _mergeReactionFieldsFromExisting(
                localMessage,
                existed,
              );
            }
            await db.saveMessageWithSender(localMessage);
          }
          eventBus.fire(ChatMessageUpdateEvent(message));
        }
      case 'messages.delete':
        {
          final targetId = pkt.data?['meta']?['message_id'] ?? message.id;
          await _markMessageAsDeleted(db, targetId, roomId);
          eventBus.fire(
            ChatMessageDeleteEvent(messageId: targetId, roomId: roomId),
          );
        }
      case 'messages.reaction.added':
      case 'messages.reaction.removed':
        {
          final applied = await _applyReactionUpdate(
            db,
            message,
            currentUserId: currentUserId,
          );
          if (applied) {
            eventBus.fire(ChatMessageUpdateEvent(message));
          }
        }
    }
  }

  Future<LocalChatMessage?> _fetchMessageFromDb(
    AppDatabase db,
    String messageId,
    String roomId,
  ) async {
    try {
      final msg =
          await (db.select(db.chatMessages)
                ..where((m) => m.id.equals(messageId))
                ..where((m) => m.roomId.equals(roomId)))
              .getSingleOrNull();
      if (msg != null) {
        return db.companionToMessage(msg);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _markMessageAsDeleted(
    AppDatabase db,
    String messageId,
    String roomId,
  ) async {
    final existingMsg = await _fetchMessageFromDb(db, messageId, roomId);
    if (existingMsg == null) return;

    final remote = existingMsg.toRemoteMessage();
    final updatedRemote = remote.copyWith(
      content: 'This message was deleted',
      deletedAt: DateTime.now(),
      attachments: [],
    );

    final deletedMessage = LocalChatMessage.fromRemoteMessage(
      updatedRemote,
      existingMsg.status,
    );
    await db.saveMessageWithSender(deletedMessage);
  }

  Map<String, int> _extractReactionsCount(LocalChatMessage message) {
    final raw = message.data['reactions_count'];
    if (raw is! Map) return {};
    return raw.map((key, value) {
      final count = value is int ? value : int.tryParse(value.toString()) ?? 0;
      return MapEntry(key.toString(), count);
    });
  }

  Map<String, bool> _extractReactionsMade(LocalChatMessage message) {
    final raw = message.data['reactions_made'];
    if (raw is! Map) return {};
    return raw.map((key, value) => MapEntry(key.toString(), value == true));
  }

  LocalChatMessage _copyWithReactionMaps(
    LocalChatMessage message, {
    required Map<String, int> reactionsCount,
    required Map<String, bool> reactionsMade,
  }) {
    final updatedData = Map<String, dynamic>.from(message.data);
    updatedData['reactions_count'] = reactionsCount;
    updatedData['reactions_made'] = reactionsMade;

    return LocalChatMessage(
      id: message.id,
      roomId: message.roomId,
      senderId: message.senderId,
      sender: message.sender,
      data: updatedData,
      createdAt: message.createdAt,
      nonce: message.nonce,
      status: message.status,
      content: message.content,
      isDeleted: message.isDeleted,
      updatedAt: message.updatedAt,
      deletedAt: message.deletedAt,
      type: message.type,
      meta: message.meta,
      membersMentioned: message.membersMentioned,
      editedAt: message.editedAt,
      attachments: message.attachments,
      reactions: message.reactions,
      repliedMessageId: message.repliedMessageId,
      forwardedMessageId: message.forwardedMessageId,
      localAttachments: message.localAttachments,
    );
  }

  LocalChatMessage _copyWithMergedData(
    LocalChatMessage message,
    Map<String, dynamic> mergedData,
  ) {
    return LocalChatMessage(
      id: message.id,
      roomId: message.roomId,
      senderId: message.senderId,
      sender: message.sender,
      data: mergedData,
      createdAt: message.createdAt,
      nonce: message.nonce,
      status: message.status,
      content: message.content,
      isDeleted: message.isDeleted,
      updatedAt: message.updatedAt,
      deletedAt: message.deletedAt,
      type: message.type,
      meta: message.meta,
      membersMentioned: message.membersMentioned,
      editedAt: message.editedAt,
      attachments: message.attachments,
      reactions: message.reactions,
      repliedMessageId: message.repliedMessageId,
      forwardedMessageId: message.forwardedMessageId,
      localAttachments: message.localAttachments,
    );
  }

  LocalChatMessage _mergeReactionFieldsFromExisting(
    LocalChatMessage incoming,
    LocalChatMessage existing,
  ) {
    final mergedData = Map<String, dynamic>.from(incoming.data);
    if (!mergedData.containsKey('reactions_count') &&
        existing.data.containsKey('reactions_count')) {
      mergedData['reactions_count'] = existing.data['reactions_count'];
    }
    if (!mergedData.containsKey('reactions_made') &&
        existing.data.containsKey('reactions_made')) {
      mergedData['reactions_made'] = existing.data['reactions_made'];
    }
    if (mergedData.length == incoming.data.length) return incoming;
    return _copyWithMergedData(incoming, mergedData);
  }

  Future<bool> _applyReactionUpdate(
    AppDatabase db,
    SnChatMessage packet, {
    String? currentUserId,
  }) async {
    final targetId = packet.meta['message_id']?.toString();
    if (targetId == null || targetId.isEmpty) return false;

    final targetMessage = await _fetchMessageFromDb(
      db,
      targetId,
      packet.chatRoomId,
    );
    if (targetMessage == null) return false;

    final reactionsCount = _extractReactionsCount(targetMessage);
    final reactionsMade = _extractReactionsMade(targetMessage);

    if (packet.type == 'messages.reaction.added') {
      final symbol =
          packet.meta['symbol']?.toString() ??
          (packet.meta['reaction'] is Map
              ? (packet.meta['reaction'] as Map)['symbol']?.toString()
              : null);
      if (symbol == null || symbol.isEmpty) return false;
      reactionsCount[symbol] = (reactionsCount[symbol] ?? 0) + 1;
      if (currentUserId != null && packet.senderId == currentUserId) {
        reactionsMade[symbol] = true;
      }
    } else if (packet.type == 'messages.reaction.removed') {
      final symbol = packet.meta['symbol']?.toString();
      if (symbol == null || symbol.isEmpty) return false;
      final nextCount = (reactionsCount[symbol] ?? 0) - 1;
      if (nextCount > 0) {
        reactionsCount[symbol] = nextCount;
      } else {
        reactionsCount.remove(symbol);
      }
      if (currentUserId != null && packet.senderId == currentUserId) {
        reactionsMade.remove(symbol);
      }
    }

    final updatedMessage = _copyWithReactionMaps(
      targetMessage,
      reactionsCount: reactionsCount,
      reactionsMade: reactionsMade,
    );

    await db.updateMessage(db.messageToCompanion(updatedMessage));
    return true;
  }

  /// Perform global sync to fetch messages from all chat rooms
  Future<void> syncAllMessages() async {
    talker.log('Starting global chat sync...');

    Future.microtask(() {
      if (ref.mounted) {
        ref.read(chatSyncingProvider.notifier).set(true);
      }
    });

    try {
      final client = ref.read(apiClientProvider);
      final db = ref.read(databaseProvider);
      final prefs = ref.read(sharedPreferencesProvider);
      final currentUserId = ref.read(userInfoProvider).value?.id;

      final savedCursor = prefs.getInt(_chatSyncCursorStoreKey) ?? 0;
      final dbLatestCursor = await _getLatestMessageTimestamp(db);
      final currentSyncTimestamp = (savedCursor > 0 && dbLatestCursor > 0)
          ? (savedCursor < dbLatestCursor ? savedCursor : dbLatestCursor)
          : (savedCursor > 0 ? savedCursor : dbLatestCursor);

      talker.log(
        'Global sync with cursor: $currentSyncTimestamp (saved=$savedCursor, dbLatest=$dbLatestCursor)',
      );

      // Eager sync: after one full pass, run one additional pass from the
      // advanced cursor to reduce race-window misses.
      var totalSynced = 0;
      final updatedRoomIds = <String>{};
      var syncCursor = currentSyncTimestamp;
      var eagerRound = 0;

      while (eagerRound < 2) {
        var roundSynced = 0;
        var roundMaxSeenTimestamp = syncCursor;
        var pagingCursor = syncCursor;

        while (true) {
          // Call the global sync endpoint
          final resp = await client.post(
            '/messager/chat/sync',
            data: {'last_sync_timestamp': pagingCursor},
          );
          final body = resp.data as Map<String, dynamic>;
          final rawMessages = (body['messages'] as List?) ?? const [];
          final messages = rawMessages
              .map((e) => _tryParseChatMessage(e, context: 'sync batch'))
              .whereType<SnChatMessage>()
              .toList();
          final currentTimestampRaw =
              body['current_timestamp'] ?? body['currentTimestamp'];
          final currentTimestamp = switch (currentTimestampRaw) {
            DateTime value => value,
            String value => DateTime.tryParse(value) ?? DateTime.now(),
            int value => DateTime.fromMillisecondsSinceEpoch(value),
            _ => DateTime.now(),
          };
          final totalMessagesRaw = body['total_count'] ?? body['totalCount'];
          final totalMessages = switch (totalMessagesRaw) {
            int value => value,
            String value => int.tryParse(value) ?? rawMessages.length,
            _ => rawMessages.length,
          };
          final skippedCount = rawMessages.length - messages.length;

          talker.log(
            'Global sync round ${eagerRound + 1} received ${messages.length} valid messages (${rawMessages.length} raw, skipped $skippedCount), timestamp: $currentTimestamp (total: $totalMessages)',
          );

          // Save all messages to database
          for (final msg in messages) {
            try {
              if (msg.type == 'messages.reaction.added' ||
                  msg.type == 'messages.reaction.removed') {
                final existed =
                    await (db.select(db.chatMessages)
                          ..where((m) => m.id.equals(msg.id)))
                        .getSingleOrNull();
                if (existed == null) {
                  await _applyReactionUpdate(
                    db,
                    msg,
                    currentUserId: currentUserId,
                  );
                }
                await db.saveMessageWithSender(
                  LocalChatMessage.fromRemoteMessage(msg, MessageStatus.sent),
                );
                updatedRoomIds.add(msg.chatRoomId);
                roundSynced += 1;
                continue;
              }
              var localMessage = LocalChatMessage.fromRemoteMessage(
                msg,
                MessageStatus.sent,
              );
              final existingMsg = await _fetchMessageFromDb(
                db,
                msg.id,
                msg.chatRoomId,
              );
              if (existingMsg != null) {
                localMessage = _mergeReactionFieldsFromExisting(
                  localMessage,
                  existingMsg,
                );
              }
              await db.saveMessageWithSender(localMessage);
              updatedRoomIds.add(msg.chatRoomId);
              roundSynced += 1;
              final createdAtMs = msg.createdAt.millisecondsSinceEpoch;
              if (createdAtMs > roundMaxSeenTimestamp) {
                roundMaxSeenTimestamp = createdAtMs;
              }
            } catch (e) {
              talker.log('Error saving message from global sync: $e');
            }
          }

          totalSynced += messages.length;

          // Check if there are more messages to sync
          if (rawMessages.length < totalMessages) {
            // Keep using the server cursor for paging within this sync session.
            pagingCursor = currentTimestamp.millisecondsSinceEpoch;
            talker.log(
              'More messages to sync, continuing with cursor: $pagingCursor',
            );
          } else {
            // No more messages to sync for this round
            pagingCursor = currentTimestamp.millisecondsSinceEpoch;
            break;
          }
        }

        syncCursor = [
          roundMaxSeenTimestamp,
          pagingCursor,
        ].reduce((a, b) => a > b ? a : b);

        // Stop eager pass if no new messages were synced in this round.
        if (roundSynced == 0) break;
        eagerRound += 1;
      }

      // Persist the farthest cursor we've reached for next sync run.
      // We use max(server cursor, latest created_at seen) for monotonic progress.
      final nextCursor = syncCursor;
      await prefs.setInt(_chatSyncCursorStoreKey, nextCursor);

      talker.log(
        'Global sync complete: $totalSynced messages saved (nextCursor=$nextCursor)',
      );
      if (updatedRoomIds.isNotEmpty) {
        eventBus.fire(ChatMessagesSyncedEvent(roomIds: updatedRoomIds));
      }
    } catch (e, stackTrace) {
      talker.log(
        'Error during global chat sync',
        exception: e,
        stackTrace: stackTrace,
      );
    } finally {
      Future.microtask(() {
        if (ref.mounted) {
          ref.read(chatSyncingProvider.notifier).set(false);
        }
      });
    }
  }
}

@riverpod
class ChatRoomJoinedNotifier extends _$ChatRoomJoinedNotifier {
  @override
  Future<List<SnChatRoom>> build() async {
    final db = ref.watch(databaseProvider);

    try {
      final localRoomsData = await db.select(db.chatRooms).get();
      final localRealmsData = await db.select(db.realms).get();
      if (localRoomsData.isNotEmpty) {
        final localRooms = await Future.wait(
          localRoomsData.map((row) async {
            final membersRows = await (db.select(
              db.chatMembers,
            )..where((m) => m.chatRoomId.equals(row.id))).get();
            final members = membersRows.map((mRow) {
              final account = SnAccount.fromJson(mRow.account);
              return SnChatMember(
                id: mRow.id,
                chatRoomId: mRow.chatRoomId,
                accountId: mRow.accountId,
                account: account,
                nick: mRow.nick,
                notify: mRow.notify,
                joinedAt: mRow.joinedAt,
                breakUntil: mRow.breakUntil,
                timeoutUntil: mRow.timeoutUntil,
                status: null,
                createdAt: mRow.createdAt,
                updatedAt: mRow.updatedAt,
                deletedAt: mRow.deletedAt,
                chatRoom: null,
              );
            }).toList();
            return SnChatRoom(
              id: row.id,
              name: row.name,
              description: row.description,
              type: row.type,
              isPublic: row.isPublic!,
              isCommunity: row.isCommunity!,
              picture: row.picture != null
                  ? SnCloudFile.fromJson(row.picture!)
                  : null,
              background: row.background != null
                  ? SnCloudFile.fromJson(row.background!)
                  : null,
              realmId: row.realmId,
              accountId: row.accountId,
              realm: localRealmsData
                  .where((e) => e.id == row.realmId)
                  .map((e) => _buildRealmFromTableEntry(e))
                  .firstOrNull,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
              deletedAt: row.deletedAt,
              members: members,
              isPinned: row.isPinned ?? false,
            );
          }),
        );

        // Background sync using global endpoint
        Future(() async {
          try {
            await ref.read(chatGlobalSyncProvider.notifier).syncAllMessages();

            // Also refresh room list
            final client = ref.read(apiClientProvider);
            final resp = await client.get('/messager/chat');
            final remoteRooms = resp.data
                .map((e) => SnChatRoom.fromJson(e))
                .cast<SnChatRoom>()
                .toList();
            await db.saveChatRooms(remoteRooms, override: true);
            // Update state with fresh data
            state = AsyncData(await _buildRoomsFromDb(db));
          } catch (_) {}
        }).ignore();

        return localRooms;
      }
    } catch (_) {}

    // Fallback to API
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/messager/chat');
    final rooms = resp.data
        .map((e) => SnChatRoom.fromJson(e))
        .cast<SnChatRoom>()
        .toList();
    await db.saveChatRooms(rooms, override: true);
    return rooms;
  }

  SnRealm _buildRealmFromTableEntry(Realm localRealm) {
    return SnRealm(
      id: localRealm.id,
      slug: localRealm.slug,
      name: localRealm.name ?? localRealm.slug,
      description: localRealm.description ?? '',
      verifiedAs: localRealm.verifiedAs,
      verifiedAt: localRealm.verifiedAt,
      isCommunity: localRealm.isCommunity,
      isPublic: localRealm.isPublic,
      picture: localRealm.picture != null
          ? SnCloudFile.fromJson(localRealm.picture!)
          : null,
      background: localRealm.background != null
          ? SnCloudFile.fromJson(localRealm.background!)
          : null,
      accountId: localRealm.accountId ?? '',
      createdAt: localRealm.createdAt,
      updatedAt: localRealm.updatedAt,
      deletedAt: localRealm.deletedAt,
    );
  }

  Future<List<SnChatRoom>> _buildRoomsFromDb(AppDatabase db) async {
    final localRoomsData = await db.select(db.chatRooms).get();
    return Future.wait(
      localRoomsData.map((row) async {
        final membersRows = await (db.select(
          db.chatMembers,
        )..where((m) => m.chatRoomId.equals(row.id))).get();
        final members = membersRows.map((mRow) {
          final account = SnAccount.fromJson(mRow.account);
          return SnChatMember(
            id: mRow.id,
            chatRoomId: mRow.chatRoomId,
            accountId: mRow.accountId,
            account: account,
            nick: mRow.nick,
            notify: mRow.notify,
            joinedAt: mRow.joinedAt,
            breakUntil: mRow.breakUntil,
            timeoutUntil: mRow.timeoutUntil,
            status: null,
            createdAt: mRow.createdAt,
            updatedAt: mRow.updatedAt,
            deletedAt: mRow.deletedAt,
            chatRoom: null,
          );
        }).toList();

        // Load realm if it exists
        SnRealm? realm;
        if (row.realmId != null) {
          try {
            final realmRow = await (db.select(
              db.realms,
            )..where((r) => r.id.equals(row.realmId!))).getSingleOrNull();
            if (realmRow != null) {
              realm = SnRealm(
                id: realmRow.id,
                slug: '', // Not stored in DB
                name: realmRow.name ?? '',
                description: realmRow.description ?? '',
                verifiedAs: null, // Not stored in DB
                verifiedAt: null, // Not stored in DB
                isCommunity: false, // Not stored in DB
                isPublic: true, // Not stored in DB
                picture: realmRow.picture != null
                    ? SnCloudFile.fromJson(realmRow.picture!)
                    : null,
                background: realmRow.background != null
                    ? SnCloudFile.fromJson(realmRow.background!)
                    : null,
                accountId: realmRow.accountId ?? '',
                createdAt: realmRow.createdAt,
                updatedAt: realmRow.updatedAt,
                deletedAt: realmRow.deletedAt,
              );
            }
          } catch (_) {
            // Realm not found, keep as null
          }
        }

        return SnChatRoom(
          id: row.id,
          name: row.name,
          description: row.description,
          type: row.type,
          isPublic: row.isPublic!,
          isCommunity: row.isCommunity!,
          picture: row.picture != null
              ? SnCloudFile.fromJson(row.picture!)
              : null,
          background: row.background != null
              ? SnCloudFile.fromJson(row.background!)
              : null,
          realmId: row.realmId,
          accountId: row.accountId,
          realm: realm,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deletedAt: row.deletedAt,
          members: members,
          isPinned: row.isPinned ?? false,
        );
      }),
    );
  }
}

@riverpod
class ChatRoomNotifier extends _$ChatRoomNotifier {
  @override
  Future<SnChatRoom?> build(String? identifier) async {
    if (identifier == null) return null;
    final db = ref.watch(databaseProvider);

    try {
      // Try to get from local database first
      final localRoomData = await (db.select(
        db.chatRooms,
      )..where((r) => r.id.equals(identifier))).getSingleOrNull();

      if (localRoomData != null) {
        // Fetch members for this room
        final membersRows = await (db.select(
          db.chatMembers,
        )..where((m) => m.chatRoomId.equals(localRoomData.id))).get();
        final members = membersRows.map((mRow) {
          final account = SnAccount.fromJson(mRow.account);
          return SnChatMember(
            id: mRow.id,
            chatRoomId: mRow.chatRoomId,
            accountId: mRow.accountId,
            account: account,
            nick: mRow.nick,
            notify: mRow.notify,
            joinedAt: mRow.joinedAt,
            breakUntil: mRow.breakUntil,
            timeoutUntil: mRow.timeoutUntil,
            status: null,
            createdAt: mRow.createdAt,
            updatedAt: mRow.updatedAt,
            deletedAt: mRow.deletedAt,
            chatRoom: null,
          );
        }).toList();

        final localRoom = SnChatRoom(
          id: localRoomData.id,
          name: localRoomData.name,
          description: localRoomData.description,
          type: localRoomData.type,
          isPublic: localRoomData.isPublic!,
          isCommunity: localRoomData.isCommunity!,
          picture: localRoomData.picture != null
              ? SnCloudFile.fromJson(localRoomData.picture!)
              : null,
          background: localRoomData.background != null
              ? SnCloudFile.fromJson(localRoomData.background!)
              : null,
          realmId: localRoomData.realmId,
          accountId: localRoomData.accountId,
          realm: null,
          createdAt: localRoomData.createdAt,
          updatedAt: localRoomData.updatedAt,
          deletedAt: localRoomData.deletedAt,
          members: members,
        );

        // Background sync
        Future(() async {
          try {
            final client = ref.read(apiClientProvider);
            final resp = await client.get('/messager/chat/$identifier');
            final remoteRoom = SnChatRoom.fromJson(resp.data);
            // Update state with fresh data directly without saving to DB
            // DB will be updated by ChatRoomJoinedNotifier's full sync
            state = AsyncData(remoteRoom);
          } catch (_) {}
        }).ignore();

        return localRoom;
      }
    } catch (_) {}

    // Fallback to API
    try {
      final client = ref.watch(apiClientProvider);
      final resp = await client.get('/messager/chat/$identifier');
      final room = SnChatRoom.fromJson(resp.data);
      await db.saveChatRooms([room]);
      return room;
    } catch (err) {
      if (err is DioException && err.response?.statusCode == 404) {
        return null; // Chat room not found
      }
      rethrow; // Rethrow other errors
    }
  }
}

@riverpod
class ChatRoomIdentityNotifier extends _$ChatRoomIdentityNotifier {
  @override
  Future<SnChatMember?> build(String? identifier) async {
    if (identifier == null) return null;
    final db = ref.watch(databaseProvider);
    final userInfo = ref.watch(userInfoProvider);

    try {
      // Try to get from local database first
      if (userInfo.value != null) {
        final localMemberData =
            await (db.select(db.chatMembers)
                  ..where((m) => m.chatRoomId.equals(identifier))
                  ..where((m) => m.accountId.equals(userInfo.value!.id)))
                .getSingleOrNull();

        if (localMemberData != null) {
          final account = SnAccount.fromJson(localMemberData.account);
          final localMember = SnChatMember(
            id: localMemberData.id,
            chatRoomId: localMemberData.chatRoomId,
            accountId: localMemberData.accountId,
            account: account,
            nick: localMemberData.nick,
            notify: localMemberData.notify,
            joinedAt: localMemberData.joinedAt,
            breakUntil: localMemberData.breakUntil,
            timeoutUntil: localMemberData.timeoutUntil,
            status: null,
            createdAt: localMemberData.createdAt,
            updatedAt: localMemberData.updatedAt,
            deletedAt: localMemberData.deletedAt,
            chatRoom: null,
          );

          // Background sync
          Future(() async {
            try {
              final client = ref.read(apiClientProvider);
              final resp = await client.get(
                '/messager/chat/$identifier/members/me',
              );
              final remoteMember = SnChatMember.fromJson(resp.data);
              await db.saveMember(remoteMember);
              // Update state with fresh data
              if (userInfo.value != null) {
                state = AsyncData(
                  await _buildMemberFromDb(db, identifier, userInfo.value!.id),
                );
              }
            } catch (_) {}
          }).ignore();

          return localMember;
        }
      }
    } catch (_) {}

    // Fallback to API
    try {
      final client = ref.watch(apiClientProvider);
      final resp = await client.get('/messager/chat/$identifier/members/me');
      final member = SnChatMember.fromJson(resp.data);
      await db.saveMember(member);
      return member;
    } catch (err) {
      if (err is DioException && err.response?.statusCode == 404) {
        return null; // Chat member not found
      }
      rethrow; // Rethrow other errors
    }
  }

  Future<SnChatMember?> _buildMemberFromDb(
    AppDatabase db,
    String identifier,
    String accountId,
  ) async {
    final localMemberData =
        await (db.select(db.chatMembers)
              ..where((m) => m.chatRoomId.equals(identifier))
              ..where((m) => m.accountId.equals(accountId)))
            .getSingleOrNull();

    if (localMemberData == null) return null;

    final account = SnAccount.fromJson(localMemberData.account);
    return SnChatMember(
      id: localMemberData.id,
      chatRoomId: localMemberData.chatRoomId,
      accountId: localMemberData.accountId,
      account: account,
      nick: localMemberData.nick,
      notify: localMemberData.notify,
      joinedAt: localMemberData.joinedAt,
      breakUntil: localMemberData.breakUntil,
      timeoutUntil: localMemberData.timeoutUntil,
      status: null,
      createdAt: localMemberData.createdAt,
      updatedAt: localMemberData.updatedAt,
      deletedAt: localMemberData.deletedAt,
      chatRoom: null,
    );
  }
}

@riverpod
Future<List<SnChatMember>> chatroomInvites(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/messager/chat/invites');
  return resp.data
      .map((e) => SnChatMember.fromJson(e))
      .cast<SnChatMember>()
      .toList();
}
