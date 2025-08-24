// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apps.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customAppHash() => r'be05431ba8bf06fd20ee988a61c3663a68e15fc9';

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
class CustomAppFamily extends Family<AsyncValue<CustomApp>> {
  /// See also [customApp].
  const CustomAppFamily();

  /// See also [customApp].
  CustomAppProvider call(String publisherName, String projectId, String appId) {
    return CustomAppProvider(publisherName, projectId, appId);
  }

  @override
  CustomAppProvider getProviderOverride(covariant CustomAppProvider provider) {
    return call(provider.publisherName, provider.projectId, provider.appId);
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
class CustomAppProvider extends AutoDisposeFutureProvider<CustomApp> {
  /// See also [customApp].
  CustomAppProvider(String publisherName, String projectId, String appId)
    : this._internal(
        (ref) =>
            customApp(ref as CustomAppRef, publisherName, projectId, appId),
        from: customAppProvider,
        name: r'customAppProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$customAppHash,
        dependencies: CustomAppFamily._dependencies,
        allTransitiveDependencies: CustomAppFamily._allTransitiveDependencies,
        publisherName: publisherName,
        projectId: projectId,
        appId: appId,
      );

  CustomAppProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.publisherName,
    required this.projectId,
    required this.appId,
  }) : super.internal();

  final String publisherName;
  final String projectId;
  final String appId;

  @override
  Override overrideWith(
    FutureOr<CustomApp> Function(CustomAppRef provider) create,
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
        projectId: projectId,
        appId: appId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CustomApp> createElement() {
    return _CustomAppProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomAppProvider &&
        other.publisherName == publisherName &&
        other.projectId == projectId &&
        other.appId == appId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, publisherName.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);
    hash = _SystemHash.combine(hash, appId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomAppRef on AutoDisposeFutureProviderRef<CustomApp> {
  /// The parameter `publisherName` of this provider.
  String get publisherName;

  /// The parameter `projectId` of this provider.
  String get projectId;

  /// The parameter `appId` of this provider.
  String get appId;
}

class _CustomAppProviderElement
    extends AutoDisposeFutureProviderElement<CustomApp>
    with CustomAppRef {
  _CustomAppProviderElement(super.provider);

  @override
  String get publisherName => (origin as CustomAppProvider).publisherName;
  @override
  String get projectId => (origin as CustomAppProvider).projectId;
  @override
  String get appId => (origin as CustomAppProvider).appId;
}

String _$customAppsHash() => r'450bedaf4220b8963cb44afeb14d4c0e80f01b11';

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
