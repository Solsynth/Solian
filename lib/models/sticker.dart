import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';
import 'package:island/models/publisher.dart';

part 'sticker.freezed.dart';
part 'sticker.g.dart';

@freezed
sealed class SnSticker with _$SnSticker {
  const factory SnSticker({
    required String id,
    required String slug,
    required String imageId,
    required SnCloudFile image,
    required String packId,
    required SnStickerPack? pack,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnSticker;

  factory SnSticker.fromJson(Map<String, dynamic> json) =>
      _$SnStickerFromJson(json);
}

@freezed
sealed class SnStickerPack with _$SnStickerPack {
  const factory SnStickerPack({
    required String id,
    required String name,
    required String description,
    required String prefix,
    required String publisherId,
    required SnPublisher? publisher,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnStickerPack;

  factory SnStickerPack.fromJson(Map<String, dynamic> json) =>
      _$SnStickerPackFromJson(json);
}
