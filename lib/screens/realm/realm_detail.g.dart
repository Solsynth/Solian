// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$realmAppbarForegroundColorHash() =>
    r'14b5563d861996ea182d0d2db7aa5c2bb3bbaf48';

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

/// See also [realmAppbarForegroundColor].
@ProviderFor(realmAppbarForegroundColor)
const realmAppbarForegroundColorProvider = RealmAppbarForegroundColorFamily();

/// See also [realmAppbarForegroundColor].
class RealmAppbarForegroundColorFamily extends Family<AsyncValue<Color?>> {
  /// See also [realmAppbarForegroundColor].
  const RealmAppbarForegroundColorFamily();

  /// See also [realmAppbarForegroundColor].
  RealmAppbarForegroundColorProvider call(String realmSlug) {
    return RealmAppbarForegroundColorProvider(realmSlug);
  }

  @override
  RealmAppbarForegroundColorProvider getProviderOverride(
    covariant RealmAppbarForegroundColorProvider provider,
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
  String? get name => r'realmAppbarForegroundColorProvider';
}

/// See also [realmAppbarForegroundColor].
class RealmAppbarForegroundColorProvider
    extends AutoDisposeFutureProvider<Color?> {
  /// See also [realmAppbarForegroundColor].
  RealmAppbarForegroundColorProvider(String realmSlug)
    : this._internal(
        (ref) => realmAppbarForegroundColor(
          ref as RealmAppbarForegroundColorRef,
          realmSlug,
        ),
        from: realmAppbarForegroundColorProvider,
        name: r'realmAppbarForegroundColorProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$realmAppbarForegroundColorHash,
        dependencies: RealmAppbarForegroundColorFamily._dependencies,
        allTransitiveDependencies:
            RealmAppbarForegroundColorFamily._allTransitiveDependencies,
        realmSlug: realmSlug,
      );

  RealmAppbarForegroundColorProvider._internal(
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
    FutureOr<Color?> Function(RealmAppbarForegroundColorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RealmAppbarForegroundColorProvider._internal(
        (ref) => create(ref as RealmAppbarForegroundColorRef),
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
  AutoDisposeFutureProviderElement<Color?> createElement() {
    return _RealmAppbarForegroundColorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RealmAppbarForegroundColorProvider &&
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
mixin RealmAppbarForegroundColorRef on AutoDisposeFutureProviderRef<Color?> {
  /// The parameter `realmSlug` of this provider.
  String get realmSlug;
}

class _RealmAppbarForegroundColorProviderElement
    extends AutoDisposeFutureProviderElement<Color?>
    with RealmAppbarForegroundColorRef {
  _RealmAppbarForegroundColorProviderElement(super.provider);

  @override
  String get realmSlug =>
      (origin as RealmAppbarForegroundColorProvider).realmSlug;
}

String _$realmIdentityHash() => r'c5e2977d243260947b919bc27146c134e34f0db1';

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

String _$realmChatRoomsHash() => r'5f199906fb287b109e2a2d2a81dcb6675bdcb816';

/// See also [realmChatRooms].
@ProviderFor(realmChatRooms)
const realmChatRoomsProvider = RealmChatRoomsFamily();

/// See also [realmChatRooms].
class RealmChatRoomsFamily extends Family<AsyncValue<List<SnChatRoom>>> {
  /// See also [realmChatRooms].
  const RealmChatRoomsFamily();

  /// See also [realmChatRooms].
  RealmChatRoomsProvider call(String realmSlug) {
    return RealmChatRoomsProvider(realmSlug);
  }

  @override
  RealmChatRoomsProvider getProviderOverride(
    covariant RealmChatRoomsProvider provider,
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
  String? get name => r'realmChatRoomsProvider';
}

/// See also [realmChatRooms].
class RealmChatRoomsProvider
    extends AutoDisposeFutureProvider<List<SnChatRoom>> {
  /// See also [realmChatRooms].
  RealmChatRoomsProvider(String realmSlug)
    : this._internal(
        (ref) => realmChatRooms(ref as RealmChatRoomsRef, realmSlug),
        from: realmChatRoomsProvider,
        name: r'realmChatRoomsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$realmChatRoomsHash,
        dependencies: RealmChatRoomsFamily._dependencies,
        allTransitiveDependencies:
            RealmChatRoomsFamily._allTransitiveDependencies,
        realmSlug: realmSlug,
      );

  RealmChatRoomsProvider._internal(
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
    FutureOr<List<SnChatRoom>> Function(RealmChatRoomsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RealmChatRoomsProvider._internal(
        (ref) => create(ref as RealmChatRoomsRef),
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
  AutoDisposeFutureProviderElement<List<SnChatRoom>> createElement() {
    return _RealmChatRoomsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RealmChatRoomsProvider && other.realmSlug == realmSlug;
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
mixin RealmChatRoomsRef on AutoDisposeFutureProviderRef<List<SnChatRoom>> {
  /// The parameter `realmSlug` of this provider.
  String get realmSlug;
}

class _RealmChatRoomsProviderElement
    extends AutoDisposeFutureProviderElement<List<SnChatRoom>>
    with RealmChatRoomsRef {
  _RealmChatRoomsProviderElement(super.provider);

  @override
  String get realmSlug => (origin as RealmChatRoomsProvider).realmSlug;
}

String _$realmMemberListNotifierHash() =>
    r'2f88f803b2e61e7287ed8a43025173e56ff6ca3b';

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
