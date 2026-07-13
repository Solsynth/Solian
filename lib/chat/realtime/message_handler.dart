import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/data/message_cache.dart';
import 'package:island/chat/data/message_repository.dart';
import 'package:island/chat/e2ee_message_service.dart';
import 'package:island/chat/sync/message_sync_service.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:island/data/message.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:uuid/uuid.dart';

/// Handles real-time message events from WebSocket and Event Bus.
class RealtimeMessageHandler {
  final _logger = Logger('RealtimeMessageHandler');
  final Ref _ref;
  final String _roomId;
  final MessageRepository _repository;
  final MessageSyncService _syncService;
  final PendingMessageCache _pendingCache;
  final MessageCache _messageCache;
  final E2eeMessageService? _e2eeService;

  // Subscriptions
  StreamSubscription<WebSocketPacket>? _wsSubscription;
  StreamSubscription<ChatMessageNewEvent>? _newMessageSub;
  StreamSubscription<ChatMessageUpdateEvent>? _updateMessageSub;
  StreamSubscription<ChatMessageDeleteEvent>? _deleteMessageSub;

  // Callbacks for UI updates
  final void Function(LocalChatMessage message, int? roomSequence)?
  onNewMessage;
  final void Function(LocalChatMessage message, int? roomSequence)?
  onMessageUpdate;
  final void Function(LocalChatMessage message, int? roomSequence)?
  onMessageDelete;
  final void Function()? onReconnectionNeeded;

  bool _isJumping = false;
  bool _hasPendingRefresh = false;

  RealtimeMessageHandler(
    this._ref,
    this._roomId,
    this._repository,
    this._syncService,
    this._pendingCache,
    this._messageCache, {
    E2eeMessageService? e2eeService,
    this.onNewMessage,
    this.onMessageUpdate,
    this.onMessageDelete,
    this.onReconnectionNeeded,
  }) : _e2eeService = e2eeService;

  /// Starts listening to real-time events.
  void startListening() {
    _logger.info('Starting real-time message listener for room $_roomId');

    // Direct WebSocket listener
    final ws = _ref.read(websocketProvider);
    _wsSubscription = ws.dataStream.listen(_handleWebSocketPacket);

    // Event bus listeners
    _newMessageSub = eventBus.on<ChatMessageNewEvent>().listen((event) {
      if (event.message.chatRoomId != _roomId) return;
      _handleNewMessage(event.message);
    });

    _updateMessageSub = eventBus.on<ChatMessageUpdateEvent>().listen((event) {
      if (event.message.chatRoomId != _roomId) return;
      _handleUpdateEvent(event);
    });

    _deleteMessageSub = eventBus.on<ChatMessageDeleteEvent>().listen((event) {
      if (event.roomId != _roomId) return;
      _handleDeleteEvent(event);
    });
  }

  /// Processes a new message manually.
  Future<void> processNewMessage(SnChatMessage message) =>
      _handleNewMessage(message);

  /// Processes a message update manually.
  Future<void> processMessageUpdate(SnChatMessage message) =>
      _handleUpdateMessage(message);

  /// Processes a message deletion manually.
  Future<void> processMessageDeletion(String messageId) =>
      _handleDeleteMessage(messageId);

  Future<void> processMessageDeleteEvent(SnChatMessage message) =>
      _handleDeleteMessageEvent(message);

  /// Processes reaction added event manually.
  Future<void> processReactionAdded(SnChatMessage message) =>
      _handleReactionEvent(message);

  /// Processes reaction removed event manually.
  Future<void> processReactionRemoved(SnChatMessage message) =>
      _handleReactionEvent(message);

  /// Stops listening to real-time events.
  void stopListening() {
    _wsSubscription?.cancel();
    _newMessageSub?.cancel();
    _updateMessageSub?.cancel();
    _deleteMessageSub?.cancel();
  }

  /// Temporarily pauses real-time updates (e.g., during jump).
  void pause() {
    _isJumping = true;
    _logger.info('Paused real-time updates for jump');
  }

  /// Resumes real-time updates.
  void resume() {
    _isJumping = false;
    _logger.info('Resumed real-time updates');

    if (_hasPendingRefresh) {
      _hasPendingRefresh = false;
      onReconnectionNeeded?.call();
    }
  }

  // ── Event Handlers ────────────────────────────────────────────────────────

