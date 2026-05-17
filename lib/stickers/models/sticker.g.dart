// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnSticker _$SnStickerFromJson(Map<String, dynamic> json) => _SnSticker(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String?,
  image: SnCloudFileReference.fromJson(json['image'] as Map<String, dynamic>),
  order: (json['order'] as num?)?.toInt() ?? 0,
  size: json['size'] == null ? 0 : _stickerSizeFromJson(json['size']),
  mode: json['mode'] == null ? 0 : _stickerModeFromJson(json['mode']),
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
      'name': instance.name,
      'image': instance.image.toJson(),
      'order': instance.order,
      'size': instance.size,
      'mode': instance.mode,
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
          : SnCloudFileReference.fromJson(json['icon'] as Map<String, dynamic>),
      publisher: json['publisher'] == null
          ? null
          : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
      order: (json['order'] as num?)?.toInt() ?? 0,
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
      'order': instance.order,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'stickers': instance.stickers.map((e) => e.toJson()).toList(),
    };

_SnStickerOwnership _$SnStickerOwnershipFromJson(Map<String, dynamic> json) =>
    _SnStickerOwnership(
      id: json['id'] as String,
      packId: json['pack_id'] as String,
      pack: json['pack'] == null
          ? null
          : SnStickerPack.fromJson(json['pack'] as Map<String, dynamic>),
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnStickerOwnershipToJson(_SnStickerOwnership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pack_id': instance.packId,
      'pack': instance.pack?.toJson(),
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'order': instance.order,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
