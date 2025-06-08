// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$realmIdentityHash() => r'eac6e829b5b46bcfadbf201ab6f918d78c894b9f';

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

/// See also [realmIdentity].
@ProviderFor(realmIdentity)
const realmIdentityProvider = RealmIdentityFamily();

/// See also [realmIdentity].
class RealmIdentityFamily extends Family<AsyncValue<SnRealmMember?>> {
  /// See also [realmIdentity].
  const RealmIdentityFamily();

  /// See also [realmIdentity].
  RealmIdentityProvider call(String realmSlug) {
    return RealmIdentityProvider(realmSlug);
  }

  @override
  RealmIdentityProvider getProviderOverride(
    covariant RealmIdentityProvider provider,
  ) {
    return call(provider.realmSlug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'realmIdentityProvider';
}

/// See also [realmIdentity].
class RealmIdentityProvider extends AutoDisposeFutureProvider<SnRealmMember?> {
  /// See also [realmIdentity].
  RealmIdentityProvider(String realmSlug)
    : this._internal(
        (ref) => realmIdentity(ref as RealmIdentityRef, realmSlug),
        from: realmIdentityProvider,
        name: r'realmIdentityProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$realmIdentityHash,
        dependencies: RealmIdentityFamily._dependencies,
        allTransitiveDependencies:
            RealmIdentityFamily._allTransitiveDependencies,
        realmSlug: realmSlug,
      );

  RealmIdentityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.realmSlug,
  }) : super.internal();

  final String realmSlug;

  @override
  Override overrideWith(
    FutureOr<SnRealmMember?> Function(RealmIdentityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RealmIdentityProvider._internal(
        (ref) => create(ref as RealmIdentityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        realmSlug: realmSlug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnRealmMember?> createElement() {
    return _RealmIdentityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RealmIdentityProvider && other.realmSlug == realmSlug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, realmSlug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RealmIdentityRef on AutoDisposeFutureProviderRef<SnRealmMember?> {
  /// The parameter `realmSlug` of this provider.
  String get realmSlug;
}

class _RealmIdentityProviderElement
    extends AutoDisposeFutureProviderElement<SnRealmMember?>
    with RealmIdentityRef {
  _RealmIdentityProviderElement(super.provider);

  @override
  String get realmSlug => (origin as RealmIdentityProvider).realmSlug;
}

String _$realmMemberListNotifierHash() =>
    r'b2e3eefc62a597f45df9470b2058fdda62f8853f';

abstract class _$RealmMemberListNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnRealmMember>> {
  late final String realmSlug;

  FutureOr<CursorPagingData<SnRealmMember>> build(String realmSlug);
}

/// See also [RealmMemberListNotifier].
@ProviderFor(RealmMemberListNotifier)
const realmMemberListNotifierProvider = RealmMemberListNotifierFamily();

/// See also [RealmMemberListNotifier].
class RealmMemberListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnRealmMember>>> {
  /// See also [RealmMemberListNotifier].
  const RealmMemberListNotifierFamily();

  /// See also [RealmMemberListNotifier].
  RealmMemberListNotifierProvider call(String realmSlug) {
    return RealmMemberListNotifierProvider(realmSlug);
  }

  @override
  RealmMemberListNotifierProvider getProviderOverride(
    covariant RealmMemberListNotifierProvider provider,
  ) {
    return call(provider.realmSlug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'realmMemberListNotifierProvider';
}

/// See also [RealmMemberListNotifier].
class RealmMemberListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          RealmMemberListNotifier,
          CursorPagingData<SnRealmMember>
        > {
  /// See also [RealmMemberListNotifier].
  RealmMemberListNotifierProvider(String realmSlug)
    : this._internal(
        () => RealmMemberListNotifier()..realmSlug = realmSlug,
        from: realmMemberListNotifierProvider,
        name: r'realmMemberListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$realmMemberListNotifierHash,
        dependencies: RealmMemberListNotifierFamily._dependencies,
        allTransitiveDependencies:
            RealmMemberListNotifierFamily._allTransitiveDependencies,
        realmSlug: realmSlug,
      );

  RealmMemberListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.realmSlug,
  }) : super.internal();

  final String realmSlug;

  @override
  FutureOr<CursorPagingData<SnRealmMember>> runNotifierBuild(
    covariant RealmMemberListNotifier notifier,
  ) {
    return notifier.build(realmSlug);
  }

  @override
  Override overrideWith(RealmMemberListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: RealmMemberListNotifierProvider._internal(
        () => create()..realmSlug = realmSlug,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        realmSlug: realmSlug,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    RealmMemberListNotifier,
    CursorPagingData<SnRealmMember>
  >
  createElement() {
    return _RealmMemberListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RealmMemberListNotifierProvider &&
        other.realmSlug == realmSlug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, realmSlug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RealmMemberListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnRealmMember>> {
  /// The parameter `realmSlug` of this provider.
  String get realmSlug;
}

class _RealmMemberListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          RealmMemberListNotifier,
          CursorPagingData<SnRealmMember>
        >
    with RealmMemberListNotifierRef {
  _RealmMemberListNotifierProviderElement(super.provider);

  @override
  String get realmSlug => (origin as RealmMemberListNotifierProvider).realmSlug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
