import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:island/chat/data/message_cache.dart';
import 'package:island/chat/data/message_repository.dart';
import 'package:island/chat/e2ee_message_service.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/drive_service.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:uuid/uuid.dart';

/// Result of sending a message.
class SendResult {
  final bool success;
  final LocalChatMessage? message;
  final LocalChatMessage? eventMessage;
  final String? error;

  const SendResult._(
    this.success, {
    this.message,
    this.eventMessage,
    this.error,
  });

  factory SendResult.success(
    LocalChatMessage message, {
    LocalChatMessage? eventMessage,
  }) => SendResult._(true, message: message, eventMessage: eventMessage);

  factory SendResult.failure(String error) => SendResult._(false, error: error);
}

/// Handles message sending, including uploads, encryption, and retries.
class MessageSender {
  final _logger = Logger('MessageSender');
  final String _roomId;
  final MessageRepository _repository;
  final PendingMessageCache _pendingCache;
  final E2eeMessageService? _e2eeService;
  final String? _fileEncryptKey;
  final Ref _ref;

  // Retry configuration
  MessageSender(
    this._ref,
    this._roomId,
    this._repository,
    this._pendingCache, {
    E2eeMessageService? e2eeService,
    String? fileEncryptKey,
  }) : _e2eeService = e2eeService,
       _fileEncryptKey = fileEncryptKey;

  /// Sends a text message with optional attachments.
  Future<SendResult> sendTextMessage({
    required String content,
    required List<UniversalFile> attachments,
    required SnChatMember sender,
    SnChatMessage? editingTo,
    SnChatMessage? replyingTo,
    SnChatMessage? forwardingTo,
    List<Map<String, dynamic>>? embeds,
    Function(LocalChatMessage message)? onPending,
    Function(String messageId, Map<int, double?>)? onProgress,
  }) async {
    final clientMessageId = const Uuid().v4();
    _logger.info('[send:$clientMessageId] Starting message send');

    if (_shouldUseAttachmentPlaceholder(
      attachments: attachments,
      editingTo: editingTo,
      replyingTo: replyingTo,
      forwardingTo: forwardingTo,
      embeds: embeds,
    )) {
      return _sendWithAttachmentPlaceholder(
        content: content,
        attachments: attachments,
        sender: sender,
        onPending: onPending,
        onProgress: onProgress,
      );
    }

    try {
      // Create pending message
      final pending = _createPendingMessage(
        clientMessageId: clientMessageId,
        content: content,
        sender: sender,
        attachments: attachments,
        replyingTo: replyingTo,
        forwardingTo: forwardingTo,
      );

      // Add to pending cache
      _pendingCache.add(pending);
      onPending?.call(pending);

      _logger.info(
        '[send:$clientMessageId] Uploading ${attachments.length} attachments',
      );

      // Upload attachments
      final cloudAttachments = await _uploadAttachments(
        attachments: attachments,
        pendingMessageId: pending.id,
        onProgress: onProgress,
      );

      _logger.info('[send:$clientMessageId] Building payload');

      // Build payload
      final (:payload, :plaintextEnvelope) = await _buildPayload(
        clientMessageId: clientMessageId,
        content: content,
        attachmentIds: cloudAttachments.map((a) => a.id).toList(),
        isEditing: editingTo != null,
        replyingTo: replyingTo,
        forwardingTo: forwardingTo,
        embeds: embeds,
      );

      _logger.info('[send:$clientMessageId] Sending to server');

      // Send to server
      final remoteMessage = await _sendToServer(
        payload: payload,
        editingTo: editingTo,
      );

      _logger.info(
        '[send:$clientMessageId] Message sent successfully: ${remoteMessage.id}',
      );

      // Preserve plaintext for E2EE
      final withPlaintext = _e2eeService?.isE2eeRoom == true
          ? E2eeMessageService.preserveSenderPlaintext(
              remoteMessage,
              plaintextEnvelope: plaintextEnvelope,
            )
          : remoteMessage;

      final sent = LocalChatMessage.fromRemoteMessage(
        editingTo != null
            ? _buildEditedTargetMessage(editingTo, withPlaintext)
            : withPlaintext,
        MessageStatus.sent,
      );
      final eventMessage = editingTo == null
          ? null
          : LocalChatMessage.fromRemoteMessage(
              withPlaintext,
              MessageStatus.sent,
            );

      // Remove pending and save sent message
      _pendingCache.remove(pending.id);
      await _repository.saveMessage(sent);
      if (eventMessage != null) {
        await _repository.saveMessage(eventMessage);
      }

      return SendResult.success(sent, eventMessage: eventMessage);
    } catch (e, stackTrace) {
      _logger.severe('[send:$clientMessageId] Send failed', e, stackTrace);

      // Mark pending as failed
      final pendingId = 'pending_$clientMessageId';
      _pendingCache.markFailed(pendingId);
      await _repository.updateStatus(pendingId, MessageStatus.failed);

      return SendResult.failure(e.toString());
    }
  }

