// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activitypub.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      type: json['type'] as String? ?? '',
      displayName: json['display_name'] as String?,
      username: json['username'] as String?,
      summary: json['summary'] as String?,
      inboxUri: json['inbox_uri'] as String?,
      outboxUri: json['outbox_uri'] as String?,
      followersUri: json['followers_uri'] as String?,
      followingUri: json['following_uri'] as String?,
      featuredUri: json['featured_uri'] as String?,
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      publicKeyId: json['public_key_id'] as String?,
      publicKey: json['public_key'] as String?,
      isBot: json['is_bot'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      discoverable: json['discoverable'] as bool? ?? true,
      manuallyApprovesFollowers:
          json['manually_approves_followers'] as bool? ?? false,
      endpoints: json['endpoints'] as Map<String, dynamic>?,
      publicKeyData: json['public_key_data'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      lastFetchedAt: json['last_fetched_at'] == null
          ? null
          : DateTime.parse(json['last_fetched_at'] as String),
      lastActivityAt: json['last_activity_at'] == null
          ? null
          : DateTime.parse(json['last_activity_at'] as String),
    );

Map<String, dynamic> _$SnActivityPubActorToJson(_SnActivityPubActor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'display_name': instance.displayName,
      'username': instance.username,
      'summary': instance.summary,
      'inbox_uri': instance.inboxUri,
      'outbox_uri': instance.outboxUri,
      'followers_uri': instance.followersUri,
      'following_uri': instance.followingUri,
      'featured_uri': instance.featuredUri,
      'icon': instance.icon,
      'image': instance.image,
      'public_key_id': instance.publicKeyId,
      'public_key': instance.publicKey,
      'is_bot': instance.isBot,
      'is_locked': instance.isLocked,
      'discoverable': instance.discoverable,
      'manually_approves_followers': instance.manuallyApprovesFollowers,
      'endpoints': instance.endpoints,
      'public_key_data': instance.publicKeyData,
      'metadata': instance.metadata,
      'last_fetched_at': instance.lastFetchedAt?.toIso8601String(),
      'last_activity_at': instance.lastActivityAt?.toIso8601String(),
    };

_SnActivityPubFollowResponse _$SnActivityPubFollowResponseFromJson(
  Map<String, dynamic> json,
) => _SnActivityPubFollowResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  targetActorUri: json['target_actor_uri'] as String,
);

Map<String, dynamic> _$SnActivityPubFollowResponseToJson(
  _SnActivityPubFollowResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'target_actor_uri': instance.targetActorUri,
};
