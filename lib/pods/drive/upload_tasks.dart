import 'dart:async';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/drive_task.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/services/file_uploader.dart';
import 'package:island/talker.dart';

final uploadTasksProvider = NotifierProvider(UploadTasksNotifier.new);

class UploadTasksNotifier extends Notifier<List<DriveTask>> {
  StreamSubscription? _websocketSubscription;
  final Map<String, Map<String, dynamic>> _pendingUploads = {};

  @override
  List<DriveTask> build() {
    _listenToWebSocket();
    return [];
  }

  void _listenToWebSocket() {
    final WebSocketService websocketService = ref.read(websocketProvider);
    _websocketSubscription = websocketService.dataStream.listen(
      _handleWebSocketPacket,
    );
  }

  void _handleWebSocketPacket(dynamic packet) {
    if (packet.type.startsWith('task.')) {
      final data = packet.data;
      if (data == null) return;

      // Debug logging
      talker.info(
        '[UploadTasks] Received WebSocket packet: ${packet.type}, data: $data',
      );

      final taskId = data['task_id'] as String?;
      if (taskId == null) return;

      switch (packet.type) {
        case 'task.created':
          _handleTaskCreated(taskId, data);
          break;
        case 'task.progress':
          _handleProgressUpdate(taskId, data);
          break;
        case 'task.completed':
          _handleUploadCompleted(taskId, data);
          break;
        case 'task.failed':
          _handleUploadFailed(taskId, data);
          break;
      }
    }
  }

  void _handleTaskCreated(String taskId, Map<String, dynamic> data) {
    talker.info('[UploadTasks] Handling task.created for taskId: $taskId');

    // Check if task already exists (might have been created locally)
    final existingTask =
        state.where((task) => task.taskId == taskId).firstOrNull;
    if (existingTask != null) {
      talker.info('[UploadTasks] Task already exists, updating status');
      // Task already exists, just update its status to confirm server creation
      state =
          state.map((task) {
            if (task.taskId == taskId) {
              return task.copyWith(
                status: DriveTaskStatus.pending,
                updatedAt: DateTime.now(),
              );
            }
            return task;
          }).toList();
      return;
    }

    // Check if we have stored metadata for this task
    final metadata = _pendingUploads[taskId];
    talker.info('[UploadTasks] Metadata for taskId $taskId: $metadata');

    if (metadata != null) {
      talker.info('[UploadTasks] Creating task with full metadata');
      // Create task with full metadata
      final uploadTask = DriveTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: taskId,
        fileName: metadata['file_name'] as String,
        contentType: metadata['mime_type'] as String,
        fileSize: metadata['file_size'] as int,
        uploadedBytes: 0,
        totalChunks: metadata['total_chunks'] as int,
        uploadedChunks: 0,
        status: DriveTaskStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: 'FileUpload',
        poolId: metadata['pool_id'] as String?,
        bundleId: metadata['bundleId'] as String?,
        encryptPassword: metadata['encrypt_password'] as String?,
        expiredAt: metadata['expired_at'] as String?,
      );

      state = [...state, uploadTask];
      talker.info(
        '[UploadTasks] Task created successfully. Total tasks: ${state.length}',
      );
      // Clean up stored metadata
      _pendingUploads.remove(taskId);
    } else {
      talker.info('[UploadTasks] No metadata found, creating minimal task');
      // Create minimal task if no metadata is stored
      final params = data['parameters'];
      final uploadTask = DriveTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: taskId,
        fileName: params['file_name'] as String? ?? 'Unknown file',
        contentType: params['content_type'],
        fileSize: params['file_size'],
        uploadedBytes:
            (params['chunk_size'] as int) * (params['chunks_uploaded'] as int),
        totalChunks: params['chunks_count'],
        uploadedChunks: params['chunks_uploaded'],
        status: DriveTaskStatus.pending,
        createdAt: DateTime.tryParse(data['created_at']) ?? DateTime.now(),
        updatedAt: DateTime.now(),
        type: data['type'],
      );

