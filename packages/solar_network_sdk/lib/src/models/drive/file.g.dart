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

_SnFileReplica _$SnFileReplicaFromJson(Map<String, dynamic> json) =>
    _SnFileReplica(
      id: json['id'] as String,
      objectId: json['object_id'] as String,
      poolId: json['pool_id'] as String,
      pool: json['pool'] == null
          ? null
          : SnFilePool.fromJson(json['pool'] as Map<String, dynamic>),
      storageId: json['storage_id'] as String,
      status: (json['status'] as num).toInt(),
      isPrimary: json['is_primary'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnFileReplicaToJson(_SnFileReplica instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object_id': instance.objectId,
      'pool_id': instance.poolId,
      'pool': instance.pool?.toJson(),
      'storage_id': instance.storageId,
      'status': instance.status,
      'is_primary': instance.isPrimary,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnCloudFileObject _$SnCloudFileObjectFromJson(Map<String, dynamic> json) =>
    _SnCloudFileObject(
      id: json['id'] as String,
      size: (json['size'] as num).toInt(),
      meta: json['meta'] as Map<String, dynamic>?,
      mimeType: json['mime_type'] as String?,
      hash: json['hash'] as String?,
      hasCompression: json['has_compression'] as bool,
      hasThumbnail: json['has_thumbnail'] as bool,
      fileReplicas: (json['file_replicas'] as List<dynamic>)
          .map((e) => SnFileReplica.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnCloudFileObjectToJson(_SnCloudFileObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'size': instance.size,
      'meta': instance.meta,
      'mime_type': instance.mimeType,
      'hash': instance.hash,
      'has_compression': instance.hasCompression,
      'has_thumbnail': instance.hasThumbnail,
      'file_replicas': instance.fileReplicas.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnCloudFile _$SnCloudFileFromJson(Map<String, dynamic> json) => _SnCloudFile(
  id: json['id'] as String,
  accountId: json['account_id'] as String,
  description: json['description'] as String?,
  indexed: json['indexed'] as bool,
  isFolder: json['is_folder'] as bool,
  isMarkedRecycle: json['is_marked_recycle'] as bool,
  name: json['name'] as String,
  object: json['object'] == null
      ? null
      : SnCloudFileObject.fromJson(json['object'] as Map<String, dynamic>),
  objectId: json['object_id'] as String?,
  parentId: json['parent_id'] as String?,
  resourceIdentifier: json['resource_identifier'] as String,
  storageId: json['storage_id'] as String?,
  storageUrl: json['storage_url'] as String?,
  mimeType: json['mime_type'] as String,
  applicationType: json['application_type'] as String?,
  usage: json['usage'] as String?,
  sensitiveMarks:
      (json['sensitive_marks'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  fileMeta: json['file_meta'] as Map<String, dynamic>? ?? const {},
  userMeta: json['user_meta'] as Map<String, dynamic>? ?? const {},
  uploadedAt: json['uploaded_at'] == null
      ? null
      : DateTime.parse(json['uploaded_at'] as String),
  expiredAt: json['expired_at'] == null
      ? null
      : DateTime.parse(json['expired_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnCloudFileToJson(_SnCloudFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'description': instance.description,
      'indexed': instance.indexed,
      'is_folder': instance.isFolder,
      'is_marked_recycle': instance.isMarkedRecycle,
      'name': instance.name,
      'object': instance.object?.toJson(),
      'object_id': instance.objectId,
      'parent_id': instance.parentId,
      'resource_identifier': instance.resourceIdentifier,
      'storage_id': instance.storageId,
      'storage_url': instance.storageUrl,
      'mime_type': instance.mimeType,
      'application_type': instance.applicationType,
      'usage': instance.usage,
      'sensitive_marks': instance.sensitiveMarks,
      'file_meta': instance.fileMeta,
      'user_meta': instance.userMeta,
      'uploaded_at': instance.uploadedAt?.toIso8601String(),
      'expired_at': instance.expiredAt?.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnCloudFileReference _$SnCloudFileReferenceFromJson(
  Map<String, dynamic> json,
) => _SnCloudFileReference(
  id: json['id'] as String,
  name: json['name'] as String,
  fileMeta: json['file_meta'] as Map<String, dynamic>? ?? const {},
  userMeta: json['user_meta'] as Map<String, dynamic>? ?? const {},
  sensitiveMarks:
      (json['sensitive_marks'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  mimeType: json['mime_type'] as String,
  hash: json['hash'] as String,
  size: (json['size'] as num).toInt(),
  hasCompression: json['has_compression'] as bool,
  storageUrl: json['url'] as String?,
  width: (json['width'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  blurhash: json['blurhash'] as String?,
  usage: json['usage'] as String?,
  applicationType: json['application_type'] as String?,
);

Map<String, dynamic> _$SnCloudFileReferenceToJson(
  _SnCloudFileReference instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'file_meta': instance.fileMeta,
  'user_meta': instance.userMeta,
  'sensitive_marks': instance.sensitiveMarks,
  'mime_type': instance.mimeType,
  'hash': instance.hash,
  'size': instance.size,
  'has_compression': instance.hasCompression,
  'url': instance.storageUrl,
  'width': instance.width,
  'height': instance.height,
  'blurhash': instance.blurhash,
  'usage': instance.usage,
  'application_type': instance.applicationType,
};
