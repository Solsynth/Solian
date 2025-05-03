import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';
import 'package:island/models/realm.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
abstract class SnChat with _$SnChat {
  const factory SnChat({
    required int id,
    required String name,
    required String description,
    required int type,
    required bool isPublic,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required int? realmId,
    required SnRealm? realm,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnChat;

  factory SnChat.fromJson(Map<String, dynamic> json) => _$SnChatFromJson(json);
}

@freezed
abstract class SnChatMessage with _$SnChatMessage {
  const factory SnChatMessage({
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    required String id,
    String? content,
    String? nonce,
    @Default({}) Map<String, dynamic> meta,
    @Default([]) List<String> membersMetioned,
    DateTime? editedAt,
    @Default([]) List<SnCloudFile> attachments,
    @Default([]) List<SnChatReaction> reactions,
    String? repliedMessageId,
    SnChatMessage? repliedMessage,
    String? forwardedMessageId,
    SnChatMessage? forwardedMessage,
    required String senderId,
    required SnChatMember sender,
    required int chatRoomId,
  }) = _SnChatMessage;

  factory SnChatMessage.fromJson(Map<String, dynamic> json) =>
      _$SnChatMessageFromJson(json);
}

@freezed
abstract class SnChatReaction with _$SnChatReaction {
  const factory SnChatReaction({
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String id,
    required String messageId,
    required String senderId,
    required SnChatMember sender,
    required String symbol,
    required int attitude,
  }) = _SnChatReaction;

  factory SnChatReaction.fromJson(Map<String, dynamic> json) =>
      _$SnChatReactionFromJson(json);
}

@freezed
abstract class SnChatMember with _$SnChatMember {
  const factory SnChatMember({
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String id,
    required int chatRoomId,
    required int accountId,
    required String? nick,
    required int role,
    required int notify,
    required DateTime? joinedAt,
    required bool isBot,
  }) = _SnChatMember;

  factory SnChatMember.fromJson(Map<String, dynamic> json) =>
      _$SnChatMemberFromJson(json);
}
