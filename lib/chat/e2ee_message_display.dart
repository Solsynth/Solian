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
    ciphertext: message.meta['e2ee_ciphertext']?.toString(),
    isEncrypted: message.meta['e2ee_is_encrypted'] == true,
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

  final resolvedEncrypted =
      isEncrypted == true || meta?['e2ee_is_encrypted'] == true;
  final resolvedDecryptedContent = meta?['e2ee_decrypted_content']?.toString();

  if (resolvedDecryptedContent != null && resolvedDecryptedContent.isNotEmpty) {
    return (
      content: resolvedDecryptedContent,
      isEncrypted: true,
      decryptFailed: false,
      emptyAfterDecrypt: false,
    );
  }

  final resolvedCiphertext = ciphertext ?? meta?['e2ee_ciphertext']?.toString();

  if (resolvedCiphertext == null || resolvedCiphertext.isEmpty) {
    return (
      content: null,
      isEncrypted: resolvedEncrypted,
      decryptFailed: false,
      emptyAfterDecrypt: false,
    );
  }

  return (
    content: null,
    isEncrypted: true,
    decryptFailed: true,
    emptyAfterDecrypt: false,
  );
}
