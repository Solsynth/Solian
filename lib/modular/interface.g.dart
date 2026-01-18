// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interface.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PluginMetadata _$PluginMetadataFromJson(Map<String, dynamic> json) =>
    _PluginMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PluginMetadataToJson(_PluginMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'author': instance.author,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_MiniAppMetadata _$MiniAppMetadataFromJson(Map<String, dynamic> json) =>
    _MiniAppMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String?,
      iconUrl: json['icon_url'] as String?,
      downloadUrl: json['download_url'] as String,
      localCachePath: json['local_cache_path'] as String?,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
      lastChecked: json['last_checked'] == null
          ? null
          : DateTime.parse(json['last_checked'] as String),
      isEnabled: json['is_enabled'] as bool? ?? false,
      localVersion: (json['local_version'] as num?)?.toInt() ?? 0,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MiniAppMetadataToJson(_MiniAppMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'author': instance.author,
      'icon_url': instance.iconUrl,
      'download_url': instance.downloadUrl,
      'local_cache_path': instance.localCachePath,
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'last_checked': instance.lastChecked?.toIso8601String(),
      'is_enabled': instance.isEnabled,
      'local_version': instance.localVersion,
      'size_bytes': instance.sizeBytes,
    };

_MiniAppServerInfo _$MiniAppServerInfoFromJson(Map<String, dynamic> json) =>
    _MiniAppServerInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String?,
      iconUrl: json['icon_url'] as String?,
      downloadUrl: json['download_url'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sizeBytes: (json['size_bytes'] as num).toInt(),
    );

Map<String, dynamic> _$MiniAppServerInfoToJson(_MiniAppServerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'author': instance.author,
      'icon_url': instance.iconUrl,
      'download_url': instance.downloadUrl,
      'updated_at': instance.updatedAt.toIso8601String(),
      'size_bytes': instance.sizeBytes,
    };
