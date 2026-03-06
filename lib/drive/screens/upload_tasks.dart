import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:island/core/database.dart';
import 'package:island/core/websocket.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/talker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'upload_tasks.g.dart';

@riverpod
class UploadTasks extends _$UploadTasks {
  StreamSubscription? _websocketSubscription;
  final Map<String, Map<String, dynamic>> _pendingUploads = {};

  @override
  List<DriveTask> build() {
    _listenToWebSocket();
    ref.onDispose(() {
      _websocketSubscription?.cancel();
    });
    return [];
  }

  void _listenToWebSocket() {
    final WebSocketService websocketService = ref.read(websocketProvider);
    _websocketSubscription = websocketService.dataStream.listen(
      _handleWebSocketPacket,
    );
  }

  void _handleWebSocketPacket(dynamic packet) {
    if (packet.type.startsWith('task.') || packet.type == 'upload.completed') {
      final data = packet.data;
      if (data == null && packet.type != 'upload.completed') return;

      // Debug logging
      talker.info(
        '[UploadTasks] Received WebSocket packet: ${packet.type}, data: $data',
      );

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
          _handleUploadCompleted(taskId!, data);
          break;
        case 'upload.completed':
          if (data != null && data['task_id'] != null) {
            _handleUploadCompleted(data['task_id'], data);
          } else {
            final inProgressTasks = state
                .where((task) => task.status == DriveTaskStatus.inProgress)
                .toList();
            if (inProgressTasks.isNotEmpty) {
              final task = inProgressTasks.last;
              _handleUploadCompleted(task.taskId, {});
            }
          }
          break;
        case 'task.failed':
          _handleUploadFailed(taskId!, data);
          break;
      }
    }
  }

  void _handleTaskCreated(String taskId, Map<String, dynamic> data) {
    talker.info('[UploadTasks] Handling task.created for taskId: $taskId');

    final existingTask = state
        .where((task) => task.taskId == taskId)
        .firstOrNull;
    if (existingTask != null) {
      talker.info('[UploadTasks] Task already exists, updating status');
      state = state.map((task) {
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

    final metadata = _pendingUploads[taskId];
    talker.info('[UploadTasks] Metadata for taskId $taskId: $metadata');

    if (metadata != null) {
      talker.info('[UploadTasks] Creating task with full metadata');
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
      _pendingUploads.remove(taskId);
    } else {
      talker.info('[UploadTasks] No metadata found, creating minimal task');
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

    state = state.map((task) {
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

    state = state.map((task) {
      if (task.taskId == taskId) {
        return task.copyWith(
          status: DriveTaskStatus.completed,
          uploadedChunks: task.totalChunks,
          uploadedBytes: task.fileSize,
          fileName: results?['file_name'] as String? ?? task.fileName,
          fileSize: results?['file_size'] as int? ?? task.fileSize,
          contentType: results?['mime_type'] as String? ?? task.contentType,
          result: results?['file_info'] != null
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

    state = state.map((task) {
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
    state = state.map((task) {
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
    state = state.map((task) {
      if (task.taskId == taskId) {
        return task.copyWith(
          transmissionProgress: progress,
          updatedAt: DateTime.now(),
        );
      }
      return task;
    }).toList();
  }

  void updateUploadProgress(
    String taskId,
    int uploadedBytes,
    int uploadedChunks,
  ) {
    state = state.map((task) {
      if (task.taskId == taskId) {
        return task.copyWith(
          uploadedBytes: uploadedBytes,
          uploadedChunks: uploadedChunks,
          status: DriveTaskStatus.inProgress,
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
    state = state.map((task) {
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
    state = state
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
}

class EnhancedFileUploader extends FileUploader {
  EnhancedFileUploader(super.ref);

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
    dynamic uploadData = fileData;
    String? encryptionScheme;
    String? encryptionHeader;
    String? encryptionSignature;
    String? localEncryptKey;

    if (encryptPassword != null && encryptPassword.trim().isNotEmpty) {
      final plaintext = switch (fileData) {
        XFile value => Uint8List.fromList(await value.readAsBytes()),
        Uint8List value => value,
        _ => throw ArgumentError(
            'Encrypted upload only supports XFile/Uint8List input.',
          ),
      };
      localEncryptKey = encryptPassword.trim();
      encryptionScheme = DriveE2eeFileEnvelope.scheme;
      final headerJson = '{"v":1,"kdf":"hkdf-sha256"}';
      encryptionHeader = base64Encode(utf8.encode(headerJson));
      uploadData = DriveE2eeFileEnvelope.encryptBytes(
        plaintext: plaintext,
        encryptKey: localEncryptKey,
        encryptionHeader: encryptionHeader,
        encryptionSignature: encryptionSignature,
        encryptionScheme: encryptionScheme,
      );
    }

    // Step 1: Create upload task
    onProgress?.call(null, Duration.zero);
    final createResponse = await createUploadTask(
      fileData: uploadData,
      fileName: fileName,
      contentType: contentType,
      poolId: poolId,
      bundleId: bundleId,
      encryptPassword: encryptPassword,
      encryptionScheme: encryptionScheme,
      encryptionHeader: encryptionHeader,
      encryptionSignature: encryptionSignature,
      expiredAt: expiredAt,
      chunkSize: customChunkSize,
      path: path,
    );

    int totalSize;
    if (uploadData is XFile) {
      totalSize = await uploadData.length();
    } else if (uploadData is Uint8List) {
      totalSize = uploadData.length;
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
    int chunksUploaded = 0;
    if (uploadData is XFile) {
      // Use stream for XFile
      final subscription = uploadData.openRead().listen(null);
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
        chunksUploaded += 1;
        // Update upload progress in UI
        ref
            .read(uploadTasksProvider.notifier)
            .updateUploadProgress(taskId, bytesUploaded, chunksUploaded);
      }
      subscription.cancel();
    } else if (uploadData is Uint8List) {
      // Use old way for Uint8List
      final chunks = <Uint8List>[];
      for (int i = 0; i < uploadData.length; i += chunkSize) {
        final end = i + chunkSize > uploadData.length
            ? uploadData.length
            : i + chunkSize;
        chunks.add(Uint8List.fromList(uploadData.sublist(i, end)));
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
        chunksUploaded += 1;
        // Update upload progress in UI
        ref
            .read(uploadTasksProvider.notifier)
            .updateUploadProgress(taskId, bytesUploaded, chunksUploaded);
      }
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    // Step 3: Complete upload
    onProgress?.call(null, Duration.zero);
    final uploaded = await completeUpload(taskId);
    if (localEncryptKey != null && localEncryptKey.isNotEmpty) {
      try {
        final db = ref.read(databaseProvider);
        await db.setSecret(
          '$driveFileKeySecretPrefix${uploaded.id}',
          localEncryptKey,
        );
      } catch (_) {}
    }
    return uploaded;
  }
}
