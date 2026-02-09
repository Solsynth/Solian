// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnRelationship _$SnRelationshipFromJson(Map<String, dynamic> json) =>
    _SnRelationship(
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      accountId: json['accountId'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      relatedId: json['relatedId'] as String,
      related: json['related'] == null
          ? null
          : SnAccount.fromJson(json['related'] as Map<String, dynamic>),
      expiredAt: json['expiredAt'] == null
          ? null
          : DateTime.parse(json['expiredAt'] as String),
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$SnRelationshipToJson(_SnRelationship instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'accountId': instance.accountId,
      'account': instance.account,
      'relatedId': instance.relatedId,
      'related': instance.related,
      'expiredAt': instance.expiredAt?.toIso8601String(),
      'status': instance.status,
    };
