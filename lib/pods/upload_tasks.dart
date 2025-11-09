import 'dart:async';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/upload_task.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/services/file_uploader.dart';

final uploadTasksProvider =
    StateNotifierProvider<UploadTasksNotifier, List<UploadTask>>(
      (ref) => UploadTasksNotifier(ref),
    );

class UploadTasksNotifier extends StateNotifier<List<UploadTask>> {
  final Ref ref;
  StreamSubscription? _websocketSubscription;

  UploadTasksNotifier(this.ref) : super([]) {
    _listenToWebSocket();
  }

  void _listenToWebSocket() {
    final WebSocketService websocketService = ref.read(websocketProvider);
    _websocketSubscription = websocketService.dataStream.listen(
      _handleWebSocketPacket,
    );
  }

  void _handleWebSocketPacket(dynamic packet) {
    if (packet.type.startsWith('upload.')) {
      final data = packet.data;
      if (data == null) return;

      final taskId = data['task_id'] as String?;
      if (taskId == null) return;

      switch (packet.type) {
        case 'upload.progress':
          _handleProgressUpdate(taskId, data);
          break;
        case 'upload.completed':
          _handleUploadCompleted(taskId, data);
          break;
        case 'upload.failed':
          _handleUploadFailed(taskId, data);
          break;
      }
    }
  }

  void _handleProgressUpdate(String taskId, Map<String, dynamic> data) {
    final uploadedChunks = data['chunksUploaded'] as int? ?? 0;
    final uploadedBytes =
        (data['progress'] as num? ?? 0.0) /
        100.0 *
        (data['fileSize'] as int? ?? 0);

    state =
        state.map((task) {
          if (task.taskId == taskId) {
            return task.copyWith(
              uploadedChunks: uploadedChunks,
              uploadedBytes: uploadedBytes.toInt(),
              status: UploadTaskStatus.inProgress,
              updatedAt: DateTime.now(),
            );
          }
          return task;
        }).toList();
  }

  void _handleUploadCompleted(String taskId, Map<String, dynamic> data) {
    final fileData = data['file'];
    if (fileData != null) {
      // Assuming the file data comes in the expected format
      // You might need to adjust this based on the actual API response
    }

    state =
        state.map((task) {
          if (task.taskId == taskId) {
            return task.copyWith(
              status: UploadTaskStatus.completed,
              uploadedChunks: task.totalChunks,
              uploadedBytes: task.fileSize,
              updatedAt: DateTime.now(),
            );
          }
          return task;
        }).toList();
  }

  void _handleUploadFailed(String taskId, Map<String, dynamic> data) {
    final errorMessage = data['error'] as String? ?? 'Upload failed';

    state =
        state.map((task) {
          if (task.taskId == taskId) {
            return task.copyWith(
              status: UploadTaskStatus.failed,
              errorMessage: errorMessage,
              updatedAt: DateTime.now(),
            );
          }
          return task;
        }).toList();
  }

  void addUploadTask(UploadTask task) {
    state = [...state, task];
  }

  void updateTaskStatus(
    String taskId,
    UploadTaskStatus status, {
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

  void removeTask(String taskId) {
    state = state.where((task) => task.taskId != taskId).toList();
  }

  UploadTask? getTask(String taskId) {
    return state.where((task) => task.taskId == taskId).firstOrNull;
  }

  List<UploadTask> getActiveTasks() {
    return state
        .where(
          (task) =>
              task.status == UploadTaskStatus.pending ||
              task.status == UploadTaskStatus.inProgress ||
              task.status == UploadTaskStatus.paused,
        )
        .toList();
  }

  @override
  void dispose() {
    _websocketSubscription?.cancel();
    super.dispose();
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
    );

    if (createResponse['file_exists'] == true) {
      // File already exists, return the existing file
      return SnCloudFile.fromJson(createResponse['file']);
    }

    final taskId = createResponse['task_id'] as String;
    final chunkSize = createResponse['chunk_size'] as int;
    final chunksCount = createResponse['chunks_count'] as int;
    int totalSize;
    if (fileData is XFile) {
      totalSize = await fileData.length();
    } else if (fileData is Uint8List) {
      totalSize = fileData.length;
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    // Create upload task and add to state
    final uploadTask = UploadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: taskId,
      fileName: fileName,
      contentType: contentType,
      fileSize: totalSize,
      uploadedBytes: 0,
      totalChunks: chunksCount,
      uploadedChunks: 0,
      status: UploadTaskStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      poolId: poolId,
      bundleId: bundleId,
      encryptPassword: encryptPassword,
      expiredAt: expiredAt,
    );

    ref.read(uploadTasksProvider.notifier).addUploadTask(uploadTask);

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
