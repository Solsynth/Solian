// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnLinkMeta _$SnLinkMetaFromJson(Map<String, dynamic> json) => _SnLinkMeta(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      entryId: json['entry_id'] as String,
      icon: json['icon'] as String?,
      url: json['url'] as String,
      title: json['title'] as String?,
      image: json['image'] as String?,
      video: json['video'] as String?,
      audio: json['audio'] as String?,
      description: json['description'] as String?,
      siteName: json['site_name'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$SnLinkMetaToJson(_SnLinkMeta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'entry_id': instance.entryId,
      'icon': instance.icon,
      'url': instance.url,
      'title': instance.title,
      'image': instance.image,
      'video': instance.video,
      'audio': instance.audio,
      'description': instance.description,
      'site_name': instance.siteName,
      'type': instance.type,
    };
