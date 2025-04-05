import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surface/types/account.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/types/realm.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
abstract class SnChannel with _$SnChannel {
  const SnChannel._();

  const factory SnChannel({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required dynamic deletedAt,
    required String alias,
    required String name,
    required String description,
    required List<SnChannelMember>? members,
    List<SnChatMessage>? messages,
    required int type,
    required int accountId,
    required SnRealm? realm,
    required int? realmId,
    required bool isPublic,
    required bool isCommunity,
  }) = _SnChannel;

  factory SnChannel.fromJson(Map<String, dynamic> json) =>
      _$SnChannelFromJson(json);

  String get key => '${realm?.alias ?? 'global'}:$alias';
  String get keyPath => '${realm?.alias ?? 'global'}/$alias';
}

@freezed
abstract class SnChannelMember with _$SnChannelMember {
  const SnChannelMember._();

  const factory SnChannelMember({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required int channelId,
    required int accountId,
    required String? nick,
    required SnChannel? channel,
    required SnAccount? account,
    @Default(0) int notify,
    required int powerLevel,
    dynamic calls,
    dynamic events,
  }) = _SnChannelMember;

  factory SnChannelMember.fromJson(Map<String, dynamic> json) =>
      _$SnChannelMemberFromJson(json);
}

@freezed
abstract class SnChatMessage with _$SnChatMessage {
  const SnChatMessage._();

  const factory SnChatMessage({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String uuid,
    @Default({}) Map<String, dynamic> body,
    required String type,
    required SnChannel channel,
    required SnChannelMember sender,
    required int channelId,
    required int senderId,
    required int? quoteEventId,
    required int? relatedEventId,
    SnChatMessagePreload? preload,
  }) = _SnChatMessage;

  factory SnChatMessage.fromJson(Map<String, dynamic> json) =>
      _$SnChatMessageFromJson(json);
}

@freezed
abstract class SnChatMessagePreload with _$SnChatMessagePreload {
  const SnChatMessagePreload._();

  const factory SnChatMessagePreload({
    List<SnAttachment?>? attachments,
    SnChatMessage? quoteEvent,
  }) = _SnChatMessagePreload;

  factory SnChatMessagePreload.fromJson(Map<String, dynamic> json) =>
      _$SnChatMessagePreloadFromJson(json);
}

@freezed
abstract class SnChatCall with _$SnChatCall {
  const factory SnChatCall({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required DateTime? endedAt,
    required String externalId,
    required int founderId,
    required int channelId,
    required SnChannelMember founder,
    @Default([]) List<dynamic> participants,
  }) = _SnChatCall;

  factory SnChatCall.fromJson(Map<String, dynamic> json) =>
      _$SnChatCallFromJson(json);
}
