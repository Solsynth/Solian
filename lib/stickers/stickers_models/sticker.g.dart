// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnSticker _$SnStickerFromJson(Map<String, dynamic> json) => _SnSticker(
  id: json['id'] as String,
  slug: json['slug'] as String,
  image: SnCloudFile.fromJson(json['image'] as Map<String, dynamic>),
  packId: json['pack_id'] as String,
  pack: json['pack'] == null
      ? null
      : SnStickerPack.fromJson(json['pack'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnStickerToJson(_SnSticker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'image': instance.image.toJson(),
      'pack_id': instance.packId,
      'pack': instance.pack?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnStickerPack _$SnStickerPackFromJson(Map<String, dynamic> json) =>
    _SnStickerPack(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      prefix: json['prefix'] as String,
      publisherId: json['publisher_id'] as String,
      icon: json['icon'] == null
          ? null
          : SnCloudFile.fromJson(json['icon'] as Map<String, dynamic>),
      publisher: json['publisher'] == null
          ? null
          : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      stickers:
          (json['stickers'] as List<dynamic>?)
              ?.map((e) => SnSticker.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SnStickerPackToJson(_SnStickerPack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'prefix': instance.prefix,
      'publisher_id': instance.publisherId,
      'icon': instance.icon?.toJson(),
      'publisher': instance.publisher?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'stickers': instance.stickers.map((e) => e.toJson()).toList(),
    };
