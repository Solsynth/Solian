import 'package:freezed_annotation/freezed_annotation.dart';

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
    );
  }
}

@freezed
sealed class SnCloudFile with _$SnCloudFile {
  const factory SnCloudFile({
    required String id,
    required String name,
    required String? description,
    required Map<String, dynamic>? fileMeta,
    required Map<String, dynamic>? userMeta,
    required String? mimeType,
    required String? hash,
    required int size,
    required DateTime? uploadedAt,
    required String? uploadedTo,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnCloudFile;

  factory SnCloudFile.fromJson(Map<String, dynamic> json) =>
      _$SnCloudFileFromJson(json);
}
