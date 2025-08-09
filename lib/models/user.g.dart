// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAccount _$SnAccountFromJson(Map<String, dynamic> json) => _SnAccount(
  id: json['id'] as String,
  name: json['name'] as String,
  nick: json['nick'] as String,
  language: json['language'] as String,
  isSuperuser: json['is_superuser'] as bool,
  profile: SnAccountProfile.fromJson(json['profile'] as Map<String, dynamic>),
  perkSubscription:
      json['perk_subscription'] == null
          ? null
          : SnWalletSubscriptionRef.fromJson(
            json['perk_subscription'] as Map<String, dynamic>,
          ),
  badges:
      (json['badges'] as List<dynamic>?)
          ?.map((e) => SnAccountBadge.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnAccountToJson(_SnAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nick': instance.nick,
      'language': instance.language,
      'is_superuser': instance.isSuperuser,
      'profile': instance.profile.toJson(),
      'perk_subscription': instance.perkSubscription?.toJson(),
      'badges': instance.badges.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_ProfileLink _$ProfileLinkFromJson(Map<String, dynamic> json) =>
    _ProfileLink(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$ProfileLinkToJson(_ProfileLink instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_SnAccountProfile _$SnAccountProfileFromJson(Map<String, dynamic> json) =>
    _SnAccountProfile(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      middleName: json['middle_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      pronouns: json['pronouns'] as String? ?? '',
      location: json['location'] as String? ?? '',
      timeZone: json['time_zone'] as String? ?? '',
      birthday:
          json['birthday'] == null
              ? null
              : DateTime.parse(json['birthday'] as String),
      links:
          json['links'] == null
              ? const []
              : const ProfileLinkConverter().fromJson(json['links']),
      lastSeenAt:
          json['last_seen_at'] == null
              ? null
              : DateTime.parse(json['last_seen_at'] as String),
      activeBadge:
          json['active_badge'] == null
              ? null
              : SnAccountBadge.fromJson(
                json['active_badge'] as Map<String, dynamic>,
              ),
      experience: (json['experience'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      levelingProgress: (json['leveling_progress'] as num).toDouble(),
      picture:
          json['picture'] == null
              ? null
              : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
      background:
          json['background'] == null
              ? null
              : SnCloudFile.fromJson(
                json['background'] as Map<String, dynamic>,
              ),
      verification:
          json['verification'] == null
              ? null
              : SnVerificationMark.fromJson(
                json['verification'] as Map<String, dynamic>,
              ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAccountProfileToJson(_SnAccountProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'middle_name': instance.middleName,
      'last_name': instance.lastName,
      'bio': instance.bio,
      'gender': instance.gender,
      'pronouns': instance.pronouns,
      'location': instance.location,
      'time_zone': instance.timeZone,
      'birthday': instance.birthday?.toIso8601String(),
      'links': const ProfileLinkConverter().toJson(instance.links),
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'active_badge': instance.activeBadge?.toJson(),
      'experience': instance.experience,
      'level': instance.level,
      'leveling_progress': instance.levelingProgress,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'verification': instance.verification?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnAccountStatus _$SnAccountStatusFromJson(Map<String, dynamic> json) =>
    _SnAccountStatus(
      id: json['id'] as String,
      attitude: (json['attitude'] as num).toInt(),
      isOnline: json['is_online'] as bool,
      isInvisible: json['is_invisible'] as bool,
      isNotDisturb: json['is_not_disturb'] as bool,
      isCustomized: json['is_customized'] as bool,
      label: json['label'] as String? ?? "",
      clearedAt:
          json['cleared_at'] == null
              ? null
              : DateTime.parse(json['cleared_at'] as String),
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAccountStatusToJson(_SnAccountStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attitude': instance.attitude,
      'is_online': instance.isOnline,
      'is_invisible': instance.isInvisible,
      'is_not_disturb': instance.isNotDisturb,
      'is_customized': instance.isCustomized,
      'label': instance.label,
      'cleared_at': instance.clearedAt?.toIso8601String(),
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnAccountBadge _$SnAccountBadgeFromJson(Map<String, dynamic> json) =>
    _SnAccountBadge(
      id: json['id'] as String,
      type: json['type'] as String,
      label: json['label'] as String?,
      caption: json['caption'] as String?,
      meta: json['meta'] as Map<String, dynamic>,
      expiredAt:
          json['expired_at'] == null
              ? null
              : DateTime.parse(json['expired_at'] as String),
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      activatedAt:
          json['activated_at'] == null
              ? null
              : DateTime.parse(json['activated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAccountBadgeToJson(_SnAccountBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'label': instance.label,
      'caption': instance.caption,
      'meta': instance.meta,
      'expired_at': instance.expiredAt?.toIso8601String(),
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'activated_at': instance.activatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnContactMethod _$SnContactMethodFromJson(Map<String, dynamic> json) =>
    _SnContactMethod(
      id: json['id'] as String,
      type: (json['type'] as num).toInt(),
      verifiedAt:
          json['verified_at'] == null
              ? null
              : DateTime.parse(json['verified_at'] as String),
      isPrimary: json['is_primary'] as bool,
      content: json['content'] as String,
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnContactMethodToJson(_SnContactMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'verified_at': instance.verifiedAt?.toIso8601String(),
      'is_primary': instance.isPrimary,
      'content': instance.content,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnNotification _$SnNotificationFromJson(Map<String, dynamic> json) =>
    _SnNotification(
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
      id: json['id'] as String,
      topic: json['topic'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      content: json['content'] as String,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      priority: (json['priority'] as num).toInt(),
      viewedAt:
          json['viewed_at'] == null
              ? null
              : DateTime.parse(json['viewed_at'] as String),
      accountId: json['account_id'] as String,
    );

Map<String, dynamic> _$SnNotificationToJson(_SnNotification instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'topic': instance.topic,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'content': instance.content,
      'meta': instance.meta,
      'priority': instance.priority,
      'viewed_at': instance.viewedAt?.toIso8601String(),
      'account_id': instance.accountId,
    };

_SnVerificationMark _$SnVerificationMarkFromJson(Map<String, dynamic> json) =>
    _SnVerificationMark(
      type: (json['type'] as num).toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      verifiedBy: json['verified_by'] as String?,
    );

Map<String, dynamic> _$SnVerificationMarkToJson(_SnVerificationMark instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'verified_by': instance.verifiedBy,
    };
