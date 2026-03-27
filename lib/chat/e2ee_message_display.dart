import 'package:solar_network_sdk/solar_network_sdk.dart';

typedef E2eeDisplayContent = ({
  String? content,
  bool isEncrypted,
  bool decryptFailed,
  bool emptyAfterDecrypt,
});

E2eeDisplayContent resolveE2eeDisplayContentForMessage(SnChatMessage message) {
  return resolveE2eeDisplayContent(
    roomId: message.chatRoomId,
    content: message.content,
    meta: message.meta,
  );
}

E2eeDisplayContent resolveE2eeDisplayContent({
  required String roomId,
  String? content,
  Map<String, dynamic>? meta,
  bool? isEncrypted,
  String? ciphertext,
}) {
  if (content?.isNotEmpty ?? false) {
    return (
      content: content,
      isEncrypted: isEncrypted == true || meta?['e2ee_is_encrypted'] == true,
      decryptFailed: false,
      emptyAfterDecrypt: false,
    );
  }

  final resolvedCiphertext = ciphertext ?? meta?['e2ee_ciphertext']?.toString();
  final resolvedEncrypted =
      isEncrypted == true || meta?['e2ee_is_encrypted'] == true;

  if (resolvedCiphertext == null || resolvedCiphertext.isEmpty) {
    return (
      content: null,
      isEncrypted: resolvedEncrypted,
      decryptFailed: false,
      emptyAfterDecrypt: false,
    );
  }

  final decoded = decodeMlsCiphertext(
    roomId: roomId,
    ciphertext: resolvedCiphertext,
  );
  if (decoded == null) {
    return (
      content: null,
      isEncrypted: true,
      decryptFailed: true,
      emptyAfterDecrypt: false,
    );
  }

  final decodedContent = decoded['content']?.toString();
  if (decodedContent == null || decodedContent.isEmpty) {
    return (
      content: null,
      isEncrypted: true,
      decryptFailed: false,
      emptyAfterDecrypt: true,
    );
  }

  return (
    content: decodedContent,
    isEncrypted: true,
    decryptFailed: false,
    emptyAfterDecrypt: false,
  );
}

Map<String, dynamic>? decodeMlsCiphertext({
  required String roomId,
  required String ciphertext,
}) {
  return null;
}
