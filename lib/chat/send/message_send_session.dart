import 'package:island/data/message.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Result of sending a message.
class SendResult {
  final bool success;
  final LocalChatMessage? message;
  final LocalChatMessage? eventMessage;
  final String? error;

  const SendResult._(
    this.success, {
    this.message,
    this.eventMessage,
    this.error,
  });

  factory SendResult.success(
    LocalChatMessage message, {
    LocalChatMessage? eventMessage,
  }) => SendResult._(true, message: message, eventMessage: eventMessage);

  factory SendResult.failure(String error) => SendResult._(false, error: error);
}

/// Everything [MessageSender] needs to send one message.
///
/// The sender is configured with the room's encryption context when it is
/// created; this request only describes the message itself.
class MessageSendRequest {
  final String roomId;
  final String content;
  final List<UniversalFile> attachments;
  final SnChatMember sender;
  final List<Map<String, dynamic>>? embeds;
  final SnChatMessage? editingTo;
  final SnChatMessage? forwardingTo;
  final SnChatMessage? replyingTo;
  final SnChatMessage? threadingTo;
  final bool isVoice;
  final String? voiceFilePath;
  final int? voiceDurationMs;

  const MessageSendRequest({
    required this.roomId,
    required this.content,
    required this.attachments,
    required this.sender,
    this.embeds,
    this.editingTo,
    this.forwardingTo,
    this.replyingTo,
    this.threadingTo,
    this.isVoice = false,
    this.voiceFilePath,
    this.voiceDurationMs,
  });

  MessageSendRequest copyWith({
    String? roomId,
    String? content,
    List<UniversalFile>? attachments,
    SnChatMember? sender,
    List<Map<String, dynamic>>? embeds,
    SnChatMessage? editingTo,
    SnChatMessage? forwardingTo,
    SnChatMessage? replyingTo,
    SnChatMessage? threadingTo,
    bool? isVoice,
    String? voiceFilePath,
    int? voiceDurationMs,
  }) {
    return MessageSendRequest(
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      sender: sender ?? this.sender,
      embeds: embeds ?? this.embeds,
      editingTo: editingTo ?? this.editingTo,
      forwardingTo: forwardingTo ?? this.forwardingTo,
      replyingTo: replyingTo ?? this.replyingTo,
      threadingTo: threadingTo ?? this.threadingTo,
      isVoice: isVoice ?? this.isVoice,
      voiceFilePath: voiceFilePath ?? this.voiceFilePath,
      voiceDurationMs: voiceDurationMs ?? this.voiceDurationMs,
    );
  }
}

/// Upload progress reported by a send, grouped by attachment index.
class MessageUploadProgress {
  final String messageId;
  final Map<int, double?> attachments;

  const MessageUploadProgress(this.messageId, this.attachments);
}

/// A send in progress.
///
/// Callers observe three independent things instead of receiving callbacks:
/// * [pending] completes when the optimistic bubble exists,
/// * [progress] emits attachment progress, and
/// * [result] completes when the send settles.
class MessageSendSession {
  final Future<LocalChatMessage> pending;
  final Stream<MessageUploadProgress> progress;
  final Future<SendResult> result;

  const MessageSendSession({
    required this.pending,
    required this.progress,
    required this.result,
  });
}
