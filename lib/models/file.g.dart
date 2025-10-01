// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UniversalFile _$UniversalFileFromJson(Map<String, dynamic> json) =>
    _UniversalFile(
      data: json['data'],
      type: $enumDecode(_$UniversalFileTypeEnumMap, json['type']),
      isLink: json['is_link'] as bool? ?? false,
      displayName: json['display_name'] as String?,
    );

Map<String, dynamic> _$UniversalFileToJson(_UniversalFile instance) =>
    <String, dynamic>{
      'data': instance.data,
      'type': _$UniversalFileTypeEnumMap[instance.type]!,
      'is_link': instance.isLink,
      'display_name': instance.displayName,
    };

const _$UniversalFileTypeEnumMap = {
  UniversalFileType.image: 'image',
  UniversalFileType.video: 'video',
  UniversalFileType.audio: 'audio',
  UniversalFileType.file: 'file',
};

_SnCloudFile _$SnCloudFileFromJson(Map<String, dynamic> json) => _SnCloudFile(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  fileMeta: json['file_meta'] as Map<String, dynamic>?,
  userMeta: json['user_meta'] as Map<String, dynamic>?,
  pool:
      json['pool'] == null
          ? null
          : SnFilePool.fromJson(json['pool'] as Map<String, dynamic>),
  sensitiveMarks:
      (json['sensitive_marks'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  mimeType: json['mime_type'] as String?,
  hash: json['hash'] as String?,
  size: (json['size'] as num).toInt(),
  uploadedAt:
      json['uploaded_at'] == null
          ? null
          : DateTime.parse(json['uploaded_at'] as String),
  uploadedTo: json['uploaded_to'] as String?,
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
      'pool': instance.pool?.toJson(),
      'sensitive_marks': instance.sensitiveMarks,
      'mime_type': instance.mimeType,
      'hash': instance.hash,
      'size': instance.size,
      'uploaded_at': instance.uploadedAt?.toIso8601String(),
      'uploaded_to': instance.uploadedTo,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
