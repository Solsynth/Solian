// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$publicationSiteDetailHash() =>
    r'e5d259ea39c4ba47e92d37e644fc3d84984927a9';

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

/// See also [publicationSiteDetail].
@ProviderFor(publicationSiteDetail)
const publicationSiteDetailProvider = PublicationSiteDetailFamily();

/// See also [publicationSiteDetail].
class PublicationSiteDetailFamily
    extends Family<AsyncValue<SnPublicationSite>> {
  /// See also [publicationSiteDetail].
  const PublicationSiteDetailFamily();

  /// See also [publicationSiteDetail].
  PublicationSiteDetailProvider call(String pubName, String siteSlug) {
    return PublicationSiteDetailProvider(pubName, siteSlug);
  }

  @override
  PublicationSiteDetailProvider getProviderOverride(
    covariant PublicationSiteDetailProvider provider,
  ) {
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
  String? get name => r'publicationSiteDetailProvider';
}

/// See also [publicationSiteDetail].
class PublicationSiteDetailProvider
    extends AutoDisposeFutureProvider<SnPublicationSite> {
  /// See also [publicationSiteDetail].
  PublicationSiteDetailProvider(String pubName, String siteSlug)
    : this._internal(
        (ref) => publicationSiteDetail(
          ref as PublicationSiteDetailRef,
          pubName,
          siteSlug,
        ),
        from: publicationSiteDetailProvider,
        name: r'publicationSiteDetailProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publicationSiteDetailHash,
        dependencies: PublicationSiteDetailFamily._dependencies,
        allTransitiveDependencies:
            PublicationSiteDetailFamily._allTransitiveDependencies,
        pubName: pubName,
        siteSlug: siteSlug,
      );

  PublicationSiteDetailProvider._internal(
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
    FutureOr<SnPublicationSite> Function(PublicationSiteDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublicationSiteDetailProvider._internal(
        (ref) => create(ref as PublicationSiteDetailRef),
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
  AutoDisposeFutureProviderElement<SnPublicationSite> createElement() {
    return _PublicationSiteDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicationSiteDetailProvider &&
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
mixin PublicationSiteDetailRef
    on AutoDisposeFutureProviderRef<SnPublicationSite> {
  /// The parameter `pubName` of this provider.
  String get pubName;

  /// The parameter `siteSlug` of this provider.
  String get siteSlug;
}

class _PublicationSiteDetailProviderElement
    extends AutoDisposeFutureProviderElement<SnPublicationSite>
    with PublicationSiteDetailRef {
  _PublicationSiteDetailProviderElement(super.provider);

  @override
  String get pubName => (origin as PublicationSiteDetailProvider).pubName;
  @override
  String get siteSlug => (origin as PublicationSiteDetailProvider).siteSlug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
