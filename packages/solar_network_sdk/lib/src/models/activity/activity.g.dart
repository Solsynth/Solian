// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnNotableDay _$SnNotableDayFromJson(Map<String, dynamic> json) =>
    _SnNotableDay(
      date: DateTime.parse(json['date'] as String),
      localName: json['local_name'] as String,
      globalName: json['global_name'] as String,
      countryCode: json['country_code'] as String?,
      localizableKey: json['localizable_key'] as String?,
      holidays: (json['holidays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$SnNotableDayToJson(_SnNotableDay instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'local_name': instance.localName,
      'global_name': instance.globalName,
      'country_code': instance.countryCode,
      'localizable_key': instance.localizableKey,
      'holidays': instance.holidays,
    };

_SnTimelineEvent _$SnTimelineEventFromJson(Map<String, dynamic> json) =>
    _SnTimelineEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      resourceIdentifier: json['resource_identifier'] as String,
      data: json['data'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnTimelineEventToJson(_SnTimelineEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'resource_identifier': instance.resourceIdentifier,
      'data': instance.data,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnCheckInResult _$SnCheckInResultFromJson(Map<String, dynamic> json) =>
    _SnCheckInResult(
      id: json['id'] as String,
      level: (json['level'] as num).toInt(),
      tips: (json['tips'] as List<dynamic>)
          .map((e) => SnFortuneTip.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnCheckInResultToJson(_SnCheckInResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'level': instance.level,
      'tips': instance.tips.map((e) => e.toJson()).toList(),
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnFortuneTip _$SnFortuneTipFromJson(Map<String, dynamic> json) =>
    _SnFortuneTip(
      isPositive: json['is_positive'] as bool,
      title: json['title'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$SnFortuneTipToJson(_SnFortuneTip instance) =>
    <String, dynamic>{
      'is_positive': instance.isPositive,
      'title': instance.title,
      'content': instance.content,
    };

_SnEventCalendarEntry _$SnEventCalendarEntryFromJson(
  Map<String, dynamic> json,
) => _SnEventCalendarEntry(
  date: DateTime.parse(json['date'] as String),
  checkInResult: json['check_in_result'] == null
      ? null
      : SnCheckInResult.fromJson(
          json['check_in_result'] as Map<String, dynamic>,
        ),
  statuses: (json['statuses'] as List<dynamic>)
      .map((e) => SnAccountStatus.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SnEventCalendarEntryToJson(
  _SnEventCalendarEntry instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'check_in_result': instance.checkInResult?.toJson(),
  'statuses': instance.statuses.map((e) => e.toJson()).toList(),
};

_SnPresenceActivity _$SnPresenceActivityFromJson(Map<String, dynamic> json) =>
    _SnPresenceActivity(
      id: json['id'] as String,
      type: (json['type'] as num).toInt(),
      manualId: json['manual_id'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      caption: json['caption'] as String?,
      titleUrl: json['title_url'] as String?,
      subtitleUrl: json['subtitle_url'] as String?,
      smallImage: json['small_image'] as String?,
      largeImage: json['large_image'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
      leaseMinutes: (json['lease_minutes'] as num).toInt(),
      leaseExpiresAt: DateTime.parse(json['lease_expires_at'] as String),
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnPresenceActivityToJson(_SnPresenceActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'manual_id': instance.manualId,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'caption': instance.caption,
      'title_url': instance.titleUrl,
      'subtitle_url': instance.subtitleUrl,
      'small_image': instance.smallImage,
      'large_image': instance.largeImage,
      'meta': instance.meta,
      'lease_minutes': instance.leaseMinutes,
      'lease_expires_at': instance.leaseExpiresAt.toIso8601String(),
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