  Future<SendResult> _sendWithAttachmentPlaceholder({
    required String content,
    required List<UniversalFile> attachments,
    required SnChatMember sender,
    Function(LocalChatMessage message)? onPending,
    Function(String messageId, Map<int, double?>)? onProgress,
  }) async {
    final placeholder = await createPlaceholder('uploading');
    if (placeholder == null) {
      _logger.warning(
        '[placeholder] Failed to create upload placeholder, falling back to normal send',
      );
      return _sendWithoutPlaceholder(
        content: content,
        attachments: attachments,
        sender: sender,
        onPending: onPending,
        onProgress: onProgress,
      );
    }

    final pending = LocalChatMessage.fromRemoteMessage(
      placeholder,
      MessageStatus.pending,
    )..localAttachments = attachments;

    _pendingCache.add(pending);
    await _repository.saveMessage(pending);
    onPending?.call(pending);

    try {
      final cloudAttachments = await _uploadAttachments(
        attachments: attachments,
        pendingMessageId: pending.id,
        onProgress: (messageId, progress) {
          final overallProgress = _calculateOverallProgress(
            attachments.length,
            progress,
          );
          updatePlaceholder(messageId, progress: overallProgress);
          onProgress?.call(messageId, progress);
        },
      );

      final finalized = await _finalizePlaceholderAndWait(
        pending.id,
        content: content,
        attachmentsId: cloudAttachments.map((file) => file.id).toList(),
      );

      final sent = LocalChatMessage.fromRemoteMessage(
        finalized,
        MessageStatus.sent,
      );

      _pendingCache.remove(pending.id);
      await _repository.saveMessage(sent);

      return SendResult.success(sent);
    } catch (e, stackTrace) {
      _logger.severe(
        '[placeholder:${pending.id}] Placeholder send failed',
        e,
        stackTrace,
      );
      _pendingCache.markFailed(pending.id);
      await _repository.updateStatus(pending.id, MessageStatus.failed);
      return SendResult.failure(e.toString());
    }
  }

