// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hub.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$developerStatsHash() => r'45546f29ec7cd1a9c3a4e0f4e39275e78bf34755';

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

/// See also [developerStats].
@ProviderFor(developerStats)
const developerStatsProvider = DeveloperStatsFamily();

/// See also [developerStats].
class DeveloperStatsFamily extends Family<AsyncValue<DeveloperStats?>> {
  /// See also [developerStats].
  const DeveloperStatsFamily();

  /// See also [developerStats].
  DeveloperStatsProvider call(String? uname) {
    return DeveloperStatsProvider(uname);
  }

  @override
  DeveloperStatsProvider getProviderOverride(
    covariant DeveloperStatsProvider provider,
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
  String? get name => r'developerStatsProvider';
}

/// See also [developerStats].
class DeveloperStatsProvider
    extends AutoDisposeFutureProvider<DeveloperStats?> {
  /// See also [developerStats].
  DeveloperStatsProvider(String? uname)
    : this._internal(
        (ref) => developerStats(ref as DeveloperStatsRef, uname),
        from: developerStatsProvider,
        name: r'developerStatsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$developerStatsHash,
        dependencies: DeveloperStatsFamily._dependencies,
        allTransitiveDependencies:
            DeveloperStatsFamily._allTransitiveDependencies,
        uname: uname,
      );

  DeveloperStatsProvider._internal(
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
    FutureOr<DeveloperStats?> Function(DeveloperStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeveloperStatsProvider._internal(
        (ref) => create(ref as DeveloperStatsRef),
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
  AutoDisposeFutureProviderElement<DeveloperStats?> createElement() {
    return _DeveloperStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeveloperStatsProvider && other.uname == uname;
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
mixin DeveloperStatsRef on AutoDisposeFutureProviderRef<DeveloperStats?> {
  /// The parameter `uname` of this provider.
  String? get uname;
}

class _DeveloperStatsProviderElement
    extends AutoDisposeFutureProviderElement<DeveloperStats?>
    with DeveloperStatsRef {
  _DeveloperStatsProviderElement(super.provider);

  @override
  String? get uname => (origin as DeveloperStatsProvider).uname;
}

String _$developersHash() => r'252341098617ac398ce133994453f318dd3edbd2';

/// See also [developers].
@ProviderFor(developers)
final developersProvider =
    AutoDisposeFutureProvider<List<SnDeveloper>>.internal(
      developers,
      name: r'developersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$developersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DevelopersRef = AutoDisposeFutureProviderRef<List<SnDeveloper>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
