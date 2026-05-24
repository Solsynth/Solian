import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/data/database.dart';
import 'package:island/data/message.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/e2ee/e2ee.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'chat_room.g.dart';

final chatSyncingProvider = NotifierProvider<ChatSyncingNotifier, bool>(
  ChatSyncingNotifier.new,
);

final chatSyncHintProvider = NotifierProvider<ChatSyncHintNotifier, String?>(
  ChatSyncHintNotifier.new,
);

class ChatSyncingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

class ChatSyncHintNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
  void clear() => state = null;
}

final flashingMessagesProvider =
    NotifierProvider<FlashingMessagesNotifier, Map<String, int>>(
      FlashingMessagesNotifier.new,
    );

class FlashingMessagesNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void trigger(String messageId) {
    state = {...state, messageId: (state[messageId] ?? 0) + 1};
  }

  void clearMessage(String messageId) {
    final next = Map<String, int>.from(state);
    next.remove(messageId);
    state = next;
  }

  void clear() => state = {};
}

const String _chatSyncCursorStoreKey = 'chat_messages_sync_cursor_ms';
const String _chatRoomEncryptionModePrefix = 'chat_room_encryption_mode_';

String _chatRoomEncryptionModeStoreKey(String roomId) =>
    '$_chatRoomEncryptionModePrefix$roomId';

int _safeToInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? fallback;
  if (value is num) return value.toInt();
  return fallback;
}

int _parseEncryptionMode(dynamic value) {
  if (value is String) {
    switch (value) {
      case 'E2eeMls':
        return 3;
      case 'E2eeDm':
      case 'E2eeSenderKeyGroup':
        // Hard-cut migration maps legacy encrypted rooms to MLS.
        return 3;
      case 'None':
        return 0;
    }
  }
  final parsed = _safeToInt(value);
  if (parsed == 1 || parsed == 2) return 3;
  return parsed;
}

Future<void> _persistRoomEncryptionModeFromJson(
  AppDatabase db,
  Map<String, dynamic> roomJson,
) async {
  final roomId = roomJson['id']?.toString();
  if (roomId == null || roomId.isEmpty) return;
  final mode = _parseEncryptionMode(roomJson['encryption_mode']);
  await db.setSecret(_chatRoomEncryptionModeStoreKey(roomId), mode.toString());
}

Future<int> _getLatestMessageTimestamp(AppDatabase db) async {
  try {
    return await db.getLatestMessageTimestamp();
  } catch (e) {
    Logger.root.info('Error getting latest message timestamp: $e');
  }
  return 0;
}

/// Global chat sync notifier that syncs messages from all chat rooms
@Riverpod(keepAlive: true)
class ChatGlobalSyncNotifier extends _$ChatGlobalSyncNotifier {
  StreamSubscription? _wsSubscription;
  Future<void>? _ongoingSync;
  DateTime? _lastSyncStartedAt;
  static const Duration _minSyncInterval = Duration(seconds: 4);
  static const int _maxSyncPagesPerRound = 25;

  String? _normalizeEncryptionMessageType(
    dynamic value, {
    dynamic messageType,
  }) {
    final raw = value?.toString();
    switch (raw) {
      case 'content.new':
      case 'text':
        return 'text';
      case 'content.edit':
      case 'messages.update':
        return 'messages.update';
      case 'content.delete':
      case 'messages.delete':
        return 'messages.delete';
    }
    final fallback = messageType?.toString();
    if (fallback == 'text' ||
        fallback == 'messages.update' ||
        fallback == 'messages.delete') {
      return fallback;
    }
    return raw;
  }

