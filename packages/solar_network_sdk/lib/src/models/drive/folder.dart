import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder.freezed.dart';
part 'folder.g.dart';

@freezed
sealed class SnCloudFolder with _$SnCloudFolder {
  const factory SnCloudFolder({
    required String id,
    required String name,
    required String? parentFolderId,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SnCloudFolder;

  factory SnCloudFolder.fromJson(Map<String, dynamic> json) =>
      _$SnCloudFolderFromJson(json);
}
