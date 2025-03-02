// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnCheckInRecord _$SnCheckInRecordFromJson(Map<String, dynamic> json) =>
    _SnCheckInRecord(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      resultTier: (json['result_tier'] as num).toInt(),
      resultExperience: (json['result_experience'] as num).toInt(),
      resultCoin: (json['result_coin'] as num).toDouble(),
      resultModifiers: (json['result_modifiers'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      accountId: (json['account_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnCheckInRecordToJson(_SnCheckInRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'result_tier': instance.resultTier,
      'result_experience': instance.resultExperience,
      'result_coin': instance.resultCoin,
      'result_modifiers': instance.resultModifiers,
      'account_id': instance.accountId,
    };
