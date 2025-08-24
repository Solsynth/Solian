// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketplaceWebFeedHash() =>
    r'8383f94f1bc272b903c341b8d95000313b69d14c';

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

/// See also [marketplaceWebFeed].
@ProviderFor(marketplaceWebFeed)
const marketplaceWebFeedProvider = MarketplaceWebFeedFamily();

/// See also [marketplaceWebFeed].
class MarketplaceWebFeedFamily extends Family<AsyncValue<SnWebFeed>> {
  /// See also [marketplaceWebFeed].
  const MarketplaceWebFeedFamily();

  /// See also [marketplaceWebFeed].
  MarketplaceWebFeedProvider call(String feedId) {
    return MarketplaceWebFeedProvider(feedId);
  }

  @override
  MarketplaceWebFeedProvider getProviderOverride(
    covariant MarketplaceWebFeedProvider provider,
  ) {
    return call(provider.feedId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketplaceWebFeedProvider';
}

/// See also [marketplaceWebFeed].
class MarketplaceWebFeedProvider extends AutoDisposeFutureProvider<SnWebFeed> {
  /// See also [marketplaceWebFeed].
  MarketplaceWebFeedProvider(String feedId)
    : this._internal(
        (ref) => marketplaceWebFeed(ref as MarketplaceWebFeedRef, feedId),
        from: marketplaceWebFeedProvider,
        name: r'marketplaceWebFeedProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$marketplaceWebFeedHash,
        dependencies: MarketplaceWebFeedFamily._dependencies,
        allTransitiveDependencies:
            MarketplaceWebFeedFamily._allTransitiveDependencies,
        feedId: feedId,
      );

  MarketplaceWebFeedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedId,
  }) : super.internal();

  final String feedId;

