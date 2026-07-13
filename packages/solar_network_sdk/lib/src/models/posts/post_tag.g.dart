// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPostTag _$SnPostTagFromJson(Map<String, dynamic> json) => _SnPostTag(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String?,
  description: json['description'] as String?,
  ownerPublisherId: json['owner_publisher_id'] as String?,
  ownerPublisher: json['owner_publisher'] == null
      ? null
      : SnPublisher.fromJson(json['owner_publisher'] as Map<String, dynamic>),
  isProtected: json['is_protected'] as bool? ?? false,
  isEvent: json['is_event'] as bool? ?? false,
  eventEndsAt: json['event_ends_at'] == null
      ? null
      : DateTime.parse(json['event_ends_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'description': instance.description,
      'owner_publisher_id': instance.ownerPublisherId,
      'owner_publisher': instance.ownerPublisher?.toJson(),
      'is_protected': instance.isProtected,
      'is_event': instance.isEvent,
      'event_ends_at': instance.eventEndsAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'posts': instance.posts.map((e) => e.toJson()).toList(),
      'usage': instance.usage,
    };
