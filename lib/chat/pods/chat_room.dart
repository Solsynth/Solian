import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/talker.dart';

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
const String _chatE2eeBundleStoreKey = 'chat_e2ee_bundle_v1';
const String _chatE2eeBundleCheckedAtStoreKey =
    'chat_e2ee_bundle_checked_at_ms';
const String _chatE2eeRotationPrefix = 'chat_e2ee_rotate_required_';
const String _chatRoomEncryptionModePrefix = 'chat_room_encryption_mode_';
const Duration _chatE2eeBundleRecheckInterval = Duration(hours: 6);

String _chatRoomEncryptionModeStoreKey(String roomId) =>
    '$_chatRoomEncryptionModePrefix$roomId';
String _chatE2eeRotationStoreKey(String roomId) =>
    '$_chatE2eeRotationPrefix$roomId';

int _safeToInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? fallback;
  if (value is num) return value.toInt();
  return fallback;
}

Map<String, dynamic> _createE2eeKeyBundle({int oneTimePreKeys = 16}) {
  final random = Random.secure();
  String randomBase64(int length) =>
      base64Encode(List<int>.generate(length, (_) => random.nextInt(256)));

  final signedPreKeyId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final signedPreKeyExpiresAt = DateTime.now().toUtc().add(
    const Duration(days: 7),
  );
  final preKeys = List<Map<String, dynamic>>.generate(oneTimePreKeys, (idx) {
    final keyId = signedPreKeyId + idx + 1;
    return {
      'key_id': keyId,
      'public_key': randomBase64(32),
      'private_key': randomBase64(32),
    };
  });

  return {
    'algorithm': 'x25519',
    'created_at': DateTime.now().toUtc().toIso8601String(),
    'identity_key': randomBase64(32),
    'identity_private_key': randomBase64(32),
    'signed_pre_key_id': signedPreKeyId,
    'signed_pre_key': randomBase64(32),
    'signed_pre_key_private_key': randomBase64(32),
    'signed_pre_key_signature': randomBase64(64),
    'signed_pre_key_expires_at': signedPreKeyExpiresAt.toIso8601String(),
    'one_time_pre_keys': preKeys,
    'meta': {'client': 'island', 'bundle_version': 1},
  };
}

Future<void> _persistRoomEncryptionModeFromJson(
  AppDatabase db,
  Map<String, dynamic> roomJson,
) async {
  final roomId = roomJson['id']?.toString();
  if (roomId == null || roomId.isEmpty) return;
  final mode = _safeToInt(roomJson['encryption_mode']);
  await db.setSecret(_chatRoomEncryptionModeStoreKey(roomId), mode.toString());
}

