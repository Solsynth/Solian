import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

const _magic = 'ISLE2E1';

List<int> _roomKey(String roomId) {
  return sha256.convert(utf8.encode('island-chat-e2ee-v1:$roomId')).bytes;
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
    ...utf8.encode(_magic),
    nonce.length,
    ...nonce,
    ...cipher,
  ];
  return base64Encode(bytes);
}

Map<String, dynamic>? decodeE2eeCiphertext({
  required String roomId,
  required String ciphertext,
}) {
  try {
    final bytes = base64Decode(ciphertext);
    final magicBytes = utf8.encode(_magic);
    if (bytes.length < magicBytes.length + 1) return null;
    for (var i = 0; i < magicBytes.length; i++) {
      if (bytes[i] != magicBytes[i]) return null;
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
    final decoded = jsonDecode(utf8.decode(plain));
    if (decoded is! Map<String, dynamic>) return null;
    return decoded;
  } catch (_) {
    return null;
  }
}