  Map<String, dynamic> _sanitizeChatMessageJson(Map<String, dynamic> input) {
    final data = Map<String, dynamic>.from(input);
    final meta = data['meta'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['meta'] as Map<String, dynamic>)
        : <String, dynamic>{};
    if (data['is_encrypted'] == true) {
      meta['e2ee_is_encrypted'] = true;
      meta['e2ee_ciphertext'] = data['ciphertext'];
      meta['e2ee_header'] = data['encryption_header'];
      meta['e2ee_signature'] = data['encryption_signature'];
      meta['e2ee_scheme'] = data['encryption_scheme'];
      meta['e2ee_epoch'] = data['encryption_epoch'];
      final normalizedType = _normalizeEncryptionMessageType(
        data['encryption_message_type'],
        messageType: data['type'],
      );
      if (normalizedType != null) {
        meta['e2ee_message_type'] = normalizedType;
      }
      meta['e2ee_client_message_id'] = data['client_message_id'];
    }
    data['meta'] = meta;
    data['members_mentioned'] =
        (data['members_mentioned'] is List
                ? data['members_mentioned'] as List
                : const [])
            .whereType<Object?>()
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList();
    data['attachments'] =
        (data['attachments'] is List ? data['attachments'] as List : const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
    data['reactions'] =
        (data['reactions'] is List ? data['reactions'] as List : const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
    return data;
  }

  SnChatMessage? _tryParseChatMessage(dynamic data, {String? context}) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMessage.fromJson(_sanitizeChatMessageJson(data));
    } catch (e) {
      Logger.root.info(
        'Skipping invalid chat message${context != null ? ' ($context)' : ''}: $e',
      );
      return null;
    }
  }

