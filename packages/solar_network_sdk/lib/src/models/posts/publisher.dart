import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'publisher.freezed.dart';
part 'publisher.g.dart';

enum FollowRequestState {
  @JsonValue(0)
  pending,
  @JsonValue(1)
  accepted,
  @JsonValue(2)
  rejected,
}

@freezed
sealed class SnPublisher with _$SnPublisher {
  const factory SnPublisher({
    @Default('') String id,
    @Default(0) int type,
    @Default('') String name,
    @Default('') String nick,
    @Default('') String bio,
    SnCloudFileReference? picture,
    SnCloudFileReference? background,
    SnAccount? account,
    String? accountId,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
    DateTime? deletedAt,
    String? realmId,
    SnRealm? realm,
    SnVerificationMark? verification,
    @Default(false) bool isShadowbanned,
    @Default(false) bool isGatekept,
    @Default(false) bool isModerateSubscription,
    @Default(100.0) double rating,
    @JsonKey(name: 'rating_level') @Default(0) int ratingLevel,
  }) = _SnPublisher;

  factory SnPublisher.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherFromJson(json);
}

@freezed
sealed class SnPublisherMember with _$SnPublisherMember {
  const factory SnPublisherMember({
    required String publisherId,
    required SnPublisher? publisher,
    required String accountId,
    required SnAccount? account,
    required int role,
    required DateTime? joinedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnPublisherMember;

  factory SnPublisherMember.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherMemberFromJson(json);
}

@freezed
sealed class SnPublisherFollowRequest with _$SnPublisherFollowRequest {
  const factory SnPublisherFollowRequest({
    required String id,
    required String publisherId,
    required String accountId,
    required FollowRequestState state,
    String? rejectReason,
    required DateTime createdAt,
    DateTime? reviewedAt,
    String? reviewedByAccountId,
    SnAccount? account,
  }) = _SnPublisherFollowRequest;

  factory SnPublisherFollowRequest.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherFollowRequestFromJson(json);
}

@freezed
sealed class SnPublisherFollowResponse with _$SnPublisherFollowResponse {
  const factory SnPublisherFollowResponse({
    String? requestId,
    FollowRequestState? state,
    String? message,
  }) = _SnPublisherFollowResponse;

  factory SnPublisherFollowResponse.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherFollowResponseFromJson(json);
}

@freezed
sealed class SnPublisherFollowRequestListResponse
    with _$SnPublisherFollowRequestListResponse {
  const factory SnPublisherFollowRequestListResponse({
    required List<SnPublisherFollowRequest> requests,
  }) = _SnPublisherFollowRequestListResponse;

  factory SnPublisherFollowRequestListResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$SnPublisherFollowRequestListResponseFromJson(json);
}

@freezed
sealed class SnPublisherFollowStatus with _$SnPublisherFollowStatus {
  const factory SnPublisherFollowStatus({
    @Default(false) bool isSubscribed,
    FollowRequestState? followRequestState,
    String? followRequestId,
  }) = _SnPublisherFollowStatus;

  factory SnPublisherFollowStatus.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherFollowStatusFromJson(json);
}

@freezed
sealed class SnPublisherSubscriptionStatus
    with _$SnPublisherSubscriptionStatus {
  const factory SnPublisherSubscriptionStatus({
    SnPublisherSubscription? subscription,
    SnPublisherFollowRequest? followRequest,
    @Default(false) bool requiresApproval,
    @Default('none') String status,
    @Default('') String message,
    @Default(false) bool isPending,
    @Default(false) bool isActive,
  }) = _SnPublisherSubscriptionStatus;

  factory SnPublisherSubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherSubscriptionStatusFromJson(json);
}

@freezed
sealed class SnPublisherSubscriber with _$SnPublisherSubscriber {
  const factory SnPublisherSubscriber({
    required SnPublisherSubscription subscription,
    required SnAccount? account,
  }) = _SnPublisherSubscriber;

  factory SnPublisherSubscriber.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherSubscriberFromJson(json);
}

enum SubscriptionEndReason {
  @JsonValue('UserLeft')
  userLeft,
  @JsonValue('RemovedByPublisher')
  removedByPublisher,
}

@freezed
sealed class SnPublisherSubscription with _$SnPublisherSubscription {
  const factory SnPublisherSubscription({
    required String id,
    required String publisherId,
    required String accountId,
    DateTime? lastReadAt,
    @Default(true) bool notify,
    DateTime? endedAt,
    SubscriptionEndReason? endReason,
    String? endedByAccountId,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SnPublisherSubscription;

  factory SnPublisherSubscription.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherSubscriptionFromJson(json);
}
