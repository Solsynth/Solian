import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:openmls/openmls.dart';
import 'package:island/talker.dart';
import 'mls_engine.dart';
import 'mls_identity_manager.dart';
import 'mls_group_manager.dart';

/// Derive a file encryption key for E2EE rooms.
/// Used for encrypting attachments/files, not MLS messages.
String deriveE2eeFileEncryptKey(String roomId) {
  final keyBytes = sha256
      .convert(utf8.encode('island-chat-file-e2ee-v1:$roomId'))
      .bytes;
  return base64Encode(keyBytes);
}

enum MlsMessageType {
  text('text'),
  messagesUpdate('messages.update'),
  messagesDelete('messages.delete');

  final String value;
  const MlsMessageType(this.value);

  static MlsMessageType fromString(String? value) {
    switch (value) {
      case 'text':
        return MlsMessageType.text;
      case 'messages.update':
        return MlsMessageType.messagesUpdate;
      case 'messages.delete':
        return MlsMessageType.messagesDelete;
      default:
        return MlsMessageType.text;
    }
  }
}

class MlsMessageHandler {
  final MlsGroupManager _groupManager;
  final MlsIdentityManager _identityManager;
  final Dio _padlockClient;

  MlsMessageHandler({
    required MlsGroupManager groupManager,
    required MlsIdentityManager identityManager,
    required Dio padlockClient,
  }) : _groupManager = groupManager,
       _identityManager = identityManager,
       _padlockClient = padlockClient;

  bool _isMissingGroupError(Object error) {
    final message = error.toString();
    return message.contains('No group found in storage') ||
        message.contains('group not found in storage');
  }

  /// Encrypt a message for the MLS group.
  ///
  /// Returns a map containing:
  /// - `ciphertext`: The encrypted message for sending to server
  /// - `plaintextEnvelope`: The plaintext envelope for local display
  /// - Other metadata fields
  ///
  /// IMPORTANT: Due to MLS Forward Secrecy, the sender cannot decrypt
  /// their own messages. The plaintextEnvelope should be used locally
  /// for immediate display by the sender.
  Future<Map<String, dynamic>> encryptMessage({
    required String roomId,
    required String content,
    required List<String> attachmentIds,
    required MlsMessageType messageType,
    String? repliedMessageId,
    String? forwardedMessageId,
    String? pollId,
    String? fundId,
  }) async {
    final engineService = await MlsEngineService.getInstance();
    final engine = engineService.engine;

    // Use clean signer access via identity manager
    final signerBytes = await _identityManager.getOrCreateSignerBytes();

    final groupIdBytes = utf8.encode('room:$roomId');
    final isAvailable = await _groupManager.ensureGroupAvailable(roomId);
    if (!isAvailable) {
      throw Exception('Failed to bootstrap MLS group for room $roomId.');
    }

    final clientMessageId = _generateNonce();
    final envelope = <String, dynamic>{
      'content': content,
      'attachments_id': attachmentIds,
      'client_message_id': clientMessageId,
      'replied_message_id': repliedMessageId,
      'forwarded_message_id': forwardedMessageId,
      'poll_id': pollId,
      'fund_id': fundId,
    }..removeWhere((_, v) => v == null);

    final plaintext = utf8.encode(jsonEncode(envelope));
    Uint8List? ciphertextBytes;
    int? epoch;

    try {
      final result = await engine.createMessage(
        groupIdBytes: groupIdBytes,
        signerBytes: signerBytes,
        message: plaintext,
      );
      ciphertextBytes = result.ciphertext;
      epoch = (await engine.groupEpoch(groupIdBytes: groupIdBytes)).toInt();
    } catch (e) {
      if (!_isMissingGroupError(e)) rethrow;

      talker.warning(
        'MLS group missing while encrypting room $roomId, re-bootstrapping and retrying...',
      );
      final recovered = await _groupManager.ensureGroupAvailable(roomId);
      if (!recovered) rethrow;

      final result = await engine.createMessage(
        groupIdBytes: groupIdBytes,
        signerBytes: signerBytes,
        message: plaintext,
      );
      ciphertextBytes = result.ciphertext;
      epoch = (await engine.groupEpoch(groupIdBytes: groupIdBytes)).toInt();
    }

    talker.debug(
      'Encrypted message for room $roomId (epoch: $epoch, type: ${messageType.value})',
    );

    // Export and cache ratchet tree for external join support
    try {
      final ratchetTree = await engine.exportRatchetTree(
        groupIdBytes: groupIdBytes,
      );
      await _groupManager.saveGroupState(roomId, {
        ...?await _groupManager.getGroupState(roomId),
        'ratchet_tree': base64Encode(ratchetTree),
      });
    } catch (e) {
      talker.debug(
        'Could not export ratchet tree after encrypt (non-fatal): $e',
      );
    }

    final deviceId = await _identityManager.getOrCreateDeviceId();
    final headerJson = jsonEncode({
      'v': 1,
      'scheme': 'mls',
      'deviceId': deviceId,
    });

    return {
      'type': messageType.value,
      'attachments_id': attachmentIds,
      'meta': {
        'attachments_id': attachmentIds,
        'replied_message_id': repliedMessageId,
        'forwarded_message_id': forwardedMessageId,
        'poll_id': pollId,
        'fund_id': fundId,
      },
      'replied_message_id': repliedMessageId,
      'forwarded_message_id': forwardedMessageId,
      'poll_id': pollId,
      'fund_id': fundId,
      'is_encrypted': true,
      'ciphertext': base64Encode(ciphertextBytes),
      'encryption_header': base64Encode(utf8.encode(headerJson)),
      'encryption_scheme': 'chat.mls.v1',
      'encryption_epoch': epoch,
      'encryption_message_type': messageType.value,
      'client_message_id': clientMessageId,
      // IMPORTANT: plaintextEnvelope for local display by the sender
      // The sender cannot decrypt their own message due to MLS Forward Secrecy
      'plaintextEnvelope': envelope,
    };
  }

