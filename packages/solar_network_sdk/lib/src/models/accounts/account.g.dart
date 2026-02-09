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
  isSuperuser: json['isSuperuser'] as bool,
  automatedId: json['automatedId'] as String?,
  profile: SnAccountProfile.fromJson(json['profile'] as Map<String, dynamic>),
  perkSubscription: json['perkSubscription'] == null
      ? null
      : SnWalletSubscriptionRef.fromJson(
          json['perkSubscription'] as Map<String, dynamic>,
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
  activatedAt: json['activatedAt'] == null
      ? null
      : DateTime.parse(json['activatedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$SnAccountToJson(_SnAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nick': instance.nick,
      'language': instance.language,
      'region': instance.region,
      'isSuperuser': instance.isSuperuser,
      'automatedId': instance.automatedId,
      'profile': instance.profile,
      'perkSubscription': instance.perkSubscription,
      'badges': instance.badges,
      'contacts': instance.contacts,
      'activatedAt': instance.activatedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
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
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UsernameColorToJson(_UsernameColor instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'direction': instance.direction,
      'colors': instance.colors,
    };

_SnAccountProfile _$SnAccountProfileFromJson(
  Map<String, dynamic> json,
) => _SnAccountProfile(
  id: json['id'] as String,
  firstName: json['firstName'] as String? ?? '',
  middleName: json['middleName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  bio: json['bio'] as String? ?? '',
  gender: json['gender'] as String? ?? '',
  pronouns: json['pronouns'] as String? ?? '',
  location: json['location'] as String? ?? '',
  timeZone: json['timeZone'] as String? ?? '',
  birthday: json['birthday'] == null
      ? null
      : DateTime.parse(json['birthday'] as String),
  links: json['links'] == null
      ? const []
      : const ProfileLinkConverter().fromJson(json['links']),
  lastSeenAt: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
  activeBadge: json['activeBadge'] == null
      ? null
      : SnAccountBadge.fromJson(json['activeBadge'] as Map<String, dynamic>),
  experience: (json['experience'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  socialCredits: (json['socialCredits'] as num?)?.toDouble() ?? 100,
  socialCreditsLevel: (json['socialCreditsLevel'] as num?)?.toInt() ?? 0,
  levelingProgress: (json['levelingProgress'] as num).toDouble(),
  picture: json['picture'] == null
      ? null
      : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background: json['background'] == null
      ? null
      : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  verification: json['verification'] == null
      ? null
      : SnVerificationMark.fromJson(
          json['verification'] as Map<String, dynamic>,
        ),
  usernameColor: json['usernameColor'] == null
      ? null
      : UsernameColor.fromJson(json['usernameColor'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$SnAccountProfileToJson(_SnAccountProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'bio': instance.bio,
      'gender': instance.gender,
      'pronouns': instance.pronouns,
      'location': instance.location,
      'timeZone': instance.timeZone,
      'birthday': instance.birthday?.toIso8601String(),
      'links': const ProfileLinkConverter().toJson(instance.links),
      'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
      'activeBadge': instance.activeBadge,
      'experience': instance.experience,
      'level': instance.level,
      'socialCredits': instance.socialCredits,
      'socialCreditsLevel': instance.socialCreditsLevel,
      'levelingProgress': instance.levelingProgress,
      'picture': instance.picture,
      'background': instance.background,
      'verification': instance.verification,
      'usernameColor': instance.usernameColor,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnAccountStatus _$SnAccountStatusFromJson(Map<String, dynamic> json) =>
    _SnAccountStatus(
      id: json['id'] as String,
      attitude: (json['attitude'] as num).toInt(),
      isOnline: json['isOnline'] as bool,
      isInvisible: json['isInvisible'] as bool,
      isNotDisturb: json['isNotDisturb'] as bool,
      isCustomized: json['isCustomized'] as bool,
      label: json['label'] as String? ?? "",
      meta: json['meta'] as Map<String, dynamic>?,
      clearedAt: json['clearedAt'] == null
          ? null
          : DateTime.parse(json['clearedAt'] as String),
      accountId: json['accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnAccountStatusToJson(_SnAccountStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attitude': instance.attitude,
      'isOnline': instance.isOnline,
      'isInvisible': instance.isInvisible,
      'isNotDisturb': instance.isNotDisturb,
      'isCustomized': instance.isCustomized,
      'label': instance.label,
      'meta': instance.meta,
      'clearedAt': instance.clearedAt?.toIso8601String(),
      'accountId': instance.accountId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnAccountBadge _$SnAccountBadgeFromJson(Map<String, dynamic> json) =>
    _SnAccountBadge(
      id: json['id'] as String,
      type: json['type'] as String,
      label: json['label'] as String?,
      caption: json['caption'] as String?,
      meta: json['meta'] as Map<String, dynamic>,
      expiredAt: json['expiredAt'] == null
          ? null
          : DateTime.parse(json['expiredAt'] as String),
      accountId: json['accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      activatedAt: json['activatedAt'] == null
          ? null
          : DateTime.parse(json['activatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnAccountBadgeToJson(_SnAccountBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'label': instance.label,
      'caption': instance.caption,
      'meta': instance.meta,
      'expiredAt': instance.expiredAt?.toIso8601String(),
      'accountId': instance.accountId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'activatedAt': instance.activatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnContactMethod _$SnContactMethodFromJson(Map<String, dynamic> json) =>
    _SnContactMethod(
      id: json['id'] as String,
      type: (json['type'] as num).toInt(),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      isPrimary: json['isPrimary'] as bool,
      isPublic: json['isPublic'] as bool,
      content: json['content'] as String,
      accountId: json['accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnContactMethodToJson(_SnContactMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'isPrimary': instance.isPrimary,
      'isPublic': instance.isPublic,
      'content': instance.content,
      'accountId': instance.accountId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnNotification _$SnNotificationFromJson(Map<String, dynamic> json) =>
    _SnNotification(
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      id: json['id'] as String,
      topic: json['topic'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      content: json['content'] as String,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      priority: (json['priority'] as num).toInt(),
      viewedAt: json['viewedAt'] == null
          ? null
          : DateTime.parse(json['viewedAt'] as String),
      accountId: json['accountId'] as String,
    );

Map<String, dynamic> _$SnNotificationToJson(_SnNotification instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'topic': instance.topic,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'content': instance.content,
      'meta': instance.meta,
      'priority': instance.priority,
      'viewedAt': instance.viewedAt?.toIso8601String(),
      'accountId': instance.accountId,
    };

_SnVerificationMark _$SnVerificationMarkFromJson(Map<String, dynamic> json) =>
    _SnVerificationMark(
      type: (json['type'] as num).toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      verifiedBy: json['verifiedBy'] as String?,
    );

Map<String, dynamic> _$SnVerificationMarkToJson(_SnVerificationMark instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'verifiedBy': instance.verifiedBy,
    };

_SnAuthDevice _$SnAuthDeviceFromJson(Map<String, dynamic> json) =>
    _SnAuthDevice(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      deviceLabel: json['deviceLabel'] as String?,
      accountId: json['accountId'] as String,
      platform: (json['platform'] as num).toInt(),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );

Map<String, dynamic> _$SnAuthDeviceToJson(_SnAuthDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'deviceLabel': instance.deviceLabel,
      'accountId': instance.accountId,
      'platform': instance.platform,
      'isCurrent': instance.isCurrent,
    };

_SnAuthDeviceWithSessione _$SnAuthDeviceWithSessioneFromJson(
  Map<String, dynamic> json,
) => _SnAuthDeviceWithSessione(
  id: json['id'] as String,
  deviceId: json['deviceId'] as String,
  deviceName: json['deviceName'] as String,
  deviceLabel: json['deviceLabel'] as String?,
  accountId: json['accountId'] as String,
  platform: (json['platform'] as num).toInt(),
  sessions: (json['sessions'] as List<dynamic>)
      .map((e) => SnAuthSession.fromJson(e as Map<String, dynamic>))
      .toList(),
  isCurrent: json['isCurrent'] as bool? ?? false,
);

Map<String, dynamic> _$SnAuthDeviceWithSessioneToJson(
  _SnAuthDeviceWithSessione instance,
) => <String, dynamic>{
  'id': instance.id,
  'deviceId': instance.deviceId,
  'deviceName': instance.deviceName,
  'deviceLabel': instance.deviceLabel,
  'accountId': instance.accountId,
  'platform': instance.platform,
  'sessions': instance.sessions,
  'isCurrent': instance.isCurrent,
};

_SnExperienceRecord _$SnExperienceRecordFromJson(Map<String, dynamic> json) =>
    _SnExperienceRecord(
      id: json['id'] as String,
      delta: (json['delta'] as num).toInt(),
      reasonType: json['reasonType'] as String,
      reason: json['reason'] as String,
      bonusMultiplier: (json['bonusMultiplier'] as num?)?.toDouble() ?? 1.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnExperienceRecordToJson(_SnExperienceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'delta': instance.delta,
      'reasonType': instance.reasonType,
      'reason': instance.reason,
      'bonusMultiplier': instance.bonusMultiplier,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnSocialCreditRecord _$SnSocialCreditRecordFromJson(
  Map<String, dynamic> json,
) => _SnSocialCreditRecord(
  id: json['id'] as String,
  delta: (json['delta'] as num).toDouble(),
  reasonType: json['reasonType'] as String,
  reason: json['reason'] as String,
  expiredAt: json['expiredAt'] == null
      ? null
      : DateTime.parse(json['expiredAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$SnSocialCreditRecordToJson(
  _SnSocialCreditRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'delta': instance.delta,
  'reasonType': instance.reasonType,
  'reason': instance.reason,
  'expiredAt': instance.expiredAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};

_SnFriendOverviewItem _$SnFriendOverviewItemFromJson(
  Map<String, dynamic> json,
) => _SnFriendOverviewItem(
  account: SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  status: SnAccountStatus.fromJson(json['status'] as Map<String, dynamic>),
  activities: (json['activities'] as List<dynamic>)
      .map((e) => SnPresenceActivity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SnFriendOverviewItemToJson(
  _SnFriendOverviewItem instance,
) => <String, dynamic>{
  'account': instance.account,
  'status': instance.status,
  'activities': instance.activities,
};
