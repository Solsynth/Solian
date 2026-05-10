// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetch user-added sticker packs (with stickers) from API:
/// GET /sphere/stickers/me

@ProviderFor(myStickerOwnerships)
final myStickerOwnershipsProvider = MyStickerOwnershipsProvider._();

/// Fetch user-added sticker packs (with stickers) from API:
/// GET /sphere/stickers/me

final class MyStickerOwnershipsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnStickerOwnership>>,
          List<SnStickerOwnership>,
          FutureOr<List<SnStickerOwnership>>
        >
    with
        $FutureModifier<List<SnStickerOwnership>>,
        $FutureProvider<List<SnStickerOwnership>> {
  /// Fetch user-added sticker packs (with stickers) from API:
  /// GET /sphere/stickers/me
  MyStickerOwnershipsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myStickerOwnershipsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myStickerOwnershipsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnStickerOwnership>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnStickerOwnership>> create(Ref ref) {
    return myStickerOwnerships(ref);
  }
}

String _$myStickerOwnershipsHash() =>
    r'4b7808d416d83a520d4030929a2814d71757474a';

@ProviderFor(myStickerPacks)
final myStickerPacksProvider = MyStickerPacksProvider._();

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

String _$myStickerPacksHash() => r'cf55548809ae4ea89570c94f418a0d6d794767e7';
