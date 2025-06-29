// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'developer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeveloperStats _$DeveloperStatsFromJson(Map<String, dynamic> json) =>
    _DeveloperStats(
      totalCustomApps: (json['total_custom_apps'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DeveloperStatsToJson(_DeveloperStats instance) =>
    <String, dynamic>{'total_custom_apps': instance.totalCustomApps};
