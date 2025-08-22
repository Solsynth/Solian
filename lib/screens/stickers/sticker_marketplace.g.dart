// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_marketplace.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketplaceStickerPacksNotifierHash() =>
    r'3bde76e18bb024f45ff6261fe735cdba97b02808';

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

abstract class _$MarketplaceStickerPacksNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnStickerPack>> {
  late final String? query;
  late final bool byUsage;

  FutureOr<CursorPagingData<SnStickerPack>> build({
    required String? query,
    required bool byUsage,
  });
}

/// See also [MarketplaceStickerPacksNotifier].
@ProviderFor(MarketplaceStickerPacksNotifier)
const marketplaceStickerPacksNotifierProvider =
    MarketplaceStickerPacksNotifierFamily();

/// See also [MarketplaceStickerPacksNotifier].
class MarketplaceStickerPacksNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnStickerPack>>> {
  /// See also [MarketplaceStickerPacksNotifier].
  const MarketplaceStickerPacksNotifierFamily();

  /// See also [MarketplaceStickerPacksNotifier].
  MarketplaceStickerPacksNotifierProvider call({
    required String? query,
    required bool byUsage,
  }) {
    return MarketplaceStickerPacksNotifierProvider(
      query: query,
      byUsage: byUsage,
    );
  }

  @override
  MarketplaceStickerPacksNotifierProvider getProviderOverride(
    covariant MarketplaceStickerPacksNotifierProvider provider,
  ) {
    return call(query: provider.query, byUsage: provider.byUsage);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketplaceStickerPacksNotifierProvider';
}

/// See also [MarketplaceStickerPacksNotifier].
class MarketplaceStickerPacksNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MarketplaceStickerPacksNotifier,
          CursorPagingData<SnStickerPack>
        > {
  /// See also [MarketplaceStickerPacksNotifier].
  MarketplaceStickerPacksNotifierProvider({
    required String? query,
    required bool byUsage,
  }) : this._internal(
         () =>
             MarketplaceStickerPacksNotifier()
               ..query = query
               ..byUsage = byUsage,
         from: marketplaceStickerPacksNotifierProvider,
         name: r'marketplaceStickerPacksNotifierProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$marketplaceStickerPacksNotifierHash,
         dependencies: MarketplaceStickerPacksNotifierFamily._dependencies,
         allTransitiveDependencies:
             MarketplaceStickerPacksNotifierFamily._allTransitiveDependencies,
         query: query,
         byUsage: byUsage,
       );

  MarketplaceStickerPacksNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.byUsage,
  }) : super.internal();

  final String? query;
  final bool byUsage;

  @override
  FutureOr<CursorPagingData<SnStickerPack>> runNotifierBuild(
    covariant MarketplaceStickerPacksNotifier notifier,
  ) {
    return notifier.build(query: query, byUsage: byUsage);
  }

  @override
  Override overrideWith(MarketplaceStickerPacksNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MarketplaceStickerPacksNotifierProvider._internal(
        () =>
            create()
              ..query = query
              ..byUsage = byUsage,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        byUsage: byUsage,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MarketplaceStickerPacksNotifier,
    CursorPagingData<SnStickerPack>
  >
  createElement() {
    return _MarketplaceStickerPacksNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceStickerPacksNotifierProvider &&
        other.query == query &&
        other.byUsage == byUsage;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, byUsage.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketplaceStickerPacksNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnStickerPack>> {
  /// The parameter `query` of this provider.
  String? get query;

  /// The parameter `byUsage` of this provider.
  bool get byUsage;
}

class _MarketplaceStickerPacksNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MarketplaceStickerPacksNotifier,
          CursorPagingData<SnStickerPack>
        >
    with MarketplaceStickerPacksNotifierRef {
  _MarketplaceStickerPacksNotifierProviderElement(super.provider);

  @override
  String? get query =>
      (origin as MarketplaceStickerPacksNotifierProvider).query;
  @override
  bool get byUsage =>
      (origin as MarketplaceStickerPacksNotifierProvider).byUsage;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
