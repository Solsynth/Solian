import 'dart:async';
import 'package:island/core/tasks/app_task.dart';
import 'package:island/core/tasks/tasks_notifier.dart';
import 'package:island/core/websocket.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drive_task_ws_handler.g.dart';

@riverpod
class DriveTaskWsHandler extends _$DriveTaskWsHandler {
  StreamSubscription? _subscription;
  final Map<String, Map<String, dynamic>> _pendingUploads = {};

  @override
  void build() {
    final ws = ref.read(websocketProvider);
    _subscription = ws.dataStream.listen(_handlePacket);
    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  void storePendingUpload(
    String serverTaskId, {
    required String fileName,
    required String contentType,
    required int fileSize,
    required int totalChunks,
    String? poolId,
    String? encryptPassword,
    String? expiredAt,
  }) {
    _pendingUploads[serverTaskId] = {
      'file_name': fileName,
      'content_type': contentType,
      'file_size': fileSize,
      'total_chunks': totalChunks,
      'poolId': ?poolId,
      'encryptPassword': ?encryptPassword,
      'expiredAt': ?expiredAt,
    };
  }

  void _handlePacket(dynamic packet) {
    if (!packet.type.startsWith('task.') && packet.type != 'upload.completed') {
      return;
    }

    final data = packet.data;
    if (data == null && packet.type != 'upload.completed') return;

    Logger.root.info('[DriveTaskWs] Received: ${packet.type}, data: $data');

    final taskId = data != null ? (data['task_id'] as String?) : null;
    if (taskId == null && packet.type != 'upload.completed') return;

    switch (packet.type) {
      case 'task.created':
        _handleTaskCreated(taskId!, data);
        break;
      case 'task.progress':
        _handleProgressUpdate(taskId!, data);
        break;
      case 'task.completed':
        _handleCompleted(taskId!, data);
        break;
      case 'upload.completed':
        _handleUploadCompleted(data);
        break;
      case 'task.failed':
        _handleFailed(taskId!, data);
        break;
    }
  }

  void _handleTaskCreated(String serverTaskId, Map<String, dynamic> data) {
    final tasks = ref.read(tasksProvider.notifier);

    // Check if we already have a local task tracking this server task
    final existing = ref
        .read(tasksProvider)
        .where((t) => t.metadata?['serverTaskId'] == serverTaskId)
        .firstOrNull;
    if (existing != null) {
      tasks.updateTask(existing.id, status: AppTaskStatus.pending);
      return;
    }

    final metadata = _pendingUploads[serverTaskId];
    if (metadata != null) {
      final taskId = tasks.addTask(
        title: metadata['file_name'] as String,
        type: AppTaskType.driveUpload,
        status: AppTaskStatus.pending,
        metadata: {
          'serverTaskId': serverTaskId,
          'fileSize': metadata['file_size'],
          'totalChunks': metadata['total_chunks'],
          'uploadedChunks': 0,
          if (metadata['poolId'] != null) 'poolId': metadata['poolId'],
          if (metadata['encryptPassword'] != null)
            'encryptPassword': metadata['encryptPassword'],
          if (metadata['expiredAt'] != null) 'expiredAt': metadata['expiredAt'],
        },
      );
      _pendingUploads.remove(serverTaskId);
      Logger.root.info('[DriveTaskWs] Created task $taskId for $serverTaskId');
    } else {
      // No local metadata — create from server data
      final params = data['parameters'];
      tasks.addTask(
        title: params['file_name'] as String? ?? 'Unknown file',
        type: AppTaskType.driveUpload,
        status: AppTaskStatus.pending,
        metadata: {
          'serverTaskId': serverTaskId,
          'fileSize': params['file_size'] ?? 0,
          'totalChunks': params['chunks_count'] ?? 1,
          'uploadedChunks': params['chunks_uploaded'] ?? 0,
        },
      );
    }
  }

  void _handleProgressUpdate(String serverTaskId, Map<String, dynamic> data) {
    final task = _findTaskByServerId(serverTaskId);
    if (task == null) return;

    final progress = (data['progress'] as num? ?? 0.0) / 100.0;
    final tasks = ref.read(tasksProvider.notifier);
    final meta = Map<String, dynamic>.from(task.metadata ?? {});
    meta['uploadedChunks'] = (progress * (meta['totalChunks'] ?? 1)).round();

    tasks.updateTask(
      task.id,
      status: AppTaskStatus.inProgress,
      progress: progress,
      statusMessage: data['status'] as String?,
      metadata: meta,
    );
  }

  void _handleCompleted(String serverTaskId, Map<String, dynamic> data) {
    final task = _findTaskByServerId(serverTaskId);
    if (task == null) return;

    final results = data['results'] as Map<String, dynamic>?;
    ref
        .read(tasksProvider.notifier)
        .updateTask(
          task.id,
          status: AppTaskStatus.completed,
          progress: 1.0,
          result: results,
        );
  }

  void _handleUploadCompleted(Map<String, dynamic>? data) {
    final tasks = ref.read(tasksProvider.notifier);
    final serverTaskId = data?['task_id'] as String?;

    if (serverTaskId != null) {
      final task = _findTaskByServerId(serverTaskId);
      if (task != null) {
        tasks.updateTask(
          task.id,
          status: AppTaskStatus.completed,
          progress: 1.0,
          result: data?['results'] as Map<String, dynamic>?,
        );
        return;
      }
    }

    // Fallback: complete the last in-progress drive upload task
    final activeDriveTasks = ref
        .read(tasksProvider)
        .where(
          (t) =>
              t.type == AppTaskType.driveUpload &&
              t.status == AppTaskStatus.inProgress,
        )
        .toList();
    if (activeDriveTasks.isNotEmpty) {
      final task = activeDriveTasks.last;
      tasks.updateTask(task.id, status: AppTaskStatus.completed, progress: 1.0);
    }
  }

  void _handleFailed(String serverTaskId, Map<String, dynamic> data) {
    final task = _findTaskByServerId(serverTaskId);
    if (task == null) return;

    ref
        .read(tasksProvider.notifier)
        .updateTask(
          task.id,
          status: AppTaskStatus.failed,
          errorMessage: data['error_message'] as String? ?? 'Upload failed',
        );
  }

  AppTask? _findTaskByServerId(String serverTaskId) {
    return ref
        .read(tasksProvider)
        .where(
          (t) =>
              t.type == AppTaskType.driveUpload &&
              t.metadata?['serverTaskId'] == serverTaskId,
        )
        .firstOrNull;
  }
}
