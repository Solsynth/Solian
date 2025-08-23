// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_project.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$devProjectHash() => r'd92be3f5cdc510c2a377615ed5c70622a6842bf2';

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

/// See also [devProject].
@ProviderFor(devProject)
const devProjectProvider = DevProjectFamily();

/// See also [devProject].
class DevProjectFamily extends Family<AsyncValue<DevProject?>> {
  /// See also [devProject].
  const DevProjectFamily();

  /// See also [devProject].
  DevProjectProvider call(String pubName, String id) {
    return DevProjectProvider(pubName, id);
  }

  @override
  DevProjectProvider getProviderOverride(
    covariant DevProjectProvider provider,
  ) {
    return call(provider.pubName, provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'devProjectProvider';
}

/// See also [devProject].
class DevProjectProvider extends AutoDisposeFutureProvider<DevProject?> {
  /// See also [devProject].
  DevProjectProvider(String pubName, String id)
    : this._internal(
        (ref) => devProject(ref as DevProjectRef, pubName, id),
        from: devProjectProvider,
        name: r'devProjectProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$devProjectHash,
        dependencies: DevProjectFamily._dependencies,
        allTransitiveDependencies: DevProjectFamily._allTransitiveDependencies,
        pubName: pubName,
        id: id,
      );

  DevProjectProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pubName,
    required this.id,
  }) : super.internal();

  final String pubName;
  final String id;

  @override
  Override overrideWith(
    FutureOr<DevProject?> Function(DevProjectRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DevProjectProvider._internal(
        (ref) => create(ref as DevProjectRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pubName: pubName,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DevProject?> createElement() {
    return _DevProjectProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DevProjectProvider &&
        other.pubName == pubName &&
        other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pubName.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DevProjectRef on AutoDisposeFutureProviderRef<DevProject?> {
  /// The parameter `pubName` of this provider.
  String get pubName;

  /// The parameter `id` of this provider.
  String get id;
}

class _DevProjectProviderElement
    extends AutoDisposeFutureProviderElement<DevProject?>
    with DevProjectRef {
  _DevProjectProviderElement(super.provider);

  @override
  String get pubName => (origin as DevProjectProvider).pubName;
  @override
  String get id => (origin as DevProjectProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
