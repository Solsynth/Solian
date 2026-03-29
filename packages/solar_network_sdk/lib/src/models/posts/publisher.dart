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
    SnCloudFile? picture,
    SnCloudFile? background,
    SnAccount? account,
    String? accountId,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
    DateTime? deletedAt,
    String? realmId,
    SnVerificationMark? verification,
    @Default(false) bool followRequiresApproval,
    @Default(false) bool postsRequireFollow,
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
    SnPublisherFollowStatus? subscription,
    SnPublisherFollowRequest? followRequest,
    @Default(false) bool requiresApproval,
    @Default('none') String status,
    @Default('') String message,
  }) = _SnPublisherSubscriptionStatus;

  factory SnPublisherSubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherSubscriptionStatusFromJson(json);
}