  void _handleWebSocketPacket(WebSocketPacket packet) {
    switch (packet.type) {
      case 'messages.new':
        // The websocket only emits generic message packets here. Message
        // mutations such as update/delete/reaction are encoded in the parsed
        // SnChatMessage.type, not in WebSocketPacket.type.
        final message = _parseMessage(packet.data);
        final roomSequence = _extractRoomSequence(packet.data);
        if (message == null || message.chatRoomId != _roomId) break;

        switch (message.type) {
          case 'messages.update':
          case 'messages.sync.finalize':
          case 'messages.sync.links':
            _handleUpdateMessage(message, roomSequence: roomSequence);
            break;
          case 'messages.delete':
            _handleDeleteMessageEvent(message, roomSequence: roomSequence);
            break;
          case 'messages.reaction.added':
          case 'messages.reaction.removed':
            _handleReactionEvent(message, roomSequence: roomSequence);
            break;
          case 'messages.pinned':
          case 'messages.unpinned':
            _handleNewMessage(message, roomSequence: roomSequence);
            break;
          default:
            _handleNewMessage(message, roomSequence: roomSequence);
        }
        break;

      // ── Placeholder message packets ──
      case 'messages.placeholder.update':
        _handlePlaceholderUpdate(packet.data);
        break;
      case 'messages.placeholder.finalize':
        _handlePlaceholderFinalize(packet.data);
        break;
      case 'messages.placeholder.expired':
        _handlePlaceholderExpired(packet.data);
        break;

      case 'system.e2ee.enabled':
        _handleE2eeEnabled();
        break;
    }
  }

  Future<void> _handleNewMessage(
    SnChatMessage remoteMessage, {
    int? roomSequence,
  }) async {
    if (_isJumping) {
      _hasPendingRefresh = true;
      _logger.info('Queued new message during jump: ${remoteMessage.id}');
      return;
    }

    _logger.info('Processing new message: ${remoteMessage.id}');

    // Check for duplicate
    final existing = await _repository.getLocalMessage(remoteMessage.id);
    if (existing != null &&
        existing.content?.isNotEmpty == true &&
        !_needsAttachmentRefresh(existing, remoteMessage)) {
      _logger.fine('Message ${remoteMessage.id} already exists, skipping');
      _pendingCache.removeByClientId(remoteMessage.clientMessageId);
      return;
    }

    // Process through sync service
    final processed = await _syncService.processRemoteMessages([remoteMessage]);

    if (processed.isNotEmpty) {
      onNewMessage?.call(processed.first, roomSequence);
    }
  }

  Future<void> _handleUpdateMessage(
    SnChatMessage remoteMessage, {
    int? roomSequence,
  }) async {
    if (_isJumping) {
      _hasPendingRefresh = true;
      return;
    }

    _logger.info('Processing message update: ${remoteMessage.id}');

    final targetId = remoteMessage.meta['message_id'] ?? remoteMessage.id;
    final existing = await _repository.getLocalMessage(targetId);

    if (existing == null) {
      _logger.warning('Cannot update non-existent message: $targetId');
      return;
    }

    final decrypted = (_e2eeService?.isE2eeRoom == true)
        ? remoteMessage
        : remoteMessage;

    // Build updated message
    final updateEvent = LocalChatMessage.fromRemoteMessage(
      decrypted,
      MessageStatus.sent,
    );

    final isSilentSync =
        updateEvent.type == 'messages.sync.finalize' ||
        updateEvent.type == 'messages.sync.links';

    if (!isSilentSync) {
      await _repository.saveMessage(updateEvent);
      onNewMessage?.call(updateEvent, roomSequence);
    }

    final updated = _buildUpdatedMessage(existing, updateEvent);

    await _repository.saveMessage(updated);
    onMessageUpdate?.call(updated, roomSequence);
  }

  Future<void> _handleUpdateEvent(ChatMessageUpdateEvent event) async {
    final type = event.message.type;

    // Handle reaction events
    if (type == 'messages.reaction.added' ||
        type == 'messages.reaction.removed') {
      if (event.appliedInBackground) {
        await _handleReactionAppliedInBackground(event.message);
        return;
      }
      await _handleReactionEvent(event.message);
      return;
    }

    // Handle edit/delete events
    if (type == 'messages.update' ||
        type == 'messages.sync.finalize' ||
        type == 'messages.sync.links' ||
        type == 'messages.delete') {
      if (type == 'messages.delete') {
        await _handleDeleteMessageEvent(event.message);
      } else {
        await _handleUpdateMessage(event.message);
      }
    }

    // Pin/unpin events are handled as new messages (system events)
    if (type == 'messages.pinned' || type == 'messages.unpinned') {
      await _handleNewMessage(event.message);
    }
  }

