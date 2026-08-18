import 'dart:async';
import 'dart:convert';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:island/core/database.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';
import 'package:island/drive/drive_service.dart';
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
    String? workspaceId,
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

    String? fallbackTaskId;
    // cannot issue signed URLs. XFiles of any size are eligible (multipart
    // above the threshold, single PUT below); in-memory payloads are capped by
    // the single-PUT object limit. E2EE payloads and explicit chunk sizes stay
    // on the proxied path.
    if (localEncryptKey == null &&
        customChunkSize == null &&
        (uploadData is XFile ||
            totalSize <= driveS3DirectUploadMaxFileSizeBytes)) {
      final s3TaskId = tasks.addTask(
        title: fileName,
        type: AppTaskType.driveUpload,
        status: AppTaskStatus.inProgress,
        metadata: DriveUploadTaskMeta(
          fileSize: totalSize,
          totalChunks: 1,
          stage: DriveUploadStage.preparing,
          poolId: poolId,
          encryptPassword: encryptPassword,
          expiredAt: expiredAt,
        ).toMap(),
      );

      void reportStage(String stage, double stageProgress) {
        final current = tasks.getTask(s3TaskId)?.metadata ?? {};
        final progress = switch (stage) {
          DriveUploadStage.uploadingSource => stageProgress * 0.82,
          DriveUploadStage.uploadingThumbnail => 0.82 + stageProgress * 0.06,
          DriveUploadStage.uploadingCompression => 0.88 + stageProgress * 0.07,
          DriveUploadStage.finalizing => 0.95 + stageProgress * 0.05,
          DriveUploadStage.completed => 1.0,
          _ => (tasks.getTask(s3TaskId)?.progress ?? 0).clamp(0.0, 1.0),
        };
        tasks.updateTask(
          s3TaskId,
          progress: progress,
          statusMessage: DriveUploadStage.label(stage),
          metadata: {
            ...current,
            'stage': stage,
            'stageProgress': stageProgress,
            if (stage == DriveUploadStage.uploadingSource)
              'sourceProgress': stageProgress,
            if (stage == DriveUploadStage.uploadingThumbnail)
              'thumbnailProgress': stageProgress,
            if (stage == DriveUploadStage.uploadingCompression)
              'compressionProgress': stageProgress,
          },
        );
      }

      try {
        onProgress?.call(null, Duration.zero);
        final s3Uploaded = await tryUploadViaS3Direct(
          fileData: uploadData,
          fileName: fileName,
          contentType: contentType,
          poolId: poolId,
          expiredAt: expiredAt,
          parentId: parentId,
          workspaceId: workspaceId,
          path: path,
          usage: usage,
          applicationType: applicationType,
          onStage: reportStage,
          onProgress: (progress, estimate) {
            onProgress?.call(progress, estimate);
            if (progress != null) {
              final current = tasks.getTask(s3TaskId)?.metadata ?? {};
              tasks.updateTask(
                s3TaskId,
                metadata: {...current, 'transmissionProgress': progress},
              );
            }
          },
        );

        if (s3Uploaded != null) {
          reportStage(DriveUploadStage.completed, 1);
          tasks.updateTask(
            s3TaskId,
            status: AppTaskStatus.completed,
            progress: 1.0,
          );
          onProgress?.call(null, Duration.zero);
          overallTimer.stop();
          debugPrint(
            '[DriveUpload] Total upload time: ${overallTimer.elapsedMilliseconds}ms',
          );
          return s3Uploaded;
        }

        reportStage(DriveUploadStage.fallingBack, 1);
        fallbackTaskId = s3TaskId;
      } catch (err) {
        tasks.updateTask(
          s3TaskId,
          status: AppTaskStatus.failed,
          errorMessage: err.toString(),
        );
        rethrow;
      }
    }

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
          stage: DriveUploadStage.preparing,
          poolId: poolId,
          encryptPassword: encryptPassword,
          expiredAt: expiredAt,
        ).toMap(),
      );

      onProgress?.call(null, Duration.zero);
      try {
        tasks.updateTask(
          taskId,
          statusMessage: DriveUploadStage.label(
            DriveUploadStage.uploadingSource,
          ),
          metadata: {
            ...?tasks.getTask(taskId)?.metadata,
            'stage': DriveUploadStage.uploadingSource,
            'stageProgress': 0.0,
          },
        );
        final uploaded = await uploadFileDirect(
          fileData: uploadData,
          fileName: fileName,
          contentType: contentType,
          poolId: poolId,
          expiredAt: expiredAt,
          parentId: parentId,
          workspaceId: workspaceId,
          path: path,
          onSendProgress: (sent, total) {
            if (total <= 0) return;
            final progress = sent / total;
            onProgress?.call(progress, Duration.zero);
            tasks.updateTask(
              taskId,
              progress: progress * 0.95,
              metadata: {
                ...?tasks.getTask(taskId)?.metadata,
                'stageProgress': progress,
                'sourceProgress': progress,
                'transmissionProgress': progress,
              },
            );
          },
        );

        tasks.updateTask(
          taskId,
          statusMessage: DriveUploadStage.label(DriveUploadStage.finalizing),
          progress: 0.98,
          metadata: {
            ...?tasks.getTask(taskId)?.metadata,
            'stage': DriveUploadStage.finalizing,
            'stageProgress': 0.5,
          },
        );
        tasks.updateTask(
          taskId,
          status: AppTaskStatus.completed,
          statusMessage: DriveUploadStage.label(DriveUploadStage.completed),
          progress: 1.0,
          metadata: {
            ...?tasks.getTask(taskId)?.metadata,
            'stage': DriveUploadStage.completed,
            'stageProgress': 1.0,
          },
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
      workspaceId: workspaceId,
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
          stage: DriveUploadStage.completed,
          stageProgress: 1,
          sourceProgress: 1,
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

    // Local task progress is driven directly by Dio's send-progress callbacks.
    final taskId =
        fallbackTaskId ??
        tasks.addTask(
          title: fileName,
          type: AppTaskType.driveUpload,
          status: AppTaskStatus.inProgress,
          metadata: DriveUploadTaskMeta(
            serverTaskId: serverTaskId,
            fileSize: totalSize,
            totalChunks: chunksCount,
            stage: DriveUploadStage.uploadingSource,
            poolId: poolId,
            encryptPassword: encryptPassword,
            expiredAt: expiredAt,
          ).toMap(),
        );
    if (fallbackTaskId != null) {
      tasks.updateTask(
        taskId,
        statusMessage: DriveUploadStage.label(DriveUploadStage.uploadingSource),
        metadata: DriveUploadTaskMeta(
          serverTaskId: serverTaskId,
          fileSize: totalSize,
          totalChunks: chunksCount,
          stage: DriveUploadStage.uploadingSource,
          poolId: poolId,
          encryptPassword: encryptPassword,
          expiredAt: expiredAt,
        ).toMap(),
      );
    }

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
            final currentMeta = tasks.getTask(taskId)?.metadata ?? {};
            tasks.updateTask(
              taskId,
              progress: overallProgress * 0.95,
              metadata: {
                ...currentMeta,
                'stageProgress': overallProgress,
                'sourceProgress': overallProgress,
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
          progress: (bytesUploaded / totalSize) * 0.95,
          metadata: {
            ...currentMeta,
            'uploadedChunks': chunksUploaded,
            'stageProgress': bytesUploaded / totalSize,
            'sourceProgress': bytesUploaded / totalSize,
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
            final currentMeta = tasks.getTask(taskId)?.metadata ?? {};
            tasks.updateTask(
              taskId,
              progress: overallProgress * 0.95,
              metadata: {
                ...currentMeta,
                'stageProgress': overallProgress,
                'sourceProgress': overallProgress,
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
          progress: (bytesUploaded / totalSize) * 0.95,
          metadata: {
            ...currentMeta,
            'uploadedChunks': chunksUploaded,
            'stageProgress': bytesUploaded / totalSize,
            'sourceProgress': bytesUploaded / totalSize,
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
    tasks.updateTask(
      taskId,
      statusMessage: DriveUploadStage.label(DriveUploadStage.finalizing),
      progress: 0.98,
      metadata: {
        ...?tasks.getTask(taskId)?.metadata,
        'stage': DriveUploadStage.finalizing,
        'stageProgress': 0.5,
      },
    );
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
      statusMessage: DriveUploadStage.label(DriveUploadStage.completed),
      progress: 1.0,
      metadata: {
        ...?tasks.getTask(taskId)?.metadata,
        'stage': DriveUploadStage.completed,
        'stageProgress': 1.0,
      },
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
