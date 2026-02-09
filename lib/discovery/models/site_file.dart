import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_file.freezed.dart';
part 'site_file.g.dart';

@freezed
sealed class SnSiteFileEntry with _$SnSiteFileEntry {
  const factory SnSiteFileEntry({
    required bool isDirectory,
    required String relativePath,
    required int size, // Size in bytes (0 for directories)
    required DateTime modified, // ISO 8601 timestamp
  }) = _SnSiteFileEntry;

  factory SnSiteFileEntry.fromJson(Map<String, dynamic> json) =>
      _$SnSiteFileEntryFromJson(json);
}

@freezed
sealed class SnFileContent with _$SnFileContent {
  const factory SnFileContent({required String content}) = _SnFileContent;

  factory SnFileContent.fromJson(Map<String, dynamic> json) =>
      _$SnFileContentFromJson(json);
}
