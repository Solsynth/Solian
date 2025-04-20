// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnCloudFile _$SnCloudFileFromJson(Map<String, dynamic> json) => _SnCloudFile(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  fileMeta: json['file_meta'] as Map<String, dynamic>?,
  userMeta: json['user_meta'] as Map<String, dynamic>?,
  mimeType: json['mime_type'] as String?,
  hash: json['hash'] as String?,
  size: (json['size'] as num).toInt(),
  uploadedAt: DateTime.parse(json['uploaded_at'] as String),
  uploadedTo: json['uploaded_to'] as String?,
  usedCount: (json['used_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnCloudFileToJson(_SnCloudFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'file_meta': instance.fileMeta,
      'user_meta': instance.userMeta,
      'mime_type': instance.mimeType,
      'hash': instance.hash,
      'size': instance.size,
      'uploaded_at': instance.uploadedAt.toIso8601String(),
      'uploaded_to': instance.uploadedTo,
      'used_count': instance.usedCount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
