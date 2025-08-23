// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apps.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customAppsHash() => r'450bedaf4220b8963cb44afeb14d4c0e80f01b11';

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
  CustomAppsProvider call(String publisherName, String projectId) {
    return CustomAppsProvider(publisherName, projectId);
  }

  @override
  CustomAppsProvider getProviderOverride(
    covariant CustomAppsProvider provider,
  ) {
    return call(provider.publisherName, provider.projectId);
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
  CustomAppsProvider(String publisherName, String projectId)
    : this._internal(
        (ref) => customApps(ref as CustomAppsRef, publisherName, projectId),
        from: customAppsProvider,
        name: r'customAppsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$customAppsHash,
        dependencies: CustomAppsFamily._dependencies,
        allTransitiveDependencies: CustomAppsFamily._allTransitiveDependencies,
        publisherName: publisherName,
        projectId: projectId,
      );

  CustomAppsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.publisherName,
    required this.projectId,
  }) : super.internal();

  final String publisherName;
  final String projectId;

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
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CustomApp>> createElement() {
    return _CustomAppsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomAppsProvider &&
        other.publisherName == publisherName &&
        other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, publisherName.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomAppsRef on AutoDisposeFutureProviderRef<List<CustomApp>> {
  /// The parameter `publisherName` of this provider.
  String get publisherName;

  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _CustomAppsProviderElement
    extends AutoDisposeFutureProviderElement<List<CustomApp>>
    with CustomAppsRef {
  _CustomAppsProviderElement(super.provider);

  @override
  String get publisherName => (origin as CustomAppsProvider).publisherName;
  @override
  String get projectId => (origin as CustomAppsProvider).projectId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
