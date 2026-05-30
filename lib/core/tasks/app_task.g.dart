// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppTask _$AppTaskFromJson(Map<String, dynamic> json) => _AppTask(
  id: json['id'] as String,
  title: json['title'] as String,
  status: $enumDecode(_$AppTaskStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  type: json['type'] as String,
  progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
  statusMessage: json['status_message'] as String?,
  errorMessage: json['error_message'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  result: json['result'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AppTaskToJson(_AppTask instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': _$AppTaskStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'type': instance.type,
  'progress': instance.progress,
  'status_message': instance.statusMessage,
  'error_message': instance.errorMessage,
  'metadata': instance.metadata,
  'result': instance.result,
};

const _$AppTaskStatusEnumMap = {
  AppTaskStatus.pending: 'pending',
  AppTaskStatus.inProgress: 'inProgress',
  AppTaskStatus.paused: 'paused',
  AppTaskStatus.completed: 'completed',
  AppTaskStatus.failed: 'failed',
  AppTaskStatus.cancelled: 'cancelled',
  AppTaskStatus.expired: 'expired',
};
