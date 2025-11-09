import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';

part 'upload_task.freezed.dart';
part 'upload_task.g.dart';

enum UploadTaskStatus {
  pending,
  inProgress,
  paused,
  completed,
  failed,
  expired,
  cancelled,
}

@freezed
sealed class UploadTask with _$UploadTask {
  const UploadTask._();

  const factory UploadTask({
    required String id,
    required String taskId,
    required String fileName,
    required String contentType,
    required int fileSize,
    required int uploadedBytes,
    required int totalChunks,
    required int uploadedChunks,
    required UploadTaskStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String type, // Task type (e.g., 'FileUpload')
    double? transmissionProgress, // Local file upload progress (0.0-1.0)
    String? errorMessage,
    SnCloudFile? result,
    String? poolId,
    String? bundleId,
    String? encryptPassword,
    String? expiredAt,
  }) = _UploadTask;

  factory UploadTask.fromJson(Map<String, dynamic> json) =>
      _$UploadTaskFromJson(json);

  double get progress => totalChunks > 0 ? uploadedChunks / totalChunks : 0.0;

  Duration get estimatedTimeRemaining {
    if (uploadedBytes == 0 || fileSize == 0) return Duration.zero;
    final remainingBytes = fileSize - uploadedBytes;
    final uploadRate =
        uploadedBytes / createdAt.difference(DateTime.now()).inSeconds.abs();
    if (uploadRate == 0) return Duration.zero;
    return Duration(seconds: (remainingBytes / uploadRate).round());
  }
}
