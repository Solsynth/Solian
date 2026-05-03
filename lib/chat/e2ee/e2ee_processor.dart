import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/e2ee_message_service.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/e2ee/e2ee.dart';
import 'package:island/e2ee/mls_client.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// E2EE/MLS state for a room.
enum E2eeState {
  idle,
  bootstrapping,
  connected,
  reconnecting,
  failed,
}

/// Processes E2EE operations for a chat room.
class E2eeProcessor {
  final _logger = Logger('E2eeProcessor');
  final Ref _ref;
  final String _roomId;
  final String? _mlsGroupId;
  final bool _isE2eeRoom;

  E2eeState _state = E2eeState.idle;
  String? _currentDeviceId;

  E2eeProcessor(
    this._ref,
    this._roomId, {
    required String? mlsGroupId,
    required bool isE2eeRoom,
  })  : _mlsGroupId = mlsGroupId,
        _isE2eeRoom = isE2eeRoom;

  // ── State ────────────────────────────────────────────────────────────────

  bool get isE2eeRoom => _isE2eeRoom;
  E2eeState get state => _state;
  String? get mlsGroupId => _mlsGroupId;

  bool get canEncrypt => _isE2eeRoom && _state == E2eeState.connected;
  bool get canDecrypt => _isE2eeRoom && _state != E2eeState.failed;

  // ── Initialization ───────────────────────────────────────────────────────

  /// Initializes E2EE for this room.
  Future<void> initialize() async {
    if (!_isE2eeRoom) return;

    _logger.info('Initializing E2EE for room $_roomId');

    // Get current device ID
    _currentDeviceId = await _ref.read(mlsClientProvider).getDeviceId();

    // Setup event listeners
    _setupEventListeners();

    // Bootstrap MLS group if needed
    if (_mlsGroupId != null) {
      await _bootstrapGroup();
    }
  }

  void _setupEventListeners() {
    eventBus.on<MlsExternalJoinStartedEvent>().listen((event) {
      if (event.mlsGroupId != _mlsGroupId) return;
      _state = E2eeState.reconnecting;
      _logger.info('E2EE reconnecting for room $_roomId');
    });

    eventBus.on<MlsExternalJoinCompletedEvent>().listen((event) {
      if (event.mlsGroupId != _mlsGroupId) return;
      _state = event.success ? E2eeState.connected : E2eeState.failed;
      _logger.info(
        'E2EE reconnection ${event.success ? 'successful' : 'failed'}',
      );
    });

    eventBus.on<MlsRecoveryFailedEvent>().listen((event) {
      if (event.mlsGroupId != _mlsGroupId) return;
      _state = E2eeState.failed;
      _logger.warning('E2EE recovery failed for room $_roomId');
    });
  }

  Future<void> _bootstrapGroup() async {
    final groupId = _mlsGroupId;
    if (groupId == null) {
      _state = E2eeState.failed;
      return;
    }

    try {
      _state = E2eeState.bootstrapping;

      final mlsClient = _ref.read(mlsClientProvider);

      final currentEpoch = await mlsClient.getCurrentEpoch(groupId);
      _logger.fine('MLS epoch for room $_roomId: $currentEpoch');

      await mlsClient.bootstrapGroup(groupId, roomId: _roomId, force: false);

      _state = E2eeState.connected;
      _logger.info('E2EE bootstrap complete for room $_roomId');
    } catch (e) {
      _state = E2eeState.failed;
      _logger.severe('E2EE bootstrap failed for room $_roomId: $e');
    }
  }

  // ── Encryption ───────────────────────────────────────────────────────────

  /// Encrypts a message for sending.
  Future<EncryptedPayload> encrypt({
    required String content,
    required List<String> attachmentIds,
    required String messageType,
    String? repliedMessageId,
    String? forwardedMessageId,
  }) async {
    if (!canEncrypt) {
      throw StateError('Cannot encrypt: E2EE not ready');
    }

    final service = E2eeMessageService(
      ref: _ref,
      mlsGroupId: _mlsGroupId,
      isE2eeRoom: true,
    );

    final result = await service.buildMessagePayload(
      clientMessageId: '', // Set by sender
      messageType: messageType,
      content: content,
      attachmentIds: attachmentIds,
      repliedMessageId: repliedMessageId,
      forwardedMessageId: forwardedMessageId,
    );

    return EncryptedPayload(
      serverPayload: result.serverPayload,
      plaintextEnvelope: result.localEnvelope,
    );
  }

