// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'articles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscribedFeedsHash() => r'cd2f5d7d4ea49ad00dc731f8fc2ed65450a3f0e4';

/// See also [subscribedFeeds].
@ProviderFor(subscribedFeeds)
final subscribedFeedsProvider =
    AutoDisposeFutureProvider<List<SnWebFeed>>.internal(
      subscribedFeeds,
      name: r'subscribedFeedsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$subscribedFeedsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscribedFeedsRef = AutoDisposeFutureProviderRef<List<SnWebFeed>>;
String _$articlesListNotifierHash() =>
    r'579741af4d90c7c81f2e2697e57c4895b7a9dabc';

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

abstract class _$ArticlesListNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnWebArticle>> {
  late final String? feedId;
  late final String? publisherId;

  FutureOr<CursorPagingData<SnWebArticle>> build({
    String? feedId,
    String? publisherId,
  });
}

/// See also [ArticlesListNotifier].
@ProviderFor(ArticlesListNotifier)
const articlesListNotifierProvider = ArticlesListNotifierFamily();

/// See also [ArticlesListNotifier].
class ArticlesListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnWebArticle>>> {
  /// See also [ArticlesListNotifier].
  const ArticlesListNotifierFamily();

  /// See also [ArticlesListNotifier].
  ArticlesListNotifierProvider call({String? feedId, String? publisherId}) {
    return ArticlesListNotifierProvider(
      feedId: feedId,
      publisherId: publisherId,
    );
  }

  @override
  ArticlesListNotifierProvider getProviderOverride(
    covariant ArticlesListNotifierProvider provider,
  ) {
    return call(feedId: provider.feedId, publisherId: provider.publisherId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'articlesListNotifierProvider';
}

/// See also [ArticlesListNotifier].
class ArticlesListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ArticlesListNotifier,
          CursorPagingData<SnWebArticle>
        > {
  /// See also [ArticlesListNotifier].
  ArticlesListNotifierProvider({String? feedId, String? publisherId})
    : this._internal(
        () =>
            ArticlesListNotifier()
              ..feedId = feedId
              ..publisherId = publisherId,
        from: articlesListNotifierProvider,
        name: r'articlesListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$articlesListNotifierHash,
        dependencies: ArticlesListNotifierFamily._dependencies,
        allTransitiveDependencies:
            ArticlesListNotifierFamily._allTransitiveDependencies,
        feedId: feedId,
        publisherId: publisherId,
      );

  ArticlesListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedId,
    required this.publisherId,
  }) : super.internal();

  final String? feedId;
  final String? publisherId;

  @override
  FutureOr<CursorPagingData<SnWebArticle>> runNotifierBuild(
    covariant ArticlesListNotifier notifier,
  ) {
    return notifier.build(feedId: feedId, publisherId: publisherId);
  }

  @override
  Override overrideWith(ArticlesListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ArticlesListNotifierProvider._internal(
        () =>
            create()
              ..feedId = feedId
              ..publisherId = publisherId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feedId: feedId,
        publisherId: publisherId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ArticlesListNotifier,
    CursorPagingData<SnWebArticle>
  >
  createElement() {
    return _ArticlesListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticlesListNotifierProvider &&
        other.feedId == feedId &&
        other.publisherId == publisherId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feedId.hashCode);
    hash = _SystemHash.combine(hash, publisherId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArticlesListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnWebArticle>> {
  /// The parameter `feedId` of this provider.
  String? get feedId;

  /// The parameter `publisherId` of this provider.
  String? get publisherId;
}

class _ArticlesListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ArticlesListNotifier,
          CursorPagingData<SnWebArticle>
        >
    with ArticlesListNotifierRef {
  _ArticlesListNotifierProviderElement(super.provider);

  @override
  String? get feedId => (origin as ArticlesListNotifierProvider).feedId;
  @override
  String? get publisherId =>
      (origin as ArticlesListNotifierProvider).publisherId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
