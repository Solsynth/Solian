// The drive (shared by Solian and SolWatt) needs these two constants; both
// hosts keep their own `AppTaskType` for app-domain jobs and point the drive
// entries at these values so the wire strings stay single-sourced.
abstract final class DriveTaskTypes {
  static const upload = 'drive.upload';
  static const download = 'drive.download';
}

/// Background task status is `DriveTaskStatus` from `solar_network_sdk`
/// (the same enum the drive API returns); hosts map it onto their own task
/// model when adapting [DriveTaskSink].

/// Upload pipeline stages surfaced in the host's task overlay.
class DriveUploadStage {
  static const preparing = 'preparing';
  static const hashing = 'hashing';
  static const preparingMedia = 'preparing_media';
  static const creatingUpload = 'creating_upload';
  static const uploadingSource = 'uploading_source';
  static const uploadingThumbnail = 'uploading_thumbnail';
  static const uploadingCompression = 'uploading_compression';
  static const finalizing = 'finalizing';
  static const fallingBack = 'falling_back';
  static const completed = 'completed';

  static String label(String stage) => switch (stage) {
    hashing => 'Hashing file',
    preparingMedia => 'Preparing media',
    creatingUpload => 'Creating upload',
    uploadingSource => 'Uploading source',
    uploadingThumbnail => 'Uploading thumbnail',
    uploadingCompression => 'Uploading compression',
    finalizing => 'Finalizing upload',
    fallingBack => 'Switching to standard upload',
    completed => 'Upload completed',
    _ => 'Preparing upload',
  };
}

/// Metadata the drive writes into an upload task for the host overlay.
class DriveUploadTaskMeta {
  final String? serverTaskId;
  final int fileSize;
  final int totalChunks;
  final int uploadedChunks;
  final double? transmissionProgress;
  final String? stage;
  final double stageProgress;
  final double sourceProgress;
  final double thumbnailProgress;
  final double compressionProgress;
  final String? poolId;
  final String? encryptPassword;
  final String? expiredAt;

  const DriveUploadTaskMeta({
    this.serverTaskId,
    required this.fileSize,
    required this.totalChunks,
    this.uploadedChunks = 0,
    this.transmissionProgress,
    this.stage,
    this.stageProgress = 0,
    this.sourceProgress = 0,
    this.thumbnailProgress = 0,
    this.compressionProgress = 0,
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
    if (stage != null) 'stage': stage,
    'stageProgress': stageProgress,
    'sourceProgress': sourceProgress,
    'thumbnailProgress': thumbnailProgress,
    'compressionProgress': compressionProgress,
    if (poolId != null) 'poolId': poolId,
    if (encryptPassword != null) 'encryptPassword': encryptPassword,
    if (expiredAt != null) 'expiredAt': expiredAt,
  };

  factory DriveUploadTaskMeta.fromMap(Map<String, dynamic> map) =>
      DriveUploadTaskMeta(
        serverTaskId: map['serverTaskId'] as String?,
        fileSize: (map['fileSize'] as num).toInt(),
        totalChunks: (map['totalChunks'] as num).toInt(),
        uploadedChunks: (map['uploadedChunks'] as num?)?.toInt() ?? 0,
        transmissionProgress: (map['transmissionProgress'] as num?)?.toDouble(),
        stage: map['stage'] as String?,
        stageProgress: (map['stageProgress'] as num?)?.toDouble() ?? 0,
        sourceProgress: (map['sourceProgress'] as num?)?.toDouble() ?? 0,
        thumbnailProgress: (map['thumbnailProgress'] as num?)?.toDouble() ?? 0,
        compressionProgress:
            (map['compressionProgress'] as num?)?.toDouble() ?? 0,
        poolId: map['poolId'] as String?,
        encryptPassword: map['encryptPassword'] as String?,
        expiredAt: map['expiredAt'] as String?,
      );
}

/// Metadata the drive writes into a download task for the host overlay.
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
