// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetch user-added sticker packs (with stickers) from API:
/// GET /sphere/stickers/me

@ProviderFor(myStickerPacks)
final myStickerPacksProvider = MyStickerPacksProvider._();

/// Fetch user-added sticker packs (with stickers) from API:
/// GET /sphere/stickers/me

final class MyStickerPacksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnStickerPack>>,
          List<SnStickerPack>,
          FutureOr<List<SnStickerPack>>
        >
    with
        $FutureModifier<List<SnStickerPack>>,
        $FutureProvider<List<SnStickerPack>> {
  /// Fetch user-added sticker packs (with stickers) from API:
  /// GET /sphere/stickers/me
  MyStickerPacksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myStickerPacksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myStickerPacksHash();

  @$internal
  @override
  $FutureProviderElement<List<SnStickerPack>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnStickerPack>> create(Ref ref) {
    return myStickerPacks(ref);
  }
}

String _$myStickerPacksHash() => r'1e19832e8ab1cb139ad18aebfa5aebdf4fdea499';
