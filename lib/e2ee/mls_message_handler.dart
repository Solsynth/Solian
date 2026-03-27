import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:island/talker.dart';
import 'mls_storage.dart';
import 'mls_group_manager.dart';

String deriveE2eeFileEncryptKey(String roomId) {
  final keyBytes = sha256
      .convert(utf8.encode('island-chat-file-e2ee-v1:$roomId'))
      .bytes;
  return base64Encode(keyBytes);
}

List<int> _roomKey(String roomId) {
  return sha256.convert(utf8.encode('island-chat-e2ee-v1:$roomId')).bytes;
}

String encodeE2eeCiphertext({
  required String roomId,
  required Map<String, dynamic> envelope,
}) {
  final payload = utf8.encode(jsonEncode(envelope));
  final nonce = List<int>.generate(12, (_) => Random.secure().nextInt(256));
  final key = _roomKey(roomId);
  final stream = _keystream(key: key, nonce: nonce, length: payload.length);
  final cipher = List<int>.generate(
    payload.length,
    (i) => payload[i] ^ stream[i],
  );
  final bytes = <int>[
    ...utf8.encode('ISLE2E1'),
    nonce.length,
    ...nonce,
    ...cipher,
  ];
  return base64Encode(bytes);
}

List<int> _keystream({
  required List<int> key,
  required List<int> nonce,
  required int length,
}) {
  final out = <int>[];
  var counter = 0;
  while (out.length < length) {
    final c = ByteData(4)..setUint32(0, counter, Endian.big);
    final block = sha256.convert([
      ...key,
      ...nonce,
      ...c.buffer.asUint8List(),
    ]).bytes;
    out.addAll(block);
    counter += 1;
  }
  return out.take(length).toList();
}

Map<String, dynamic>? decodeE2eeCiphertext({
  required String roomId,
  required String ciphertext,
}) {
  Map<String, dynamic>? parseJsonBytes(List<int> bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  try {
    final bytes = base64Decode(ciphertext);
    final magicBytes = utf8.encode('ISLE2E1');
    var hasMagic = bytes.length >= magicBytes.length + 1;
    if (hasMagic) {
      for (var i = 0; i < magicBytes.length; i++) {
        if (bytes[i] != magicBytes[i]) {
          hasMagic = false;
          break;
        }
      }
    }

    if (!hasMagic) {
      return parseJsonBytes(bytes);
    }

    final nonceLen = bytes[magicBytes.length];
    final nonceStart = magicBytes.length + 1;
    final nonceEnd = nonceStart + nonceLen;
    if (bytes.length < nonceEnd) return null;
    final nonce = bytes.sublist(nonceStart, nonceEnd);
    final cipher = bytes.sublist(nonceEnd);
    final key = _roomKey(roomId);
    final stream = _keystream(key: key, nonce: nonce, length: cipher.length);
    final plain = List<int>.generate(
      cipher.length,
      (i) => cipher[i] ^ stream[i],
    );
    return parseJsonBytes(plain);
  } catch (_) {
    try {
      final decoded = jsonDecode(ciphertext);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }
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
      'ciphertext': utf8.encode(
        encodeE2eeCiphertext(roomId: roomId, envelope: envelope),
      ),
      'encryption_header': utf8.encode('{"v":1}'),
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
