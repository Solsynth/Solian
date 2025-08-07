// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_app.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customAppHash() => r'42ad937b8439c793e3c5c35568bb5fa4da017df3';

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

/// See also [customApp].
@ProviderFor(customApp)
const customAppProvider = CustomAppFamily();

/// See also [customApp].
class CustomAppFamily extends Family<AsyncValue<CustomApp?>> {
  /// See also [customApp].
  const CustomAppFamily();

  /// See also [customApp].
  CustomAppProvider call(String publisherName, String id) {
    return CustomAppProvider(publisherName, id);
  }

  @override
  CustomAppProvider getProviderOverride(covariant CustomAppProvider provider) {
    return call(provider.publisherName, provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customAppProvider';
}

/// See also [customApp].
class CustomAppProvider extends AutoDisposeFutureProvider<CustomApp?> {
  /// See also [customApp].
  CustomAppProvider(String publisherName, String id)
    : this._internal(
        (ref) => customApp(ref as CustomAppRef, publisherName, id),
        from: customAppProvider,
        name: r'customAppProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$customAppHash,
        dependencies: CustomAppFamily._dependencies,
        allTransitiveDependencies: CustomAppFamily._allTransitiveDependencies,
        publisherName: publisherName,
        id: id,
      );

  CustomAppProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.publisherName,
    required this.id,
  }) : super.internal();

  final String publisherName;
  final String id;

  @override
  Override overrideWith(
    FutureOr<CustomApp?> Function(CustomAppRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomAppProvider._internal(
        (ref) => create(ref as CustomAppRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        publisherName: publisherName,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CustomApp?> createElement() {
    return _CustomAppProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomAppProvider &&
        other.publisherName == publisherName &&
        other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, publisherName.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomAppRef on AutoDisposeFutureProviderRef<CustomApp?> {
  /// The parameter `publisherName` of this provider.
  String get publisherName;

  /// The parameter `id` of this provider.
  String get id;
}

class _CustomAppProviderElement
    extends AutoDisposeFutureProviderElement<CustomApp?>
    with CustomAppRef {
  _CustomAppProviderElement(super.provider);

  @override
  String get publisherName => (origin as CustomAppProvider).publisherName;
  @override
  String get id => (origin as CustomAppProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
