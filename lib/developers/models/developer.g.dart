// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'developer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnDeveloper _$SnDeveloperFromJson(Map<String, dynamic> json) => _SnDeveloper(
  id: json['id'] as String,
  publisherId: json['publisher_id'] as String,
  publisher: json['publisher'] == null
      ? null
      : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SnDeveloperToJson(_SnDeveloper instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publisher_id': instance.publisherId,
      'publisher': instance.publisher?.toJson(),
    };

_DeveloperStats _$DeveloperStatsFromJson(Map<String, dynamic> json) =>
    _DeveloperStats(
      totalCustomApps: (json['total_custom_apps'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DeveloperStatsToJson(_DeveloperStats instance) =>
    <String, dynamic>{'total_custom_apps': instance.totalCustomApps};