  /// Decrypt a message from the MLS group.
  ///
  /// Due to MLS Forward Secrecy, a sender cannot decrypt their own messages.
  /// If this method is called on a message that was sent by this device,
  /// it will return null and log a warning.
  ///
  /// Handles all MLS content types:
  /// - `application`: Decrypts and returns the plaintext envelope
  /// - `proposal`: Processes the proposal, updates group state
  /// - `commit` (stagedCommit): Processes the commit, updates epoch, saves ratchet tree
  Future<Map<String, dynamic>?> decryptMessage({
    required String messageId,
    required String roomId,
    required String ciphertext,
    required String? encryptionHeader,
  }) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;

      final groupIdBytes = utf8.encode('room:$roomId');
      final isAvailable = await _groupManager.ensureGroupAvailable(roomId);
      if (!isAvailable) {
        talker.debug('Group not active for room: $roomId');
        return null;
      }

      final ciphertextBytes = base64Decode(ciphertext);

      // Detect content type before processing
      String contentType;
      try {
        contentType = mlsMessageContentType(messageBytes: ciphertextBytes);
      } catch (e) {
        // If content type detection fails, fall back to trying processMessage
        talker.debug('Could not detect content type for $messageId: $e');
        contentType = 'application';
      }

      // Handle Welcome messages (routed from pending envelopes, not via this path normally)
      if (contentType == 'welcome') {
        talker.debug(
          'Received Welcome content type in decryptMessage for room $roomId — '
          'use processWelcome() instead',
        );
        return null;
      }

