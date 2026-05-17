import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'sticker.freezed.dart';
part 'sticker.g.dart';

int _stickerEnumFromJson(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
    switch (value) {
      case 'auto':
      case 'sticker':
        return 0;
      case 'small':
        return 1;
      case 'medium':
        return 2;
      case 'large':
      case 'emote':
        return 3;
    }
  }
  return fallback;
}

int _stickerSizeFromJson(dynamic value) => _stickerEnumFromJson(value, 0);
int _stickerModeFromJson(dynamic value) {
  final parsed = _stickerEnumFromJson(value, 0);
  return parsed > 1 ? 0 : parsed;
}

@freezed
sealed class SnSticker with _$SnSticker {
  const factory SnSticker({
    required String id,
    required String slug,
    String? name,
    required SnCloudFileReference image,
    @Default(0) int order,
    @JsonKey(fromJson: _stickerSizeFromJson) @Default(0) int size,
    @JsonKey(fromJson: _stickerModeFromJson) @Default(0) int mode,
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
    required SnCloudFileReference? icon,
    required SnPublisher? publisher,
    @Default(0) int order,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    @Default([]) List<SnSticker> stickers,
  }) = _SnStickerPack;

  factory SnStickerPack.fromJson(Map<String, dynamic> json) =>
      _$SnStickerPackFromJson(json);
}

@freezed
sealed class SnStickerOwnership with _$SnStickerOwnership {
  const factory SnStickerOwnership({
    required String id,
    @JsonKey(name: 'pack_id') required String packId,
    required SnStickerPack? pack,
    @JsonKey(name: 'account_id') required String accountId,
    required SnAccount? account,
    @Default(0) int order,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnStickerOwnership;

  factory SnStickerOwnership.fromJson(Map<String, dynamic> json) =>
      _$SnStickerOwnershipFromJson(json);
}
