// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnNotableDay _$SnNotableDayFromJson(Map<String, dynamic> json) =>
    _SnNotableDay(
      date: DateTime.parse(json['date'] as String),
      localName: json['localName'] as String,
      globalName: json['globalName'] as String,
      countryCode: json['countryCode'] as String?,
      localizableKey: json['localizableKey'] as String?,
      holidays: (json['holidays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$SnNotableDayToJson(_SnNotableDay instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'localName': instance.localName,
      'globalName': instance.globalName,
      'countryCode': instance.countryCode,
      'localizableKey': instance.localizableKey,
      'holidays': instance.holidays,
    };

_SnTimelineEvent _$SnTimelineEventFromJson(Map<String, dynamic> json) =>
    _SnTimelineEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      resourceIdentifier: json['resourceIdentifier'] as String,
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnTimelineEventToJson(_SnTimelineEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'resourceIdentifier': instance.resourceIdentifier,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnCheckInResult _$SnCheckInResultFromJson(Map<String, dynamic> json) =>
    _SnCheckInResult(
      id: json['id'] as String,
      level: (json['level'] as num).toInt(),
      tips: (json['tips'] as List<dynamic>)
          .map((e) => SnFortuneTip.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountId: json['accountId'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnCheckInResultToJson(_SnCheckInResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'level': instance.level,
      'tips': instance.tips,
      'accountId': instance.accountId,
      'account': instance.account,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnFortuneTip _$SnFortuneTipFromJson(Map<String, dynamic> json) =>
    _SnFortuneTip(
      isPositive: json['isPositive'] as bool,
      title: json['title'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$SnFortuneTipToJson(_SnFortuneTip instance) =>
    <String, dynamic>{
      'isPositive': instance.isPositive,
      'title': instance.title,
      'content': instance.content,
    };

_SnEventCalendarEntry _$SnEventCalendarEntryFromJson(
  Map<String, dynamic> json,
) => _SnEventCalendarEntry(
  date: DateTime.parse(json['date'] as String),
  checkInResult: json['checkInResult'] == null
      ? null
      : SnCheckInResult.fromJson(json['checkInResult'] as Map<String, dynamic>),
  statuses: (json['statuses'] as List<dynamic>)
      .map((e) => SnAccountStatus.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SnEventCalendarEntryToJson(
  _SnEventCalendarEntry instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'checkInResult': instance.checkInResult,
  'statuses': instance.statuses,
};

_SnPresenceActivity _$SnPresenceActivityFromJson(Map<String, dynamic> json) =>
    _SnPresenceActivity(
      id: json['id'] as String,
      type: (json['type'] as num).toInt(),
      manualId: json['manualId'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      caption: json['caption'] as String?,
      titleUrl: json['titleUrl'] as String?,
      subtitleUrl: json['subtitleUrl'] as String?,
      smallImage: json['smallImage'] as String?,
      largeImage: json['largeImage'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
      leaseMinutes: (json['leaseMinutes'] as num).toInt(),
      leaseExpiresAt: DateTime.parse(json['leaseExpiresAt'] as String),
      accountId: json['accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnPresenceActivityToJson(_SnPresenceActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'manualId': instance.manualId,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'caption': instance.caption,
      'titleUrl': instance.titleUrl,
      'subtitleUrl': instance.subtitleUrl,
      'smallImage': instance.smallImage,
      'largeImage': instance.largeImage,
      'meta': instance.meta,
      'leaseMinutes': instance.leaseMinutes,
      'leaseExpiresAt': instance.leaseExpiresAt.toIso8601String(),
      'accountId': instance.accountId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
