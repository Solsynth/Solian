// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activitypub.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnActivityPubInstance _$SnActivityPubInstanceFromJson(
  Map<String, dynamic> json,
) => _SnActivityPubInstance(
  id: json['id'] as String,
  domain: json['domain'] as String,
  name: json['name'] as String?,
  description: json['description'] as String?,
  software: json['software'] as String?,
  version: json['version'] as String?,
  iconUrl: json['icon_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  contactEmail: json['contact_email'] as String?,
  contactAccountUsername: json['contact_account_username'] as String?,
  activeUsers: (json['active_users'] as num?)?.toInt(),
  isBlocked: json['is_blocked'] as bool? ?? false,
  isSilenced: json['is_silenced'] as bool? ?? false,
  blockReason: json['block_reason'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  lastFetchedAt: json['last_fetched_at'] == null
      ? null
      : DateTime.parse(json['last_fetched_at'] as String),
  lastActivityAt: json['last_activity_at'] == null
      ? null
      : DateTime.parse(json['last_activity_at'] as String),
  metadataFetchedAt: json['metadata_fetched_at'] == null
      ? null
      : DateTime.parse(json['metadata_fetched_at'] as String),
);

Map<String, dynamic> _$SnActivityPubInstanceToJson(
  _SnActivityPubInstance instance,
) => <String, dynamic>{
  'id': instance.id,
  'domain': instance.domain,
  'name': instance.name,
  'description': instance.description,
  'software': instance.software,
  'version': instance.version,
  'icon_url': instance.iconUrl,
  'thumbnail_url': instance.thumbnailUrl,
  'contact_email': instance.contactEmail,
  'contact_account_username': instance.contactAccountUsername,
  'active_users': instance.activeUsers,
  'is_blocked': instance.isBlocked,
  'is_silenced': instance.isSilenced,
  'block_reason': instance.blockReason,
  'metadata': instance.metadata,
  'last_fetched_at': instance.lastFetchedAt?.toIso8601String(),
  'last_activity_at': instance.lastActivityAt?.toIso8601String(),
  'metadata_fetched_at': instance.metadataFetchedAt?.toIso8601String(),
};

_SnActivityPubUser _$SnActivityPubUserFromJson(Map<String, dynamic> json) =>
    _SnActivityPubUser(
      actorUri: json['actor_uri'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      bio: json['bio'] as String,
      avatarUrl: json['avatar_url'] as String,
      followedAt: DateTime.parse(json['followed_at'] as String),
      isLocal: json['is_local'] as bool,
      instanceDomain: json['instance_domain'] as String,
    );

Map<String, dynamic> _$SnActivityPubUserToJson(_SnActivityPubUser instance) =>
    <String, dynamic>{
      'actor_uri': instance.actorUri,
      'username': instance.username,
      'display_name': instance.displayName,
      'bio': instance.bio,
      'avatar_url': instance.avatarUrl,
      'followed_at': instance.followedAt.toIso8601String(),
      'is_local': instance.isLocal,
      'instance_domain': instance.instanceDomain,
    };

_SnActivityPubActor _$SnActivityPubActorFromJson(Map<String, dynamic> json) =>
    _SnActivityPubActor(
      id: json['id'] as String,
      username: json['username'] as String,
      instanceDomain: json['instance_domain'] as String,
      instance: SnActivityPubInstance.fromJson(
        json['instance'] as Map<String, dynamic>,
      ),
      type: json['type'] as String? ?? 'Person',
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      headerUrl: json['header_url'] as String?,
      webUrl: json['web_url'] as String?,
      isBot: json['is_bot'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      isDiscoverable: json['is_discoverable'] as bool? ?? true,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      lastActivityAt: json['last_activity_at'] == null
          ? null
          : DateTime.parse(json['last_activity_at'] as String),
      lastFetchedAt: json['last_fetched_at'] == null
          ? null
          : DateTime.parse(json['last_fetched_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isFollowing: json['is_following'] as bool?,
    );

Map<String, dynamic> _$SnActivityPubActorToJson(_SnActivityPubActor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'instance_domain': instance.instanceDomain,
      'instance': instance.instance.toJson(),
      'type': instance.type,
      'display_name': instance.displayName,
      'bio': instance.bio,
      'avatar_url': instance.avatarUrl,
      'header_url': instance.headerUrl,
      'web_url': instance.webUrl,
      'is_bot': instance.isBot,
      'is_locked': instance.isLocked,
      'is_discoverable': instance.isDiscoverable,
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'last_activity_at': instance.lastActivityAt?.toIso8601String(),
      'last_fetched_at': instance.lastFetchedAt?.toIso8601String(),
      'metadata': instance.metadata,
      'is_following': instance.isFollowing,
    };

_SnActivityPubFollowResponse _$SnActivityPubFollowResponseFromJson(
  Map<String, dynamic> json,
) => _SnActivityPubFollowResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
);

Map<String, dynamic> _$SnActivityPubFollowResponseToJson(
  _SnActivityPubFollowResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

_SnActorStatusResponse _$SnActorStatusResponseFromJson(
  Map<String, dynamic> json,
) => _SnActorStatusResponse(
  enabled: json['enabled'] as bool,
  followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
  actor: json['actor'] == null
      ? null
      : SnActivityPubActor.fromJson(json['actor'] as Map<String, dynamic>),
  actorUri: json['actor_uri'] as String?,
);

Map<String, dynamic> _$SnActorStatusResponseToJson(
  _SnActorStatusResponse instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'follower_count': instance.followerCount,
  'actor': instance.actor?.toJson(),
  'actor_uri': instance.actorUri,
};
