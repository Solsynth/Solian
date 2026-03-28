import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:openmls/openmls.dart';
import 'package:island/talker.dart';
import 'mls_engine.dart';
import 'mls_identity_manager.dart';
import 'mls_group_manager.dart';

const _mlsLogPrefix = '[MLS] ';

void _mlsLog(dynamic msg) {
  talker.info('$_mlsLogPrefix$msg');
}

void _mlsLogWarn(dynamic msg) {
  talker.warning('$_mlsLogPrefix$msg');
}

void _mlsLogError(dynamic msg) {
  talker.error('$_mlsLogPrefix$msg');
}

/// Used for encrypting attachments/files, not MLS messages.
String deriveE2eeFileEncryptKey(String mlsGroupId) {
  final keyBytes = sha256
      .convert(utf8.encode('island-chat-file-e2ee-v1:$mlsGroupId'))
      .bytes;
  return base64Encode(keyBytes);
}

enum MlsMessageType {
  text,
  messagesUpdate,
  messagesDelete;

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

  String get value {
    switch (this) {
      case MlsMessageType.text:
        return 'text';
      case MlsMessageType.messagesUpdate:
        return 'messages.update';
      case MlsMessageType.messagesDelete:
        return 'messages.delete';
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
    required String mlsGroupId,
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

    final groupIdBytes = utf8.encode(mlsGroupId);
    final isAvailable = await _groupManager.ensureGroupAvailable(mlsGroupId);
    if (!isAvailable) {
      throw Exception('Failed to bootstrap MLS group for room $mlsGroupId.');
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
      final epochBefore = (await engine.groupEpoch(
        groupIdBytes: groupIdBytes,
      )).toInt();
      _mlsLog('Creating message: epoch before=$epochBefore');

      final result = await engine.createMessage(
        groupIdBytes: groupIdBytes,
        signerBytes: signerBytes,
        message: plaintext,
      );
      ciphertextBytes = result.ciphertext;
      epoch = (await engine.groupEpoch(groupIdBytes: groupIdBytes)).toInt();
      _mlsLog(
        'Created message: epoch after=$epoch, ciphertext len=${ciphertextBytes.length}',
      );
    } catch (e) {
      if (!_isMissingGroupError(e)) rethrow;

      _mlsLogWarn(
        'MLS group missing while encrypting room $mlsGroupId, re-bootstrapping and retrying...',
      );
      final recovered = await _groupManager.ensureGroupAvailable(mlsGroupId);
      if (!recovered) rethrow;

      final result = await engine.createMessage(
        groupIdBytes: groupIdBytes,
        signerBytes: signerBytes,
        message: plaintext,
      );
      ciphertextBytes = result.ciphertext;
      epoch = (await engine.groupEpoch(groupIdBytes: groupIdBytes)).toInt();
    }

    _mlsLog(
      'Encrypted message for room $mlsGroupId (epoch: $epoch, type: ${messageType.value})',
    );

    // Export and cache ratchet tree and epoch for external join support
    try {
      final ratchetTree = await engine.exportRatchetTree(
        groupIdBytes: groupIdBytes,
      );
      await _groupManager.saveGroupState(mlsGroupId, {
        ...?await _groupManager.getGroupState(mlsGroupId),
        'ratchet_tree': base64Encode(ratchetTree),
        'epoch': epoch,
      });
      _mlsLog('Saved group state after encrypt: epoch=$epoch');
    } catch (e) {
      _mlsLog('Could not export ratchet tree after encrypt (non-fatal): $e');
    }

    final deviceId = await _identityManager.getOrCreateDeviceId();
    final headerJson = jsonEncode({
      'v': 1,
      'scheme': 'mls',
      'device_id': deviceId,
      'epoch': epoch,
    });
    _mlsLog('Encrypt header created: $headerJson');

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
      'encryption_scheme': 'chat.mls.v2',
      'encryption_epoch': epoch,
      'encryption_message_type': messageType.value,
      'client_message_id': clientMessageId,
      'plaintext_envelope': envelope,
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
    required String mlsGroupId,
    required String ciphertext,
    required String? encryptionHeader,
    String? encryptionScheme,
  }) async {
    // Skip messages with old encryption schemes
    if (encryptionScheme != null && encryptionScheme != 'chat.mls.v2') {
      // _mlsLog(
      //   'Skipping decryption for old encryption scheme: $encryptionScheme',
      // );
      return null;
    }

    // Parse message epoch from header for diagnostics
    int? messageEpoch;
    String? parsedDeviceId;
    if (encryptionHeader != null && encryptionHeader.isNotEmpty) {
      try {
        final headerBytes = base64Decode(encryptionHeader);
        final headerJson = utf8.decode(headerBytes);
        _mlsLog('Decrypt header raw: $headerJson');
        final header = jsonDecode(headerJson) as Map<String, dynamic>;
        messageEpoch = header['epoch'] as int?;
        parsedDeviceId = header['device_id'] as String?;
        _mlsLog(
          'Decrypt header parsed: epoch=$messageEpoch, deviceId=$parsedDeviceId',
        );
      } catch (e) {
        _mlsLogWarn('Failed to parse encryption header: $e');
      }
    } else {
      _mlsLogWarn('No encryption header provided for decryption!');
    }

    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;

      final groupIdBytes = utf8.encode(mlsGroupId);
      final isAvailable = await _groupManager.ensureGroupAvailable(mlsGroupId);
      if (!isAvailable) {
        _mlsLog('Group not active for room: $mlsGroupId');
        return null;
      }

      // Log epoch info for debugging
      int localEpoch = 0;
      try {
        localEpoch = (await engine.groupEpoch(
          groupIdBytes: groupIdBytes,
        )).toInt();
        _mlsLog(
          'Decrypting: messageEpoch=$messageEpoch, localEpoch=$localEpoch, msgId=$messageId, ciphertextLen=${ciphertext.length}',
        );
      } catch (e) {
        _mlsLogWarn('Failed to get local epoch: $e');
      }

      final ciphertextBytes = base64Decode(ciphertext);
      _mlsLog('Ciphertext decoded: ${ciphertextBytes.length} bytes');

      // Detect content type before processing
      String contentType;
      try {
        contentType = mlsMessageContentType(messageBytes: ciphertextBytes);
      } catch (e) {
        // If content type detection fails, fall back to trying processMessage
        _mlsLog('Could not detect content type for $messageId: $e');
        contentType = 'application';
      }

      // Handle Welcome messages (routed from pending envelopes, not via this path normally)
      if (contentType == 'welcome') {
        _mlsLog(
          'Received Welcome content type in decryptMessage for room $mlsGroupId — '
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
          _mlsLog(
            'Cannot decrypt own message $messageId (expected MLS behavior)',
          );
          return null;
        }

        final errorStr = e.toString();
        _mlsLogError(
          'Decrypt failed for room $mlsGroupId | messageId: $messageId | error: $errorStr',
        );

        _mlsLog('Ciphertext length: ${ciphertext.length}');
        int localEpoch = 0;
        try {
          localEpoch = await _groupManager.getCurrentEpoch(mlsGroupId);
          _mlsLog(
            'Current local epoch: $localEpoch, message epoch: $messageEpoch',
          );
        } catch (_) {
          _mlsLog('Current local epoch: unknown');
        }

        if (errorStr.contains('AEAD')) {
          _mlsLogWarn(
            'AEAD decryption failed → likely epoch mismatch (message epoch: $messageEpoch vs local: $localEpoch)',
          );
        }

        if (!_isMissingGroupError(e)) rethrow;

        _mlsLogWarn(
          'MLS group missing while decrypting room $mlsGroupId, re-bootstrapping and retrying...',
        );
        final recovered = await _groupManager.ensureGroupAvailable(mlsGroupId);
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
          _mlsLog(
            'Processed staged commit for room $mlsGroupId (new epoch: $epoch)',
          );

          // Save epoch and ratchet tree for external join support by other devices
          try {
            final ratchetTree = await engine.exportRatchetTree(
              groupIdBytes: groupIdBytes,
            );
            final existingState = await _groupManager.getGroupState(mlsGroupId);
            await _groupManager.saveGroupState(mlsGroupId, {
              ...?existingState,
              'group_id': mlsGroupId,
              'epoch': epoch,
              'ratchet_tree': base64Encode(ratchetTree),
              'last_commit_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            _mlsLog('Saved epoch=$epoch after processing commit');
          } catch (e) {
            _mlsLogWarn('Could not save ratchet tree after commit: $e');
            // Still update epoch even if ratchet tree fails
            await _groupManager.handleEpochChanged(mlsGroupId, epoch);
          }
          return null;

        case ProcessedMessageType.proposal:
          _mlsLog('Processed proposal for room $mlsGroupId');
          // Proposals don't change the epoch until committed
          return null;
      }
    } catch (e) {
      // Final catch for any remaining errors
      if (e.toString().contains('Cannot decrypt') ||
          e.toString().contains('cannot decrypt')) {
        _mlsLog(
          'Cannot decrypt message for room $mlsGroupId (likely own message)',
        );
        return null;
      }
      _mlsLogError('Failed to decrypt message for room $mlsGroupId: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fanoutMessage({
    required String mlsGroupId,
    required Map<String, dynamic> encryptedPayload,
  }) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/messages/fanout',
        data: {'room_id': mlsGroupId, 'payload': encryptedPayload},
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
      );
      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      _mlsLogError('Failed to fanout message: $e');
      rethrow;
    }
  }

  /// Process an incoming Welcome envelope to join an MLS group.
  ///
  /// The [welcomeBytes] should be the raw Welcome message bytes from
  /// the server (base64-decoded from the envelope payload).
  /// [mlsGroupId] identifies which room this Welcome is for.
  Future<Map<String, dynamic>?> processWelcomeEnvelope({
    required String mlsGroupId,
    required Uint8List welcomeBytes,
  }) async {
    return _groupManager.processWelcome(
      mlsGroupId: mlsGroupId,
      welcomeBytes: welcomeBytes,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingEnvelopes(
    String deviceId,
  ) async {
    try {
      final response = await _padlockClient.get(
        '/e2ee/mls/envelopes/pending',
        queryParameters: {'deviceId': deviceId},
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
      );
      if (response.data is List) {
        return (response.data as List).map((e) {
          return Map<String, dynamic>.from(e as Map);
        }).toList();
      }
      return [];
    } catch (e) {
      _mlsLogError('Failed to get pending envelopes: $e');
      return [];
    }
  }

  Future<bool> ackEnvelope(String envelopeId, String deviceId) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/envelopes/$envelopeId/ack',
        queryParameters: {'deviceId': deviceId},
        options: Options(headers: {'X-Client-Ability': 'chat.mls.v2'}),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      _mlsLogError('Failed to ack envelope: $e');
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
