// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadTask _$UploadTaskFromJson(Map<String, dynamic> json) => _UploadTask(
  id: json['id'] as String,
  taskId: json['task_id'] as String,
  fileName: json['file_name'] as String,
  contentType: json['content_type'] as String,
  fileSize: (json['file_size'] as num).toInt(),
  uploadedBytes: (json['uploaded_bytes'] as num).toInt(),
  totalChunks: (json['total_chunks'] as num).toInt(),
  uploadedChunks: (json['uploaded_chunks'] as num).toInt(),
  status: $enumDecode(_$UploadTaskStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  type: json['type'] as String,
  transmissionProgress: (json['transmission_progress'] as num?)?.toDouble(),
  errorMessage: json['error_message'] as String?,
  result:
      json['result'] == null
          ? null
          : SnCloudFile.fromJson(json['result'] as Map<String, dynamic>),
  poolId: json['pool_id'] as String?,
  bundleId: json['bundle_id'] as String?,
  encryptPassword: json['encrypt_password'] as String?,
  expiredAt: json['expired_at'] as String?,
);

Map<String, dynamic> _$UploadTaskToJson(_UploadTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'file_name': instance.fileName,
      'content_type': instance.contentType,
      'file_size': instance.fileSize,
      'uploaded_bytes': instance.uploadedBytes,
      'total_chunks': instance.totalChunks,
      'uploaded_chunks': instance.uploadedChunks,
      'status': _$UploadTaskStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'type': instance.type,
      'transmission_progress': instance.transmissionProgress,
      'error_message': instance.errorMessage,
      'result': instance.result?.toJson(),
      'pool_id': instance.poolId,
      'bundle_id': instance.bundleId,
      'encrypt_password': instance.encryptPassword,
      'expired_at': instance.expiredAt,
    };

const _$UploadTaskStatusEnumMap = {
  UploadTaskStatus.pending: 'pending',
  UploadTaskStatus.inProgress: 'inProgress',
  UploadTaskStatus.paused: 'paused',
  UploadTaskStatus.completed: 'completed',
  UploadTaskStatus.failed: 'failed',
  UploadTaskStatus.expired: 'expired',
  UploadTaskStatus.cancelled: 'cancelled',
};
