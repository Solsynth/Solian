// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Marketplace version of sticker pack detail page (no publisher dependency).
/// Shows all stickers in the pack and provides a button to add the sticker.
/// API interactions are intentionally left blank per request.

@ProviderFor(marketplaceStickerPackContent)
final marketplaceStickerPackContentProvider =
    MarketplaceStickerPackContentFamily._();

/// Marketplace version of sticker pack detail page (no publisher dependency).
/// Shows all stickers in the pack and provides a button to add the sticker.
/// API interactions are intentionally left blank per request.

final class MarketplaceStickerPackContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnSticker>>,
          List<SnSticker>,
          FutureOr<List<SnSticker>>
        >
    with $FutureModifier<List<SnSticker>>, $FutureProvider<List<SnSticker>> {
  /// Marketplace version of sticker pack detail page (no publisher dependency).
  /// Shows all stickers in the pack and provides a button to add the sticker.
  /// API interactions are intentionally left blank per request.
  MarketplaceStickerPackContentProvider._({
    required MarketplaceStickerPackContentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'marketplaceStickerPackContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$marketplaceStickerPackContentHash();

  @override
  String toString() {
    return r'marketplaceStickerPackContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnSticker>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnSticker>> create(Ref ref) {
    final argument = this.argument as String;
    return marketplaceStickerPackContent(ref, packId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceStickerPackContentProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$marketplaceStickerPackContentHash() =>
    r'b5c9e3e25e0cca7fc2022edce656246bb48a7415';

/// Marketplace version of sticker pack detail page (no publisher dependency).
/// Shows all stickers in the pack and provides a button to add the sticker.
/// API interactions are intentionally left blank per request.

final class MarketplaceStickerPackContentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnSticker>>, String> {
  MarketplaceStickerPackContentFamily._()
    : super(
        retry: null,
        name: r'marketplaceStickerPackContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Marketplace version of sticker pack detail page (no publisher dependency).
  /// Shows all stickers in the pack and provides a button to add the sticker.
  /// API interactions are intentionally left blank per request.

  MarketplaceStickerPackContentProvider call({required String packId}) =>
      MarketplaceStickerPackContentProvider._(argument: packId, from: this);

  @override
  String toString() => r'marketplaceStickerPackContentProvider';
}

@ProviderFor(marketplaceStickerPackOwnership)
final marketplaceStickerPackOwnershipProvider =
    MarketplaceStickerPackOwnershipFamily._();

final class MarketplaceStickerPackOwnershipProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  MarketplaceStickerPackOwnershipProvider._({
    required MarketplaceStickerPackOwnershipFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'marketplaceStickerPackOwnershipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$marketplaceStickerPackOwnershipHash();

  @override
  String toString() {
    return r'marketplaceStickerPackOwnershipProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return marketplaceStickerPackOwnership(ref, packId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceStickerPackOwnershipProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$marketplaceStickerPackOwnershipHash() =>
    r'7d71ddcff83b1e01c593c59f5c9b80b6d691bd30';

final class MarketplaceStickerPackOwnershipFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  MarketplaceStickerPackOwnershipFamily._()
    : super(
        retry: null,
        name: r'marketplaceStickerPackOwnershipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MarketplaceStickerPackOwnershipProvider call({required String packId}) =>
      MarketplaceStickerPackOwnershipProvider._(argument: packId, from: this);

  @override
  String toString() => r'marketplaceStickerPackOwnershipProvider';
}