  // ── Decryption ───────────────────────────────────────────────────────────

  /// Decrypts a received message.
  /// Returns null if decryption fails or should be skipped.
  Future<DecryptionResult?> decrypt(SnChatMessage message) async {
    if (!canDecrypt) {
      return DecryptionResult.plaintext(message.content);
    }

    // Skip decryption for own messages (MLS forward secrecy)
    if (_isOwnMessage(message)) {
      return _handleOwnMessage(message);
    }

    final service = E2eeMessageService(
      ref: _ref,
      mlsGroupId: _mlsGroupId,
      isE2eeRoom: true,
    );

    final decrypted = await service.decryptMessage(message);

    if (decrypted == null) {
      _logger.warning('Decryption failed for message ${message.id}');
      return null;
    }

    final content = decrypted['content']?.toString();
    return DecryptionResult.success(
      content: content ?? '',
      decryptedData: decrypted,
    );
  }

  /// Checks if a message was sent by the current device.
  bool _isOwnMessage(SnChatMessage message) {
    final headerStr = message.meta['e2ee_header']?.toString();
    if (headerStr == null || headerStr.isEmpty) return false;

    try {
      final headerBytes = base64Decode(headerStr);
      final headerJson = utf8.decode(headerBytes);
      final header = jsonDecode(headerJson) as Map<String, dynamic>;
      final senderDeviceId = header['deviceId']?.toString();

      return senderDeviceId != null &&
          _currentDeviceId != null &&
          senderDeviceId == _currentDeviceId;
    } catch (e) {
      _logger.fine('Failed to parse E2EE header: $e');
      return false;
    }
  }

  /// Handles decryption for own messages (skip decryption, use plaintext).
  DecryptionResult _handleOwnMessage(SnChatMessage message) {
    _logger.fine('Skipping decryption for own message ${message.id}');

    // Try to get plaintext from pending or meta
    final clientMessageId =
        message.clientMessageId ?? message.meta['e2ee_client_message_id']?.toString();

    // Return empty result - plaintext should be preserved by sender
    return DecryptionResult.success(
      content: message.content ?? '',
      isOwnMessage: true,
      clientMessageId: clientMessageId,
    );
  }

  // ── Plaintext Preservation ───────────────────────────────────────────────

  /// Preserves sender plaintext for display.
  static SnChatMessage preservePlaintext(
    SnChatMessage message, {
    Map<String, dynamic>? plaintextEnvelope,
    String? existingDbContent,
    String? pendingContent,
  }) {
    if (message.content?.isNotEmpty == true) return message;

    String? plaintext;

    // Priority: envelope > DB > pending
    if (plaintextEnvelope != null) {
      plaintext = plaintextEnvelope['content']?.toString();
    }
    if ((plaintext == null || plaintext.isEmpty) &&
        existingDbContent?.isNotEmpty == true) {
      plaintext = existingDbContent;
    }
    if ((plaintext == null || plaintext.isEmpty) &&
        pendingContent?.isNotEmpty == true) {
      plaintext = pendingContent;
    }

    if (plaintext == null || plaintext.isEmpty) return message;

    final updatedMeta = Map<String, dynamic>.from(message.meta);
    updatedMeta['e2ee_decrypted_content'] = plaintext;

    return message.copyWith(
      content: plaintext,
      meta: updatedMeta,
    );
  }
}

/// Result of encrypting a message.
class EncryptedPayload {
  final Map<String, dynamic> serverPayload;
  final Map<String, dynamic>? plaintextEnvelope;

  const EncryptedPayload({
    required this.serverPayload,
    this.plaintextEnvelope,
  });
}

/// Result of decrypting a message.
class DecryptionResult {
  final String content;
  final bool isOwnMessage;
  final String? clientMessageId;
  final Map<String, dynamic>? decryptedData;

  const DecryptionResult._({
    required this.content,
    this.isOwnMessage = false,
    this.clientMessageId,
    this.decryptedData,
  });

  factory DecryptionResult.success({
    required String content,
    bool isOwnMessage = false,
    String? clientMessageId,
    Map<String, dynamic>? decryptedData,
  }) =>
      DecryptionResult._(
        content: content,
        isOwnMessage: isOwnMessage,
        clientMessageId: clientMessageId,
        decryptedData: decryptedData,
      );

  factory DecryptionResult.plaintext(String? content) => DecryptionResult._(
        content: content ?? '',
        isOwnMessage: false,
      );
}
