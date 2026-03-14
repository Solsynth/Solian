// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_quota_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RealmQuotaInfo _$RealmQuotaInfoFromJson(Map<String, dynamic> json) =>
    _RealmQuotaInfo(
      total: (json['total'] as num).toInt(),
      used: (json['used'] as num).toInt(),
      remaining: (json['remaining'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      perkLevel: (json['perk_level'] as num).toInt(),
      records: json['records'] as List<dynamic>,
    );

Map<String, dynamic> _$RealmQuotaInfoToJson(_RealmQuotaInfo instance) =>
    <String, dynamic>{
      'total': instance.total,
      'used': instance.used,
      'remaining': instance.remaining,
      'level': instance.level,
      'perk_level': instance.perkLevel,
      'records': instance.records,
    };