  Future<SendResult> _sendWithoutPlaceholder({
    required String content,
    required List<UniversalFile> attachments,
    required SnChatMember sender,
    SnChatMessage? editingTo,
    SnChatMessage? replyingTo,
    SnChatMessage? forwardingTo,
    List<Map<String, dynamic>>? embeds,
    Function(LocalChatMessage message)? onPending,
    Function(String messageId, Map<int, double?>)? onProgress,
  }) async {
    final clientMessageId = const Uuid().v4();
    _logger.info('[send:$clientMessageId] Starting message send');

    try {
      final pending = _createPendingMessage(
        clientMessageId: clientMessageId,
        content: content,
        sender: sender,
        attachments: attachments,
        replyingTo: replyingTo,
        forwardingTo: forwardingTo,
      );

      _pendingCache.add(pending);
      onPending?.call(pending);

      _logger.info(
        '[send:$clientMessageId] Uploading ${attachments.length} attachments',
      );

      final cloudAttachments = await _uploadAttachments(
        attachments: attachments,
        pendingMessageId: pending.id,
        onProgress: onProgress,
      );

      _logger.info('[send:$clientMessageId] Building payload');

      final (:payload, :plaintextEnvelope) = await _buildPayload(
        clientMessageId: clientMessageId,
        content: content,
        attachmentIds: cloudAttachments.map((a) => a.id).toList(),
        isEditing: editingTo != null,
        replyingTo: replyingTo,
        forwardingTo: forwardingTo,
        embeds: embeds,
      );

      _logger.info('[send:$clientMessageId] Sending to server');

      final remoteMessage = await _sendToServer(
        payload: payload,
        editingTo: editingTo,
      );

      _logger.info(
        '[send:$clientMessageId] Message sent successfully: ${remoteMessage.id}',
      );

      final withPlaintext = _e2eeService?.isE2eeRoom == true
          ? E2eeMessageService.preserveSenderPlaintext(
              remoteMessage,
              plaintextEnvelope: plaintextEnvelope,
            )
          : remoteMessage;

      final sent = LocalChatMessage.fromRemoteMessage(
        editingTo != null
            ? _buildEditedTargetMessage(editingTo, withPlaintext)
            : withPlaintext,
        MessageStatus.sent,
      );
      final eventMessage = editingTo == null
          ? null
          : LocalChatMessage.fromRemoteMessage(
              withPlaintext,
              MessageStatus.sent,
            );

      _pendingCache.remove(pending.id);
      await _repository.saveMessage(sent);
      if (eventMessage != null) {
        await _repository.saveMessage(eventMessage);
      }

      return SendResult.success(sent, eventMessage: eventMessage);
    } catch (e, stackTrace) {
      _logger.severe('[send:$clientMessageId] Send failed', e, stackTrace);

      final pendingId = 'pending_$clientMessageId';
      _pendingCache.markFailed(pendingId);
      await _repository.updateStatus(pendingId, MessageStatus.failed);

      return SendResult.failure(e.toString());
    }
  }