  Future<void> _handleReactionAppliedInBackground(
    SnChatMessage remoteMessage,
  ) async {
    final targetId = remoteMessage.meta['message_id']?.toString();
    if (targetId == null || targetId.isEmpty) return;

    _messageCache.remove(targetId);
    final updated = await _repository.getLocalMessage(targetId);
    if (updated != null) {
      onMessageUpdate?.call(updated, null);
    }
  }

  Future<void> _handleReactionEvent(
    SnChatMessage remoteMessage, {
    int? roomSequence,
  }) async {
    final targetId = remoteMessage.meta['message_id']?.toString();
    if (targetId == null) return;

    final existing = await _repository.getLocalMessage(targetId);
    if (existing == null) return;

    final countSnapshot = _extractReactionsCount(remoteMessage);
    final madeSnapshot = _extractReactionsMade(remoteMessage);
    final reactionsCount =
        countSnapshot ?? _extractExistingReactionsCount(existing);
    final reactionsMade =
        madeSnapshot ?? _extractExistingReactionsMade(existing);
    final symbol = _extractReactionSymbol(remoteMessage);
    final currentUserId = _ref.read(userInfoProvider).value?.id;
    final reactionSenderAccountId = remoteMessage.sender.accountId;
    final isCurrentUserReaction =
        currentUserId != null && reactionSenderAccountId == currentUserId;

    if (countSnapshot == null) {
      if (symbol == null || symbol.isEmpty) return;
      final alreadyAppliedLocally =
          isCurrentUserReaction &&
          ((remoteMessage.type == 'messages.reaction.added' &&
                  reactionsMade[symbol] == true) ||
              (remoteMessage.type == 'messages.reaction.removed' &&
                  reactionsMade[symbol] != true));
      if (!alreadyAppliedLocally) {
        final delta = remoteMessage.type == 'messages.reaction.removed'
            ? -1
            : 1;
        final nextCount = (reactionsCount[symbol] ?? 0) + delta;
        if (nextCount > 0) {
          reactionsCount[symbol] = nextCount;
        } else {
          reactionsCount.remove(symbol);
        }
      }
    }

    if (madeSnapshot == null && symbol != null && symbol.isNotEmpty) {
      if (remoteMessage.type == 'messages.reaction.added' &&
          isCurrentUserReaction) {
        reactionsMade[symbol] = true;
      } else if (remoteMessage.type == 'messages.reaction.removed' &&
          isCurrentUserReaction) {
        reactionsMade.remove(symbol);
      }
    }

    final updatedData = Map<String, dynamic>.from(existing.data);
    updatedData['reactions_count'] = reactionsCount;
    updatedData['reactions_made'] = reactionsMade;

    final updated = _copyWithMergedData(existing, updatedData);
    await _repository.saveMessage(updated);
    _messageCache.put(updated);
    onMessageUpdate?.call(updated, roomSequence);
  }

  Future<void> _handleDeleteEvent(ChatMessageDeleteEvent event) async {
    await _handleDeleteMessage(event.messageId);
  }

  Future<void> _handleDeleteMessageEvent(
    SnChatMessage remoteMessage, {
    int? roomSequence,
  }) async {
    if (_isJumping) {
      _hasPendingRefresh = true;
      return;
    }

    final deleteEvent = LocalChatMessage.fromRemoteMessage(
      remoteMessage,
      MessageStatus.sent,
    );
    await _repository.saveMessage(deleteEvent);
    onNewMessage?.call(deleteEvent, roomSequence);

    final targetId =
        remoteMessage.meta['message_id']?.toString() ?? remoteMessage.id;
    await _handleDeleteMessage(targetId);
  }

  Future<void> _handleDeleteMessage(String messageId) async {
    if (_isJumping) {
      _hasPendingRefresh = true;
      return;
    }

    _logger.info('Processing message deletion: $messageId');

    _pendingCache.remove(messageId);

    final message = await _repository.getLocalMessage(messageId);
    if (message == null) {
      return;
    }

    // Mark as deleted
    final remote = message.toRemoteMessage();
    final deletedRemote = remote.copyWith(
      content: 'This message was deleted',
      deletedAt: DateTime.now(),
      attachments: [],
      meta: <String, dynamic>{},
    );

    final deleted = LocalChatMessage.fromRemoteMessage(
      deletedRemote,
      message.status,
    );

    await _repository.saveMessage(deleted);
    _messageCache.put(deleted);
    onMessageDelete?.call(deleted, null);
  }

