// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hub.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$publisherStatsHash() => r'eea4ed98bf165cc785874f83b912bb7e23d1f7bc';

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

/// See also [publisherStats].
@ProviderFor(publisherStats)
const publisherStatsProvider = PublisherStatsFamily();

/// See also [publisherStats].
class PublisherStatsFamily extends Family<AsyncValue<SnPublisherStats?>> {
  /// See also [publisherStats].
  const PublisherStatsFamily();

  /// See also [publisherStats].
  PublisherStatsProvider call(String? uname) {
    return PublisherStatsProvider(uname);
  }

  @override
  PublisherStatsProvider getProviderOverride(
    covariant PublisherStatsProvider provider,
  ) {
    return call(provider.uname);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publisherStatsProvider';
}

/// See also [publisherStats].
class PublisherStatsProvider
    extends AutoDisposeFutureProvider<SnPublisherStats?> {
  /// See also [publisherStats].
  PublisherStatsProvider(String? uname)
    : this._internal(
        (ref) => publisherStats(ref as PublisherStatsRef, uname),
        from: publisherStatsProvider,
        name: r'publisherStatsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherStatsHash,
        dependencies: PublisherStatsFamily._dependencies,
        allTransitiveDependencies:
            PublisherStatsFamily._allTransitiveDependencies,
        uname: uname,
      );

  PublisherStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uname,
  }) : super.internal();

  final String? uname;

  @override
  Override overrideWith(
    FutureOr<SnPublisherStats?> Function(PublisherStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublisherStatsProvider._internal(
        (ref) => create(ref as PublisherStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uname: uname,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnPublisherStats?> createElement() {
    return _PublisherStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherStatsProvider && other.uname == uname;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uname.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublisherStatsRef on AutoDisposeFutureProviderRef<SnPublisherStats?> {
  /// The parameter `uname` of this provider.
  String? get uname;
}

class _PublisherStatsProviderElement
    extends AutoDisposeFutureProviderElement<SnPublisherStats?>
    with PublisherStatsRef {
  _PublisherStatsProviderElement(super.provider);

  @override
  String? get uname => (origin as PublisherStatsProvider).uname;
}

String _$publisherHeatmapHash() => r'780dfb05b8610a37cfcd937fd04cf5bbe9b298c9';

/// See also [publisherHeatmap].
@ProviderFor(publisherHeatmap)
const publisherHeatmapProvider = PublisherHeatmapFamily();

/// See also [publisherHeatmap].
class PublisherHeatmapFamily extends Family<AsyncValue<SnHeatmap?>> {
  /// See also [publisherHeatmap].
  const PublisherHeatmapFamily();

  /// See also [publisherHeatmap].
  PublisherHeatmapProvider call(String? uname) {
    return PublisherHeatmapProvider(uname);
  }

  @override
  PublisherHeatmapProvider getProviderOverride(
    covariant PublisherHeatmapProvider provider,
  ) {
    return call(provider.uname);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publisherHeatmapProvider';
}

/// See also [publisherHeatmap].
class PublisherHeatmapProvider extends AutoDisposeFutureProvider<SnHeatmap?> {
  /// See also [publisherHeatmap].
  PublisherHeatmapProvider(String? uname)
    : this._internal(
        (ref) => publisherHeatmap(ref as PublisherHeatmapRef, uname),
        from: publisherHeatmapProvider,
        name: r'publisherHeatmapProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherHeatmapHash,
        dependencies: PublisherHeatmapFamily._dependencies,
        allTransitiveDependencies:
            PublisherHeatmapFamily._allTransitiveDependencies,
        uname: uname,
      );

  PublisherHeatmapProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uname,
  }) : super.internal();

  final String? uname;

  @override
  Override overrideWith(
    FutureOr<SnHeatmap?> Function(PublisherHeatmapRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublisherHeatmapProvider._internal(
        (ref) => create(ref as PublisherHeatmapRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uname: uname,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnHeatmap?> createElement() {
    return _PublisherHeatmapProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherHeatmapProvider && other.uname == uname;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uname.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublisherHeatmapRef on AutoDisposeFutureProviderRef<SnHeatmap?> {
  /// The parameter `uname` of this provider.
  String? get uname;
}

class _PublisherHeatmapProviderElement
    extends AutoDisposeFutureProviderElement<SnHeatmap?>
    with PublisherHeatmapRef {
  _PublisherHeatmapProviderElement(super.provider);

  @override
  String? get uname => (origin as PublisherHeatmapProvider).uname;
}

String _$publisherIdentityHash() => r'299372f25fa4b2bf8e11a8ba2d645100fc38e76f';

/// See also [publisherIdentity].
@ProviderFor(publisherIdentity)
const publisherIdentityProvider = PublisherIdentityFamily();

/// See also [publisherIdentity].
class PublisherIdentityFamily extends Family<AsyncValue<SnPublisherMember?>> {
  /// See also [publisherIdentity].
  const PublisherIdentityFamily();

  /// See also [publisherIdentity].
  PublisherIdentityProvider call(String uname) {
    return PublisherIdentityProvider(uname);
  }

  @override
  PublisherIdentityProvider getProviderOverride(
    covariant PublisherIdentityProvider provider,
  ) {
    return call(provider.uname);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publisherIdentityProvider';
}

/// See also [publisherIdentity].
class PublisherIdentityProvider
    extends AutoDisposeFutureProvider<SnPublisherMember?> {
  /// See also [publisherIdentity].
  PublisherIdentityProvider(String uname)
    : this._internal(
        (ref) => publisherIdentity(ref as PublisherIdentityRef, uname),
        from: publisherIdentityProvider,
        name: r'publisherIdentityProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherIdentityHash,
        dependencies: PublisherIdentityFamily._dependencies,
        allTransitiveDependencies:
            PublisherIdentityFamily._allTransitiveDependencies,
        uname: uname,
      );

  PublisherIdentityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uname,
  }) : super.internal();

  final String uname;

  @override
  Override overrideWith(
    FutureOr<SnPublisherMember?> Function(PublisherIdentityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublisherIdentityProvider._internal(
        (ref) => create(ref as PublisherIdentityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uname: uname,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnPublisherMember?> createElement() {
    return _PublisherIdentityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherIdentityProvider && other.uname == uname;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uname.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublisherIdentityRef on AutoDisposeFutureProviderRef<SnPublisherMember?> {
  /// The parameter `uname` of this provider.
  String get uname;
}

class _PublisherIdentityProviderElement
    extends AutoDisposeFutureProviderElement<SnPublisherMember?>
    with PublisherIdentityRef {
  _PublisherIdentityProviderElement(super.provider);

  @override
  String get uname => (origin as PublisherIdentityProvider).uname;
}

String _$publisherFeaturesHash() => r'08bace2d9a3da227ecec0cbf8709e55ee0646ca2';

/// See also [publisherFeatures].
@ProviderFor(publisherFeatures)
const publisherFeaturesProvider = PublisherFeaturesFamily();

/// See also [publisherFeatures].
class PublisherFeaturesFamily extends Family<AsyncValue<Map<String, bool>>> {
  /// See also [publisherFeatures].
  const PublisherFeaturesFamily();

  /// See also [publisherFeatures].
  PublisherFeaturesProvider call(String? uname) {
    return PublisherFeaturesProvider(uname);
  }

  @override
  PublisherFeaturesProvider getProviderOverride(
    covariant PublisherFeaturesProvider provider,
  ) {
    return call(provider.uname);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publisherFeaturesProvider';
}

/// See also [publisherFeatures].
class PublisherFeaturesProvider
    extends AutoDisposeFutureProvider<Map<String, bool>> {
  /// See also [publisherFeatures].
  PublisherFeaturesProvider(String? uname)
    : this._internal(
        (ref) => publisherFeatures(ref as PublisherFeaturesRef, uname),
        from: publisherFeaturesProvider,
        name: r'publisherFeaturesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherFeaturesHash,
        dependencies: PublisherFeaturesFamily._dependencies,
        allTransitiveDependencies:
            PublisherFeaturesFamily._allTransitiveDependencies,
        uname: uname,
      );

  PublisherFeaturesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uname,
  }) : super.internal();

  final String? uname;

  @override
  Override overrideWith(
    FutureOr<Map<String, bool>> Function(PublisherFeaturesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublisherFeaturesProvider._internal(
        (ref) => create(ref as PublisherFeaturesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uname: uname,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, bool>> createElement() {
    return _PublisherFeaturesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherFeaturesProvider && other.uname == uname;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uname.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublisherFeaturesRef on AutoDisposeFutureProviderRef<Map<String, bool>> {
  /// The parameter `uname` of this provider.
  String? get uname;
}

class _PublisherFeaturesProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, bool>>
    with PublisherFeaturesRef {
  _PublisherFeaturesProviderElement(super.provider);

  @override
  String? get uname => (origin as PublisherFeaturesProvider).uname;
}

String _$publisherInvitesHash() => r'93aafc2f02af0a7a055ec1770b3999363dfaabdc';

/// See also [publisherInvites].
@ProviderFor(publisherInvites)
final publisherInvitesProvider =
    AutoDisposeFutureProvider<List<SnPublisherMember>>.internal(
      publisherInvites,
      name: r'publisherInvitesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$publisherInvitesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PublisherInvitesRef =
    AutoDisposeFutureProviderRef<List<SnPublisherMember>>;
String _$publisherMemberListNotifierHash() =>
    r'b4afd5d591a6f3d29f1b45fb1b6d17cb34f3f11b';

abstract class _$PublisherMemberListNotifier
    extends
        BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnPublisherMember>> {
  late final String uname;

  FutureOr<CursorPagingData<SnPublisherMember>> build(String uname);
}

/// See also [PublisherMemberListNotifier].
@ProviderFor(PublisherMemberListNotifier)
const publisherMemberListNotifierProvider = PublisherMemberListNotifierFamily();

/// See also [PublisherMemberListNotifier].
class PublisherMemberListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnPublisherMember>>> {
  /// See also [PublisherMemberListNotifier].
  const PublisherMemberListNotifierFamily();

  /// See also [PublisherMemberListNotifier].
  PublisherMemberListNotifierProvider call(String uname) {
    return PublisherMemberListNotifierProvider(uname);
  }

  @override
  PublisherMemberListNotifierProvider getProviderOverride(
    covariant PublisherMemberListNotifierProvider provider,
  ) {
    return call(provider.uname);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publisherMemberListNotifierProvider';
}

/// See also [PublisherMemberListNotifier].
class PublisherMemberListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PublisherMemberListNotifier,
          CursorPagingData<SnPublisherMember>
        > {
  /// See also [PublisherMemberListNotifier].
  PublisherMemberListNotifierProvider(String uname)
    : this._internal(
        () => PublisherMemberListNotifier()..uname = uname,
        from: publisherMemberListNotifierProvider,
        name: r'publisherMemberListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherMemberListNotifierHash,
        dependencies: PublisherMemberListNotifierFamily._dependencies,
        allTransitiveDependencies:
            PublisherMemberListNotifierFamily._allTransitiveDependencies,
        uname: uname,
      );

  PublisherMemberListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uname,
  }) : super.internal();

  final String uname;

  @override
  FutureOr<CursorPagingData<SnPublisherMember>> runNotifierBuild(
    covariant PublisherMemberListNotifier notifier,
  ) {
    return notifier.build(uname);
  }

  @override
  Override overrideWith(PublisherMemberListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PublisherMemberListNotifierProvider._internal(
        () => create()..uname = uname,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uname: uname,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    PublisherMemberListNotifier,
    CursorPagingData<SnPublisherMember>
  >
  createElement() {
    return _PublisherMemberListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherMemberListNotifierProvider && other.uname == uname;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uname.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublisherMemberListNotifierRef
    on
        AutoDisposeAsyncNotifierProviderRef<
          CursorPagingData<SnPublisherMember>
        > {
  /// The parameter `uname` of this provider.
  String get uname;
}

class _PublisherMemberListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PublisherMemberListNotifier,
          CursorPagingData<SnPublisherMember>
        >
    with PublisherMemberListNotifierRef {
  _PublisherMemberListNotifierProviderElement(super.provider);

  @override
  String get uname => (origin as PublisherMemberListNotifierProvider).uname;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
