// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnSiteFileEntry _$SnSiteFileEntryFromJson(Map<String, dynamic> json) =>
    _SnSiteFileEntry(
      isDirectory: json['is_directory'] as bool,
      relativePath: json['relative_path'] as String,
      size: (json['size'] as num).toInt(),
      modified: DateTime.parse(json['modified'] as String),
    );

Map<String, dynamic> _$SnSiteFileEntryToJson(_SnSiteFileEntry instance) =>
    <String, dynamic>{
      'is_directory': instance.isDirectory,
      'relative_path': instance.relativePath,
      'size': instance.size,
      'modified': instance.modified.toIso8601String(),
    };

_SnFileContent _$SnFileContentFromJson(Map<String, dynamic> json) =>
    _SnFileContent(content: json['content'] as String);

Map<String, dynamic> _$SnFileContentToJson(_SnFileContent instance) =>
    <String, dynamic>{'content': instance.content};
