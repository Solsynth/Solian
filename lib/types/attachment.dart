import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment.freezed.dart';

part 'attachment.g.dart';

enum SnMediaType {
  image,
  video,
  audio,
  file,
}

@freezed
class SnAttachment with _$SnAttachment {
  const SnAttachment._();

  const factory SnAttachment({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String rid,
    required String uuid,
    required int size,
    required String name,
    required String alt,
    required String mimetype,
    required String hash,
    required int destination,
    required int refCount,
    @Default(0) int contentRating,
    @Default(0) int qualityRating,
    required DateTime? cleanedAt,
    required bool isAnalyzed,
    required bool isSelfRef,
    required bool isIndexable,
    required SnAttachment? ref,
    required int? refId,
    required SnAttachmentPool? pool,
    required int? poolId,
    required int accountId,
    int? thumbnailId,
    SnAttachment? thumbnail,
    int? compressedId,
    SnAttachment? compressed,
    @Default([]) List<SnAttachmentBoost> boosts,
    @Default({}) Map<String, dynamic> usermeta,
    @Default({}) Map<String, dynamic> metadata,
  }) = _SnAttachment;

  factory SnAttachment.fromJson(Map<String, Object?> json) => _$SnAttachmentFromJson(json);

  Map<String, dynamic> get data => {
        ...metadata,
        ...usermeta,
      };

  SnMediaType get mediaType => switch (mimetype.split('/').firstOrNull) {
        'image' => SnMediaType.image,
        'video' => SnMediaType.video,
        'audio' => SnMediaType.audio,
        _ => SnMediaType.file,
      };
}

@freezed
class SnAttachmentFragment with _$SnAttachmentFragment {
  const SnAttachmentFragment._();

  const factory SnAttachmentFragment({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String rid,
    required String uuid,
    required int size,
    required String name,
    required String alt,
    required String mimetype,
    required String hash,
    String? fingerprint,
    @Default({}) Map<String, int> fileChunks,
    @Default([]) List<String> fileChunksMissing,
  }) = _SnAttachmentFragment;

  factory SnAttachmentFragment.fromJson(Map<String, Object?> json) => _$SnAttachmentFragmentFromJson(json);

  SnMediaType get mediaType => switch (mimetype.split('/').firstOrNull) {
        'image' => SnMediaType.image,
        'video' => SnMediaType.video,
        'audio' => SnMediaType.audio,
        _ => SnMediaType.file,
      };
}

@freezed
class SnAttachmentPool with _$SnAttachmentPool {
  const factory SnAttachmentPool({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String alias,
    required String name,
    required String description,
    required Map<String, dynamic> config,
    required int? accountId,
  }) = _SnAttachmentPool;

  factory SnAttachmentPool.fromJson(Map<String, Object?> json) => _$SnAttachmentPoolFromJson(json);
}

@freezed
class SnAttachmentDestination with _$SnAttachmentDestination {
  const factory SnAttachmentDestination({
    @Default(0) int id,
    required String type,
    required String label,
    required String region,
    required bool isBoost,
  }) = _SnAttachmentDestination;

  factory SnAttachmentDestination.fromJson(Map<String, Object?> json) => _$SnAttachmentDestinationFromJson(json);
}

@freezed
class SnAttachmentBoost with _$SnAttachmentBoost {
  const factory SnAttachmentBoost({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required int status,
    required int destination,
    required int attachmentId,
    required SnAttachment attachment,
    required int account,
  }) = _SnAttachmentBoost;

  factory SnAttachmentBoost.fromJson(Map<String, Object?> json) => _$SnAttachmentBoostFromJson(json);
}

@freezed
class SnSticker with _$SnSticker {
  const factory SnSticker({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String alias,
    required String name,
    required int attachmentId,
    required SnAttachment attachment,
    required int packId,
    required SnStickerPack pack,
    required int accountId,
  }) = _SnSticker;

  factory SnSticker.fromJson(Map<String, Object?> json) => _$SnStickerFromJson(json);
}

@freezed
class SnStickerPack with _$SnStickerPack {
  const factory SnStickerPack({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String prefix,
    required String name,
    required String description,
    required List<SnSticker>? stickers,
    required int accountId,
  }) = _SnStickerPack;

  factory SnStickerPack.fromJson(Map<String, Object?> json) => _$SnStickerPackFromJson(json);
}

@freezed
class SnAttachmentBilling with _$SnAttachmentBilling {
  const factory SnAttachmentBilling({
    required int currentBytes,
    required int discountFileSize,
    required double includedRatio,
  }) = _SnAttachmentBilling;

  factory SnAttachmentBilling.fromJson(Map<String, Object?> json) => _$SnAttachmentBillingFromJson(json);
}
