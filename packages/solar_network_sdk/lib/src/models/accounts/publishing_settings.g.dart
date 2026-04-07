// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publishing_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPublishingSettings _$SnPublishingSettingsFromJson(
  Map<String, dynamic> json,
) => _SnPublishingSettings(
  id: json['id'] as String,
  accountId: json['account_id'] as String,
  defaultPostingPublisherId: json['default_posting_publisher_id'] as String?,
  defaultReplyPublisherId: json['default_reply_publisher_id'] as String?,
  defaultFediversePublisherId:
      json['default_fediverse_publisher_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SnPublishingSettingsToJson(
  _SnPublishingSettings instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'default_posting_publisher_id': instance.defaultPostingPublisherId,
  'default_reply_publisher_id': instance.defaultReplyPublisherId,
  'default_fediverse_publisher_id': instance.defaultFediversePublisherId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_SnFediversePublisherAvailability _$SnFediversePublisherAvailabilityFromJson(
  Map<String, dynamic> json,
) => _SnFediversePublisherAvailability(
  publisherId: json['publisher_id'] as String,
  publisherName: json['publisher_name'] as String,
  fediverseHandle: json['fediverse_handle'] as String,
  fediverseUri: json['fediverse_uri'] as String,
  avatarUrl: json['avatar_url'] as String?,
  isEnabled: json['is_enabled'] as bool,
  followersCount: (json['followers_count'] as num).toInt(),
  followingCount: (json['following_count'] as num).toInt(),
  postsCount: (json['posts_count'] as num).toInt(),
);

Map<String, dynamic> _$SnFediversePublisherAvailabilityToJson(
  _SnFediversePublisherAvailability instance,
) => <String, dynamic>{
  'publisher_id': instance.publisherId,
  'publisher_name': instance.publisherName,
  'fediverse_handle': instance.fediverseHandle,
  'fediverse_uri': instance.fediverseUri,
  'avatar_url': instance.avatarUrl,
  'is_enabled': instance.isEnabled,
  'followers_count': instance.followersCount,
  'following_count': instance.followingCount,
  'posts_count': instance.postsCount,
};

_SnFediverseAvailabilityResponse _$SnFediverseAvailabilityResponseFromJson(
  Map<String, dynamic> json,
) => _SnFediverseAvailabilityResponse(
  isEnabled: json['is_enabled'] as bool,
  publishers: (json['publishers'] as List<dynamic>)
      .map(
        (e) => SnFediversePublisherAvailability.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$SnFediverseAvailabilityResponseToJson(
  _SnFediverseAvailabilityResponse instance,
) => <String, dynamic>{
  'is_enabled': instance.isEnabled,
  'publishers': instance.publishers.map((e) => e.toJson()).toList(),
};
