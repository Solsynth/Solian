// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPostTag _$SnPostTagFromJson(Map<String, dynamic> json) => _SnPostTag(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String?,
  posts:
      (json['posts'] as List<dynamic>?)
          ?.map((e) => SnPost.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  usage: (json['usage'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SnPostTagToJson(_SnPostTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'posts': instance.posts.map((e) => e.toJson()).toList(),
      'usage': instance.usage,
    };
