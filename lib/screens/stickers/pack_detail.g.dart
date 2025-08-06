// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketplaceStickerPackContentHash() =>
    r'886f8305c978dbea6e5d990a7d555048ac704a5d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Marketplace version of sticker pack detail page (no publisher dependency).
/// Shows all stickers in the pack and provides a button to add the sticker.
/// API interactions are intentionally left blank per request.
///
/// Copied from [marketplaceStickerPackContent].
@ProviderFor(marketplaceStickerPackContent)
const marketplaceStickerPackContentProvider =
    MarketplaceStickerPackContentFamily();

/// Marketplace version of sticker pack detail page (no publisher dependency).
/// Shows all stickers in the pack and provides a button to add the sticker.
/// API interactions are intentionally left blank per request.
///
/// Copied from [marketplaceStickerPackContent].
class MarketplaceStickerPackContentFamily
    extends Family<AsyncValue<List<SnSticker>>> {
  /// Marketplace version of sticker pack detail page (no publisher dependency).
  /// Shows all stickers in the pack and provides a button to add the sticker.
  /// API interactions are intentionally left blank per request.
  ///
  /// Copied from [marketplaceStickerPackContent].
  const MarketplaceStickerPackContentFamily();

  /// Marketplace version of sticker pack detail page (no publisher dependency).
  /// Shows all stickers in the pack and provides a button to add the sticker.
  /// API interactions are intentionally left blank per request.
  ///
  /// Copied from [marketplaceStickerPackContent].
  MarketplaceStickerPackContentProvider call({required String packId}) {
    return MarketplaceStickerPackContentProvider(packId: packId);
  }

  @override
  MarketplaceStickerPackContentProvider getProviderOverride(
    covariant MarketplaceStickerPackContentProvider provider,
  ) {
    return call(packId: provider.packId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketplaceStickerPackContentProvider';
}

/// Marketplace version of sticker pack detail page (no publisher dependency).
/// Shows all stickers in the pack and provides a button to add the sticker.
/// API interactions are intentionally left blank per request.
///
/// Copied from [marketplaceStickerPackContent].
class MarketplaceStickerPackContentProvider
    extends AutoDisposeFutureProvider<List<SnSticker>> {
  /// Marketplace version of sticker pack detail page (no publisher dependency).
  /// Shows all stickers in the pack and provides a button to add the sticker.
  /// API interactions are intentionally left blank per request.
  ///
  /// Copied from [marketplaceStickerPackContent].
  MarketplaceStickerPackContentProvider({required String packId})
    : this._internal(
        (ref) => marketplaceStickerPackContent(
          ref as MarketplaceStickerPackContentRef,
          packId: packId,
        ),
        from: marketplaceStickerPackContentProvider,
        name: r'marketplaceStickerPackContentProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$marketplaceStickerPackContentHash,
        dependencies: MarketplaceStickerPackContentFamily._dependencies,
        allTransitiveDependencies:
            MarketplaceStickerPackContentFamily._allTransitiveDependencies,
        packId: packId,
      );

  MarketplaceStickerPackContentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.packId,
  }) : super.internal();

  final String packId;

  @override
  Override overrideWith(
    FutureOr<List<SnSticker>> Function(
      MarketplaceStickerPackContentRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarketplaceStickerPackContentProvider._internal(
        (ref) => create(ref as MarketplaceStickerPackContentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        packId: packId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnSticker>> createElement() {
    return _MarketplaceStickerPackContentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceStickerPackContentProvider &&
        other.packId == packId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, packId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketplaceStickerPackContentRef
    on AutoDisposeFutureProviderRef<List<SnSticker>> {
  /// The parameter `packId` of this provider.
  String get packId;
}

class _MarketplaceStickerPackContentProviderElement
    extends AutoDisposeFutureProviderElement<List<SnSticker>>
    with MarketplaceStickerPackContentRef {
  _MarketplaceStickerPackContentProviderElement(super.provider);

  @override
  String get packId => (origin as MarketplaceStickerPackContentProvider).packId;
}

String _$marketplaceStickerPackOwnershipHash() =>
    r'e5dd301c309fac958729d13d984ce7a77edbe7e6';

/// See also [marketplaceStickerPackOwnership].
@ProviderFor(marketplaceStickerPackOwnership)
const marketplaceStickerPackOwnershipProvider =
    MarketplaceStickerPackOwnershipFamily();

/// See also [marketplaceStickerPackOwnership].
class MarketplaceStickerPackOwnershipFamily extends Family<AsyncValue<bool>> {
  /// See also [marketplaceStickerPackOwnership].
  const MarketplaceStickerPackOwnershipFamily();

  /// See also [marketplaceStickerPackOwnership].
  MarketplaceStickerPackOwnershipProvider call({required String packId}) {
    return MarketplaceStickerPackOwnershipProvider(packId: packId);
  }

  @override
  MarketplaceStickerPackOwnershipProvider getProviderOverride(
    covariant MarketplaceStickerPackOwnershipProvider provider,
  ) {
    return call(packId: provider.packId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketplaceStickerPackOwnershipProvider';
}

/// See also [marketplaceStickerPackOwnership].
class MarketplaceStickerPackOwnershipProvider
    extends AutoDisposeFutureProvider<bool> {
  /// See also [marketplaceStickerPackOwnership].
  MarketplaceStickerPackOwnershipProvider({required String packId})
    : this._internal(
        (ref) => marketplaceStickerPackOwnership(
          ref as MarketplaceStickerPackOwnershipRef,
          packId: packId,
        ),
        from: marketplaceStickerPackOwnershipProvider,
        name: r'marketplaceStickerPackOwnershipProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$marketplaceStickerPackOwnershipHash,
        dependencies: MarketplaceStickerPackOwnershipFamily._dependencies,
        allTransitiveDependencies:
            MarketplaceStickerPackOwnershipFamily._allTransitiveDependencies,
        packId: packId,
      );

  MarketplaceStickerPackOwnershipProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.packId,
  }) : super.internal();

  final String packId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(MarketplaceStickerPackOwnershipRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarketplaceStickerPackOwnershipProvider._internal(
        (ref) => create(ref as MarketplaceStickerPackOwnershipRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        packId: packId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _MarketplaceStickerPackOwnershipProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceStickerPackOwnershipProvider &&
        other.packId == packId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, packId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketplaceStickerPackOwnershipRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `packId` of this provider.
  String get packId;
}

class _MarketplaceStickerPackOwnershipProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with MarketplaceStickerPackOwnershipRef {
  _MarketplaceStickerPackOwnershipProviderElement(super.provider);

  @override
  String get packId =>
      (origin as MarketplaceStickerPackOwnershipProvider).packId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