  SnChatMember? _tryParseChatMember(dynamic data, {String? context}) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMember.fromJson(data);
    } catch (e) {
      Logger.root.info(
        'Skipping invalid chat member${context != null ? ' ($context)' : ''}: $e',
      );
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
          if (message.type == 'system.e2ee.enabled') {
            await _markRoomE2eeEnabled(db, message);
          }
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
          var eventMessage = LocalChatMessage.fromRemoteMessage(
            message,
            MessageStatus.sent,
          );
          final existingEvent = await _fetchMessageFromDb(
            db,
            message.id,
            roomId,
          );
          if (existingEvent != null) {
            eventMessage = _mergeReactionFieldsFromExisting(
              eventMessage,
              existingEvent,
            );
          }
          await db.saveMessageWithSender(eventMessage);

          final targetId = pkt.data?['meta']?['message_id'] ?? message.id;
          final existingMsg = await _fetchMessageFromDb(db, targetId, roomId);

          if (existingMsg != null) {
            final existingRemote = existingMsg.toRemoteMessage();
            final mergedMeta = Map<String, dynamic>.of(existingRemote.meta);
            mergedMeta.addAll(message.meta);
            mergedMeta.remove('message_id');

            final updatePayload = LocalChatMessage.fromRemoteMessage(
              message,
              MessageStatus.sent,
            ).toRemoteMessage();

            final updatedRemote = existingRemote.copyWith(
              content: updatePayload.content,
              attachments: updatePayload.attachments,
              membersMentioned: updatePayload.membersMentioned,
              repliedMessageId: updatePayload.repliedMessageId,
              forwardedMessageId: updatePayload.forwardedMessageId,
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
          var eventMessage = LocalChatMessage.fromRemoteMessage(
            message,
            MessageStatus.sent,
          );
          final existingEvent = await _fetchMessageFromDb(
            db,
            message.id,
            roomId,
          );
          if (existingEvent != null) {
            eventMessage = _mergeReactionFieldsFromExisting(
              eventMessage,
              existingEvent,
            );
          }
          await db.saveMessageWithSender(eventMessage);

          final targetId = pkt.data?['meta']?['message_id'] ?? message.id;
          await _markMessageAsDeleted(db, targetId, roomId);
          eventBus.fire(ChatMessageUpdateEvent(message));
          eventBus.fire(
            ChatMessageDeleteEvent(messageId: targetId, roomId: roomId),
          );
        }
      case 'messages.reaction.added':
      case 'messages.reaction.removed':
        {
          var eventMessage = LocalChatMessage.fromRemoteMessage(
            message,
            MessageStatus.sent,
          );
          final existingEvent = await _fetchMessageFromDb(
            db,
            message.id,
            roomId,
          );
          if (existingEvent != null) {
            eventMessage = _mergeReactionFieldsFromExisting(
              eventMessage,
              existingEvent,
            );
          }
          await db.saveMessageWithSender(eventMessage);

          final applied = await _applyReactionUpdate(
            db,
            message,
            currentUserId: currentUserId,
          );
          eventBus.fire(
            ChatMessageUpdateEvent(message, appliedInBackground: applied),
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
      final msg = await db.getMessageById(messageId);
      if (msg != null && msg.roomId == roomId) {
        return msg;
      }
    } catch (_) {}
    return null;
  }

  Future<LocalChatMessage?> _fetchMessageFromApiAndCache(
    AppDatabase db,
    String roomId,
    String messageId,
  ) async {
    try {
      final client = ref.read(apiClientProvider);
      final resp = await client.get(
        '/messager/chat/$roomId/messages/$messageId',
      );
      final parsed = _tryParseChatMessage(
        resp.data,
        context: 'reaction target',
      );
      if (parsed == null) return null;
      final local = LocalChatMessage.fromRemoteMessage(
        parsed,
        MessageStatus.sent,
      );
      await db.saveMessageWithSender(local);
      return local;
    } catch (_) {
      return null;
    }
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

  Future<void> _applyMessageUpdateToTarget(
    AppDatabase db,
    SnChatMessage message,
  ) async {
    final targetId = message.meta['message_id']?.toString() ?? message.id;
    final existingMsg = await _fetchMessageFromDb(
      db,
      targetId,
      message.chatRoomId,
    );

    if (existingMsg == null) return;

    final existingRemote = existingMsg.toRemoteMessage();
    final mergedMeta = Map<String, dynamic>.of(existingRemote.meta);
    mergedMeta.addAll(message.meta);
    mergedMeta.remove('message_id');

    final updatePayload = LocalChatMessage.fromRemoteMessage(
      message,
      MessageStatus.sent,
    ).toRemoteMessage();

    final updatedRemote = existingRemote.copyWith(
      content: updatePayload.content,
      attachments: updatePayload.attachments,
      membersMentioned: updatePayload.membersMentioned,
      repliedMessageId: updatePayload.repliedMessageId,
      forwardedMessageId: updatePayload.forwardedMessageId,
      meta: mergedMeta,
      editedAt: message.createdAt,
    );

    await db.saveMessageWithSender(
      LocalChatMessage.fromRemoteMessage(updatedRemote, existingMsg.status),
    );
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

  Map<String, int>? _extractReactionSnapshot(SnChatMessage message) {
    final raw = message.meta['reactions_count'];
    if (raw is! Map) return null;
    return raw.map((key, value) {
      final count = value is int ? value : int.tryParse(value.toString()) ?? 0;
      return MapEntry(key.toString(), count);
    });
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
      clientMessageId: message.clientMessageId,
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
      clientMessageId: message.clientMessageId,
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
    for (final key in const ['sender', 'reactions_count', 'reactions_made']) {
      if (!mergedData.containsKey(key) && existing.data.containsKey(key)) {
        mergedData[key] = existing.data[key];
      }
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

    var targetMessage = await _fetchMessageFromDb(
      db,
      targetId,
      packet.chatRoomId,
    );
    targetMessage ??= await _fetchMessageFromApiAndCache(
      db,
      packet.chatRoomId,
      targetId,
    );
    if (targetMessage == null) return false;

    final snapshot = _extractReactionSnapshot(packet);
    final reactionsCount = snapshot ?? _extractReactionsCount(targetMessage);
    final reactionsMade = _extractReactionsMade(targetMessage);
    final isCurrentUserReaction =
        currentUserId != null && packet.sender.accountId == currentUserId;

    if (packet.type == 'messages.reaction.added') {
      final symbol =
          packet.meta['symbol']?.toString() ??
          (packet.meta['reaction'] is Map
              ? (packet.meta['reaction'] as Map)['symbol']?.toString()
              : null);
      if (symbol == null || symbol.isEmpty) return false;
      if (snapshot == null) {
        reactionsCount[symbol] = (reactionsCount[symbol] ?? 0) + 1;
      }
      if (isCurrentUserReaction) {
        reactionsMade[symbol] = true;
      }
    } else if (packet.type == 'messages.reaction.removed') {
      final symbol =
          packet.meta['symbol']?.toString() ??
          (packet.meta['reaction'] is Map
              ? (packet.meta['reaction'] as Map)['symbol']?.toString()
              : null);
      if (symbol == null || symbol.isEmpty) return false;
      if (snapshot == null) {
        final nextCount = (reactionsCount[symbol] ?? 0) - 1;
        if (nextCount > 0) {
          reactionsCount[symbol] = nextCount;
        } else {
          reactionsCount.remove(symbol);
        }
      }
      if (isCurrentUserReaction) {
        reactionsMade.remove(symbol);
      }
    }

    final updatedMessage = _copyWithReactionMaps(
      targetMessage,
      reactionsCount: reactionsCount,
      reactionsMade: reactionsMade,
    );

    await db.saveMessage(updatedMessage);
    return true;
  }

  Future<void> _markRoomE2eeEnabled(
    AppDatabase db,
    SnChatMessage message,
  ) async {
    final roomId = message.meta['room_id']?.toString() ?? message.chatRoomId;
    final mode = _parseEncryptionMode(message.meta['mode']);
    await db.setSecret(
      _chatRoomEncryptionModeStoreKey(roomId),
      mode.toString(),
    );
  }

  /// Decrypts an E2EE message if needed, preserving plaintext for own messages.
  /// Returns the message with plaintext content if available, or original if not E2EE.
  Future<SnChatMessage?> _decryptSyncMessage(
    SnChatMessage message,
    AppDatabase db,
  ) async {
    final isEncrypted = message.meta['e2ee_is_encrypted'] == true;
    if (!isEncrypted) return message;

    // Get mlsGroupId from room
    final room = await db.getChatRoomById(message.chatRoomId);
    final mlsGroupId = room?.mlsGroupId;
    if (mlsGroupId == null) {
      Logger.root.fine(
        'No mlsGroupId for room ${message.chatRoomId}, skipping decrypt',
      );
      return null;
    }

    // Check if message already has content in DB - use it directly
    final existing = await db.getMessageById(message.id);
    if (existing != null &&
        existing.content != null &&
        existing.content!.isNotEmpty) {
      return message.copyWith(content: existing.content);
    }

    // Check if it's our own message by device ID
    final headerStr = message.meta['e2ee_header']?.toString();
    if (headerStr != null && headerStr.isNotEmpty) {
      try {
        final headerBytes = base64Decode(headerStr);
        final headerJson = utf8.decode(headerBytes);
        final header = jsonDecode(headerJson) as Map<String, dynamic>;
        final senderDeviceId = header['deviceId']?.toString();

        if (senderDeviceId != null) {
          final currentDeviceId = await ref
              .read(mlsClientProvider)
              .getDeviceId();
          if (currentDeviceId != null && senderDeviceId == currentDeviceId) {
            // Our own message - check meta for existing decrypted content
            final decryptedContent = message.meta['e2ee_decrypted_content']
                ?.toString();
            if (decryptedContent != null && decryptedContent.isNotEmpty) {
              return message.copyWith(content: decryptedContent);
            }
            // No plaintext available - skip this message
            Logger.root.fine(
              'Skipping sync for own message ${message.id} - no plaintext',
            );
            return null;
          }
        }
      } catch (e) {
        Logger.root.fine('Failed to parse encryption header in sync: $e');
      }
    }

    // Try to decrypt
    try {
      final mlsClient = ref.read(mlsClientProvider);
      final result = await mlsClient.decryptMessage(
        messageId: message.id,
        mlsGroupId: mlsGroupId,
        ciphertext: message.meta['e2ee_ciphertext']?.toString() ?? '',
        encryptionHeader: headerStr,
        encryptionScheme: message.meta['e2ee_scheme']?.toString(),
      );
      if (result != null) {
        final content = result['content']?.toString();
        if (content != null && content.isNotEmpty) {
          return message.copyWith(content: content);
        }
      }
    } catch (e) {
      Logger.root.fine('Failed to decrypt sync message ${message.id}: $e');
    }

    return null;
  }

  /// Perform global sync to fetch messages from all chat rooms
  Future<void> syncAllMessages({bool force = false}) async {
    if (_ongoingSync != null) {
      Logger.root.info(
        'Global sync already in progress, joining existing task',
      );
      return _ongoingSync!;
    }

    final now = DateTime.now();
    if (!force &&
        _lastSyncStartedAt != null &&
        now.difference(_lastSyncStartedAt!) < _minSyncInterval) {
      Logger.root.info(
        'Skipping global sync due to cooldown (${now.difference(_lastSyncStartedAt!).inMilliseconds}ms < ${_minSyncInterval.inMilliseconds}ms)',
      );
      return;
    }
    _lastSyncStartedAt = now;

    final task = _syncAllMessagesImpl();
    _ongoingSync = task;
    try {
      await task;
    } finally {
      _ongoingSync = null;
    }
  }

  Future<void> _syncAllMessagesImpl() async {
    Logger.root.info('Starting global chat sync...');
    ref.read(chatSyncHintProvider.notifier).set('Syncing chat history...');

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
      if (savedCursor <= 0 && dbLatestCursor <= 0) {
        Logger.root.info(
          'Skipping global sync: no saved sync cursor and no local latest message timestamp.',
        );
        return;
      }
      final currentSyncTimestamp = (savedCursor > 0 && dbLatestCursor > 0)
          ? (savedCursor < dbLatestCursor ? savedCursor : dbLatestCursor)
          : (savedCursor > 0 ? savedCursor : dbLatestCursor);

      Logger.root.info(
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
        var pagesProcessed = 0;

        while (true) {
          pagesProcessed += 1;
          if (pagesProcessed > _maxSyncPagesPerRound) {
            Logger.root.info(
              'Stopping sync round ${eagerRound + 1}: reached page limit $_maxSyncPagesPerRound',
            );
            break;
          }

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
          final nextPagingCursor = currentTimestamp.millisecondsSinceEpoch;
          final hasCursorProgress = nextPagingCursor > pagingCursor;

          Logger.root.info(
            'Global sync round ${eagerRound + 1} received ${messages.length} valid messages (${rawMessages.length} raw, skipped $skippedCount), timestamp: $currentTimestamp (total: $totalMessages)',
          );
          ref
              .read(chatSyncHintProvider.notifier)
              .set(
                'Syncing history: ${roundSynced + messages.length} in round ${eagerRound + 1}',
              );

          // Save normal messages in one write transaction to avoid UI jank.
          final normalMessages = <LocalChatMessage>[];
          final updateMessages = <SnChatMessage>[];
          final deleteMessages = <SnChatMessage>[];
          final reactionMessages = <SnChatMessage>[];
          for (final msg in messages) {
            if (msg.type == 'messages.update' ||
                msg.type == 'messages.update.links') {
              updateMessages.add(msg);
              continue;
            }
            if (msg.type == 'messages.delete') {
              deleteMessages.add(msg);
              continue;
            }
            if (msg.type == 'messages.reaction.added' ||
                msg.type == 'messages.reaction.removed') {
              reactionMessages.add(msg);
              continue;
            }

            // Decrypt E2EE messages if needed
            final decryptedMsg = await _decryptSyncMessage(msg, db);
            if (decryptedMsg == null) {
              // Skipped - own message without plaintext or decryption failed
              continue;
            }

            normalMessages.add(
              LocalChatMessage.fromRemoteMessage(
                decryptedMsg,
                MessageStatus.sent,
              ),
            );
            updatedRoomIds.add(msg.chatRoomId);
            roundSynced += 1;
            final createdAtMs = msg.createdAt.millisecondsSinceEpoch;
            if (createdAtMs > roundMaxSeenTimestamp) {
              roundMaxSeenTimestamp = createdAtMs;
            }
          }

          if (normalMessages.isNotEmpty) {
            try {
              await db.saveMessagesWithSenders(normalMessages);
            } catch (e) {
              Logger.root.info('Error bulk-saving sync messages: $e');
            }
          }

          for (final msg in updateMessages) {
            try {
              await db.saveMessageWithSender(
                LocalChatMessage.fromRemoteMessage(msg, MessageStatus.sent),
              );
              await _applyMessageUpdateToTarget(db, msg);
              updatedRoomIds.add(msg.chatRoomId);
              roundSynced += 1;
              final createdAtMs = msg.createdAt.millisecondsSinceEpoch;
              if (createdAtMs > roundMaxSeenTimestamp) {
                roundMaxSeenTimestamp = createdAtMs;
              }
            } catch (e) {
              Logger.root.info('Error applying message update from sync: $e');
            }
          }

          for (final msg in deleteMessages) {
            try {
              await db.saveMessageWithSender(
                LocalChatMessage.fromRemoteMessage(msg, MessageStatus.sent),
              );
              final targetId = msg.meta['message_id']?.toString() ?? msg.id;
              await _markMessageAsDeleted(db, targetId, msg.chatRoomId);
              updatedRoomIds.add(msg.chatRoomId);
              roundSynced += 1;
              final createdAtMs = msg.createdAt.millisecondsSinceEpoch;
              if (createdAtMs > roundMaxSeenTimestamp) {
                roundMaxSeenTimestamp = createdAtMs;
              }
            } catch (e) {
              Logger.root.info('Error applying message delete from sync: $e');
            }
          }

          for (final msg in reactionMessages) {
            try {
              await _applyReactionUpdate(db, msg, currentUserId: currentUserId);
              await db.saveMessageWithSender(
                LocalChatMessage.fromRemoteMessage(msg, MessageStatus.sent),
              );
              updatedRoomIds.add(msg.chatRoomId);
              roundSynced += 1;
              final createdAtMs = msg.createdAt.millisecondsSinceEpoch;
              if (createdAtMs > roundMaxSeenTimestamp) {
                roundMaxSeenTimestamp = createdAtMs;
              }
            } catch (e) {
              Logger.root.info('Error saving reaction from global sync: $e');
            }
          }

          totalSynced += messages.length;

          if (rawMessages.isEmpty) {
            if (hasCursorProgress) {
              pagingCursor = nextPagingCursor;
            }
            break;
          }

          // Continue paging as long as server cursor advances and the page
          // contains data. Do not rely solely on total_count semantics.
          if (hasCursorProgress) {
            pagingCursor = nextPagingCursor;
            Logger.root.info(
              'Continuing sync round ${eagerRound + 1} with cursor: $pagingCursor (pageRaw=${rawMessages.length}, pageValid=${messages.length}, totalHint=$totalMessages)',
            );
            await Future<void>.delayed(Duration.zero);
            continue;
          }

          Logger.root.info(
            'Stopping sync round ${eagerRound + 1}: cursor did not advance (cursor=$pagingCursor, next=$nextPagingCursor, pageRaw=${rawMessages.length})',
          );
          break;
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

      Logger.root.info(
        'Global sync complete: $totalSynced messages saved (nextCursor=$nextCursor)',
      );
      ref
          .read(chatSyncHintProvider.notifier)
          .set('Sync complete: $totalSynced messages');
      if (updatedRoomIds.isNotEmpty) {
        eventBus.fire(ChatMessagesSyncedEvent(roomIds: updatedRoomIds));
      }
    } catch (e, stackTrace) {
      Logger.root.info('Error during global chat sync', e, stackTrace);
    } finally {
      Future.microtask(() {
        if (ref.mounted) {
          ref.read(chatSyncingProvider.notifier).set(false);
          ref.read(chatSyncHintProvider.notifier).clear();
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
      final localRooms = await db.getAllChatRooms();
      final localRealms = await db.getAllRealms();
      if (localRooms.isNotEmpty) {
        final roomsWithDetails = await Future.wait(
          localRooms.map((room) async {
            final encryptionModeRaw = await db.getSecret(
              _chatRoomEncryptionModeStoreKey(room.id),
            );
            final encryptionMode = int.tryParse(encryptionModeRaw ?? '') ?? 0;
            final members = await db.getMembersByRoomId(room.id);
            final realm = localRealms
                .where((e) => e.id == room.realmId)
                .firstOrNull;
            return room.copyWith(
              encryptionMode: encryptionMode,
              members: members,
              realm: realm,
            );
          }),
        );

        // Always fetch remote chat rooms to check for new ones
        try {
          final client = ref.watch(apiClientProvider);
          final resp = await client.get('/messager/chat');
          final rawRooms = (resp.data as List).whereType<Map>().toList();
          for (final roomJson in rawRooms) {
            await _persistRoomEncryptionModeFromJson(
              db,
              Map<String, dynamic>.from(roomJson),
            );
          }
          final rooms = rawRooms
              .map((e) => SnChatRoom.fromJson(Map<String, dynamic>.from(e)))
              .cast<SnChatRoom>()
              .toList();
          await db.saveChatRooms(rooms, override: true);
          return rooms;
        } catch (_) {
          // If remote fetch fails, return local rooms
          return roomsWithDetails;
        }
      }
    } catch (_) {}

    // Fallback to API
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/messager/chat');
    final rawRooms = (resp.data as List).whereType<Map>().toList();
    for (final roomJson in rawRooms) {
      await _persistRoomEncryptionModeFromJson(
        db,
        Map<String, dynamic>.from(roomJson),
      );
    }
    final rooms = rawRooms
        .map((e) => SnChatRoom.fromJson(Map<String, dynamic>.from(e)))
        .cast<SnChatRoom>()
        .toList();
    await db.saveChatRooms(rooms, override: true);
    return rooms;
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
      final localRoom = await db.getChatRoomById(identifier);

      if (localRoom != null) {
        final encryptionModeRaw = await db.getSecret(
          _chatRoomEncryptionModeStoreKey(localRoom.id),
        );
        final encryptionMode = int.tryParse(encryptionModeRaw ?? '') ?? 0;
        // Fetch members for this room
        final members = await db.getMembersByRoomId(localRoom.id);

        final room = localRoom.copyWith(
          encryptionMode: encryptionMode,
          members: members,
        );

        // Background sync
        Future(() async {
          try {
            final client = ref.read(apiClientProvider);
            final resp = await client.get('/messager/chat/$identifier');
            await _persistRoomEncryptionModeFromJson(
              db,
              Map<String, dynamic>.from(resp.data as Map),
            );
            final remoteRoom = SnChatRoom.fromJson(resp.data);
            // Update state with fresh data directly without saving to DB
            // DB will be updated by ChatRoomJoinedNotifier's full sync
            state = AsyncData(remoteRoom);
          } catch (_) {}
        }).ignore();

        return room;
      }
    } catch (_) {}

    // Fallback to API
    try {
      final client = ref.watch(apiClientProvider);
      final resp = await client.get('/messager/chat/$identifier');
      await _persistRoomEncryptionModeFromJson(
        db,
        Map<String, dynamic>.from(resp.data as Map),
      );
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
        final localMember = await db.getMemberByRoomAndAccount(
          identifier,
          userInfo.value!.id,
        );

        if (localMember != null) {
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
                  await db.getMemberByRoomAndAccount(
                    identifier,
                    userInfo.value!.id,
                  ),
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
