// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pub_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$publisherHash() => r'3a7ae4d48765170aea42c7d6f4502d68f984dfab';

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
class PublisherFamily extends Family<AsyncValue<SnPublisher>> {
  /// See also [publisher].
  const PublisherFamily();

  /// See also [publisher].
  PublisherProvider call(String uname) {
    return PublisherProvider(uname);
  }

  @override
  PublisherProvider getProviderOverride(covariant PublisherProvider provider) {
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
  String? get name => r'publisherProvider';
}

/// See also [publisher].
class PublisherProvider extends AutoDisposeFutureProvider<SnPublisher> {
  /// See also [publisher].
  PublisherProvider(String uname)
    : this._internal(
        (ref) => publisher(ref as PublisherRef, uname),
        from: publisherProvider,
        name: r'publisherProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherHash,
        dependencies: PublisherFamily._dependencies,
        allTransitiveDependencies: PublisherFamily._allTransitiveDependencies,
        uname: uname,
      );

  PublisherProvider._internal(
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
    FutureOr<SnPublisher> Function(PublisherRef provider) create,
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
        uname: uname,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnPublisher> createElement() {
    return _PublisherProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherProvider && other.uname == uname;
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
mixin PublisherRef on AutoDisposeFutureProviderRef<SnPublisher> {
  /// The parameter `uname` of this provider.
  String get uname;
}

class _PublisherProviderElement
    extends AutoDisposeFutureProviderElement<SnPublisher>
    with PublisherRef {
  _PublisherProviderElement(super.provider);

  @override
  String get uname => (origin as PublisherProvider).uname;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
