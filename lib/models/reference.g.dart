// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reference _$ReferenceFromJson(Map<String, dynamic> json) => _Reference(
  id: json['id'] as String,
  fileId: json['file_id'] as String,
  file: json['file'] == null
      ? null
      : SnCloudFile.fromJson(json['file'] as Map<String, dynamic>),
  usage: json['usage'] as String,
  resourceId: json['resource_id'] as String,
  expiredAt: json['expired_at'] == null
      ? null
      : DateTime.parse(json['expired_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$ReferenceToJson(_Reference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'file_id': instance.fileId,
      'file': instance.file?.toJson(),
      'usage': instance.usage,
      'resource_id': instance.resourceId,
      'expired_at': instance.expiredAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