  void _handleE2eeEnabled() {
    _logger.info('E2EE enabled for room $_roomId');
    // Trigger re-sync to ensure proper encryption state
    onReconnectionNeeded?.call();
  }

  // ── Placeholder Message Handling ──────────────────────────────────────────

  Future<void> _handlePlaceholderUpdate(Map<String, dynamic>? data) async {
    if (data == null) return;
    try {
      final message = SnChatMessage.fromJson(
        E2eeMessageService.sanitizeChatMessageJson(data),
      );
      if (message.chatRoomId != _roomId) return;

      _logger.info('Placeholder update: ${message.id}');
      final local = LocalChatMessage.fromRemoteMessage(
        message,
        MessageStatus.sent,
      );
      await _repository.saveMessage(local);
      _messageCache.put(local);
      onMessageUpdate?.call(local, null);
    } catch (e) {
      _logger.warning('Failed to handle placeholder update: $e');
    }
  }

  Future<void> _handlePlaceholderFinalize(Map<String, dynamic>? data) async {
    if (data == null) return;
    try {
      final message = SnChatMessage.fromJson(
        E2eeMessageService.sanitizeChatMessageJson(data),
      );
      if (message.chatRoomId != _roomId) return;

      _logger.info('Placeholder finalized: ${message.id}');
      final local = LocalChatMessage.fromRemoteMessage(
        message,
        MessageStatus.sent,
      );
      await _repository.saveMessage(local);
      _messageCache.put(local);
      onMessageUpdate?.call(local, null);
    } catch (e) {
      _logger.warning('Failed to handle placeholder finalize: $e');
    }
  }

  Future<void> _handlePlaceholderExpired(Map<String, dynamic>? data) async {
    if (data == null) return;
    final messageId = data['message_id']?.toString();
    if (messageId == null) return;

    _logger.info('Placeholder expired: $messageId');
    _messageCache.remove(messageId);

    final message = await _repository.getLocalMessage(messageId);
    if (message != null) {
      onMessageDelete?.call(message, null);
    }
  }

  // ── System Message Handling ───────────────────────────────────────────────

  /// Inserts a system message into the chat.
  Future<void> insertSystemMessage({
    required String type,
    required String content,
    Map<String, dynamic>? meta,
  }) async {
    final now = DateTime.now();
    final messageId = const Uuid().v4();

    final systemMessage = LocalChatMessage(
      id: messageId,
      roomId: _roomId,
      senderId: 'system',
      sender: null,
      data: {
        'id': messageId,
        'chat_room_id': _roomId,
        'sender_id': 'system',
        'type': type,
        'content': content,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'deleted_at': null,
        'client_message_id': null,
        'nonce': null,
        'meta': meta ?? <String, dynamic>{},
        'members_mentioned': <String>[],
        'attachments': <Map<String, dynamic>>[],
        'reactions': <Map<String, dynamic>>[],
        'sender': _buildSystemSender(now),
        'replied_message_id': null,
        'forwarded_message_id': null,
      },
      createdAt: now,
      clientMessageId: null,
      status: MessageStatus.sent,
      type: type,
      meta: meta ?? {},
      membersMentioned: [],
      attachments: [],
      reactions: [],
    );

    await _repository.saveMessage(systemMessage);
    onNewMessage?.call(systemMessage, null);
  }

  /// Inserts the E2EE history unavailable message.
  Future<void> insertE2eeHistoryUnavailableMessage() async {
    await insertSystemMessage(
      type: 'system.e2ee.history_unavailable',
      content:
          'Message history is no longer available due to an encryption key change',
    );
  }

  // ── Private Helpers ──────────────────────────────────────────────────────

