import 'package:freezed_annotation/freezed_annotation.dart';

part 'activitypub.freezed.dart';
part 'activitypub.g.dart';

@freezed
sealed class SnActivityPubInstance with _$SnActivityPubInstance {
  const factory SnActivityPubInstance({
    required String id,
    required String domain,
    String? name,
    String? description,
    String? software,
    String? version,
    String? iconUrl,
    String? thumbnailUrl,
    String? contactEmail,
    String? contactAccountUsername,
    int? activeUsers,
    @Default(false) bool isBlocked,
    @Default(false) bool isSilenced,
    String? blockReason,
    Map<String, dynamic>? metadata,
    DateTime? lastFetchedAt,
    DateTime? lastActivityAt,
    DateTime? metadataFetchedAt,
  }) = _SnActivityPubInstance;

  factory SnActivityPubInstance.fromJson(Map<String, dynamic> json) =>
      _$SnActivityPubInstanceFromJson(json);
}

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
    required String username,
    required String instanceDomain,
    required SnActivityPubInstance instance,
    @Default('Person') String type,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? headerUrl,
    String? webUrl,
    @Default(false) bool isBot,
    @Default(false) bool isLocked,
    @Default(true) bool isDiscoverable,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    DateTime? lastActivityAt,
    DateTime? lastFetchedAt,
    Map<String, dynamic>? metadata,
    bool? isFollowing,
  }) = _SnActivityPubActor;

  factory SnActivityPubActor.fromJson(Map<String, dynamic> json) =>
      _$SnActivityPubActorFromJson(json);
}

@freezed
sealed class SnActivityPubFollowResponse with _$SnActivityPubFollowResponse {
  const factory SnActivityPubFollowResponse({
    required bool success,
    required String message,
  }) = _SnActivityPubFollowResponse;

  factory SnActivityPubFollowResponse.fromJson(Map<String, dynamic> json) =>
      _$SnActivityPubFollowResponseFromJson(json);
}

@freezed
sealed class SnActorStatusResponse with _$SnActorStatusResponse {
  const factory SnActorStatusResponse({
    required bool enabled,
    @Default(0) int followerCount,
    SnActivityPubActor? actor,
    String? actorUri,
  }) = _SnActorStatusResponse;

  factory SnActorStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$SnActorStatusResponseFromJson(json);
}
