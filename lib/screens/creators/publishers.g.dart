// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publishers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$publishersManagedHash() => r'ea83759fed9bd5119738b4d09f12b4476959e0a3';

/// See also [publishersManaged].
@ProviderFor(publishersManaged)
final publishersManagedProvider =
    AutoDisposeFutureProvider<List<SnPublisher>>.internal(
      publishersManaged,
      name: r'publishersManagedProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$publishersManagedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PublishersManagedRef = AutoDisposeFutureProviderRef<List<SnPublisher>>;
String _$publisherHash() => r'18fb5c6b3d79dd8af4fbee108dec1a0e8a034038';

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

/// See also [publisher].
@ProviderFor(publisher)
const publisherProvider = PublisherFamily();

/// See also [publisher].
class PublisherFamily extends Family<AsyncValue<SnPublisher?>> {
  /// See also [publisher].
  const PublisherFamily();

  /// See also [publisher].
  PublisherProvider call(String? identifier) {
    return PublisherProvider(identifier);
  }

  @override
  PublisherProvider getProviderOverride(covariant PublisherProvider provider) {
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
  String? get name => r'publisherProvider';
}

/// See also [publisher].
class PublisherProvider extends AutoDisposeFutureProvider<SnPublisher?> {
  /// See also [publisher].
  PublisherProvider(String? identifier)
    : this._internal(
        (ref) => publisher(ref as PublisherRef, identifier),
        from: publisherProvider,
        name: r'publisherProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherHash,
        dependencies: PublisherFamily._dependencies,
        allTransitiveDependencies: PublisherFamily._allTransitiveDependencies,
        identifier: identifier,
      );

  PublisherProvider._internal(
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
  Override overrideWith(
    FutureOr<SnPublisher?> Function(PublisherRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublisherProvider._internal(
        (ref) => create(ref as PublisherRef),
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
  AutoDisposeFutureProviderElement<SnPublisher?> createElement() {
    return _PublisherProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherProvider && other.identifier == identifier;
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
mixin PublisherRef on AutoDisposeFutureProviderRef<SnPublisher?> {
  /// The parameter `identifier` of this provider.
  String? get identifier;
}

class _PublisherProviderElement
    extends AutoDisposeFutureProviderElement<SnPublisher?>
    with PublisherRef {
  _PublisherProviderElement(super.provider);

  @override
  String? get identifier => (origin as PublisherProvider).identifier;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
