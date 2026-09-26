import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_task.freezed.dart';
part 'app_task.g.dart';

enum AppTaskStatus {
  pending,
  inProgress,
  paused,
  completed,
  failed,
  cancelled,
  expired,
}

@freezed
sealed class AppTask with _$AppTask {
  const AppTask._();

  const factory AppTask({
    required String id,
    required String title,
    required AppTaskStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String type,
    @Default(0.0) double progress,
    String? statusMessage,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? result,
  }) = _AppTask;

  factory AppTask.fromJson(Map<String, dynamic> json) =>
      _$AppTaskFromJson(json);

  bool get isActive =>
      status == AppTaskStatus.pending ||
      status == AppTaskStatus.inProgress ||
      status == AppTaskStatus.paused;

  bool get isFinished =>
      status == AppTaskStatus.completed ||
      status == AppTaskStatus.failed ||
      status == AppTaskStatus.cancelled ||
      status == AppTaskStatus.expired;
}

class PostPublishTaskMeta {
  final String? draftId;
  final int attachmentCount;

  const PostPublishTaskMeta({this.draftId, this.attachmentCount = 0});

  Map<String, dynamic> toMap() => {
    if (draftId != null) 'draftId': draftId,
    'attachmentCount': attachmentCount,
  };

  factory PostPublishTaskMeta.fromMap(Map<String, dynamic> map) =>
      PostPublishTaskMeta(
        draftId: map['draftId'] as String?,
        attachmentCount: map['attachmentCount'] as int? ?? 0,
      );
}

// --- Task type constants ---

abstract class AppTaskType {
  static const driveUpload = DriveTaskTypes.upload;
  static const driveDownload = DriveTaskTypes.download;
  static const postPublish = 'post.publish';
  static const accountCheckIn = 'account.check-in';
}
