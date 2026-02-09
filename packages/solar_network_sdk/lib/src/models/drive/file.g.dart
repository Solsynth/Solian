// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UniversalFile _$UniversalFileFromJson(Map<String, dynamic> json) =>
    _UniversalFile(
      data: json['data'],
      type: $enumDecode(_$UniversalFileTypeEnumMap, json['type']),
      isLink: json['isLink'] as bool? ?? false,
      displayName: json['displayName'] as String?,
    );

Map<String, dynamic> _$UniversalFileToJson(_UniversalFile instance) =>
    <String, dynamic>{
      'data': instance.data,
      'type': _$UniversalFileTypeEnumMap[instance.type]!,
      'isLink': instance.isLink,
      'displayName': instance.displayName,
    };

const _$UniversalFileTypeEnumMap = {
  UniversalFileType.image: 'image',
  UniversalFileType.video: 'video',
  UniversalFileType.audio: 'audio',
  UniversalFileType.file: 'file',
};

_SnFileReplica _$SnFileReplicaFromJson(Map<String, dynamic> json) =>
    _SnFileReplica(
      id: json['id'] as String,
      objectId: json['objectId'] as String,
      poolId: json['poolId'] as String,
      pool: json['pool'] == null
          ? null
          : SnFilePool.fromJson(json['pool'] as Map<String, dynamic>),
      storageId: json['storageId'] as String,
      status: (json['status'] as num).toInt(),
      isPrimary: json['isPrimary'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnFileReplicaToJson(_SnFileReplica instance) =>
    <String, dynamic>{
      'id': instance.id,
      'objectId': instance.objectId,
      'poolId': instance.poolId,
      'pool': instance.pool,
      'storageId': instance.storageId,
      'status': instance.status,
      'isPrimary': instance.isPrimary,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnCloudFileObject _$SnCloudFileObjectFromJson(Map<String, dynamic> json) =>
    _SnCloudFileObject(
      id: json['id'] as String,
      size: (json['size'] as num).toInt(),
      meta: json['meta'] as Map<String, dynamic>?,
      mimeType: json['mimeType'] as String?,
      hash: json['hash'] as String?,
      hasCompression: json['hasCompression'] as bool,
      hasThumbnail: json['hasThumbnail'] as bool,
      fileReplicas: (json['fileReplicas'] as List<dynamic>)
          .map((e) => SnFileReplica.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnCloudFileObjectToJson(_SnCloudFileObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'size': instance.size,
      'meta': instance.meta,
      'mimeType': instance.mimeType,
      'hash': instance.hash,
      'hasCompression': instance.hasCompression,
      'hasThumbnail': instance.hasThumbnail,
      'fileReplicas': instance.fileReplicas,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnCloudFile _$SnCloudFileFromJson(Map<String, dynamic> json) => _SnCloudFile(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  fileMeta: json['fileMeta'] as Map<String, dynamic>?,
  userMeta: json['userMeta'] as Map<String, dynamic>?,
  sensitiveMarks:
      (json['sensitiveMarks'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  mimeType: json['mimeType'] as String?,
  hash: json['hash'] as String?,
  size: (json['size'] as num).toInt(),
  uploadedAt: json['uploadedAt'] == null
      ? null
      : DateTime.parse(json['uploadedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  url: json['url'] as String?,
);

Map<String, dynamic> _$SnCloudFileToJson(_SnCloudFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'fileMeta': instance.fileMeta,
      'userMeta': instance.userMeta,
      'sensitiveMarks': instance.sensitiveMarks,
      'mimeType': instance.mimeType,
      'hash': instance.hash,
      'size': instance.size,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'url': instance.url,
    };

_SnCloudFileIndex _$SnCloudFileIndexFromJson(Map<String, dynamic> json) =>
    _SnCloudFileIndex(
      id: json['id'] as String,
      path: json['path'] as String,
      fileId: json['fileId'] as String,
      file: SnCloudFile.fromJson(json['file'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnCloudFileIndexToJson(_SnCloudFileIndex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'fileId': instance.fileId,
      'file': instance.file,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
