import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';

part 'drive_task.freezed.dart';
part 'drive_task.g.dart';

enum DriveTaskStatus {
  pending,
  inProgress,
  paused,
  completed,
  failed,
  expired,
  cancelled,
}

@freezed
sealed class DriveTask with _$DriveTask {
  const DriveTask._();

  const factory DriveTask({
    required String id,
    required String taskId,
    required String fileName,
    required String contentType,
    required int fileSize,
    required int uploadedBytes,
    required int totalChunks,
    required int uploadedChunks,
    required DriveTaskStatus status,
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
  }) = _DriveTask;

  factory DriveTask.fromJson(Map<String, dynamic> json) =>
      _$DriveTaskFromJson(json);

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
