// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnActivity _$SnActivityFromJson(Map<String, dynamic> json) => _SnActivity(
  id: json['id'] as String,
  type: json['type'] as String,
  resourceIdentifier: json['resource_identifier'] as String,
  data: json['data'],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnActivityToJson(_SnActivity instance) =>
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
      tips:
          (json['tips'] as List<dynamic>)
              .map((e) => SnFortuneTip.fromJson(e as Map<String, dynamic>))
              .toList(),
      accountId: json['account_id'] as String,
      account:
          json['account'] == null
              ? null
              : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
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
  checkInResult:
      json['check_in_result'] == null
          ? null
          : SnCheckInResult.fromJson(
            json['check_in_result'] as Map<String, dynamic>,
          ),
  statuses: json['statuses'] as List<dynamic>,
);

Map<String, dynamic> _$SnEventCalendarEntryToJson(
  _SnEventCalendarEntry instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'check_in_result': instance.checkInResult?.toJson(),
  'statuses': instance.statuses,
};
