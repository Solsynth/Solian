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

// --- Typed metadata classes for domain-specific data ---

class DriveUploadTaskMeta {
  final String? serverTaskId;
  final int fileSize;
  final int totalChunks;
  final int uploadedChunks;
  final double? transmissionProgress;
  final String? poolId;
  final String? encryptPassword;
  final String? expiredAt;

  const DriveUploadTaskMeta({
    this.serverTaskId,
    required this.fileSize,
    required this.totalChunks,
    this.uploadedChunks = 0,
    this.transmissionProgress,
    this.poolId,
    this.encryptPassword,
    this.expiredAt,
  });

  Map<String, dynamic> toMap() => {
    if (serverTaskId != null) 'serverTaskId': serverTaskId,
    'fileSize': fileSize,
    'totalChunks': totalChunks,
    'uploadedChunks': uploadedChunks,
    if (transmissionProgress != null)
      'transmissionProgress': transmissionProgress,
    if (poolId != null) 'poolId': poolId,
    if (encryptPassword != null) 'encryptPassword': encryptPassword,
    if (expiredAt != null) 'expiredAt': expiredAt,
  };

  factory DriveUploadTaskMeta.fromMap(Map<String, dynamic> map) =>
      DriveUploadTaskMeta(
        serverTaskId: map['serverTaskId'] as String?,
        fileSize: map['fileSize'] as int,
        totalChunks: map['totalChunks'] as int,
        uploadedChunks: map['uploadedChunks'] as int? ?? 0,
        transmissionProgress: map['transmissionProgress'] as double?,
        poolId: map['poolId'] as String?,
        encryptPassword: map['encryptPassword'] as String?,
        expiredAt: map['expiredAt'] as String?,
      );
}

class DriveDownloadTaskMeta {
  final String fileId;
  final int totalBytes;
  final int downloadedBytes;

  const DriveDownloadTaskMeta({
    required this.fileId,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
  });

  Map<String, dynamic> toMap() => {
    'fileId': fileId,
    'totalBytes': totalBytes,
    'downloadedBytes': downloadedBytes,
  };

  factory DriveDownloadTaskMeta.fromMap(Map<String, dynamic> map) =>
      DriveDownloadTaskMeta(
        fileId: map['fileId'] as String,
        totalBytes: map['totalBytes'] as int? ?? 0,
        downloadedBytes: map['downloadedBytes'] as int? ?? 0,
      );
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
  static const driveUpload = 'drive.upload';
  static const driveDownload = 'drive.download';
  static const postPublish = 'post.publish';
}
