import 'package:freezed_annotation/freezed_annotation.dart';

part 'activitypub.freezed.dart';
part 'activitypub.g.dart';

@freezed
sealed class SnActivityPubUser with _$SnActivityPubUser {
  const factory SnActivityPubUser({
    required String actorUri,
    required String username,
    required String displayName,
    required String bio,
    required String avatarUrl,
    required DateTime followedAt,
    required bool isLocal,
    required String instanceDomain,
  }) = _SnActivityPubUser;

  factory SnActivityPubUser.fromJson(Map<String, dynamic> json) =>
      _$SnActivityPubUserFromJson(json);
}

@freezed
sealed class SnActivityPubActor with _$SnActivityPubActor {
  const factory SnActivityPubActor({
    required String id,
    @Default('') String type,
    String? displayName,
    String? username,
    String? summary,
    String? inboxUri,
    String? outboxUri,
    String? followersUri,
    String? followingUri,
    String? featuredUri,
    String? icon,
    String? image,
    String? publicKeyId,
    String? publicKey,
    @Default(false) bool isBot,
    @Default(false) bool isLocked,
    @Default(true) bool discoverable,
    @Default(false) bool manuallyApprovesFollowers,
    Map<String, dynamic>? endpoints,
    Map<String, dynamic>? publicKeyData,
    Map<String, dynamic>? metadata,
    DateTime? lastFetchedAt,
    DateTime? lastActivityAt,
  }) = _SnActivityPubActor;

  factory SnActivityPubActor.fromJson(Map<String, dynamic> json) =>
      _$SnActivityPubActorFromJson(json);
}

@freezed
sealed class SnActivityPubFollowResponse with _$SnActivityPubFollowResponse {
  const factory SnActivityPubFollowResponse({
    required bool success,
    required String message,
    required String targetActorUri,
  }) = _SnActivityPubFollowResponse;

  factory SnActivityPubFollowResponse.fromJson(Map<String, dynamic> json) =>
      _$SnActivityPubFollowResponseFromJson(json);
}
