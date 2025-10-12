// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myStickerPacksHash() => r'1e19832e8ab1cb139ad18aebfa5aebdf4fdea499';

/// Fetch user-added sticker packs (with stickers) from API:
/// GET /sphere/stickers/me
///
/// Copied from [myStickerPacks].
@ProviderFor(myStickerPacks)
final myStickerPacksProvider =
    AutoDisposeFutureProvider<List<SnStickerPack>>.internal(
      myStickerPacks,
      name: r'myStickerPacksProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$myStickerPacksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyStickerPacksRef = AutoDisposeFutureProviderRef<List<SnStickerPack>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
