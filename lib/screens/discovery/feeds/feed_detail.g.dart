// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketplaceWebFeedContentHash() =>
    r'4e65350bff4055302e15ec14266cdebb1cd89bbe';

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

/// Provider for web feed articles content
///
/// Copied from [marketplaceWebFeedContent].
@ProviderFor(marketplaceWebFeedContent)
const marketplaceWebFeedContentProvider = MarketplaceWebFeedContentFamily();

/// Provider for web feed articles content
///
/// Copied from [marketplaceWebFeedContent].
class MarketplaceWebFeedContentFamily
    extends Family<AsyncValue<List<SnWebArticle>>> {
  /// Provider for web feed articles content
  ///
  /// Copied from [marketplaceWebFeedContent].
  const MarketplaceWebFeedContentFamily();

  /// Provider for web feed articles content
  ///
  /// Copied from [marketplaceWebFeedContent].
  MarketplaceWebFeedContentProvider call({required String feedId}) {
    return MarketplaceWebFeedContentProvider(feedId: feedId);
  }

  @override
  MarketplaceWebFeedContentProvider getProviderOverride(
    covariant MarketplaceWebFeedContentProvider provider,
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
  String? get name => r'marketplaceWebFeedContentProvider';
}

/// Provider for web feed articles content
///
/// Copied from [marketplaceWebFeedContent].
class MarketplaceWebFeedContentProvider
    extends AutoDisposeFutureProvider<List<SnWebArticle>> {
  /// Provider for web feed articles content
  ///
  /// Copied from [marketplaceWebFeedContent].
  MarketplaceWebFeedContentProvider({required String feedId})
    : this._internal(
        (ref) => marketplaceWebFeedContent(
          ref as MarketplaceWebFeedContentRef,
          feedId: feedId,
        ),
        from: marketplaceWebFeedContentProvider,
        name: r'marketplaceWebFeedContentProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$marketplaceWebFeedContentHash,
        dependencies: MarketplaceWebFeedContentFamily._dependencies,
        allTransitiveDependencies:
            MarketplaceWebFeedContentFamily._allTransitiveDependencies,
        feedId: feedId,
      );

  MarketplaceWebFeedContentProvider._internal(
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
    FutureOr<List<SnWebArticle>> Function(MarketplaceWebFeedContentRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarketplaceWebFeedContentProvider._internal(
        (ref) => create(ref as MarketplaceWebFeedContentRef),
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
  AutoDisposeFutureProviderElement<List<SnWebArticle>> createElement() {
    return _MarketplaceWebFeedContentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceWebFeedContentProvider && other.feedId == feedId;
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
mixin MarketplaceWebFeedContentRef
    on AutoDisposeFutureProviderRef<List<SnWebArticle>> {
  /// The parameter `feedId` of this provider.
  String get feedId;
}

class _MarketplaceWebFeedContentProviderElement
    extends AutoDisposeFutureProviderElement<List<SnWebArticle>>
    with MarketplaceWebFeedContentRef {
  _MarketplaceWebFeedContentProviderElement(super.provider);

  @override
  String get feedId => (origin as MarketplaceWebFeedContentProvider).feedId;
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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
