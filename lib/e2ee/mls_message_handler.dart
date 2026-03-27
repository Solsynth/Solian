import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:openmls/openmls.dart';
import 'package:island/talker.dart';
import 'mls_engine.dart';
import 'mls_storage.dart';
import 'mls_group_manager.dart';

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
  final MlsStorage _storage;
  final MlsGroupManager _groupManager;
  final Dio _padlockClient;

  MlsMessageHandler({
    required MlsStorage storage,
    required MlsGroupManager groupManager,
    required Dio padlockClient,
  }) : _storage = storage,
       _groupManager = groupManager,
       _padlockClient = padlockClient;

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

    final signerKeyPairRaw = await _storage.getSignerKeyPair();
    if (signerKeyPairRaw == null) {
      throw Exception('Signer keypair not found. Please initialize MLS first.');
    }

    final signerKeyPair = MlsSignatureKeyPair.fromRaw(
      ciphersuite: defaultCiphersuite,
      privateKey: base64Decode(signerKeyPairRaw.split(':')[0]),
      publicKey: base64Decode(signerKeyPairRaw.split(':')[1]),
    );

    final groupIdBytes = utf8.encode('room:$roomId');

    final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
    if (!isActive) {
      talker.info('Group not active for room $roomId, bootstrapping...');
      await _groupManager.bootstrapGroup(roomId);
    }

    final envelope = {
      'content': content,
      'attachments_id': attachmentIds,
      'nonce': _generateNonce(),
      if (repliedMessageId != null) 'replied_message_id': repliedMessageId,
      if (forwardedMessageId != null)
        'forwarded_message_id': forwardedMessageId,
      if (pollId != null) 'poll_id': pollId,
      if (fundId != null) 'fund_id': fundId,
    };

    final plaintext = utf8.encode(jsonEncode(envelope));
    final result = await engine.createMessage(
      groupIdBytes: groupIdBytes,
      signerBytes: signerKeyPair.privateKey(),
      message: plaintext,
    );

    final epoch = await engine.groupEpoch(groupIdBytes: groupIdBytes);

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
      'ciphertext': base64Encode(result.ciphertext),
      'encryption_header': base64Encode(utf8.encode('{"v":1,"scheme":"mls"}')),
      'encryption_scheme': 'chat.mls.v1',
      'encryption_epoch': epoch.toInt(),
      'encryption_message_type': messageType.value,
      'client_message_id': envelope['nonce'],
      'nonce': envelope['nonce'],
    };
  }

  Future<Map<String, dynamic>?> decryptMessage({
    required String roomId,
    required String ciphertext,
    required String? encryptionHeader,
  }) async {
    try {
      final engineService = await MlsEngineService.getInstance();
      final engine = engineService.engine;

      final groupIdBytes = utf8.encode('room:$roomId');
      final isActive = await engine.groupIsActive(groupIdBytes: groupIdBytes);
      if (!isActive) {
        talker.debug('Group not active for room: $roomId');
        return null;
      }

      final ciphertextBytes = base64Decode(ciphertext);
      final result = await engine.processMessage(
        groupIdBytes: groupIdBytes,
        messageBytes: ciphertextBytes,
      );

      if (result.messageType == ProcessedMessageType.application) {
        if (result.applicationMessage != null) {
          final plaintext = utf8.decode(result.applicationMessage!);
          return jsonDecode(plaintext) as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      talker.error('Failed to decrypt message: $e');
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
