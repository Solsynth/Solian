import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/drive/drive_models/file_pool.dart';

part 'file.freezed.dart';
part 'file.g.dart';

enum UniversalFileType { image, video, audio, file }

@freezed
sealed class UniversalFile with _$UniversalFile {
  const UniversalFile._();

  const factory UniversalFile({
    required dynamic data,
    required UniversalFileType type,
    @Default(false) bool isLink,
    String? displayName,
  }) = _UniversalFile;

  factory UniversalFile.fromJson(Map<String, dynamic> json) =>
      _$UniversalFileFromJson(json);

  bool get isOnCloud => data is SnCloudFile;
  bool get isOnDevice => !isOnCloud;

  factory UniversalFile.fromAttachment(SnCloudFile attachment) {
    return UniversalFile(
      data: attachment,
      type: switch (attachment.mimeType?.split('/').firstOrNull) {
        'image' => UniversalFileType.image,
        'audio' => UniversalFileType.audio,
        'video' => UniversalFileType.video,
        _ => UniversalFileType.file,
      },
      displayName: attachment.name,
    );
  }
}

@freezed
sealed class SnFileReplica with _$SnFileReplica {
  const factory SnFileReplica({
    required String id,
    required String objectId,
    required String poolId,
    required SnFilePool? pool,
    required String storageId,
    required int status,
    required bool isPrimary,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnFileReplica;

  factory SnFileReplica.fromJson(Map<String, dynamic> json) =>
      _$SnFileReplicaFromJson(json);
}

@freezed
sealed class SnCloudFileObject with _$SnCloudFileObject {
  const factory SnCloudFileObject({
    required String id,
    required int size,
    required Map<String, dynamic>? meta,
    required String? mimeType,
    required String? hash,
    required bool hasCompression,
    required bool hasThumbnail,
    required List<SnFileReplica> fileReplicas,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnCloudFileObject;

  factory SnCloudFileObject.fromJson(Map<String, dynamic> json) =>
      _$SnCloudFileObjectFromJson(json);
}

@freezed
sealed class SnCloudFile with _$SnCloudFile {
  const factory SnCloudFile({
    required String id,
    required String name,
    required String? description,
    required Map<String, dynamic>? fileMeta,
    required Map<String, dynamic>? userMeta,
    @Default([]) List<int> sensitiveMarks,
    required String? mimeType,
    required String? hash,
    required int size,
    required DateTime? uploadedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    String? url,
  }) = _SnCloudFile;

  factory SnCloudFile.fromJson(Map<String, dynamic> json) =>
      _$SnCloudFileFromJson(json);
}

@freezed
sealed class SnCloudFileIndex with _$SnCloudFileIndex {
  const factory SnCloudFileIndex({
    required String id,
    required String path,
    required String fileId,
    required SnCloudFile file,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnCloudFileIndex;

  factory SnCloudFileIndex.fromJson(Map<String, dynamic> json) =>
      _$SnCloudFileIndexFromJson(json);
}