  SnChatMessage? _parseMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMessage.fromJson(
        E2eeMessageService.sanitizeChatMessageJson(data),
      );
    } catch (e) {
      _logger.warning('Failed to parse message: $e');
      return null;
    }
  }

  int? _extractRoomSequence(dynamic data) {
    if (data is! Map) return null;
    final raw = data['room_sequence'] ?? data['roomSequence'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  LocalChatMessage _buildUpdatedMessage(
    LocalChatMessage existing,
    LocalChatMessage updateEvent,
  ) {
    final updateRemote = updateEvent.toRemoteMessage();
    final isLinkPreviewUpdate = updateEvent.type == 'messages.sync.links';
    final isPlaceholderFinalize = updateEvent.type == 'messages.sync.finalize';
    final mergedMeta =
        isPlaceholderFinalize
              ? Map<String, dynamic>.of(updateRemote.meta)
              : Map<String, dynamic>.of(existing.toRemoteMessage().meta)
          ..addAll(updateRemote.meta);
    mergedMeta
      ..remove('message_id')
      ..remove('placeholder_kind')
      ..remove('placeholder_content')
      ..remove('placeholder_progress')
      ..remove('placeholder_expires_at');

    return LocalChatMessage.fromRemoteMessage(
      existing.toRemoteMessage().copyWith(
        content: isLinkPreviewUpdate ? existing.content : updateRemote.content,
        attachments: updateRemote.attachments,
        // Sync events may omit message relationships. Keep the target's
        // existing values instead of treating an omitted field as a removal.
        membersMentioned: updateRemote.membersMentioned.isEmpty
            ? existing.membersMentioned
            : updateRemote.membersMentioned,
        repliedMessageId:
            updateRemote.repliedMessageId ?? existing.repliedMessageId,
        forwardedMessageId:
            updateRemote.forwardedMessageId ?? existing.forwardedMessageId,
        id: existing.id,
        createdAt: existing.createdAt,
        meta: mergedMeta,
        type: isPlaceholderFinalize ? 'text' : existing.type,
        // A finalize event can be either a placeholder completion or an edit.
        // Only the latter carries EditedAt; retaining the target timestamp for
        // placeholder completions avoids adding a false edited indicator.
        editedAt: isLinkPreviewUpdate
            ? existing.editedAt
            : updateEvent.editedAt ??
                  (isPlaceholderFinalize
                      ? existing.editedAt
                      : updateEvent.createdAt),
      ),
      existing.status,
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

  bool _needsAttachmentRefresh(
    LocalChatMessage existing,
    SnChatMessage remote,
  ) {
    return existing.attachments.isEmpty && remote.attachments.isNotEmpty;
  }

  Map<String, int>? _extractReactionsCount(SnChatMessage message) {
    if (message.reactionsCount.isNotEmpty) {
      return Map<String, int>.from(message.reactionsCount);
    }
    final raw = message.meta['reactions_count'];
    if (raw is! Map) return null;
    return raw.map((key, value) {
      final count = value is int ? value : int.tryParse(value.toString()) ?? 0;
      return MapEntry(key.toString(), count);
    });
  }

  Map<String, bool>? _extractReactionsMade(SnChatMessage message) {
    if (message.reactionsMade.isNotEmpty) {
      return Map<String, bool>.from(message.reactionsMade);
    }
    final raw = message.meta['reactions_made'];
    if (raw is! Map) return null;
    return raw.map((key, value) => MapEntry(key.toString(), value == true));
  }

  Map<String, int> _extractExistingReactionsCount(LocalChatMessage message) {
    final raw = message.data['reactions_count'];
    if (raw is! Map) return {};
    return raw.map((key, value) {
      final count = value is int ? value : int.tryParse(value.toString()) ?? 0;
      return MapEntry(key.toString(), count);
    });
  }

  Map<String, bool> _extractExistingReactionsMade(LocalChatMessage message) {
    final raw = message.data['reactions_made'];
    if (raw is! Map) return {};
    return raw.map((key, value) => MapEntry(key.toString(), value == true));
  }

  String? _extractReactionSymbol(SnChatMessage message) {
    final direct = message.meta['symbol']?.toString();
    if (direct != null && direct.isNotEmpty) return direct;
    final reaction = message.meta['reaction'];
    if (reaction is Map) return reaction['symbol']?.toString();
    return null;
  }

  Map<String, dynamic> _buildSystemSender(DateTime now) => {
    'id': 'system',
    'chat_room_id': _roomId,
    'account_id': 'system',
    'created_at': now.toIso8601String(),
    'updated_at': now.toIso8601String(),
    'deleted_at': null,
    'nick': null,
    'notify': 0,
    'joined_at': now.toIso8601String(),
    'break_until': null,
    'timeout_until': null,
    'last_read_at': null,
    'status': null,
    'realm_nick': null,
    'realm_bio': null,
    'realm_experience': null,
    'realm_level': null,
    'realm_leveling_progress': null,
    'realm_label': null,
  };
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
