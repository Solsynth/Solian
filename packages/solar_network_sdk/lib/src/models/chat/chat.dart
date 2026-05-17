import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';
import 'package:solar_network_sdk/src/models/drive/file.dart';
import 'package:solar_network_sdk/src/models/realms/realm.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
sealed class SnChatRoom with _$SnChatRoom {
  const factory SnChatRoom({
    required String id,
    required String? name,
    required String? description,
    required int type,
    @JsonKey(name: 'encryption_mode') @Default(0) int encryptionMode,
    @JsonKey(name: 'mls_group_id') String? mlsGroupId,
    @Default(false) bool isPublic,
    @Default(false) bool isCommunity,
    required SnCloudFileReference? picture,
    required SnCloudFileReference? background,
    required String? realmId,
    required String? accountId,
    required SnRealm? realm,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required List<SnChatMember>? members,
    // Frontend data
    @Default(false) bool isPinned,
  }) = _SnChatRoom;

  factory SnChatRoom.fromJson(Map<String, dynamic> json) =>
      _$SnChatRoomFromJson(json);
}

@freezed
sealed class SnChatMessage with _$SnChatMessage {
  const factory SnChatMessage({
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    required String id,
    @Default('text') String type,
    String? content,
    @JsonKey(name: 'client_message_id') String? clientMessageId,
    String? nonce,
    @Default({}) Map<String, dynamic> meta,
    @Default([]) List<String> membersMentioned,
    DateTime? editedAt,
    @Default([]) List<SnCloudFileReference> attachments,
    @Default([]) List<SnChatReaction> reactions,
    @JsonKey(name: 'reactions_count')
    @Default({})
    Map<String, int> reactionsCount,
    @JsonKey(name: 'reactions_made')
    @Default({})
    Map<String, bool> reactionsMade,
    String? repliedMessageId,
    String? forwardedMessageId,
    required String senderId,
    required SnChatMember sender,
    required String chatRoomId,
  }) = _SnChatMessage;

  factory SnChatMessage.fromJson(Map<String, dynamic> json) =>
      _$SnChatMessageFromJson(json);
}

@freezed
sealed class SnChatReaction with _$SnChatReaction {
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
sealed class SnChatMember with _$SnChatMember {
  const factory SnChatMember({
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String id,
    required String chatRoomId,
    required SnChatRoom? chatRoom,
    required String accountId,
    required SnAccount account,
    required String? nick,
    required int notify,
    required DateTime? joinedAt,
    required DateTime? breakUntil,
    required DateTime? timeoutUntil,
    required DateTime? lastReadAt,
    required SnAccountStatus? status,
    // Realm related-content
    required String? realmNick,
    required String? realmBio,
    required int? realmExperience,
    required int? realmLevel,
    required double? realmLevelingProgress,
    required SnRealmLabel? realmLabel,
    // Frontend data
    DateTime? lastTyped,
  }) = _SnChatMember;

  factory SnChatMember.fromJson(Map<String, dynamic> json) =>
      _$SnChatMemberFromJson(json);
}

@freezed
sealed class SnChatSummary with _$SnChatSummary {
  const factory SnChatSummary({
    required int unreadCount,
    required SnChatMessage? lastMessage,
  }) = _SnChatSummary;

  factory SnChatSummary.fromJson(Map<String, dynamic> json) =>
      _$SnChatSummaryFromJson(json);
}

@freezed
sealed class SnChatOnlineAccount with _$SnChatOnlineAccount {
  const factory SnChatOnlineAccount({
    required String id,
    required String name,
    required String nick,
  }) = _SnChatOnlineAccount;

  factory SnChatOnlineAccount.fromJson(Map<String, dynamic> json) =>
      _$SnChatOnlineAccountFromJson(json);
}

@freezed
sealed class SnChatOnlineStatus with _$SnChatOnlineStatus {
  const factory SnChatOnlineStatus({
    required int onlineCount,
    SnAccountStatus? directMessageStatus,
    @Default([]) List<String> onlineUserNames,
    @Default([]) List<SnChatOnlineAccount> onlineAccounts,
  }) = _SnChatOnlineStatus;

  factory SnChatOnlineStatus.fromJson(Map<String, dynamic> json) =>
      _$SnChatOnlineStatusFromJson(json);
}

class MessageChangeAction {
  static const String create = "create";
  static const String update = "update";
  static const String delete = "delete";
}

@freezed
sealed class MessageSyncResponse with _$MessageSyncResponse {
  const factory MessageSyncResponse({
    @Default([]) List<SnChatMessage> messages,
    @Default(0) int totalCount,
    required DateTime currentTimestamp,
  }) = _MessageSyncResponse;

  factory MessageSyncResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageSyncResponseFromJson(json);
}

@freezed
sealed class ChatRealtimeJoinResponse with _$ChatRealtimeJoinResponse {
  const factory ChatRealtimeJoinResponse({
    required String provider,
    required String endpoint,
    required String token,
    required String callId,
    required String roomName,
    required bool isAdmin,
    required List<CallParticipant> participants,
  }) = _ChatRealtimeJoinResponse;

  factory ChatRealtimeJoinResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatRealtimeJoinResponseFromJson(json);
}

@freezed
sealed class CallParticipant with _$CallParticipant {
  const factory CallParticipant({
    required String identity,
    required String name,
    required DateTime joinedAt,
  }) = _CallParticipant;

  factory CallParticipant.fromJson(Map<String, dynamic> json) =>
      _$CallParticipantFromJson(json);
}

@freezed
sealed class SnRealtimeCall with _$SnRealtimeCall {
  const factory SnRealtimeCall({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required DateTime? endedAt,
    required String senderId,
    required SnChatMember sender,
    required String roomId,
    required SnChatRoom room,
    required Map<String, dynamic> upstreamConfig,
    String? providerName,
    String? sessionId,
  }) = _SnRealtimeCall;

  factory SnRealtimeCall.fromJson(Map<String, dynamic> json) =>
      _$SnRealtimeCallFromJson(json);
}
