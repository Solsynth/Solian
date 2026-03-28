import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/e2ee/e2ee.dart';
import 'package:island/talker.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Service layer for E2EE/MLS message operations.
///
/// Extracts all MLS-related logic from [MessagesNotifier] so the notifier
/// only handles state management and UI concerns.
class E2eeMessageService {
  final Ref _ref;
  final String _roomId;
  final bool _isE2eeRoom;

  E2eeMessageService({
    required Ref ref,
    required String roomId,
    required bool isE2eeRoom,
  }) : _ref = ref,
       _roomId = roomId,
       _isE2eeRoom = isE2eeRoom;

  bool get isE2eeRoom => _isE2eeRoom;

  // ── Message type normalization ──────────────────────────────────────

  /// Normalizes various encryption message type representations to canonical forms.
  static String? normalizeEncryptionMessageType(
    dynamic value, {
    dynamic messageType,
  }) {
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
      return fallback;
    }
    return raw;
  }

  // ── JSON sanitization ──────────────────────────────────────────────

  /// Sanitizes raw chat message JSON for [SnChatMessage.fromJson].
  ///
  /// Extracts E2EE encryption fields into meta, normalizes list types
  /// for mentioned members, attachments, and reactions.
  static Map<String, dynamic> sanitizeChatMessageJson(
    Map<String, dynamic> input,
  ) {
    final data = Map<String, dynamic>.from(input);
    final meta = data['meta'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['meta'] as Map<String, dynamic>)
        : <String, dynamic>{};

    if (data['is_encrypted'] == true) {
      meta['e2ee_is_encrypted'] = true;
      meta['e2ee_ciphertext'] = data['ciphertext'];
      meta['e2ee_header'] = data['encryption_header'];
      meta['e2ee_signature'] = data['encryption_signature'];
      meta['e2ee_scheme'] = data['encryption_scheme'];
      meta['e2ee_epoch'] = data['encryption_epoch'];
      final normalizedType = normalizeEncryptionMessageType(
        data['encryption_message_type'],
        messageType: data['type'],
      );
      if (normalizedType != null) {
        meta['e2ee_message_type'] = normalizedType;
      }
      meta['e2ee_client_message_id'] = data['client_message_id'];
    }

    data['meta'] = meta;
    data['members_mentioned'] =
        (data['members_mentioned'] is List
                ? data['members_mentioned'] as List
                : const [])
            .whereType<Object?>()
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList();
    data['attachments'] =
        (data['attachments'] is List ? data['attachments'] as List : const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
    data['reactions'] =
        (data['reactions'] is List ? data['reactions'] as List : const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
    return data;
  }

  // ── Encryption ─────────────────────────────────────────────────────

  /// Builds the E2EE message payload.
  ///
  /// Returns both the server payload (encrypted) and the local plaintext
  /// envelope for displaying the sender's own message (MLS forward secrecy
  /// prevents sender from decrypting their own ciphertext).
  Future<
    ({Map<String, dynamic> serverPayload, Map<String, dynamic> localEnvelope})
  >
  buildMessagePayload({
    required String clientMessageId,
    required String messageType,
    required String content,
    required List<String> attachmentIds,
    String? repliedMessageId,
    String? forwardedMessageId,
    String? pollId,
    String? fundId,
  }) async {
    final normalizedMessageType =
        normalizeEncryptionMessageType(messageType) ?? 'text';
    final mlsClient = _ref.read(mlsClientProvider);
    final encrypted = await mlsClient.encryptMessage(
      roomId: _roomId,
      content: content,
      attachmentIds: attachmentIds,
      messageType: MlsMessageType.fromString(normalizedMessageType),
      repliedMessageId: repliedMessageId,
      forwardedMessageId: forwardedMessageId,
    );

    final plaintextEnvelope =
        (encrypted['plaintextEnvelope'] as Map<String, dynamic>?) ?? {};

    final serverPayload = Map<String, dynamic>.from(encrypted)
      ..remove('plaintextEnvelope')
      ..['client_message_id'] = clientMessageId;

    return (serverPayload: serverPayload, localEnvelope: plaintextEnvelope);
  }

  // ── Decryption ─────────────────────────────────────────────────────

  /// Decrypts an E2EE message if it has encrypted content.
  ///
  /// Returns the decrypted result map, or the original message if
  /// not encrypted / decryption fails. For own messages, decryption
  /// will fail due to MLS forward secrecy — this is expected.
  Future<Map<String, dynamic>?> decryptMessage(SnChatMessage message) async {
    if (!_isE2eeRoom) return {'content': message.content};

    final ciphertext = message.meta['e2ee_ciphertext']?.toString();
    if (ciphertext == null || ciphertext.isEmpty) {
      return {'content': message.content};
    }

    try {
      final mlsClient = _ref.read(mlsClientProvider);
      return await mlsClient.decryptMessage(
        messageId: message.id,
        roomId: message.chatRoomId,
        ciphertext: ciphertext,
        encryptionHeader: message.meta['e2ee_header']?.toString(),
      );
    } catch (e) {
      talker.debug('E2EE decrypt failed for ${message.id}: $e');
      return null;
    }
  }

  // ── Sender plaintext preservation ──────────────────────────────────

  /// Restores plaintext for the sender's own message after encryption/decryption.
  ///
  /// MLS forward secrecy means senders cannot decrypt their own messages.
  /// We preserve plaintext via a cascade:
  /// 1. [plaintextEnvelope] from encryptMessage (highest priority)
  /// 2. [existingDbContent] from an existing DB record
  /// 3. [pendingContent] from a pending message
  static SnChatMessage preserveSenderPlaintext(
    SnChatMessage message, {
    Map<String, dynamic>? plaintextEnvelope,
    String? existingDbContent,
    String? pendingContent,
  }) {
    if (message.content != null && message.content!.isNotEmpty) return message;

    String? plaintext;
    if (plaintextEnvelope != null) {
      plaintext = plaintextEnvelope['content']?.toString();
    }
    if ((plaintext == null || plaintext.isEmpty) &&
        existingDbContent != null &&
        existingDbContent.isNotEmpty) {
      plaintext = existingDbContent;
    }
    if ((plaintext == null || plaintext.isEmpty) &&
        pendingContent != null &&
        pendingContent.isNotEmpty) {
      plaintext = pendingContent;
    }

    if (plaintext == null || plaintext.isEmpty) return message;

    final updatedMeta = Map<String, dynamic>.from(message.meta);
    updatedMeta['e2ee_decrypted_content'] = plaintext;
    return message.copyWith(content: plaintext, meta: updatedMeta);
  }
}
