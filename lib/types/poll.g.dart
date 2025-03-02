// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPoll _$SnPollFromJson(Map<String, dynamic> json) => _SnPoll(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'],
      expiredAt: json['expired_at'],
      options: (json['options'] as List<dynamic>)
          .map((e) => SnPollOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountId: (json['account_id'] as num).toInt(),
      metric: SnPollMetric.fromJson(json['metric'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnPollToJson(_SnPoll instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt,
      'expired_at': instance.expiredAt,
      'options': instance.options.map((e) => e.toJson()).toList(),
      'account_id': instance.accountId,
      'metric': instance.metric.toJson(),
    };

_SnPollMetric _$SnPollMetricFromJson(Map<String, dynamic> json) =>
    _SnPollMetric(
      totalAnswer: (json['total_answer'] as num).toInt(),
      byOptions: (json['by_options'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      byOptionsPercentage:
          (json['by_options_percentage'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toDouble()),
              ) ??
              const {},
    );

Map<String, dynamic> _$SnPollMetricToJson(_SnPollMetric instance) =>
    <String, dynamic>{
      'total_answer': instance.totalAnswer,
      'by_options': instance.byOptions,
      'by_options_percentage': instance.byOptionsPercentage,
    };

_SnPollOption _$SnPollOptionFromJson(Map<String, dynamic> json) =>
    _SnPollOption(
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$SnPollOptionToJson(_SnPollOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'name': instance.name,
      'description': instance.description,
    };
