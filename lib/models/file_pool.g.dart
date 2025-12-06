// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_pool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnFilePool _$SnFilePoolFromJson(Map<String, dynamic> json) => _SnFilePool(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  storageConfig: json['storage_config'] as Map<String, dynamic>?,
  billingConfig: json['billing_config'] as Map<String, dynamic>?,
  policyConfig: json['policy_config'] as Map<String, dynamic>?,
  isHidden: json['is_hidden'] as bool?,
  accountId: json['account_id'] as String?,
  resourceIdentifier: json['resource_identifier'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnFilePoolToJson(_SnFilePool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'storage_config': instance.storageConfig,
      'billing_config': instance.billingConfig,
      'policy_config': instance.policyConfig,
      'is_hidden': instance.isHidden,
      'account_id': instance.accountId,
      'resource_identifier': instance.resourceIdentifier,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
