// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$siteListNotifierHash() => r'5cd2d75f13b6e7d4910dc66a24bbd6508fc4175d';

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

abstract class _$SiteListNotifier
    extends
        BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnPublicationSite>> {
  late final String? pubName;

  FutureOr<CursorPagingData<SnPublicationSite>> build(String? pubName);
}

/// See also [SiteListNotifier].
@ProviderFor(SiteListNotifier)
const siteListNotifierProvider = SiteListNotifierFamily();

/// See also [SiteListNotifier].
class SiteListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnPublicationSite>>> {
  /// See also [SiteListNotifier].
  const SiteListNotifierFamily();

  /// See also [SiteListNotifier].
  SiteListNotifierProvider call(String? pubName) {
    return SiteListNotifierProvider(pubName);
  }

  @override
  SiteListNotifierProvider getProviderOverride(
    covariant SiteListNotifierProvider provider,
  ) {
    return call(provider.pubName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'siteListNotifierProvider';
}

/// See also [SiteListNotifier].
class SiteListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          SiteListNotifier,
          CursorPagingData<SnPublicationSite>
        > {
  /// See also [SiteListNotifier].
  SiteListNotifierProvider(String? pubName)
    : this._internal(
        () => SiteListNotifier()..pubName = pubName,
        from: siteListNotifierProvider,
        name: r'siteListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$siteListNotifierHash,
        dependencies: SiteListNotifierFamily._dependencies,
        allTransitiveDependencies:
            SiteListNotifierFamily._allTransitiveDependencies,
        pubName: pubName,
      );

  SiteListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pubName,
  }) : super.internal();

  final String? pubName;

  @override
  FutureOr<CursorPagingData<SnPublicationSite>> runNotifierBuild(
    covariant SiteListNotifier notifier,
  ) {
    return notifier.build(pubName);
  }

  @override
  Override overrideWith(SiteListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SiteListNotifierProvider._internal(
        () => create()..pubName = pubName,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pubName: pubName,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    SiteListNotifier,
    CursorPagingData<SnPublicationSite>
  >
  createElement() {
    return _SiteListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteListNotifierProvider && other.pubName == pubName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pubName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SiteListNotifierRef
    on
        AutoDisposeAsyncNotifierProviderRef<
          CursorPagingData<SnPublicationSite>
        > {
  /// The parameter `pubName` of this provider.
  String? get pubName;
}

class _SiteListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          SiteListNotifier,
          CursorPagingData<SnPublicationSite>
        >
    with SiteListNotifierRef {
  _SiteListNotifierProviderElement(super.provider);

  @override
  String? get pubName => (origin as SiteListNotifierProvider).pubName;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