Future<int> _getLatestMessageTimestamp(AppDatabase db) async {
  try {
    return await db.getLatestMessageTimestamp();
  } catch (e) {
    talker.log('Error getting latest message timestamp: $e');
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
      meta['e2ee_message_type'] = data['encryption_message_type'];
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
      talker.log(
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
      talker.log(
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
          if (message.type == 'system.e2ee.rotate_required') {
            await _markRoomE2eeRotationRequired(db, message);
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
      final msg = await db.getMessageById(messageId);
      if (msg != null && msg.roomId == roomId) {
        return db.companionToMessage(msg);
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

  Future<void> _markRoomE2eeRotationRequired(
    AppDatabase db,
    SnChatMessage message,
  ) async {
    final roomId = message.meta['room_id']?.toString() ?? message.chatRoomId;
    final payload = jsonEncode({
      'requiredAt': DateTime.now().toUtc().toIso8601String(),
      'rotationHintEpoch': _safeToInt(message.meta['rotation_hint_epoch']),
      'changedMemberId': message.meta['changed_member_id']?.toString(),
      'reason': message.meta['reason']?.toString(),
    });
    await db.setSecret(_chatE2eeRotationStoreKey(roomId), payload);
  }

  Future<void> _ensureE2eeBundle(Dio client, AppDatabase db) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final localBundleRaw = await db.getSecret(_chatE2eeBundleStoreKey);
    final lastCheckRaw = await db.getSecret(_chatE2eeBundleCheckedAtStoreKey);
    final lastCheckMs = int.tryParse(lastCheckRaw ?? '') ?? 0;
    final hasLocalBundle = localBundleRaw != null && localBundleRaw.isNotEmpty;
    final shouldRecheck =
        !hasLocalBundle ||
        nowMs - lastCheckMs > _chatE2eeBundleRecheckInterval.inMilliseconds;

    if (!shouldRecheck) return;

    var hasRemoteBundle = false;
    try {
      await client.get('/pass/e2ee/keys/me');
      hasRemoteBundle = true;
    } catch (err) {
      if (err is DioException && err.response?.statusCode == 404) {
        hasRemoteBundle = false;
      } else {
        rethrow;
      }
    }

    if (hasLocalBundle && hasRemoteBundle) {
      await db.setSecret(_chatE2eeBundleCheckedAtStoreKey, nowMs.toString());
      return;
    }

    final bundle = hasLocalBundle
        ? (jsonDecode(localBundleRaw) as Map).cast<String, dynamic>()
        : _createE2eeKeyBundle();
    await _uploadE2eeBundle(client, bundle);
    await db.setSecret(_chatE2eeBundleStoreKey, jsonEncode(bundle));
    await db.setSecret(_chatE2eeBundleCheckedAtStoreKey, nowMs.toString());
  }

  Future<void> _uploadE2eeBundle(
    Dio client,
    Map<String, dynamic> localBundle,
  ) async {
    T? read<T>(List<String> keys) {
      for (final key in keys) {
        final value = localBundle[key];
        if (value is T) return value;
      }
      return null;
    }

    final publicOneTimePreKeys =
        ((localBundle['one_time_pre_keys'] as List?) ??
                (localBundle['oneTimePreKeys'] as List?) ??
                const [])
            .whereType<Map>()
            .map(
              (entry) => {
                'key_id': _safeToInt(entry['key_id'] ?? entry['keyId']),
                'public_key': entry['public_key'] ?? entry['publicKey'],
              },
            )
            .toList();

    await client.post(
      '/pass/e2ee/keys/upload',
      data: {
        'algorithm': localBundle['algorithm'] ?? 'x25519',
        'identity_key': read<String>(['identity_key', 'identityKey']),
        'signed_pre_key_id': _safeToInt(
          read<dynamic>(['signed_pre_key_id', 'signedPreKeyId']),
        ),
        'signed_pre_key': read<String>(['signed_pre_key', 'signedPreKey']),
        'signed_pre_key_signature': read<String>([
          'signed_pre_key_signature',
          'signedPreKeySignature',
        ]),
        'signed_pre_key_expires_at': read<String>([
          'signed_pre_key_expires_at',
          'signedPreKeyExpiresAt',
        ]),
        'one_time_pre_keys': publicOneTimePreKeys,
        'meta': {'client': 'island', 'bundle_version': 1},
      },
    );
  }

  /// Perform global sync to fetch messages from all chat rooms
  Future<void> syncAllMessages({bool force = false}) async {
    if (_ongoingSync != null) {
      talker.log('Global sync already in progress, joining existing task');
      return _ongoingSync!;
    }

    final now = DateTime.now();
    if (!force &&
        _lastSyncStartedAt != null &&
        now.difference(_lastSyncStartedAt!) < _minSyncInterval) {
      talker.log(
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
    talker.log('Starting global chat sync...');
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
      try {
        await _ensureE2eeBundle(client, db);
      } catch (err, stackTrace) {
        talker.log(
          'E2EE bootstrap failed, continue with plaintext-compatible sync',
          exception: err,
          stackTrace: stackTrace,
        );
      }

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
        var pagesProcessed = 0;

        while (true) {
          pagesProcessed += 1;
          if (pagesProcessed > _maxSyncPagesPerRound) {
            talker.log(
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

          talker.log(
            'Global sync round ${eagerRound + 1} received ${messages.length} valid messages (${rawMessages.length} raw, skipped $skippedCount), timestamp: $currentTimestamp (total: $totalMessages)',
          );
          ref
              .read(chatSyncHintProvider.notifier)
              .set(
                'Syncing history: ${roundSynced + messages.length} in round ${eagerRound + 1}',
              );

          // Save normal messages in one write transaction to avoid UI jank.
          final normalMessages = <LocalChatMessage>[];
          final reactionMessages = <SnChatMessage>[];
          for (final msg in messages) {
            if (msg.type == 'messages.reaction.added' ||
                msg.type == 'messages.reaction.removed') {
              reactionMessages.add(msg);
              continue;
            }
            normalMessages.add(
              LocalChatMessage.fromRemoteMessage(msg, MessageStatus.sent),
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
              talker.log('Error bulk-saving sync messages: $e');
            }
          }

          for (final msg in reactionMessages) {
            try {
              final targetId = msg.meta['message_id']?.toString();
              final existed = targetId == null || targetId.isEmpty
                  ? null
                  : await db.getMessageById(targetId);
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
            } catch (e) {
              talker.log('Error saving reaction from global sync: $e');
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
            talker.log(
              'Continuing sync round ${eagerRound + 1} with cursor: $pagingCursor (pageRaw=${rawMessages.length}, pageValid=${messages.length}, totalHint=$totalMessages)',
            );
            await Future<void>.delayed(Duration.zero);
            continue;
          }

          talker.log(
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

      talker.log(
        'Global sync complete: $totalSynced messages saved (nextCursor=$nextCursor)',
      );
      ref
          .read(chatSyncHintProvider.notifier)
          .set('Sync complete: $totalSynced messages');
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
      final localRoomsData = await db.getAllChatRooms();
      final localRealmsData = await db.getAllRealms();
      if (localRoomsData.isNotEmpty) {
        final localRooms = await Future.wait(
          localRoomsData.map((row) async {
            final encryptionModeRaw = await db.getSecret(
              _chatRoomEncryptionModeStoreKey(row.id),
            );
            final encryptionMode = int.tryParse(encryptionModeRaw ?? '') ?? 0;
            final membersRows = await db.getMembersByRoomId(row.id);
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
              encryptionMode: encryptionMode,
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
          return localRooms;
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
}

@riverpod
class ChatRoomNotifier extends _$ChatRoomNotifier {
  @override
  Future<SnChatRoom?> build(String? identifier) async {
    if (identifier == null) return null;
    final db = ref.watch(databaseProvider);

    try {
      // Try to get from local database first
      final localRoomData = await db.getChatRoomById(identifier);

      if (localRoomData != null) {
        final encryptionModeRaw = await db.getSecret(
          _chatRoomEncryptionModeStoreKey(localRoomData.id),
        );
        final encryptionMode = int.tryParse(encryptionModeRaw ?? '') ?? 0;
        // Fetch members for this room
        final membersRows = await db.getMembersByRoomId(localRoomData.id);
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
          encryptionMode: encryptionMode,
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

        return localRoom;
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
        final localMemberData = await db.getMemberByRoomAndAccount(
          identifier,
          userInfo.value!.id,
        );

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
    final localMemberData = await db.getMemberByRoomAndAccount(
      identifier,
      accountId,
    );

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
