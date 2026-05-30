import 'dart:async';
import 'dart:convert';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:island/core/database.dart';
import 'package:island/core/tasks/app_task.dart';
import 'package:island/core/tasks/tasks_notifier.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/services/drive_task_ws_handler.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
    String? parentId,
    String? path,
    String? usage,
    String? applicationType,
    Function(double? progress, Duration estimate)? onProgress,
  }) async {
    final overallTimer = Stopwatch()..start();
    dynamic uploadData = fileData;
    String? encryptionScheme;
    String? encryptionHeader;
    String? encryptionSignature;
    String? localEncryptKey;

    if (encryptPassword != null && encryptPassword.trim().isNotEmpty) {
      final encryptTimer = Stopwatch()..start();
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
      encryptTimer.stop();
      debugPrint(
        '[DriveUpload] Encryption took: ${encryptTimer.elapsedMilliseconds}ms',
      );
    }

    final totalSize = await resolveUploadDataSize(uploadData);
    final tasks = ref.read(tasksProvider.notifier);

    if (shouldUseDirectUpload(
      totalSize: totalSize,
      customChunkSize: customChunkSize,
    )) {
      final taskId = tasks.addTask(
        title: fileName,
        type: AppTaskType.driveUpload,
        status: AppTaskStatus.inProgress,
        metadata: DriveUploadTaskMeta(
          fileSize: totalSize,
          totalChunks: 1,
          poolId: poolId,
          encryptPassword: encryptPassword,
          expiredAt: expiredAt,
        ).toMap(),
      );

      onProgress?.call(null, Duration.zero);
      try {
        final uploaded = await uploadFileDirect(
          fileData: uploadData,
          fileName: fileName,
          contentType: contentType,
          poolId: poolId,
          expiredAt: expiredAt,
          parentId: parentId,
          path: path,
          usage: usage,
          applicationType: applicationType,
          onSendProgress: (sent, total) {
            if (total <= 0) return;
            final progress = sent / total;
            onProgress?.call(progress, Duration.zero);
            tasks.updateTask(
              taskId,
              progress: progress,
              metadata: {
                ...?tasks.getTask(taskId)?.metadata,
                'transmissionProgress': progress,
              },
            );
          },
        );

        tasks.updateTask(
          taskId,
          status: AppTaskStatus.completed,
          progress: 1.0,
        );

        if (localEncryptKey != null && localEncryptKey.isNotEmpty) {
          try {
            final db = ref.read(databaseProvider);
            await db.setSecret(
              '$driveFileKeySecretPrefix${uploaded.id}',
              localEncryptKey,
            );
          } catch (_) {}
        }

        onProgress?.call(null, Duration.zero);
        overallTimer.stop();
        debugPrint(
          '[DriveUpload] Total upload time: ${overallTimer.elapsedMilliseconds}ms',
        );
        return uploaded;
      } catch (err) {
        tasks.updateTask(
          taskId,
          status: AppTaskStatus.failed,
          errorMessage: err.toString(),
        );
        rethrow;
      }
    }

    // Step 1: Create upload task
    onProgress?.call(null, Duration.zero);
    final createTimer = Stopwatch()..start();
    final createResponse = await createUploadTask(
      fileData: uploadData,
      fileName: fileName,
      contentType: contentType,
      poolId: poolId,
      expiredAt: expiredAt,
      chunkSize: customChunkSize,
      parentId: parentId,
      path: path,
      usage: usage,
      applicationType: applicationType,
    );
    createTimer.stop();
    debugPrint(
      '[DriveUpload] Step 1 (Create upload task) total took: ${createTimer.elapsedMilliseconds}ms',
    );

    if (createResponse['file_exists'] == true) {
      final existingFile = SnCloudFile.fromJson(createResponse['file']);

      tasks.addTask(
        title: fileName,
        type: AppTaskType.driveUpload,
        status: AppTaskStatus.completed,
        metadata: DriveUploadTaskMeta(
          fileSize: totalSize,
          totalChunks: 1,
          uploadedChunks: 1,
          poolId: poolId,
          encryptPassword: encryptPassword,
          expiredAt: expiredAt,
        ).toMap(),
      );

      return existingFile;
    }

    final serverTaskId = createResponse['task_id'] as String;
    final chunkSize = createResponse['chunk_size'] as int;
    final chunksCount = createResponse['chunks_count'] as int;

    // Create local task and store metadata for WS handler
    final taskId = tasks.addTask(
      title: fileName,
      type: AppTaskType.driveUpload,
      status: AppTaskStatus.inProgress,
      metadata: DriveUploadTaskMeta(
        serverTaskId: serverTaskId,
        fileSize: totalSize,
        totalChunks: chunksCount,
        poolId: poolId,
        encryptPassword: encryptPassword,
        expiredAt: expiredAt,
      ).toMap(),
    );

    Logger.root.info('[DriveUpload] Storing WS metadata for: $serverTaskId');
    ref
        .read(driveTaskWsHandlerProvider.notifier)
        .storePendingUpload(
          serverTaskId,
          fileName: fileName,
          contentType: contentType,
          fileSize: totalSize,
          totalChunks: chunksCount,
          poolId: poolId,
          encryptPassword: encryptPassword,
          expiredAt: expiredAt,
        );

    // Step 2: Upload chunks
    final chunkTimer = Stopwatch()..start();
    int bytesUploaded = 0;
    int chunksUploaded = 0;
    if (uploadData is XFile) {
      final subscription = uploadData.openRead().listen(null);
      subscription.pause();
      for (int i = 0; i < chunksCount; i++) {
        subscription.resume();
        final chunkData = await _readNextChunkFromStream(
          subscription,
          chunkSize,
        );
        await uploadChunk(
          taskId: serverTaskId,
          chunkIndex: i,
          chunkData: chunkData,
          onSendProgress: (sent, total) {
            final overallProgress = (bytesUploaded + sent) / totalSize;
            onProgress?.call(overallProgress, Duration.zero);
            final currentMeta =
                tasks.getTask(taskId)?.metadata ?? {};
            tasks.updateTask(
              taskId,
              progress: overallProgress,
              metadata: {
                ...currentMeta,
                'transmissionProgress': overallProgress,
              },
            );
          },
        );
        bytesUploaded += chunkData.length;
        chunksUploaded += 1;
        final currentMeta = tasks.getTask(taskId)?.metadata ?? {};
        tasks.updateTask(
          taskId,
          progress: bytesUploaded / totalSize,
          metadata: {
            ...currentMeta,
            'uploadedChunks': chunksUploaded,
            'transmissionProgress': bytesUploaded / totalSize,
          },
        );
      }
      subscription.cancel();
    } else if (uploadData is Uint8List) {
      final chunks = <Uint8List>[];
      for (int i = 0; i < uploadData.length; i += chunkSize) {
        final end = i + chunkSize > uploadData.length
            ? uploadData.length
            : i + chunkSize;
        chunks.add(Uint8List.fromList(uploadData.sublist(i, end)));
      }

      for (int i = 0; i < chunks.length; i++) {
        await uploadChunk(
          taskId: serverTaskId,
          chunkIndex: i,
          chunkData: chunks[i],
          onSendProgress: (sent, total) {
            final overallProgress = (bytesUploaded + sent) / totalSize;
            onProgress?.call(overallProgress, Duration.zero);
            final currentMeta =
                tasks.getTask(taskId)?.metadata ?? {};
            tasks.updateTask(
              taskId,
              progress: overallProgress,
              metadata: {
                ...currentMeta,
                'transmissionProgress': overallProgress,
              },
            );
          },
        );
        bytesUploaded += chunks[i].length;
        chunksUploaded += 1;
        final currentMeta = tasks.getTask(taskId)?.metadata ?? {};
        tasks.updateTask(
          taskId,
          progress: bytesUploaded / totalSize,
          metadata: {
            ...currentMeta,
            'uploadedChunks': chunksUploaded,
            'transmissionProgress': bytesUploaded / totalSize,
          },
        );
      }
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    chunkTimer.stop();
    debugPrint(
      '[DriveUpload] Step 2 (Upload $chunksUploaded chunks) total took: ${chunkTimer.elapsedMilliseconds}ms',
    );

    // Step 3: Complete upload
    onProgress?.call(null, Duration.zero);
    final completeTimer = Stopwatch()..start();
    final uploaded = await completeUpload(serverTaskId);
    completeTimer.stop();
    debugPrint(
      '[DriveUpload] Step 3 (Complete upload) took: ${completeTimer.elapsedMilliseconds}ms',
    );

    tasks.updateTask(
      taskId,
      status: AppTaskStatus.completed,
      progress: 1.0,
    );

    if (localEncryptKey != null && localEncryptKey.isNotEmpty) {
      try {
        final db = ref.read(databaseProvider);
        await db.setSecret(
          '$driveFileKeySecretPrefix${uploaded.id}',
          localEncryptKey,
        );
      } catch (_) {}
    }

    overallTimer.stop();
    debugPrint(
      '[DriveUpload] Total upload time: ${overallTimer.elapsedMilliseconds}ms',
    );
    return uploaded;
  }
}
