import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'interface.freezed.dart';
part 'interface.g.dart';

@freezed
sealed class PluginMetadata with _$PluginMetadata {
  const factory PluginMetadata({
    required String id,
    required String name,
    required String version,
    required String description,
    String? author,
    DateTime? updatedAt,
  }) = _PluginMetadata;

  factory PluginMetadata.fromJson(Map<String, dynamic> json) =>
      _$PluginMetadataFromJson(json);
}

abstract class Plugin {
  PluginMetadata get metadata;
}

abstract class RawPlugin extends Plugin {}

abstract class MiniApp extends Plugin {
  Widget buildEntry();
}

@freezed
sealed class MiniAppMetadata with _$MiniAppMetadata {
  const factory MiniAppMetadata({
    required String id,
    required String name,
    required String version,
    required String description,
    String? author,
    String? iconUrl,
    required String downloadUrl,
    String? localCachePath,
    DateTime? lastUpdated,
    DateTime? lastChecked,
    @Default(false) bool isEnabled,
    @Default(0) int localVersion,
    int? sizeBytes,
  }) = _MiniAppMetadata;

  factory MiniAppMetadata.fromJson(Map<String, dynamic> json) =>
      _$MiniAppMetadataFromJson(json);
}

@freezed
sealed class MiniAppServerInfo with _$MiniAppServerInfo {
  const factory MiniAppServerInfo({
    required String id,
    required String name,
    required String version,
    required String description,
    String? author,
    String? iconUrl,
    required String downloadUrl,
    required DateTime updatedAt,
    required int sizeBytes,
  }) = _MiniAppServerInfo;

  factory MiniAppServerInfo.fromJson(Map<String, dynamic> json) =>
      _$MiniAppServerInfoFromJson(json);
}

enum PluginLoadResult { success, failed, alreadyLoaded }
