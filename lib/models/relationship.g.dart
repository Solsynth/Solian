// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnRelationship _$SnRelationshipFromJson(Map<String, dynamic> json) =>
    _SnRelationship(
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      relatedId: json['related_id'] as String,
      related: json['related'] == null
          ? null
          : SnAccount.fromJson(json['related'] as Map<String, dynamic>),
      expiredAt: json['expired_at'] == null
          ? null
          : DateTime.parse(json['expired_at'] as String),
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$SnRelationshipToJson(_SnRelationship instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'related_id': instance.relatedId,
      'related': instance.related?.toJson(),
      'expired_at': instance.expiredAt?.toIso8601String(),
      'status': instance.status,
    };
