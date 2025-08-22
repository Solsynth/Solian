// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_marketplace.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketplaceWebFeedsNotifierHash() =>
    r'dbf885d95570ca9c2259a58998975db813b18cbb';

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

abstract class _$MarketplaceWebFeedsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnWebFeed>> {
  late final String? query;

  FutureOr<CursorPagingData<SnWebFeed>> build({required String? query});
}

/// See also [MarketplaceWebFeedsNotifier].
@ProviderFor(MarketplaceWebFeedsNotifier)
const marketplaceWebFeedsNotifierProvider = MarketplaceWebFeedsNotifierFamily();

/// See also [MarketplaceWebFeedsNotifier].
class MarketplaceWebFeedsNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnWebFeed>>> {
  /// See also [MarketplaceWebFeedsNotifier].
  const MarketplaceWebFeedsNotifierFamily();

  /// See also [MarketplaceWebFeedsNotifier].
  MarketplaceWebFeedsNotifierProvider call({required String? query}) {
    return MarketplaceWebFeedsNotifierProvider(query: query);
  }

  @override
  MarketplaceWebFeedsNotifierProvider getProviderOverride(
    covariant MarketplaceWebFeedsNotifierProvider provider,
  ) {
    return call(query: provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketplaceWebFeedsNotifierProvider';
}

/// See also [MarketplaceWebFeedsNotifier].
class MarketplaceWebFeedsNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MarketplaceWebFeedsNotifier,
          CursorPagingData<SnWebFeed>
        > {
  /// See also [MarketplaceWebFeedsNotifier].
  MarketplaceWebFeedsNotifierProvider({required String? query})
    : this._internal(
        () => MarketplaceWebFeedsNotifier()..query = query,
        from: marketplaceWebFeedsNotifierProvider,
        name: r'marketplaceWebFeedsNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$marketplaceWebFeedsNotifierHash,
        dependencies: MarketplaceWebFeedsNotifierFamily._dependencies,
        allTransitiveDependencies:
            MarketplaceWebFeedsNotifierFamily._allTransitiveDependencies,
        query: query,
      );

  MarketplaceWebFeedsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String? query;

  @override
  FutureOr<CursorPagingData<SnWebFeed>> runNotifierBuild(
    covariant MarketplaceWebFeedsNotifier notifier,
  ) {
    return notifier.build(query: query);
  }

  @override
  Override overrideWith(MarketplaceWebFeedsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MarketplaceWebFeedsNotifierProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MarketplaceWebFeedsNotifier,
    CursorPagingData<SnWebFeed>
  >
  createElement() {
    return _MarketplaceWebFeedsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceWebFeedsNotifierProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketplaceWebFeedsNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnWebFeed>> {
  /// The parameter `query` of this provider.
  String? get query;
}

class _MarketplaceWebFeedsNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MarketplaceWebFeedsNotifier,
          CursorPagingData<SnWebFeed>
        >
    with MarketplaceWebFeedsNotifierRef {
  _MarketplaceWebFeedsNotifierProviderElement(super.provider);

  @override
  String? get query => (origin as MarketplaceWebFeedsNotifierProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
