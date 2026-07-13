// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_quota.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnProtectedTagRecord _$SnProtectedTagRecordFromJson(
  Map<String, dynamic> json,
) => _SnProtectedTagRecord(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String?,
  description: json['description'] as String?,
  isProtected: json['is_protected'] as bool? ?? false,
  isEvent: json['is_event'] as bool? ?? false,
  eventEndsAt: json['event_ends_at'] == null
      ? null
      : DateTime.parse(json['event_ends_at'] as String),
);

Map<String, dynamic> _$SnProtectedTagRecordToJson(
  _SnProtectedTagRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'description': instance.description,
  'is_protected': instance.isProtected,
  'is_event': instance.isEvent,
  'event_ends_at': instance.eventEndsAt?.toIso8601String(),
};

_SnTagQuota _$SnTagQuotaFromJson(Map<String, dynamic> json) => _SnTagQuota(
  total: (json['total'] as num).toInt(),
  used: (json['used'] as num).toInt(),
  remaining: (json['remaining'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  perkLevel: (json['perk_level'] as num).toInt(),
  records: (json['records'] as List<dynamic>)
      .map((e) => SnProtectedTagRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SnTagQuotaToJson(_SnTagQuota instance) =>
    <String, dynamic>{
      'total': instance.total,
      'used': instance.used,
      'remaining': instance.remaining,
      'level': instance.level,
      'perk_level': instance.perkLevel,
      'records': instance.records.map((e) => e.toJson()).toList(),
    };