      ProcessedMessageResult? result;
      try {
        result = await engine.processMessage(
          groupIdBytes: groupIdBytes,
          messageBytes: ciphertextBytes,
        );
      } catch (e) {
        // Handle "Cannot decrypt own messages" gracefully
        // This is expected MLS behavior due to Forward Secrecy
        if (e.toString().contains('Cannot decrypt') ||
            e.toString().contains('cannot decrypt')) {
          talker.debug(
            'Cannot decrypt own message $messageId (expected MLS behavior)',
          );
          return null;
        }

        if (!_isMissingGroupError(e)) rethrow;

        talker.warning(
          'MLS group missing while decrypting room $roomId, re-bootstrapping and retrying...',
        );
        final recovered = await _groupManager.ensureGroupAvailable(roomId);
        if (!recovered) return null;

        result = await engine.processMessage(
          groupIdBytes: groupIdBytes,
          messageBytes: ciphertextBytes,
        );
      }

      switch (result.messageType) {
        case ProcessedMessageType.application:
          if (result.applicationMessage != null) {
            final plaintext = utf8.decode(result.applicationMessage!);
            return jsonDecode(plaintext) as Map<String, dynamic>;
          }
          return null;

        case ProcessedMessageType.stagedCommit:
          final epoch = result.epoch.toInt();
          talker.debug(
            'Processed staged commit for room $roomId (new epoch: $epoch)',
          );
          await _groupManager.handleEpochChanged(roomId, epoch);

          // Save ratchet tree for external join support by other devices
          try {
            final ratchetTree = await engine.exportRatchetTree(
              groupIdBytes: groupIdBytes,
            );
            await _groupManager.saveGroupState(roomId, {
              ...?await _groupManager.getGroupState(roomId),
              'epoch': epoch,
              'ratchet_tree': base64Encode(ratchetTree),
              'last_commit_at': DateTime.now().toIso8601String(),
            });
          } catch (e) {
            talker.debug('Could not save ratchet tree (non-fatal): $e');
            await _groupManager.handleEpochChanged(roomId, epoch);
          }
          return null;

        case ProcessedMessageType.proposal:
          talker.debug('Processed proposal for room $roomId');
          // Proposals don't change the epoch until committed
          return null;
      }
    } catch (e) {
      // Final catch for any remaining errors
      if (e.toString().contains('Cannot decrypt') ||
          e.toString().contains('cannot decrypt')) {
        talker.debug(
          'Cannot decrypt message for room $roomId (likely own message)',
        );
        return null;
      }
      talker.error('Failed to decrypt message for room $roomId: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fanoutMessage({
    required String roomId,
    required Map<String, dynamic> encryptedPayload,
  }) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/messages/fanout',
        data: {'room_id': roomId, 'payload': encryptedPayload},
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      talker.error('Failed to fanout message: $e');
      rethrow;
    }
  }

  /// Process an incoming Welcome envelope to join an MLS group.
  ///
  /// The [welcomeBytes] should be the raw Welcome message bytes from
  /// the server (base64-decoded from the envelope payload).
  /// [roomId] identifies which room this Welcome is for.
  Future<Map<String, dynamic>?> processWelcomeEnvelope({
    required String roomId,
    required Uint8List welcomeBytes,
  }) async {
    return _groupManager.processWelcome(
      roomId: roomId,
      welcomeBytes: welcomeBytes,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingEnvelopes(
    String deviceId,
  ) async {
    try {
      final response = await _padlockClient.get(
        '/e2ee/mls/envelopes/pending',
        queryParameters: {'device_id': deviceId},
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return [];
    } catch (e) {
      talker.error('Failed to get pending envelopes: $e');
      return [];
    }
  }

  Future<bool> ackEnvelope(String envelopeId, String deviceId) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/envelopes/$envelopeId/ack',
        queryParameters: {'device_id': deviceId},
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      talker.error('Failed to ack envelope: $e');
      return false;
    }
  }

  String _generateNonce() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = timestamp.hashCode.abs().toString();
    return base64Url
        .encode(utf8.encode('$timestamp$random'))
        .replaceAll('=', '');
  }

  String normalizeMessageType(dynamic value, {dynamic messageType}) {
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
      return fallback!;
    }
    return raw ?? 'text';
  }
}