  /// Sends a voice message.
  Future<SendResult> sendVoiceMessage({
    required String filePath,
    required SnChatMember sender,
    int? durationMs,
    SnChatMessage? replyingTo,
    SnChatMessage? forwardingTo,
  }) async {
    // Voice messages not supported in E2EE rooms yet
    if (_e2eeService?.isE2eeRoom == true) {
      return SendResult.failure(
        'Voice messages are not supported in encrypted rooms yet',
      );
    }

    final clientMessageId = const Uuid().v4();
    _logger.info('[voice:$clientMessageId] Sending voice message');

    try {
      // Create pending message
      final pending = _createVoicePendingMessage(
        clientMessageId: clientMessageId,
        filePath: filePath,
        sender: sender,
        durationMs: durationMs,
        replyingTo: replyingTo,
        forwardingTo: forwardingTo,
      );

      _pendingCache.add(pending);

      // Upload voice file
      final mimeType = lookupMimeType(filePath) ?? 'audio/m4a';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: p.basename(filePath),
          contentType: MediaType.parse(mimeType),
        ),
        'client_message_id': clientMessageId,
        if (replyingTo != null) 'repliedMessageId': replyingTo.id,
        if (forwardingTo != null) 'forwardedMessageId': forwardingTo.id,
        ...?durationMs == null ? null : {'durationMs': durationMs},
      });

      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/messager/chat/$_roomId/messages/voice',
        data: formData,
      );

      final remoteMessage = SnChatMessage.fromJson(response.data);
      final sent = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      // Prefetch voice media
      final voiceUrl = remoteMessage.meta['voice_url']?.toString();
      if (voiceUrl != null) {
        unawaited(_repository.prefetchVoiceMedia(voiceUrl));
      }

      _pendingCache.remove(pending.id);
      await _repository.saveMessage(sent);

      _logger.info('[voice:$clientMessageId] Voice message sent: ${sent.id}');
      return SendResult.success(sent);
    } catch (e, stackTrace) {
      _logger.severe(
        '[voice:$clientMessageId] Voice send failed',
        e,
        stackTrace,
      );

      final pendingId = 'pending_$clientMessageId';
      _pendingCache.markFailed(pendingId);
      await _repository.updateStatus(pendingId, MessageStatus.failed);

      return SendResult.failure(e.toString());
    }
  }

  /// Retries a failed message.
  Future<SendResult> retryMessage(
    String pendingMessageId, {
    required SnChatMember sender,
    Function(String messageId, Map<int, double?>)? onProgress,
  }) async {
    final pending = _pendingCache.get(pendingMessageId);
    if (pending == null) {
      return SendResult.failure('Pending message not found');
    }

    _logger.info('[retry:$pendingMessageId] Retrying message');

    // Reset status to pending
    pending.status = MessageStatus.pending;
    _pendingCache.add(pending);
    onProgress?.call(pendingMessageId, {});

    try {
      // Extract local attachments
      final attachments = pending.localAttachments ?? [];

      // Re-upload attachments
      final cloudAttachments = await _uploadAttachments(
        attachments: attachments,
        pendingMessageId: pendingMessageId,
        onProgress: onProgress,
      );

      // Build and send payload
      final remoteMessage = await _sendToServer(
        payload: {
          'content': pending.content,
          'attachments_id': cloudAttachments.map((a) => a.id).toList(),
          'client_message_id': pending.clientMessageId,
          'meta': pending.meta,
        },
      );

      final sent = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      _pendingCache.remove(pendingMessageId);
      await _repository.deleteMessage(pendingMessageId);
      await _repository.saveMessage(sent);

      _logger.info('[retry:$pendingMessageId] Retry successful: ${sent.id}');
      return SendResult.success(sent);
    } catch (e, stackTrace) {
      _logger.severe('[retry:$pendingMessageId] Retry failed', e, stackTrace);

      _pendingCache.markFailed(pendingMessageId);
      await _repository.updateStatus(pendingMessageId, MessageStatus.failed);

      return SendResult.failure(e.toString());
    }
  }

  /// Deletes a message.
  Future<bool> deleteMessage(String messageId, {Options? options}) async {
    // Check if it's a pending/failed message
    final pending = _pendingCache.get(messageId);
    if (pending != null) {
      _pendingCache.remove(messageId);
      await _repository.deleteMessage(messageId);
      return true;
    }

    try {
      await _repository.deleteRemoteMessage(messageId, options: options);
      await _repository.deleteMessage(messageId);
      return true;
    } catch (e) {
      _logger.warning('Failed to delete message $messageId: $e');
      return false;
    }
  }

  // ── Private Helpers ──────────────────────────────────────────────────────

  LocalChatMessage _createPendingMessage({
    required String clientMessageId,
    required String content,
    required SnChatMember sender,
    required List<UniversalFile> attachments,
    SnChatMessage? replyingTo,
    SnChatMessage? forwardingTo,
  }) {
    final mock = SnChatMessage(
      id: 'pending_$clientMessageId',
      chatRoomId: _roomId,
      senderId: sender.id,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      clientMessageId: clientMessageId,
      sender: sender,
      attachments: const [],
      repliedMessageId: replyingTo?.id,
      forwardedMessageId: forwardingTo?.id,
    );

    return LocalChatMessage.fromRemoteMessage(mock, MessageStatus.pending)
      ..localAttachments = attachments;
  }

  LocalChatMessage _createVoicePendingMessage({
    required String clientMessageId,
    required String filePath,
    required SnChatMember sender,
    int? durationMs,
    SnChatMessage? replyingTo,
    SnChatMessage? forwardingTo,
  }) {
    final mock = SnChatMessage(
      id: 'pending_$clientMessageId',
      chatRoomId: _roomId,
      senderId: sender.id,
      type: 'voice',
      content: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      clientMessageId: clientMessageId,
      sender: sender,
      repliedMessageId: replyingTo?.id,
      forwardedMessageId: forwardingTo?.id,
      meta: {
        'file_name': p.basename(filePath),
        ...?durationMs == null ? null : {'duration_ms': durationMs},
      },
    );

    return LocalChatMessage.fromRemoteMessage(mock, MessageStatus.pending);
  }

  Future<List<SnCloudFile>> _uploadAttachments({
    required List<UniversalFile> attachments,
    required String pendingMessageId,
    Function(String messageId, Map<int, double?>)? onProgress,
  }) async {
    final cloudFiles = <SnCloudFile>[];

    for (var i = 0; i < attachments.length; i++) {
      final attachment = attachments[i];

      // Skip already-uploaded files
      if (attachment.isOnCloud) {
        cloudFiles.add(attachment.data as SnCloudFile);
        continue;
      }

      final cloudFile = await _ref
          .read(driveFileUploaderProvider)
          .createCloudFile(
            fileData: attachment,
            encryptPassword: _fileEncryptKey,
            usage: 'chat_message',
            onProgress: (progress, _) {
              _pendingCache.updateProgress(pendingMessageId, i, progress);
              onProgress?.call(
                pendingMessageId,
                _pendingCache.getProgress(pendingMessageId) ?? {},
              );
            },
          )
          .future;

      if (cloudFile == null) {
        throw Exception('Failed to upload attachment ${i + 1}');
      }

      cloudFiles.add(cloudFile);
    }

    return cloudFiles;
  }

  bool _shouldUseAttachmentPlaceholder({
    required List<UniversalFile> attachments,
    SnChatMessage? editingTo,
    SnChatMessage? replyingTo,
    SnChatMessage? forwardingTo,
    List<Map<String, dynamic>>? embeds,
  }) {
    if (attachments.isEmpty) return false;
    if (_e2eeService?.isE2eeRoom == true) return false;
    if (!_isWebSocketConnected) return false;
    if (editingTo != null || replyingTo != null || forwardingTo != null) {
      return false;
    }
    if (embeds != null && embeds.isNotEmpty) return false;
    return true;
  }

  double _calculateOverallProgress(
    int attachmentCount,
    Map<int, double?> progressByAttachment,
  ) {
    if (attachmentCount <= 0) return 0;
    var total = 0.0;
    for (var i = 0; i < attachmentCount; i++) {
      total += progressByAttachment[i] ?? 0.0;
    }
    return (total / attachmentCount).clamp(0.0, 1.0);
  }

  Future<
    ({Map<String, dynamic> payload, Map<String, dynamic>? plaintextEnvelope})
  >
  _buildPayload({
    required String clientMessageId,
    required String content,
    required List<String> attachmentIds,
    bool isEditing = false,
    SnChatMessage? replyingTo,
    SnChatMessage? forwardingTo,
    List<Map<String, dynamic>>? embeds,
  }) async {
    if (_e2eeService?.isE2eeRoom == true) {
      // For E2EE, we need to extract survey and fund IDs for the encrypted payload
      String? surveyId;
      String? fundId;
      if (embeds != null) {
        for (final embed in embeds) {
          if (embed['type'] == 'survey') surveyId = embed['id'];
          if (embed['type'] == 'fund') fundId = embed['id'];
        }
      }
      final result = await _e2eeService!.buildMessagePayload(
        clientMessageId: clientMessageId,
        messageType: isEditing ? 'messages.update' : 'text',
        content: content,
        attachmentIds: attachmentIds,
        repliedMessageId: replyingTo?.id,
        forwardedMessageId: forwardingTo?.id,
        surveyId: surveyId,
        fundId: fundId,
      );
      return (
        payload: result.serverPayload,
        plaintextEnvelope: result.localEnvelope,
      );
    }

    final meta = <String, dynamic>{};
    final payload = {
      'content': content,
      'attachments_id': attachmentIds,
      'replied_message_id': replyingTo?.id,
      'forwarded_message_id': forwardingTo?.id,
      if (embeds != null && embeds.isNotEmpty) 'embeds': embeds,
      'meta': meta,
      'client_message_id': clientMessageId,
    };

    return (payload: payload, plaintextEnvelope: null);
  }

  Future<SnChatMessage> _sendToServer({
    required Map<String, dynamic> payload,
    SnChatMessage? editingTo,
  }) async {
    if (editingTo != null) {
      return _repository.editMessage(
        editingTo.id,
        payload,
        options: _e2eeService?.isE2eeRoom == true ? _mlsOptions : null,
      );
    }

    // MLS (E2EE) messages must go through HTTP
    if (_e2eeService?.isE2eeRoom == true) {
      return _repository.sendMessage(payload, options: _mlsOptions);
    }

    // Try WebSocket first for non-E2EE rooms
    if (_isWebSocketConnected) {
      try {
        return await _sendViaWebSocket(payload);
      } catch (e) {
        _logger.info('WebSocket send failed, falling back to HTTP: $e');
      }
    }

    // HTTP fallback
    return _repository.sendMessage(payload);
  }

  Future<SnChatMessage> _sendViaWebSocket(Map<String, dynamic> payload) async {
    final ws = _ref.read(websocketProvider);
    final wsState = _ref.read(websocketStateProvider.notifier);

    final packet = WebSocketPacket(
      type: 'messages.send',
      endpoint: 'messager',
      data: {'chat_room_id': _roomId, ...payload},
    );

    final completer = Completer<SnChatMessage>();
    StreamSubscription? subscription;

    subscription = ws.dataStream
        .where((pkt) => pkt.type == 'messages.delivered')
        .map((pkt) => pkt.data)
        .where((data) => data is Map<String, dynamic>)
        .cast<Map<String, dynamic>>()
        .where((data) {
          final roomId = data['chat_room_id']?.toString();
          final clientId =
              data['client_message_id']?.toString() ??
              data['nonce']?.toString();
          return roomId == _roomId && clientId == payload['client_message_id'];
        })
        .listen((data) {
          subscription?.cancel();
          final message = _parseMessage(data);
          if (message != null) {
            completer.complete(message);
          } else {
            completer.completeError('Invalid message response');
          }
        });

    // Timeout
    Future.delayed(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        subscription?.cancel();
        completer.completeError(TimeoutException('Message delivery timeout'));
      }
    });

    wsState.sendMessage(jsonEncode(packet));
    return completer.future;
  }

  Future<SnChatMessage> _finalizePlaceholderAndWait(
    String messageId, {
    String? content,
    List<String>? attachmentsId,
  }) async {
    final ws = _ref.read(websocketProvider);
    final completer = Completer<SnChatMessage>();
    StreamSubscription? subscription;

    subscription = ws.dataStream.listen((packet) {
      final data = packet.data;
      if (data == null) return;

      final message = _parseMessage(data);
      if (message == null) return;

      if (packet.type == 'messages.placeholder.finalize' &&
          message.id == messageId) {
        subscription?.cancel();
        completer.complete(message);
        return;
      }

      // The server also broadcasts the authoritative completion as a normal
      // message-update packet. It can arrive before the device-specific
      // confirmation above, so treat it as a successful finalize as well.
      if (packet.type != 'messages.update' ||
          message.type != 'messages.sync.finalize' ||
          message.meta['message_id']?.toString() != messageId) {
        return;
      }

      final finalizedData = Map<String, dynamic>.from(data)
        ..['id'] = messageId
        ..['type'] = 'text';
      final meta = Map<String, dynamic>.from(message.meta)
        ..remove('message_id');
      finalizedData['meta'] = meta;

      final finalized = _parseMessage(finalizedData);
      if (finalized == null) return;
      subscription?.cancel();
      completer.complete(finalized);
    });

    Future.delayed(const Duration(seconds: 12), () {
      if (completer.isCompleted) return;
      subscription?.cancel();
      completer.completeError(TimeoutException('Placeholder finalize timeout'));
    });

    finalizePlaceholder(
      messageId,
      content: content,
      attachmentsId: attachmentsId,
    );

    return completer.future;
  }

  SnChatMessage _buildEditedTargetMessage(
    SnChatMessage original,
    SnChatMessage updateEvent,
  ) {
    final mergedMeta = Map<String, dynamic>.of(original.meta)
      ..addAll(updateEvent.meta)
      ..remove('message_id');

    return original.copyWith(
      content: updateEvent.content,
      attachments: updateEvent.attachments,
      membersMentioned: updateEvent.membersMentioned,
      repliedMessageId: updateEvent.repliedMessageId,
      forwardedMessageId: updateEvent.forwardedMessageId,
      meta: mergedMeta,
      editedAt: updateEvent.createdAt,
    );
  }

  SnChatMessage? _parseMessage(Map<String, dynamic> data) {
    try {
      return SnChatMessage.fromJson(
        E2eeMessageService.sanitizeChatMessageJson(data),
      );
    } catch (e) {
      _logger.warning('Failed to parse message: $e');
      return null;
    }
  }

  bool get _isWebSocketConnected => _ref
      .read(websocketStateProvider)
      .maybeWhen(connected: () => true, orElse: () => false);

  Options? get _mlsOptions => null;

  // ── Placeholder Message Methods ──────────────────────────────────────────

  /// Creates a placeholder message for streaming or uploading.
  ///
  /// [kind] - "streaming" or "uploading".
  /// Returns the created placeholder message with its ID.
  Future<SnChatMessage?> createPlaceholder(String kind) async {
    try {
      final dio = _ref.read(apiClientProvider);
      final response = await dio.post(
        '/messager/chat/$_roomId/messages/placeholder',
        data: {'kind': kind},
      );
      return SnChatMessage.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.warning('Failed to create placeholder: $e');
      return null;
    }
  }

  /// Sends a placeholder update via WebSocket.
  ///
  /// [messageId] - The placeholder message ID.
  /// [contentChunk] - Text to append (streaming kind).
  /// [progress] - Upload progress 0.0–1.0 (uploading kind).
  void updatePlaceholder(
    String messageId, {
    String? contentChunk,
    double? progress,
  }) {
    final wsState = _ref.read(websocketStateProvider.notifier);

    final packet = WebSocketPacket(
      type: 'messages.placeholder.update',
      endpoint: 'DysonNetwork.Messager',
      data: {
        'message_id': messageId,
        'content_chunk': ?contentChunk,
        'progress': ?progress,
      },
    );

    wsState.sendMessage(jsonEncode(packet));
  }

  /// Finalizes a placeholder, converting it to a real message.
  ///
  /// [messageId] - The placeholder message ID.
  /// [content] - Optional final content (defaults to accumulated).
  /// [attachmentsId] - Optional file IDs to attach.
  void finalizePlaceholder(
    String messageId, {
    String? content,
    List<String>? attachmentsId,
  }) {
    final wsState = _ref.read(websocketStateProvider.notifier);

    final packet = WebSocketPacket(
      type: 'messages.placeholder.finalize',
      endpoint: 'DysonNetwork.Messager',
      data: {
        'message_id': messageId,
        'content': ?content,
        'attachments_id': ?attachmentsId,
      },
    );

    wsState.sendMessage(jsonEncode(packet));
  }
}
