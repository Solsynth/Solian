// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$realmListNotifierHash() => r'8ae5c3ae2837acae4c7bf5e44578518afc9ea1a6';

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

abstract class _$RealmListNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnRealm>> {
  late final String? query;

  FutureOr<CursorPagingData<SnRealm>> build(String? query);
}

/// See also [RealmListNotifier].
@ProviderFor(RealmListNotifier)
const realmListNotifierProvider = RealmListNotifierFamily();

/// See also [RealmListNotifier].
class RealmListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnRealm>>> {
  /// See also [RealmListNotifier].
  const RealmListNotifierFamily();

  /// See also [RealmListNotifier].
  RealmListNotifierProvider call(String? query) {
    return RealmListNotifierProvider(query);
  }

  @override
  RealmListNotifierProvider getProviderOverride(
    covariant RealmListNotifierProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'realmListNotifierProvider';
}

/// See also [RealmListNotifier].
class RealmListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          RealmListNotifier,
          CursorPagingData<SnRealm>
        > {
  /// See also [RealmListNotifier].
  RealmListNotifierProvider(String? query)
    : this._internal(
        () => RealmListNotifier()..query = query,
        from: realmListNotifierProvider,
        name: r'realmListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$realmListNotifierHash,
        dependencies: RealmListNotifierFamily._dependencies,
        allTransitiveDependencies:
            RealmListNotifierFamily._allTransitiveDependencies,
        query: query,
      );

  RealmListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String? query;

  @override
  FutureOr<CursorPagingData<SnRealm>> runNotifierBuild(
    covariant RealmListNotifier notifier,
  ) {
    return notifier.build(query);
  }

  @override
  Override overrideWith(RealmListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: RealmListNotifierProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    RealmListNotifier,
    CursorPagingData<SnRealm>
  >
  createElement() {
    return _RealmListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RealmListNotifierProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RealmListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnRealm>> {
  /// The parameter `query` of this provider.
  String? get query;
}

class _RealmListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          RealmListNotifier,
          CursorPagingData<SnRealm>
        >
    with RealmListNotifierRef {
  _RealmListNotifierProviderElement(super.provider);

  @override
  String? get query => (origin as RealmListNotifierProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
