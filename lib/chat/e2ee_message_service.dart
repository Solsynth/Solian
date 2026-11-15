import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/e2ee/e2ee.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Service layer for E2EE/MLS message operations.
///
/// Extracts all MLS-related logic from [MessagesNotifier] so the notifier
/// only handles state management and UI concerns.
class E2eeMessageService {
  final Ref _ref;
  final String? _mlsGroupId;
  final bool _isE2eeRoom;

  E2eeMessageService({
    required Ref ref,
    required String? mlsGroupId,
    required bool isE2eeRoom,
  }) : _ref = ref,
       _mlsGroupId = mlsGroupId,
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

    final encryptionMeta = data['encryption_meta'] is Map
        ? Map<String, dynamic>.from(data['encryption_meta'] as Map)
        : null;
    if (encryptionMeta != null) {
      meta['e2ee_is_encrypted'] = true;
      meta['e2ee_ciphertext'] = encryptionMeta['ciphertext'];
      meta['e2ee_header'] = encryptionMeta['header'];
      meta['e2ee_signature'] = encryptionMeta['signature'];
      meta['e2ee_scheme'] = encryptionMeta['scheme'];
      meta['e2ee_epoch'] = encryptionMeta['epoch'];
      meta['e2ee_message_type'] = data['type'];
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
    String? threadId,
    SnChatMessage? threadingTo,
    String? surveyId,
    String? fundId,
  }) async {
    final normalizedMessageType =
        normalizeEncryptionMessageType(messageType) ?? 'text';
    final mlsClient = _ref.read(mlsClientProvider);
    final encrypted = await mlsClient.encryptMessage(
      mlsGroupId: _mlsGroupId!,
      content: content,
      attachmentIds: attachmentIds,
      messageType: MlsMessageType.fromString(normalizedMessageType),
      repliedMessageId: repliedMessageId,
      forwardedMessageId: forwardedMessageId,
      threadId: threadId ?? threadingTo?.id,
      surveyId: surveyId,
      fundId: fundId,
    );

    final plaintextEnvelope =
        (encrypted['plaintext_envelope'] as Map<String, dynamic>?) ?? {};

    final serverPayload = Map<String, dynamic>.from(encrypted)
      ..remove('plaintext_envelope')
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
        mlsGroupId: _mlsGroupId!,
        ciphertext: ciphertext,
        encryptionHeader: message.meta['e2ee_header']?.toString(),
        encryptionScheme: message.meta['e2ee_scheme']?.toString(),
      );
    } catch (e) {
      Logger.root.fine('E2EE decrypt failed for ${message.id}: $e');
      return null;
    }
  }

  /// Decrypts an E2EE message and applies all decrypted envelope fields
  /// (`content`, `replied_message_id`, `forwarded_message_id`, `thread_id`,
  /// `attachments_id`, `survey_id`, `fund_id`, `e2ee_decrypted_content`)
  /// back onto the returned [SnChatMessage].
  Future<SnChatMessage> decryptMessageAndApply(
    SnChatMessage message, {
    String? existingDbContent,
    String? pendingContent,
  }) async {
    if (!_isE2eeRoom || _mlsGroupId == null || _mlsGroupId.isEmpty) {
      return message;
    }

    if (message.content != null && message.content!.isNotEmpty) {
      final updatedMeta = Map<String, dynamic>.from(message.meta);
      updatedMeta['e2ee_decrypted_content'] = message.content;
      return message.copyWith(meta: updatedMeta);
    }

    final existingDecrypted = message.meta['e2ee_decrypted_content']
        ?.toString();
    if (existingDecrypted != null && existingDecrypted.isNotEmpty) {
      return message.copyWith(content: existingDecrypted);
    }

    final decrypted = await decryptMessage(message);
    if (decrypted != null && decrypted['_mls_control_processed'] != true) {
      final content = decrypted['content']?.toString();
      final repliedMessageId =
          decrypted['replied_message_id']?.toString() ??
          message.repliedMessageId;
      final forwardedMessageId =
          decrypted['forwarded_message_id']?.toString() ??
          message.forwardedMessageId;
      final threadId = decrypted['thread_id']?.toString() ?? message.threadId;
      final updatedMeta = Map<String, dynamic>.from(message.meta);
      if (content != null && content.isNotEmpty) {
        updatedMeta['e2ee_decrypted_content'] = content;
      }
      if (decrypted['attachments_id'] != null) {
        updatedMeta['attachments_id'] = decrypted['attachments_id'];
      }
      if (decrypted['replied_message_id'] != null) {
        updatedMeta['replied_message_id'] = decrypted['replied_message_id'];
      }
      if (decrypted['forwarded_message_id'] != null) {
        updatedMeta['forwarded_message_id'] = decrypted['forwarded_message_id'];
      }
      if (decrypted['survey_id'] != null) {
        updatedMeta['survey_id'] = decrypted['survey_id'];
      }
      if (decrypted['fund_id'] != null) {
        updatedMeta['fund_id'] = decrypted['fund_id'];
      }
      return message.copyWith(
        content: content ?? message.content,
        repliedMessageId: repliedMessageId,
        forwardedMessageId: forwardedMessageId,
        threadId: threadId,
        meta: updatedMeta,
      );
    }

    return preserveSenderPlaintext(
      message,
      existingDbContent: existingDbContent,
      pendingContent: pendingContent,
    );
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