  @override
  Override overrideWith(
    FutureOr<SnWebFeed> Function(MarketplaceWebFeedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarketplaceWebFeedProvider._internal(
        (ref) => create(ref as MarketplaceWebFeedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feedId: feedId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnWebFeed> createElement() {
    return _MarketplaceWebFeedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceWebFeedProvider && other.feedId == feedId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feedId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketplaceWebFeedRef on AutoDisposeFutureProviderRef<SnWebFeed> {
  /// The parameter `feedId` of this provider.
  String get feedId;
}

class _MarketplaceWebFeedProviderElement
    extends AutoDisposeFutureProviderElement<SnWebFeed>
    with MarketplaceWebFeedRef {
  _MarketplaceWebFeedProviderElement(super.provider);

  @override
  String get feedId => (origin as MarketplaceWebFeedProvider).feedId;
}

String _$marketplaceWebFeedSubscriptionHash() =>
    r'2ff06a48ed7d4236b57412ecca55e94c0a0b6330';

/// Provider for web feed subscription status
///
/// Copied from [marketplaceWebFeedSubscription].
@ProviderFor(marketplaceWebFeedSubscription)
const marketplaceWebFeedSubscriptionProvider =
    MarketplaceWebFeedSubscriptionFamily();

/// Provider for web feed subscription status
///
/// Copied from [marketplaceWebFeedSubscription].
class MarketplaceWebFeedSubscriptionFamily extends Family<AsyncValue<bool>> {
  /// Provider for web feed subscription status
  ///
  /// Copied from [marketplaceWebFeedSubscription].
  const MarketplaceWebFeedSubscriptionFamily();

  /// Provider for web feed subscription status
  ///
  /// Copied from [marketplaceWebFeedSubscription].
  MarketplaceWebFeedSubscriptionProvider call({required String feedId}) {
    return MarketplaceWebFeedSubscriptionProvider(feedId: feedId);
  }

  @override
  MarketplaceWebFeedSubscriptionProvider getProviderOverride(
    covariant MarketplaceWebFeedSubscriptionProvider provider,
  ) {
    return call(feedId: provider.feedId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketplaceWebFeedSubscriptionProvider';
}

/// Provider for web feed subscription status
///
/// Copied from [marketplaceWebFeedSubscription].
class MarketplaceWebFeedSubscriptionProvider
    extends AutoDisposeFutureProvider<bool> {
  /// Provider for web feed subscription status
  ///
  /// Copied from [marketplaceWebFeedSubscription].
  MarketplaceWebFeedSubscriptionProvider({required String feedId})
    : this._internal(
        (ref) => marketplaceWebFeedSubscription(
          ref as MarketplaceWebFeedSubscriptionRef,
          feedId: feedId,
        ),
        from: marketplaceWebFeedSubscriptionProvider,
        name: r'marketplaceWebFeedSubscriptionProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$marketplaceWebFeedSubscriptionHash,
        dependencies: MarketplaceWebFeedSubscriptionFamily._dependencies,
        allTransitiveDependencies:
            MarketplaceWebFeedSubscriptionFamily._allTransitiveDependencies,
        feedId: feedId,
      );

  MarketplaceWebFeedSubscriptionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedId,
  }) : super.internal();

  final String feedId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(MarketplaceWebFeedSubscriptionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarketplaceWebFeedSubscriptionProvider._internal(
        (ref) => create(ref as MarketplaceWebFeedSubscriptionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feedId: feedId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _MarketplaceWebFeedSubscriptionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceWebFeedSubscriptionProvider &&
        other.feedId == feedId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feedId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketplaceWebFeedSubscriptionRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `feedId` of this provider.
  String get feedId;
}

class _MarketplaceWebFeedSubscriptionProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with MarketplaceWebFeedSubscriptionRef {
  _MarketplaceWebFeedSubscriptionProviderElement(super.provider);

  @override
  String get feedId =>
      (origin as MarketplaceWebFeedSubscriptionProvider).feedId;
}

String _$marketplaceWebFeedContentNotifierHash() =>
    r'25688082884cb824eeff300888ba38c9748295dc';

abstract class _$MarketplaceWebFeedContentNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnWebArticle>> {
  late final String feedId;

  FutureOr<CursorPagingData<SnWebArticle>> build(String feedId);
}

/// Provider for web feed articles content
///
/// Copied from [MarketplaceWebFeedContentNotifier].
@ProviderFor(MarketplaceWebFeedContentNotifier)
const marketplaceWebFeedContentNotifierProvider =
    MarketplaceWebFeedContentNotifierFamily();

/// Provider for web feed articles content
///
/// Copied from [MarketplaceWebFeedContentNotifier].
class MarketplaceWebFeedContentNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnWebArticle>>> {
  /// Provider for web feed articles content
  ///
  /// Copied from [MarketplaceWebFeedContentNotifier].
  const MarketplaceWebFeedContentNotifierFamily();

  /// Provider for web feed articles content
  ///
  /// Copied from [MarketplaceWebFeedContentNotifier].
  MarketplaceWebFeedContentNotifierProvider call(String feedId) {
    return MarketplaceWebFeedContentNotifierProvider(feedId);
  }

  @override
  MarketplaceWebFeedContentNotifierProvider getProviderOverride(
    covariant MarketplaceWebFeedContentNotifierProvider provider,
  ) {
    return call(provider.feedId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketplaceWebFeedContentNotifierProvider';
}

/// Provider for web feed articles content
///
/// Copied from [MarketplaceWebFeedContentNotifier].
class MarketplaceWebFeedContentNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MarketplaceWebFeedContentNotifier,
          CursorPagingData<SnWebArticle>
        > {
  /// Provider for web feed articles content
  ///
  /// Copied from [MarketplaceWebFeedContentNotifier].
  MarketplaceWebFeedContentNotifierProvider(String feedId)
    : this._internal(
        () => MarketplaceWebFeedContentNotifier()..feedId = feedId,
        from: marketplaceWebFeedContentNotifierProvider,
        name: r'marketplaceWebFeedContentNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$marketplaceWebFeedContentNotifierHash,
        dependencies: MarketplaceWebFeedContentNotifierFamily._dependencies,
        allTransitiveDependencies:
            MarketplaceWebFeedContentNotifierFamily._allTransitiveDependencies,
        feedId: feedId,
      );

  MarketplaceWebFeedContentNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedId,
  }) : super.internal();

  final String feedId;

  @override
  FutureOr<CursorPagingData<SnWebArticle>> runNotifierBuild(
    covariant MarketplaceWebFeedContentNotifier notifier,
  ) {
    return notifier.build(feedId);
  }

  @override
  Override overrideWith(MarketplaceWebFeedContentNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MarketplaceWebFeedContentNotifierProvider._internal(
        () => create()..feedId = feedId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feedId: feedId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MarketplaceWebFeedContentNotifier,
    CursorPagingData<SnWebArticle>
  >
  createElement() {
    return _MarketplaceWebFeedContentNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceWebFeedContentNotifierProvider &&
        other.feedId == feedId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feedId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketplaceWebFeedContentNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnWebArticle>> {
  /// The parameter `feedId` of this provider.
  String get feedId;
}

class _MarketplaceWebFeedContentNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MarketplaceWebFeedContentNotifier,
          CursorPagingData<SnWebArticle>
        >
    with MarketplaceWebFeedContentNotifierRef {
  _MarketplaceWebFeedContentNotifierProviderElement(super.provider);

  @override
  String get feedId =>
      (origin as MarketplaceWebFeedContentNotifierProvider).feedId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
