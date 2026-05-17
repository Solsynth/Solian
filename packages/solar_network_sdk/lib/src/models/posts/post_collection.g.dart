// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPostCollection _$SnPostCollectionFromJson(Map<String, dynamic> json) =>
    _SnPostCollection(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      publisherId: json['publisher_id'] as String,
      publisher: json['publisher'] == null
          ? null
          : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
      background: json['background'] == null
          ? null
          : SnCloudFileReference.fromJson(
              json['background'] as Map<String, dynamic>,
            ),
      icon: json['icon'] == null
          ? null
          : SnCloudFileReference.fromJson(json['icon'] as Map<String, dynamic>),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SnPostCollectionToJson(_SnPostCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'publisher_id': instance.publisherId,
      'publisher': instance.publisher?.toJson(),
      'background': instance.background?.toJson(),
      'icon': instance.icon?.toJson(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
