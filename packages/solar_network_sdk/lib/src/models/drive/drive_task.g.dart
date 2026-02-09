// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriveTask _$DriveTaskFromJson(Map<String, dynamic> json) => _DriveTask(
  id: json['id'] as String,
  taskId: json['taskId'] as String,
  fileName: json['fileName'] as String,
  contentType: json['contentType'] as String,
  fileSize: (json['fileSize'] as num).toInt(),
  uploadedBytes: (json['uploadedBytes'] as num).toInt(),
  totalChunks: (json['totalChunks'] as num).toInt(),
  uploadedChunks: (json['uploadedChunks'] as num).toInt(),
  status: $enumDecode(_$DriveTaskStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  type: json['type'] as String,
  transmissionProgress: (json['transmissionProgress'] as num?)?.toDouble(),
  errorMessage: json['errorMessage'] as String?,
  statusMessage: json['statusMessage'] as String?,
  result: json['result'] == null
      ? null
      : SnCloudFile.fromJson(json['result'] as Map<String, dynamic>),
  poolId: json['poolId'] as String?,
  bundleId: json['bundleId'] as String?,
  encryptPassword: json['encryptPassword'] as String?,
  expiredAt: json['expiredAt'] as String?,
);

Map<String, dynamic> _$DriveTaskToJson(_DriveTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'fileSize': instance.fileSize,
      'uploadedBytes': instance.uploadedBytes,
      'totalChunks': instance.totalChunks,
      'uploadedChunks': instance.uploadedChunks,
      'status': _$DriveTaskStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'type': instance.type,
      'transmissionProgress': instance.transmissionProgress,
      'errorMessage': instance.errorMessage,
      'statusMessage': instance.statusMessage,
      'result': instance.result,
      'poolId': instance.poolId,
      'bundleId': instance.bundleId,
      'encryptPassword': instance.encryptPassword,
      'expiredAt': instance.expiredAt,
    };

const _$DriveTaskStatusEnumMap = {
  DriveTaskStatus.pending: 'pending',
  DriveTaskStatus.inProgress: 'inProgress',
  DriveTaskStatus.paused: 'paused',
  DriveTaskStatus.completed: 'completed',
  DriveTaskStatus.failed: 'failed',
  DriveTaskStatus.expired: 'expired',
  DriveTaskStatus.cancelled: 'cancelled',
};
