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
  iconUrl: json['iconUrl'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  contactEmail: json['contactEmail'] as String?,
  contactAccountUsername: json['contactAccountUsername'] as String?,
  activeUsers: (json['activeUsers'] as num?)?.toInt(),
  isBlocked: json['isBlocked'] as bool? ?? false,
  isSilenced: json['isSilenced'] as bool? ?? false,
  blockReason: json['blockReason'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  lastFetchedAt: json['lastFetchedAt'] == null
      ? null
      : DateTime.parse(json['lastFetchedAt'] as String),
  lastActivityAt: json['lastActivityAt'] == null
      ? null
      : DateTime.parse(json['lastActivityAt'] as String),
  metadataFetchedAt: json['metadataFetchedAt'] == null
      ? null
      : DateTime.parse(json['metadataFetchedAt'] as String),
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
  'iconUrl': instance.iconUrl,
  'thumbnailUrl': instance.thumbnailUrl,
  'contactEmail': instance.contactEmail,
  'contactAccountUsername': instance.contactAccountUsername,
  'activeUsers': instance.activeUsers,
  'isBlocked': instance.isBlocked,
  'isSilenced': instance.isSilenced,
  'blockReason': instance.blockReason,
  'metadata': instance.metadata,
  'lastFetchedAt': instance.lastFetchedAt?.toIso8601String(),
  'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
  'metadataFetchedAt': instance.metadataFetchedAt?.toIso8601String(),
};

_SnActivityPubUser _$SnActivityPubUserFromJson(Map<String, dynamic> json) =>
    _SnActivityPubUser(
      actorUri: json['actorUri'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String,
      avatarUrl: json['avatarUrl'] as String,
      followedAt: DateTime.parse(json['followedAt'] as String),
      isLocal: json['isLocal'] as bool,
      instanceDomain: json['instanceDomain'] as String,
    );

Map<String, dynamic> _$SnActivityPubUserToJson(_SnActivityPubUser instance) =>
    <String, dynamic>{
      'actorUri': instance.actorUri,
      'username': instance.username,
      'displayName': instance.displayName,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'followedAt': instance.followedAt.toIso8601String(),
      'isLocal': instance.isLocal,
      'instanceDomain': instance.instanceDomain,
    };

_SnActivityPubActor _$SnActivityPubActorFromJson(Map<String, dynamic> json) =>
    _SnActivityPubActor(
      id: json['id'] as String,
      uri: json['uri'] as String,
      type: json['type'] as String? ?? '',
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      summary: json['summary'] as String?,
      inboxUri: json['inboxUri'] as String?,
      outboxUri: json['outboxUri'] as String?,
      followersUri: json['followersUri'] as String?,
      followingUri: json['followingUri'] as String?,
      featuredUri: json['featuredUri'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      headerUrl: json['headerUrl'] as String?,
      publicKeyId: json['publicKeyId'] as String?,
      publicKey: json['publicKey'] as String?,
      isBot: json['isBot'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      discoverable: json['discoverable'] as bool? ?? true,
      manuallyApprovesFollowers:
          json['manuallyApprovesFollowers'] as bool? ?? false,
      endpoints: json['endpoints'] as Map<String, dynamic>?,
      publicKeyData: json['publicKeyData'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      lastFetchedAt: json['lastFetchedAt'] == null
          ? null
          : DateTime.parse(json['lastFetchedAt'] as String),
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
      instance: SnActivityPubInstance.fromJson(
        json['instance'] as Map<String, dynamic>,
      ),
      instanceId: json['instanceId'] as String,
      isFollowing: json['isFollowing'] as bool?,
    );

Map<String, dynamic> _$SnActivityPubActorToJson(_SnActivityPubActor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uri': instance.uri,
      'type': instance.type,
      'displayName': instance.displayName,
      'username': instance.username,
      'summary': instance.summary,
      'inboxUri': instance.inboxUri,
      'outboxUri': instance.outboxUri,
      'followersUri': instance.followersUri,
      'followingUri': instance.followingUri,
      'featuredUri': instance.featuredUri,
      'avatarUrl': instance.avatarUrl,
      'headerUrl': instance.headerUrl,
      'publicKeyId': instance.publicKeyId,
      'publicKey': instance.publicKey,
      'isBot': instance.isBot,
      'isLocked': instance.isLocked,
      'discoverable': instance.discoverable,
      'manuallyApprovesFollowers': instance.manuallyApprovesFollowers,
      'endpoints': instance.endpoints,
      'publicKeyData': instance.publicKeyData,
      'metadata': instance.metadata,
      'lastFetchedAt': instance.lastFetchedAt?.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
      'instance': instance.instance,
      'instanceId': instance.instanceId,
      'isFollowing': instance.isFollowing,
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
  followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
  actor: json['actor'] == null
      ? null
      : SnActivityPubActor.fromJson(json['actor'] as Map<String, dynamic>),
  actorUri: json['actorUri'] as String?,
);

Map<String, dynamic> _$SnActorStatusResponseToJson(
  _SnActorStatusResponse instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'followerCount': instance.followerCount,
  'actor': instance.actor,
  'actorUri': instance.actorUri,
};
