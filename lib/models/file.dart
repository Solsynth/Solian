import 'package:freezed_annotation/freezed_annotation.dart';

part 'file.freezed.dart';
part 'file.g.dart';

@freezed
abstract class SnCloudFile with _$SnCloudFile {
  const factory SnCloudFile({
    required String id,
    required String name,
    required String? description,
    required Map<String, dynamic>? fileMeta,
    required Map<String, dynamic>? userMeta,
    required String? mimeType,
    required String? hash,
    required int size,
    required DateTime uploadedAt,
    required String? uploadedTo,
    required int usedCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnCloudFile;

  factory SnCloudFile.fromJson(Map<String, dynamic> json) =>
      _$SnCloudFileFromJson(json);
}
