// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_secrets.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customAppSecretsHash() => r'1bc62ad812487883ce739793b22a76168d656752';

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

/// See also [customAppSecrets].
@ProviderFor(customAppSecrets)
const customAppSecretsProvider = CustomAppSecretsFamily();

/// See also [customAppSecrets].
class CustomAppSecretsFamily extends Family<AsyncValue<List<CustomAppSecret>>> {
  /// See also [customAppSecrets].
  const CustomAppSecretsFamily();

  /// See also [customAppSecrets].
  CustomAppSecretsProvider call(
    String publisherName,
    String projectId,
    String appId,
  ) {
    return CustomAppSecretsProvider(publisherName, projectId, appId);
  }

  @override
  CustomAppSecretsProvider getProviderOverride(
    covariant CustomAppSecretsProvider provider,
  ) {
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
  String? get name => r'customAppSecretsProvider';
}

/// See also [customAppSecrets].
class CustomAppSecretsProvider
    extends AutoDisposeFutureProvider<List<CustomAppSecret>> {
  /// See also [customAppSecrets].
  CustomAppSecretsProvider(String publisherName, String projectId, String appId)
    : this._internal(
        (ref) => customAppSecrets(
          ref as CustomAppSecretsRef,
          publisherName,
          projectId,
          appId,
        ),
        from: customAppSecretsProvider,
        name: r'customAppSecretsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$customAppSecretsHash,
        dependencies: CustomAppSecretsFamily._dependencies,
        allTransitiveDependencies:
            CustomAppSecretsFamily._allTransitiveDependencies,
        publisherName: publisherName,
        projectId: projectId,
        appId: appId,
      );

  CustomAppSecretsProvider._internal(
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
    FutureOr<List<CustomAppSecret>> Function(CustomAppSecretsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomAppSecretsProvider._internal(
        (ref) => create(ref as CustomAppSecretsRef),
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
  AutoDisposeFutureProviderElement<List<CustomAppSecret>> createElement() {
    return _CustomAppSecretsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomAppSecretsProvider &&
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
mixin CustomAppSecretsRef
    on AutoDisposeFutureProviderRef<List<CustomAppSecret>> {
  /// The parameter `publisherName` of this provider.
  String get publisherName;

  /// The parameter `projectId` of this provider.
  String get projectId;

  /// The parameter `appId` of this provider.
  String get appId;
}

class _CustomAppSecretsProviderElement
    extends AutoDisposeFutureProviderElement<List<CustomAppSecret>>
    with CustomAppSecretsRef {
  _CustomAppSecretsProviderElement(super.provider);

  @override
  String get publisherName =>
      (origin as CustomAppSecretsProvider).publisherName;
  @override
  String get projectId => (origin as CustomAppSecretsProvider).projectId;
  @override
  String get appId => (origin as CustomAppSecretsProvider).appId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
