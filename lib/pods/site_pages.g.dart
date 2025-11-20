// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_pages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sitePagesHash() => r'5e084e9694ad665e9b238c6a747c6c6e99c5eb03';

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

/// See also [sitePages].
@ProviderFor(sitePages)
const sitePagesProvider = SitePagesFamily();

/// See also [sitePages].
class SitePagesFamily extends Family<AsyncValue<List<SnPublicationPage>>> {
  /// See also [sitePages].
  const SitePagesFamily();

  /// See also [sitePages].
  SitePagesProvider call(String pubName, String siteSlug) {
    return SitePagesProvider(pubName, siteSlug);
  }

  @override
  SitePagesProvider getProviderOverride(covariant SitePagesProvider provider) {
    return call(provider.pubName, provider.siteSlug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sitePagesProvider';
}

/// See also [sitePages].
class SitePagesProvider
    extends AutoDisposeFutureProvider<List<SnPublicationPage>> {
  /// See also [sitePages].
  SitePagesProvider(String pubName, String siteSlug)
    : this._internal(
        (ref) => sitePages(ref as SitePagesRef, pubName, siteSlug),
        from: sitePagesProvider,
        name: r'sitePagesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$sitePagesHash,
        dependencies: SitePagesFamily._dependencies,
        allTransitiveDependencies: SitePagesFamily._allTransitiveDependencies,
        pubName: pubName,
        siteSlug: siteSlug,
      );

  SitePagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pubName,
    required this.siteSlug,
  }) : super.internal();

  final String pubName;
  final String siteSlug;

  @override
  Override overrideWith(
    FutureOr<List<SnPublicationPage>> Function(SitePagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SitePagesProvider._internal(
        (ref) => create(ref as SitePagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pubName: pubName,
        siteSlug: siteSlug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnPublicationPage>> createElement() {
    return _SitePagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SitePagesProvider &&
        other.pubName == pubName &&
        other.siteSlug == siteSlug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pubName.hashCode);
    hash = _SystemHash.combine(hash, siteSlug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SitePagesRef on AutoDisposeFutureProviderRef<List<SnPublicationPage>> {
  /// The parameter `pubName` of this provider.
  String get pubName;

  /// The parameter `siteSlug` of this provider.
  String get siteSlug;
}

class _SitePagesProviderElement
    extends AutoDisposeFutureProviderElement<List<SnPublicationPage>>
    with SitePagesRef {
  _SitePagesProviderElement(super.provider);

  @override
  String get pubName => (origin as SitePagesProvider).pubName;
  @override
  String get siteSlug => (origin as SitePagesProvider).siteSlug;
}

String _$sitePageHash() => r'542f70c5b103fe34d7cf7eb0821d52f017022efc';

/// See also [sitePage].
@ProviderFor(sitePage)
const sitePageProvider = SitePageFamily();

/// See also [sitePage].
class SitePageFamily extends Family<AsyncValue<SnPublicationPage>> {
  /// See also [sitePage].
  const SitePageFamily();

  /// See also [sitePage].
  SitePageProvider call(String pageId) {
    return SitePageProvider(pageId);
  }

  @override
  SitePageProvider getProviderOverride(covariant SitePageProvider provider) {
    return call(provider.pageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sitePageProvider';
}

/// See also [sitePage].
class SitePageProvider extends AutoDisposeFutureProvider<SnPublicationPage> {
  /// See also [sitePage].
  SitePageProvider(String pageId)
    : this._internal(
        (ref) => sitePage(ref as SitePageRef, pageId),
        from: sitePageProvider,
        name: r'sitePageProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$sitePageHash,
        dependencies: SitePageFamily._dependencies,
        allTransitiveDependencies: SitePageFamily._allTransitiveDependencies,
        pageId: pageId,
      );

  SitePageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pageId,
  }) : super.internal();

  final String pageId;

  @override
  Override overrideWith(
    FutureOr<SnPublicationPage> Function(SitePageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SitePageProvider._internal(
        (ref) => create(ref as SitePageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pageId: pageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnPublicationPage> createElement() {
    return _SitePageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SitePageProvider && other.pageId == pageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SitePageRef on AutoDisposeFutureProviderRef<SnPublicationPage> {
  /// The parameter `pageId` of this provider.
  String get pageId;
}

class _SitePageProviderElement
    extends AutoDisposeFutureProviderElement<SnPublicationPage>
    with SitePageRef {
  _SitePageProviderElement(super.provider);

  @override
  String get pageId => (origin as SitePageProvider).pageId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
