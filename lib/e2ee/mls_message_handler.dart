import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:island/talker.dart';
import 'mls_storage.dart';
import 'mls_group_manager.dart';

String deriveFileEncryptKey(String roomId) {
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
  }) async {
    final envelope = {
      'content': content,
      'attachments_id': attachmentIds,
      'nonce': _generateNonce(),
    };
    final meta = <String, dynamic>{
      'attachments_id': attachmentIds,
      if (repliedMessageId != null) 'replied_message_id': repliedMessageId,
      if (forwardedMessageId != null)
        'forwarded_message_id': forwardedMessageId,
    };
    final epoch = await _groupManager.getCurrentEpoch(roomId);

    return {
      'type': messageType.value,
      'attachments_id': attachmentIds,
      'meta': meta,
      if (repliedMessageId != null) 'replied_message_id': repliedMessageId,
      if (forwardedMessageId != null)
        'forwarded_message_id': forwardedMessageId,
      'is_encrypted': true,
      'ciphertext': base64Encode(utf8.encode(jsonEncode(envelope))),
      'encryption_header': base64Encode(
        utf8.encode('{"v":1,"room_id":"$roomId"}'),
      ),
      'encryption_scheme': 'chat.mls.v1',
      'encryption_epoch': epoch,
      'encryption_message_type': messageType.value,
      'nonce': envelope['nonce'],
    };
  }

  Future<Map<String, dynamic>?> decryptMessage({
    required String roomId,
    required String ciphertext,
    required String? encryptionHeader,
  }) async {
    try {
      final ciphertextBytes = base64Decode(ciphertext);
      final decrypted = utf8.decode(ciphertextBytes);
      return jsonDecode(decrypted) as Map<String, dynamic>;
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
