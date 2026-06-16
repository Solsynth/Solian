// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorized_app.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthorizedApp _$AuthorizedAppFromJson(Map<String, dynamic> json) =>
    _AuthorizedApp(
      id: json['id'] as String,
      type: (json['type'] as num?)?.toInt() ?? 0,
      appId: json['app_id'] as String,
      appSlug: json['app_slug'] as String?,
      appName: json['app_name'] as String?,
      appDescription: json['app_description'] as String?,
      picture: json['picture'] == null
          ? null
          : SnCloudFileReference.fromJson(
              json['picture'] as Map<String, dynamic>,
            ),
      background: json['background'] == null
          ? null
          : SnCloudFileReference.fromJson(
              json['background'] as Map<String, dynamic>,
            ),
      lastAuthorizedAt: json['last_authorized_at'] as String?,
      lastUsedAt: json['last_used_at'] as String?,
    );

Map<String, dynamic> _$AuthorizedAppToJson(_AuthorizedApp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'app_id': instance.appId,
      'app_slug': instance.appSlug,
      'app_name': instance.appName,
      'app_description': instance.appDescription,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'last_authorized_at': instance.lastAuthorizedAt,
      'last_used_at': instance.lastUsedAt,
    };
