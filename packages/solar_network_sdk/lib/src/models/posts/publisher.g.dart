// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPublisher _$SnPublisherFromJson(Map<String, dynamic> json) => _SnPublisher(
  id: json['id'] as String? ?? '',
  type: (json['type'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  nick: json['nick'] as String? ?? '',
  bio: json['bio'] as String? ?? '',
  picture: json['picture'] == null
      ? null
      : SnCloudFileReference.fromJson(json['picture'] as Map<String, dynamic>),
  background: json['background'] == null
      ? null
      : SnCloudFileReference.fromJson(
          json['background'] as Map<String, dynamic>,
        ),
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  accountId: json['account_id'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  realmId: json['realm_id'] as String?,
  realm: json['realm'] == null
      ? null
      : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
  verification: json['verification'] == null
      ? null
      : SnVerificationMark.fromJson(
          json['verification'] as Map<String, dynamic>,
        ),
  isShadowbanned: json['is_shadowbanned'] as bool? ?? false,
  isGatekept: json['is_gatekept'] as bool? ?? false,
  isModerateSubscription: json['is_moderate_subscription'] as bool? ?? false,
  rating: (json['rating'] as num?)?.toDouble() ?? 100.0,
  ratingLevel: (json['rating_level'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SnPublisherToJson(_SnPublisher instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'nick': instance.nick,
      'bio': instance.bio,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'account': instance.account?.toJson(),
      'account_id': instance.accountId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'realm_id': instance.realmId,
      'realm': instance.realm?.toJson(),
      'verification': instance.verification?.toJson(),
      'is_shadowbanned': instance.isShadowbanned,
      'is_gatekept': instance.isGatekept,
      'is_moderate_subscription': instance.isModerateSubscription,
      'rating': instance.rating,
      'rating_level': instance.ratingLevel,
    };

_SnPublisherMember _$SnPublisherMemberFromJson(Map<String, dynamic> json) =>
    _SnPublisherMember(
      publisherId: json['publisher_id'] as String,
      publisher: json['publisher'] == null
          ? null
          : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      role: (json['role'] as num).toInt(),
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnPublisherMemberToJson(_SnPublisherMember instance) =>
    <String, dynamic>{
      'publisher_id': instance.publisherId,
      'publisher': instance.publisher?.toJson(),
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'role': instance.role,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnPublisherFollowRequest _$SnPublisherFollowRequestFromJson(
  Map<String, dynamic> json,
) => _SnPublisherFollowRequest(
  id: json['id'] as String,
  publisherId: json['publisher_id'] as String,
  accountId: json['account_id'] as String,
  state: $enumDecode(_$FollowRequestStateEnumMap, json['state']),
  rejectReason: json['reject_reason'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  reviewedByAccountId: json['reviewed_by_account_id'] as String?,
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SnPublisherFollowRequestToJson(
  _SnPublisherFollowRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'publisher_id': instance.publisherId,
  'account_id': instance.accountId,
  'state': _$FollowRequestStateEnumMap[instance.state]!,
  'reject_reason': instance.rejectReason,
  'created_at': instance.createdAt.toIso8601String(),
  'reviewed_at': instance.reviewedAt?.toIso8601String(),
  'reviewed_by_account_id': instance.reviewedByAccountId,
  'account': instance.account?.toJson(),
};

const _$FollowRequestStateEnumMap = {
  FollowRequestState.pending: 0,
  FollowRequestState.accepted: 1,
  FollowRequestState.rejected: 2,
};

_SnPublisherFollowResponse _$SnPublisherFollowResponseFromJson(
  Map<String, dynamic> json,
) => _SnPublisherFollowResponse(
  requestId: json['request_id'] as String?,
  state: $enumDecodeNullable(_$FollowRequestStateEnumMap, json['state']),
  message: json['message'] as String?,
);

Map<String, dynamic> _$SnPublisherFollowResponseToJson(
  _SnPublisherFollowResponse instance,
) => <String, dynamic>{
  'request_id': instance.requestId,
  'state': _$FollowRequestStateEnumMap[instance.state],
  'message': instance.message,
};

_SnPublisherFollowRequestListResponse
_$SnPublisherFollowRequestListResponseFromJson(Map<String, dynamic> json) =>
    _SnPublisherFollowRequestListResponse(
      requests: (json['requests'] as List<dynamic>)
          .map(
            (e) => SnPublisherFollowRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$SnPublisherFollowRequestListResponseToJson(
  _SnPublisherFollowRequestListResponse instance,
) => <String, dynamic>{
  'requests': instance.requests.map((e) => e.toJson()).toList(),
};

_SnPublisherFollowStatus _$SnPublisherFollowStatusFromJson(
  Map<String, dynamic> json,
) => _SnPublisherFollowStatus(
  isSubscribed: json['is_subscribed'] as bool? ?? false,
  followRequestState: $enumDecodeNullable(
    _$FollowRequestStateEnumMap,
    json['follow_request_state'],
  ),
  followRequestId: json['follow_request_id'] as String?,
);

Map<String, dynamic> _$SnPublisherFollowStatusToJson(
  _SnPublisherFollowStatus instance,
) => <String, dynamic>{
  'is_subscribed': instance.isSubscribed,
  'follow_request_state':
      _$FollowRequestStateEnumMap[instance.followRequestState],
  'follow_request_id': instance.followRequestId,
};

_SnPublisherSubscriptionStatus _$SnPublisherSubscriptionStatusFromJson(
  Map<String, dynamic> json,
) => _SnPublisherSubscriptionStatus(
  subscription: json['subscription'] == null
      ? null
      : SnPublisherSubscription.fromJson(
          json['subscription'] as Map<String, dynamic>,
        ),
  followRequest: json['follow_request'] == null
      ? null
      : SnPublisherFollowRequest.fromJson(
          json['follow_request'] as Map<String, dynamic>,
        ),
  requiresApproval: json['requires_approval'] as bool? ?? false,
  status: json['status'] as String? ?? 'none',
  message: json['message'] as String? ?? '',
  isPending: json['is_pending'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? false,
);

Map<String, dynamic> _$SnPublisherSubscriptionStatusToJson(
  _SnPublisherSubscriptionStatus instance,
) => <String, dynamic>{
  'subscription': instance.subscription?.toJson(),
  'follow_request': instance.followRequest?.toJson(),
  'requires_approval': instance.requiresApproval,
  'status': instance.status,
  'message': instance.message,
  'is_pending': instance.isPending,
  'is_active': instance.isActive,
};

_SnPublisherSubscriber _$SnPublisherSubscriberFromJson(
  Map<String, dynamic> json,
) => _SnPublisherSubscriber(
  subscription: SnPublisherSubscription.fromJson(
    json['subscription'] as Map<String, dynamic>,
  ),
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SnPublisherSubscriberToJson(
  _SnPublisherSubscriber instance,
) => <String, dynamic>{
  'subscription': instance.subscription.toJson(),
  'account': instance.account?.toJson(),
};

_SnPublisherSubscription _$SnPublisherSubscriptionFromJson(
  Map<String, dynamic> json,
) => _SnPublisherSubscription(
  id: json['id'] as String,
  publisherId: json['publisher_id'] as String,
  accountId: json['account_id'] as String,
  lastReadAt: json['last_read_at'] == null
      ? null
      : DateTime.parse(json['last_read_at'] as String),
  notify: json['notify'] as bool? ?? true,
  endedAt: json['ended_at'] == null
      ? null
      : DateTime.parse(json['ended_at'] as String),
  endReason: $enumDecodeNullable(
    _$SubscriptionEndReasonEnumMap,
    json['end_reason'],
  ),
  endedByAccountId: json['ended_by_account_id'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SnPublisherSubscriptionToJson(
  _SnPublisherSubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'publisher_id': instance.publisherId,
  'account_id': instance.accountId,
  'last_read_at': instance.lastReadAt?.toIso8601String(),
  'notify': instance.notify,
  'ended_at': instance.endedAt?.toIso8601String(),
  'end_reason': _$SubscriptionEndReasonEnumMap[instance.endReason],
  'ended_by_account_id': instance.endedByAccountId,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$SubscriptionEndReasonEnumMap = {
  SubscriptionEndReason.userLeft: 'UserLeft',
  SubscriptionEndReason.removedByPublisher: 'RemovedByPublisher',
};
