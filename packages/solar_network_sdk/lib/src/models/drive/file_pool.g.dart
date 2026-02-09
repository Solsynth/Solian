// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_pool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnFilePool _$SnFilePoolFromJson(Map<String, dynamic> json) => _SnFilePool(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  storageConfig: json['storageConfig'] as Map<String, dynamic>?,
  billingConfig: json['billingConfig'] as Map<String, dynamic>?,
  policyConfig: json['policyConfig'] as Map<String, dynamic>?,
  isHidden: json['isHidden'] as bool?,
  accountId: json['accountId'] as String?,
  resourceIdentifier: json['resourceIdentifier'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$SnFilePoolToJson(_SnFilePool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'storageConfig': instance.storageConfig,
      'billingConfig': instance.billingConfig,
      'policyConfig': instance.policyConfig,
      'isHidden': instance.isHidden,
      'accountId': instance.accountId,
      'resourceIdentifier': instance.resourceIdentifier,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
