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

/// Global chat sync notifier that syncs messages from all chat rooms
@Riverpod(keepAlive: true)
class ChatGlobalSyncNotifier extends _$ChatGlobalSyncNotifier {
  StreamSubscription? _wsSubscription;

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

    // Handle typing events
    if (pkt.type == 'messages.typing' && pkt.data?['sender'] != null) {
      final roomId = pkt.data?['room_id'];
      if (roomId == null) return;

      final sender = SnChatMember.fromJson(pkt.data?['sender']);
      eventBus.fire(
        ChatTypingEvent(roomId: roomId, sender: sender, isTyping: true),
      );
      return;
    }

    // Handle message events
    final message = SnChatMessage.fromJson(pkt.data!);
    final roomId = message.chatRoomId;

    switch (pkt.type) {
      case 'messages.new':
        {
          final localMessage = LocalChatMessage.fromRemoteMessage(
            message,
            MessageStatus.sent,
          );
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
            final localMessage = LocalChatMessage.fromRemoteMessage(
              message,
              MessageStatus.sent,
            );
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

      // Use a dedicated persisted sync cursor instead of DB max(created_at).
      // This prevents websocket-received newer messages from skipping older
      // offline windows during the next API sync.
      var currentSyncTimestamp = prefs.getInt(_chatSyncCursorStoreKey) ?? 0;

      talker.log('Global sync with cursor: $currentSyncTimestamp');

      // Use a loop to handle pagination - continue syncing until all messages are fetched
      var totalSynced = 0;
      var maxSeenTimestamp = currentSyncTimestamp;

      while (true) {
        // Call the global sync endpoint
        final resp = await client.post(
          '/messager/chat/sync',
          data: {'last_sync_timestamp': currentSyncTimestamp},
        );
        final rsp = MessageSyncResponse.fromJson(resp.data);

        // Parse the response
        final messages = rsp.messages;
        final currentTimestamp = rsp.currentTimestamp;
        final totalMessages = rsp.totalCount;

        talker.log(
          'Global sync received ${messages.length} messages, timestamp: $currentTimestamp (total: $totalMessages)',
        );

        // Save all messages to database
        for (final msg in messages) {
          try {
            final localMessage = LocalChatMessage.fromRemoteMessage(
              msg,
              MessageStatus.sent,
            );
            await db.saveMessageWithSender(localMessage);
            final createdAtMs = msg.createdAt.millisecondsSinceEpoch;
            if (createdAtMs > maxSeenTimestamp) {
              maxSeenTimestamp = createdAtMs;
            }
          } catch (e) {
            talker.log('Error saving message from global sync: $e');
          }
        }

        totalSynced += messages.length;

        // Check if there are more messages to sync
        // If messages.length < totalMessages, we need to continue with pagination
        if (messages.length < totalMessages) {
          // Keep using the server cursor for paging within this sync session.
          currentSyncTimestamp = currentTimestamp.millisecondsSinceEpoch;
          talker.log(
            'More messages to sync, continuing with cursor: $currentSyncTimestamp',
          );
        } else {
          // No more messages to sync
          break;
        }
      }

      // Persist the farthest cursor we've reached for next sync run.
      // We use max(server cursor, latest created_at seen) for monotonic progress.
      final nextCursor = [
        maxSeenTimestamp,
        currentSyncTimestamp,
      ].reduce((a, b) => a > b ? a : b);
      await prefs.setInt(_chatSyncCursorStoreKey, nextCursor);

      talker.log(
        'Global sync complete: $totalSynced messages saved (nextCursor=$nextCursor)',
      );
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
