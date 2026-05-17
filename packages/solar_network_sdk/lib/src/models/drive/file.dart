import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/drive/file_pool.dart';

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

  bool get isOnCloud => data is IDisplayableCloudFile;
  bool get isOnDevice => !isOnCloud;

  factory UniversalFile.fromAttachment(IDisplayableCloudFile attachment) {
    return UniversalFile(
      data: attachment,
      type: switch (attachment.mimeType.split('/').firstOrNull) {
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

abstract interface class IDisplayableCloudFile {
  String get id;
  String get name;
  String? get storageUrl;
  Map<String, dynamic> get fileMeta;
  Map<String, dynamic> get userMeta;
  String get mimeType;
  int get size;
  double? get width;
  double? get height;
  String? get blurhash;
  List<int> get sensitiveMarks;
  String? get hash;

  double? get ratio {
    if (width != null && height != null && height != 0) {
      return width! / height!;
    }
    final meta = fileMeta;
    if (meta['ratio'] is num) {
      return (meta['ratio'] as num).toDouble();
    }
    return null;
  }
}

@freezed
sealed class SnCloudFile with _$SnCloudFile implements IDisplayableCloudFile {
  const SnCloudFile._();

  const factory SnCloudFile({
    required String id,
    required String accountId,
    required String? description,
    required bool indexed,
    required bool isFolder,
    required bool isMarkedRecycle,
    required String name,
    // Folder will not have object
    required SnCloudFileObject? object,
    required String? objectId,
    required String? parentId,
    required String resourceIdentifier,
    required String? storageId,
    required String? storageUrl,
    required String mimeType,
    required String? applicationType,
    required String? usage,
    @Default([]) List<int> sensitiveMarks,
    required Map<String, dynamic> fileMeta,
    required Map<String, dynamic> userMeta,
    required DateTime? uploadedAt,
    required DateTime? expiredAt,
    required DateTime updatedAt,
    required DateTime createdAt,
    required DateTime? deletedAt,
  }) = _SnCloudFile;

  int get size => object?.size ?? 0;
  String? get hash => object?.hash;

  double? get ratio {
    if (object?.meta?['width'] != null && object?.meta?['height'] != null) {
      final width = object!.meta?['width'] as num;
      final height = object!.meta?['height'] as num;
      if (height != 0) {
        return width / height;
      }
    }
    if (object?.meta?['ratio'] != null) {
      return (object!.meta?['ratio'] as num).toDouble();
    }
    return null;
  }

  double? get width => object?.meta?['width'] != null
      ? (object!.meta?['width'] as num).toDouble()
      : null;
  double? get height => object?.meta?['height'] != null
      ? (object!.meta?['height'] as num).toDouble()
      : null;

  String? get blurhash =>
      (object?.meta?['blurhash'] ?? object?.meta?['blur']) as String?;

  factory SnCloudFile.fromJson(Map<String, dynamic> json) =>
      _$SnCloudFileFromJson(json);
}

@freezed
sealed class SnCloudFileReference
    with _$SnCloudFileReference
    implements IDisplayableCloudFile {
  const SnCloudFileReference._();

  const factory SnCloudFileReference({
    required String id,
    required String name,
    @Default({}) Map<String, dynamic> fileMeta,
    @Default({}) Map<String, dynamic> userMeta,
    @Default([]) List<int> sensitiveMarks,
    required String mimeType,
    required String hash,
    required int size,
    required bool hasCompression,
    @JsonKey(name: "url") required String? storageUrl,
    required double? width,
    required double? height,
    required String? blurhash,
    required String? usage,
    required String? applicationType,
  }) = _SnCloudFileReference;

  @override
  double? get ratio {
    if (width != null && height != null && height != 0) {
      return width! / height!;
    }
    if (fileMeta['ratio'] is num) {
      return (fileMeta['ratio'] as num).toDouble();
    }
    return null;
  }

  factory SnCloudFileReference.fromJson(Map<String, dynamic> json) =>
      _$SnCloudFileReferenceFromJson(json);
}
