// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realms.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$realmsJoinedHash() => r'b15029acd38f03bbbb8708adb78f25ac357a0421';

/// See also [realmsJoined].
@ProviderFor(realmsJoined)
final realmsJoinedProvider = AutoDisposeFutureProvider<List<SnRealm>>.internal(
  realmsJoined,
  name: r'realmsJoinedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$realmsJoinedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RealmsJoinedRef = AutoDisposeFutureProviderRef<List<SnRealm>>;
String _$realmHash() => r'71a126ab2810566646e1629290c1ce9ffa0839e3';

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

/// See also [realm].
@ProviderFor(realm)
const realmProvider = RealmFamily();

/// See also [realm].
class RealmFamily extends Family<AsyncValue<SnRealm?>> {
  /// See also [realm].
  const RealmFamily();

  /// See also [realm].
  RealmProvider call(String? identifier) {
    return RealmProvider(identifier);
  }

  @override
  RealmProvider getProviderOverride(covariant RealmProvider provider) {
    return call(provider.identifier);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'realmProvider';
}

/// See also [realm].
class RealmProvider extends AutoDisposeFutureProvider<SnRealm?> {
  /// See also [realm].
  RealmProvider(String? identifier)
    : this._internal(
        (ref) => realm(ref as RealmRef, identifier),
        from: realmProvider,
        name: r'realmProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product') ? null : _$realmHash,
        dependencies: RealmFamily._dependencies,
        allTransitiveDependencies: RealmFamily._allTransitiveDependencies,
        identifier: identifier,
      );

  RealmProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.identifier,
  }) : super.internal();

  final String? identifier;

  @override
  Override overrideWith(FutureOr<SnRealm?> Function(RealmRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: RealmProvider._internal(
        (ref) => create(ref as RealmRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        identifier: identifier,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnRealm?> createElement() {
    return _RealmProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RealmProvider && other.identifier == identifier;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, identifier.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RealmRef on AutoDisposeFutureProviderRef<SnRealm?> {
  /// The parameter `identifier` of this provider.
  String? get identifier;
}

class _RealmProviderElement extends AutoDisposeFutureProviderElement<SnRealm?>
    with RealmRef {
  _RealmProviderElement(super.provider);

  @override
  String? get identifier => (origin as RealmProvider).identifier;
}

String _$realmInvitesHash() => r'92cce0978c7ca8813e27ae42fc6f3a93a09a8962';

/// See also [realmInvites].
@ProviderFor(realmInvites)
final realmInvitesProvider =
    AutoDisposeFutureProvider<List<SnRealmMember>>.internal(
      realmInvites,
      name: r'realmInvitesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$realmInvitesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RealmInvitesRef = AutoDisposeFutureProviderRef<List<SnRealmMember>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
