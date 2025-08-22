// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bots.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$botsHash() => r'04bff237afa91032310eaa8acd792c5a98da0d75';

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

/// See also [bots].
@ProviderFor(bots)
const botsProvider = BotsFamily();

/// See also [bots].
class BotsFamily extends Family<AsyncValue<List<Bot>>> {
  /// See also [bots].
  const BotsFamily();

  /// See also [bots].
  BotsProvider call(String publisherName, {String? appId}) {
    return BotsProvider(publisherName, appId: appId);
  }

  @override
  BotsProvider getProviderOverride(covariant BotsProvider provider) {
    return call(provider.publisherName, appId: provider.appId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'botsProvider';
}

/// See also [bots].
class BotsProvider extends AutoDisposeFutureProvider<List<Bot>> {
  /// See also [bots].
  BotsProvider(String publisherName, {String? appId})
    : this._internal(
        (ref) => bots(ref as BotsRef, publisherName, appId: appId),
        from: botsProvider,
        name: r'botsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product') ? null : _$botsHash,
        dependencies: BotsFamily._dependencies,
        allTransitiveDependencies: BotsFamily._allTransitiveDependencies,
        publisherName: publisherName,
        appId: appId,
      );

  BotsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.publisherName,
    required this.appId,
  }) : super.internal();

  final String publisherName;
  final String? appId;

  @override
  Override overrideWith(FutureOr<List<Bot>> Function(BotsRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: BotsProvider._internal(
        (ref) => create(ref as BotsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        publisherName: publisherName,
        appId: appId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Bot>> createElement() {
    return _BotsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BotsProvider &&
        other.publisherName == publisherName &&
        other.appId == appId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, publisherName.hashCode);
    hash = _SystemHash.combine(hash, appId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BotsRef on AutoDisposeFutureProviderRef<List<Bot>> {
  /// The parameter `publisherName` of this provider.
  String get publisherName;

  /// The parameter `appId` of this provider.
  String? get appId;
}

class _BotsProviderElement extends AutoDisposeFutureProviderElement<List<Bot>>
    with BotsRef {
  _BotsProviderElement(super.provider);

  @override
  String get publisherName => (origin as BotsProvider).publisherName;
  @override
  String? get appId => (origin as BotsProvider).appId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
