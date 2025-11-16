// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAccount _$SnAccountFromJson(Map<String, dynamic> json) => _SnAccount(
  id: json['id'] as String,
  name: json['name'] as String,
  nick: json['nick'] as String,
  language: json['language'] as String,
  region: json['region'] as String? ?? "",
  isSuperuser: json['is_superuser'] as bool,
  automatedId: json['automated_id'] as String?,
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
  contacts:
      (json['contacts'] as List<dynamic>?)
          ?.map((e) => SnContactMethod.fromJson(e as Map<String, dynamic>))
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
      'region': instance.region,
      'is_superuser': instance.isSuperuser,
      'automated_id': instance.automatedId,
      'profile': instance.profile.toJson(),
      'perk_subscription': instance.perkSubscription?.toJson(),
      'badges': instance.badges.map((e) => e.toJson()).toList(),
      'contacts': instance.contacts.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_ProfileLink _$ProfileLinkFromJson(Map<String, dynamic> json) =>
    _ProfileLink(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$ProfileLinkToJson(_ProfileLink instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

_UsernameColor _$UsernameColorFromJson(Map<String, dynamic> json) =>
    _UsernameColor(
      type: json['type'] as String? ?? 'plain',
      value: json['value'] as String?,
      direction: json['direction'] as String?,
      colors:
          (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UsernameColorToJson(_UsernameColor instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'direction': instance.direction,
      'colors': instance.colors,
    };

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
      socialCredits: (json['social_credits'] as num?)?.toDouble() ?? 100,
      socialCreditsLevel: (json['social_credits_level'] as num?)?.toInt() ?? 0,
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
      usernameColor:
          json['username_color'] == null
              ? null
              : UsernameColor.fromJson(
                json['username_color'] as Map<String, dynamic>,
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
      'social_credits': instance.socialCredits,
      'social_credits_level': instance.socialCreditsLevel,
      'leveling_progress': instance.levelingProgress,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'verification': instance.verification?.toJson(),
      'username_color': instance.usernameColor?.toJson(),
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
      meta: json['meta'] as Map<String, dynamic>?,
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
      'meta': instance.meta,
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
      isPublic: json['is_public'] as bool,
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
      'is_public': instance.isPublic,
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

_SnAuthDevice _$SnAuthDeviceFromJson(Map<String, dynamic> json) =>
    _SnAuthDevice(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      deviceLabel: json['device_label'] as String?,
      accountId: json['account_id'] as String,
      platform: (json['platform'] as num).toInt(),
      isCurrent: json['is_current'] as bool? ?? false,
    );

Map<String, dynamic> _$SnAuthDeviceToJson(_SnAuthDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'device_name': instance.deviceName,
      'device_label': instance.deviceLabel,
      'account_id': instance.accountId,
      'platform': instance.platform,
      'is_current': instance.isCurrent,
    };

_SnAuthDeviceWithChallengee _$SnAuthDeviceWithChallengeeFromJson(
  Map<String, dynamic> json,
) => _SnAuthDeviceWithChallengee(
  id: json['id'] as String,
  deviceId: json['device_id'] as String,
  deviceName: json['device_name'] as String,
  deviceLabel: json['device_label'] as String?,
  accountId: json['account_id'] as String,
  platform: (json['platform'] as num).toInt(),
  challenges:
      (json['challenges'] as List<dynamic>)
          .map((e) => SnAuthChallenge.fromJson(e as Map<String, dynamic>))
          .toList(),
  isCurrent: json['is_current'] as bool? ?? false,
);

Map<String, dynamic> _$SnAuthDeviceWithChallengeeToJson(
  _SnAuthDeviceWithChallengee instance,
) => <String, dynamic>{
  'id': instance.id,
  'device_id': instance.deviceId,
  'device_name': instance.deviceName,
  'device_label': instance.deviceLabel,
  'account_id': instance.accountId,
  'platform': instance.platform,
  'challenges': instance.challenges.map((e) => e.toJson()).toList(),
  'is_current': instance.isCurrent,
};

_SnExperienceRecord _$SnExperienceRecordFromJson(Map<String, dynamic> json) =>
    _SnExperienceRecord(
      id: json['id'] as String,
      delta: (json['delta'] as num).toInt(),
      reasonType: json['reason_type'] as String,
      reason: json['reason'] as String,
      bonusMultiplier: (json['bonus_multiplier'] as num?)?.toDouble() ?? 1.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnExperienceRecordToJson(_SnExperienceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'delta': instance.delta,
      'reason_type': instance.reasonType,
      'reason': instance.reason,
      'bonus_multiplier': instance.bonusMultiplier,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnSocialCreditRecord _$SnSocialCreditRecordFromJson(
  Map<String, dynamic> json,
) => _SnSocialCreditRecord(
  id: json['id'] as String,
  delta: (json['delta'] as num).toDouble(),
  reasonType: json['reason_type'] as String,
  reason: json['reason'] as String,
  expiredAt:
      json['expired_at'] == null
          ? null
          : DateTime.parse(json['expired_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnSocialCreditRecordToJson(
  _SnSocialCreditRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'delta': instance.delta,
  'reason_type': instance.reasonType,
  'reason': instance.reason,
  'expired_at': instance.expiredAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SnFriendOverviewItem _$SnFriendOverviewItemFromJson(
  Map<String, dynamic> json,
) => _SnFriendOverviewItem(
  account: SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  status: SnAccountStatus.fromJson(json['status'] as Map<String, dynamic>),
  activities:
      (json['activities'] as List<dynamic>)
          .map((e) => SnPresenceActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$SnFriendOverviewItemToJson(
  _SnFriendOverviewItem instance,
) => <String, dynamic>{
  'account': instance.account.toJson(),
  'status': instance.status.toJson(),
  'activities': instance.activities.map((e) => e.toJson()).toList(),
};