      state = [...state, uploadTask];
      talker.info(
        '[UploadTasks] Minimal task created. Total tasks: ${state.length}',
      );
    }
  }

  void _handleProgressUpdate(String taskId, Map<String, dynamic> data) {
    final progress = data['progress'] as num? ?? 0.0;

    state =
        state.map((task) {
          if (task.taskId == taskId) {
            final uploadedBytes = (progress / 100.0 * task.fileSize).toInt();
            return task.copyWith(
              statusMessage: data['status'],
              uploadedBytes: uploadedBytes,
              status: DriveTaskStatus.inProgress,
              updatedAt: DateTime.now(),
            );
          }
          return task;
        }).toList();
  }

  void _handleUploadCompleted(String taskId, Map<String, dynamic> data) {
    final results = data['results'] as Map<String, dynamic>?;

    state =
        state.map((task) {
          if (task.taskId == taskId) {
            return task.copyWith(
              status: DriveTaskStatus.completed,
              uploadedChunks: task.totalChunks,
              uploadedBytes: task.fileSize,
              // Update file information from Results if available
              fileName: results?['file_name'] as String? ?? task.fileName,
              fileSize: results?['file_size'] as int? ?? task.fileSize,
              contentType: results?['mime_type'] as String? ?? task.contentType,
              result:
                  results?['file_info'] != null
                      ? SnCloudFile.fromJson(results!['file_info'])
                      : null,
              updatedAt: DateTime.now(),
            );
          }
          return task;
        }).toList();
  }

  void _handleUploadFailed(String taskId, Map<String, dynamic> data) {
    final errorMessage = data['error_message'] as String? ?? 'Upload failed';

    state =
        state.map((task) {
          if (task.taskId == taskId) {
            return task.copyWith(
              status: DriveTaskStatus.failed,
              errorMessage: errorMessage,
              updatedAt: DateTime.now(),
            );
          }
          return task;
        }).toList();
  }

  void addUploadTask(DriveTask task) {
    state = [...state, task];
  }

  void storeUploadMetadata(
    String taskId, {
    required String fileName,
    required String contentType,
    required int fileSize,
    required int totalChunks,
    String? poolId,
    String? bundleId,
    String? encryptPassword,
    String? expiredAt,
  }) {
    _pendingUploads[taskId] = {
      'file_name': fileName,
      'mime_type': contentType,
      'file_size': fileSize,
      'total_chunks': totalChunks,
      'pool_id': poolId,
      'bundleId': bundleId,
      'encrypt_password': encryptPassword,
      'expired_at': expiredAt,
    };
  }

  void updateTaskStatus(
    String taskId,
    DriveTaskStatus status, {
    String? errorMessage,
  }) {
    state =
        state.map((task) {
          if (task.taskId == taskId) {
            return task.copyWith(
              status: status,
              errorMessage: errorMessage,
              updatedAt: DateTime.now(),
            );
          }
          return task;
        }).toList();
  }

  void updateTransmissionProgress(String taskId, double progress) {
    state =
        state.map((task) {
          if (task.taskId == taskId) {
            return task.copyWith(
              transmissionProgress: progress,
              updatedAt: DateTime.now(),
            );
          }
          return task;
        }).toList();
  }

  void updateDownloadProgress(
    String taskId,
    int downloadedBytes,
    int totalBytes,
  ) {
    state =
        state.map((task) {
          if (task.taskId == taskId) {
            return task.copyWith(
              fileSize: totalBytes,
              uploadedBytes: downloadedBytes,
              updatedAt: DateTime.now(),
            );
          }
          return task;
        }).toList();
  }

  void removeTask(String taskId) {
    state = state.where((task) => task.taskId != taskId).toList();
  }

  void clearCompletedTasks() {
    state =
        state
            .where(
              (task) =>
                  task.status != DriveTaskStatus.completed &&
                  task.status != DriveTaskStatus.failed &&
                  task.status != DriveTaskStatus.cancelled &&
                  task.status != DriveTaskStatus.expired,
            )
            .toList();
  }

  void clearAllTasks() {
    state = [];
  }

  DriveTask? getTask(String taskId) {
    return state.where((task) => task.taskId == taskId).firstOrNull;
  }

  List<DriveTask> getActiveTasks() {
    return state
        .where(
          (task) =>
              task.status == DriveTaskStatus.pending ||
              task.status == DriveTaskStatus.inProgress ||
              task.status == DriveTaskStatus.paused ||
              task.status == DriveTaskStatus.completed,
        )
        .toList();
  }

  String addLocalDownloadTask(SnCloudFile item) {
    final taskId =
        'download-${item.id}-${DateTime.now().millisecondsSinceEpoch}';
    final task = DriveTask(
      id: taskId,
      taskId: taskId,
      fileName: item.name,
      contentType: item.mimeType ?? '',
      fileSize: 0,
      uploadedBytes: 0,
      totalChunks: 1,
      uploadedChunks: 0,
      status: DriveTaskStatus.inProgress,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: 'FileDownload',
    );
    state = [...state, task];
    return taskId;
  }

  void dispose() {
    _websocketSubscription?.cancel();
  }
}

// Provider for the enhanced FileUploader that integrates with upload tasks
final enhancedFileUploaderProvider = Provider<EnhancedFileUploader>((ref) {
  final dio = ref.watch(apiClientProvider);
  return EnhancedFileUploader(dio, ref);
});

class EnhancedFileUploader extends FileUploader {
  final Ref ref;

  EnhancedFileUploader(super.client, this.ref);

