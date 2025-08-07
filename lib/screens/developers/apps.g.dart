// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apps.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customAppsHash() => r'c6ac78060eb51a2b208a749a81ecbe0a9c608ce1';

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

/// See also [customApps].
@ProviderFor(customApps)
const customAppsProvider = CustomAppsFamily();

/// See also [customApps].
class CustomAppsFamily extends Family<AsyncValue<List<CustomApp>>> {
  /// See also [customApps].
  const CustomAppsFamily();

  /// See also [customApps].
  CustomAppsProvider call(String publisherName) {
    return CustomAppsProvider(publisherName);
  }

  @override
  CustomAppsProvider getProviderOverride(
    covariant CustomAppsProvider provider,
  ) {
    return call(provider.publisherName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customAppsProvider';
}

/// See also [customApps].
class CustomAppsProvider extends AutoDisposeFutureProvider<List<CustomApp>> {
  /// See also [customApps].
  CustomAppsProvider(String publisherName)
    : this._internal(
        (ref) => customApps(ref as CustomAppsRef, publisherName),
        from: customAppsProvider,
        name: r'customAppsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$customAppsHash,
        dependencies: CustomAppsFamily._dependencies,
        allTransitiveDependencies: CustomAppsFamily._allTransitiveDependencies,
        publisherName: publisherName,
      );

  CustomAppsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.publisherName,
  }) : super.internal();

  final String publisherName;

  @override
  Override overrideWith(
    FutureOr<List<CustomApp>> Function(CustomAppsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomAppsProvider._internal(
        (ref) => create(ref as CustomAppsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        publisherName: publisherName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CustomApp>> createElement() {
    return _CustomAppsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomAppsProvider && other.publisherName == publisherName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, publisherName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomAppsRef on AutoDisposeFutureProviderRef<List<CustomApp>> {
  /// The parameter `publisherName` of this provider.
  String get publisherName;
}

class _CustomAppsProviderElement
    extends AutoDisposeFutureProviderElement<List<CustomApp>>
    with CustomAppsRef {
  _CustomAppsProviderElement(super.provider);

  @override
  String get publisherName => (origin as CustomAppsProvider).publisherName;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
