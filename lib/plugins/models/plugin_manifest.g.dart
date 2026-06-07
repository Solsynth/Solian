// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PluginManifest _$PluginManifestFromJson(Map<String, dynamic> json) =>
    _PluginManifest(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String? ?? '1.0.0',
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      entry: json['entry'] as String? ?? 'main.js',
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$PluginPermissionEnumMap, e))
              .toList() ??
          const [],
      background: json['background'] as bool? ?? false,
      icon: json['icon'] as String?,
      homepage: json['homepage'] as String?,
    );

Map<String, dynamic> _$PluginManifestToJson(_PluginManifest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'author': instance.author,
      'description': instance.description,
      'entry': instance.entry,
      'permissions': instance.permissions
          .map((e) => _$PluginPermissionEnumMap[e]!)
          .toList(),
      'background': instance.background,
      'icon': instance.icon,
      'homepage': instance.homepage,
    };

const _$PluginPermissionEnumMap = {
  PluginPermission.eventsSubscribe: 'eventsSubscribe',
  PluginPermission.commandsRegister: 'commandsRegister',
  PluginPermission.uiRender: 'uiRender',
  PluginPermission.sdkPostsRead: 'sdkPostsRead',
  PluginPermission.sdkPostsCreate: 'sdkPostsCreate',
  PluginPermission.sdkChatRead: 'sdkChatRead',
  PluginPermission.sdkChatSend: 'sdkChatSend',
  PluginPermission.sdkDriveRead: 'sdkDriveRead',
  PluginPermission.sdkDriveWrite: 'sdkDriveWrite',
  PluginPermission.sdkUserRead: 'sdkUserRead',
  PluginPermission.notify: 'notify',
  PluginPermission.tasksSchedule: 'tasksSchedule',
};
