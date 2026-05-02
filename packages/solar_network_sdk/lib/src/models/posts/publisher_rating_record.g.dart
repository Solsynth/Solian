// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher_rating_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPublisherRatingRecord _$SnPublisherRatingRecordFromJson(
  Map<String, dynamic> json,
) => _SnPublisherRatingRecord(
  id: json['id'] as String,
  reasonType: json['reason_type'] as String,
  reason: json['reason'] as String,
  delta: (json['delta'] as num).toDouble(),
  status: $enumDecode(_$SnPublisherRatingStatusEnumMap, json['status']),
  expiredAt: json['expired_at'] == null
      ? null
      : DateTime.parse(json['expired_at'] as String),
  publisherId: json['publisher_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnPublisherRatingRecordToJson(
  _SnPublisherRatingRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'reason_type': instance.reasonType,
  'reason': instance.reason,
  'delta': instance.delta,
  'status': _$SnPublisherRatingStatusEnumMap[instance.status]!,
  'expired_at': instance.expiredAt?.toIso8601String(),
  'publisher_id': instance.publisherId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

const _$SnPublisherRatingStatusEnumMap = {
  SnPublisherRatingStatus.active: 0,
  SnPublisherRatingStatus.expired: 1,
};
