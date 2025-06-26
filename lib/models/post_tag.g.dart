// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostTag _$PostTagFromJson(Map<String, dynamic> json) => _PostTag(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String?,
  posts:
      (json['posts'] as List<dynamic>?)
          ?.map((e) => SnPost.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PostTagToJson(_PostTag instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'posts': instance.posts.map((e) => e.toJson()).toList(),
};