  /// Reads the next chunk from a stream subscription.
  Future<Uint8List> _readNextChunkFromStream(
    StreamSubscription<List<int>> subscription,
    int size,
  ) async {
    final completer = Completer<Uint8List>();
    final buffer = <int>[];
    int remaining = size;

    void onData(List<int> data) {
      buffer.addAll(data);
      remaining -= data.length;
      if (remaining <= 0) {
        subscription.pause();
        completer.complete(Uint8List.fromList(buffer.sublist(0, size)));
      }
    }

    void onDone() {
      if (!completer.isCompleted) {
        completer.complete(Uint8List.fromList(buffer));
      }
    }

    subscription.onData(onData);
    subscription.onDone(onDone);

    return completer.future;
  }

  @override
  Future<SnCloudFile> uploadFile({
    required dynamic fileData,
    required String fileName,
    required String contentType,
    String? poolId,
    String? bundleId,
    String? encryptPassword,
    String? expiredAt,
    int? customChunkSize,
    String? path,
    Function(double? progress, Duration estimate)? onProgress,
  }) async {
    // Step 1: Create upload task
    onProgress?.call(null, Duration.zero);
    final createResponse = await createUploadTask(
      fileData: fileData,
      fileName: fileName,
      contentType: contentType,
      poolId: poolId,
      bundleId: bundleId,
      encryptPassword: encryptPassword,
      expiredAt: expiredAt,
      chunkSize: customChunkSize,
      path: path,
    );

    int totalSize;
    if (fileData is XFile) {
      totalSize = await fileData.length();
    } else if (fileData is Uint8List) {
      totalSize = fileData.length;
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    if (createResponse['file_exists'] == true) {
      // File already exists, create a local task to show it was found
      final existingFile = SnCloudFile.fromJson(createResponse['file']);

      // Create a task that shows as completed immediately
      // Use a generated taskId since the server might not provide one for existing files
      final taskId =
          createResponse['task_id'] as String? ??
          'existing-${DateTime.now().millisecondsSinceEpoch}';

      final uploadTask = DriveTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: taskId,
        fileName: fileName,
        contentType: contentType,
        fileSize: totalSize,
        uploadedBytes: totalSize,
        totalChunks: 1, // For existing files, we consider it as 1 chunk
        uploadedChunks: 1,
        status: DriveTaskStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: 'FileUpload',
        poolId: poolId,
        bundleId: bundleId,
        encryptPassword: encryptPassword,
        expiredAt: expiredAt,
      );

      ref.read(uploadTasksProvider.notifier).addUploadTask(uploadTask);

      return existingFile;
    }

    final taskId = createResponse['task_id'] as String;
    final chunkSize = createResponse['chunk_size'] as int;
    final chunksCount = createResponse['chunks_count'] as int;

    // Store upload metadata for when task.created event arrives
    talker.info('[UploadTasks] Storing metadata for taskId: $taskId');
    ref
        .read(uploadTasksProvider.notifier)
        .storeUploadMetadata(
          taskId,
          fileName: fileName,
          contentType: contentType,
          fileSize: totalSize,
          totalChunks: chunksCount,
          poolId: poolId,
          bundleId: bundleId,
          encryptPassword: encryptPassword,
          expiredAt: expiredAt,
        );

    // Step 2: Upload chunks
    int bytesUploaded = 0;
    if (fileData is XFile) {
      // Use stream for XFile
      final subscription = fileData.openRead().listen(null);
      subscription.pause();
      for (int i = 0; i < chunksCount; i++) {
        subscription.resume();
        final chunkData = await _readNextChunkFromStream(
          subscription,
          chunkSize,
        );
        await uploadChunk(
          taskId: taskId,
          chunkIndex: i,
          chunkData: chunkData,
          onSendProgress: (sent, total) {
            final overallProgress = (bytesUploaded + sent) / totalSize;
            onProgress?.call(overallProgress, Duration.zero);
            // Update transmission progress in UI
            ref
                .read(uploadTasksProvider.notifier)
                .updateTransmissionProgress(taskId, overallProgress);
          },
        );
        bytesUploaded += chunkData.length;
      }
      subscription.cancel();
    } else if (fileData is Uint8List) {
      // Use old way for Uint8List
      final chunks = <Uint8List>[];
      for (int i = 0; i < fileData.length; i += chunkSize) {
        final end =
            i + chunkSize > fileData.length ? fileData.length : i + chunkSize;
        chunks.add(Uint8List.fromList(fileData.sublist(i, end)));
      }

      // Upload each chunk
      for (int i = 0; i < chunks.length; i++) {
        await uploadChunk(
          taskId: taskId,
          chunkIndex: i,
          chunkData: chunks[i],
          onSendProgress: (sent, total) {
            final overallProgress = (bytesUploaded + sent) / totalSize;
            onProgress?.call(overallProgress, Duration.zero);
            // Update transmission progress in UI
            ref
                .read(uploadTasksProvider.notifier)
                .updateTransmissionProgress(taskId, overallProgress);
          },
        );
        bytesUploaded += chunks[i].length;
      }
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    // Step 3: Complete upload
    onProgress?.call(null, Duration.zero);
    return await completeUpload(taskId);
  }
}
