// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_presence.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$discordAssetsHash() => r'3ef8465188059de96cf2ac9660ed3d88910443bf';

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

/// See also [discordAssets].
@ProviderFor(discordAssets)
const discordAssetsProvider = DiscordAssetsFamily();

/// See also [discordAssets].
class DiscordAssetsFamily extends Family<AsyncValue<Map<String, String>?>> {
  /// See also [discordAssets].
  const DiscordAssetsFamily();

  /// See also [discordAssets].
  DiscordAssetsProvider call(SnPresenceActivity activity) {
    return DiscordAssetsProvider(activity);
  }

  @override
  DiscordAssetsProvider getProviderOverride(
    covariant DiscordAssetsProvider provider,
  ) {
    return call(provider.activity);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'discordAssetsProvider';
}

/// See also [discordAssets].
class DiscordAssetsProvider
    extends AutoDisposeFutureProvider<Map<String, String>?> {
  /// See also [discordAssets].
  DiscordAssetsProvider(SnPresenceActivity activity)
    : this._internal(
        (ref) => discordAssets(ref as DiscordAssetsRef, activity),
        from: discordAssetsProvider,
        name: r'discordAssetsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$discordAssetsHash,
        dependencies: DiscordAssetsFamily._dependencies,
        allTransitiveDependencies:
            DiscordAssetsFamily._allTransitiveDependencies,
        activity: activity,
      );

  DiscordAssetsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.activity,
  }) : super.internal();

  final SnPresenceActivity activity;

  @override
  Override overrideWith(
    FutureOr<Map<String, String>?> Function(DiscordAssetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DiscordAssetsProvider._internal(
        (ref) => create(ref as DiscordAssetsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        activity: activity,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, String>?> createElement() {
    return _DiscordAssetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiscordAssetsProvider && other.activity == activity;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, activity.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DiscordAssetsRef on AutoDisposeFutureProviderRef<Map<String, String>?> {
  /// The parameter `activity` of this provider.
  SnPresenceActivity get activity;
}

class _DiscordAssetsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, String>?>
    with DiscordAssetsRef {
  _DiscordAssetsProviderElement(super.provider);

  @override
  SnPresenceActivity get activity => (origin as DiscordAssetsProvider).activity;
}

String _$discordAssetsUrlHash() => r'a32f9333c3fb4d50ff88a54a6b8b72fbf5ba3ea1';

/// See also [discordAssetsUrl].
@ProviderFor(discordAssetsUrl)
const discordAssetsUrlProvider = DiscordAssetsUrlFamily();

/// See also [discordAssetsUrl].
class DiscordAssetsUrlFamily extends Family<AsyncValue<String?>> {
  /// See also [discordAssetsUrl].
  const DiscordAssetsUrlFamily();

  /// See also [discordAssetsUrl].
  DiscordAssetsUrlProvider call(SnPresenceActivity activity, String key) {
    return DiscordAssetsUrlProvider(activity, key);
  }

  @override
  DiscordAssetsUrlProvider getProviderOverride(
    covariant DiscordAssetsUrlProvider provider,
  ) {
    return call(provider.activity, provider.key);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'discordAssetsUrlProvider';
}

/// See also [discordAssetsUrl].
class DiscordAssetsUrlProvider extends AutoDisposeFutureProvider<String?> {
  /// See also [discordAssetsUrl].
  DiscordAssetsUrlProvider(SnPresenceActivity activity, String key)
    : this._internal(
        (ref) => discordAssetsUrl(ref as DiscordAssetsUrlRef, activity, key),
        from: discordAssetsUrlProvider,
        name: r'discordAssetsUrlProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$discordAssetsUrlHash,
        dependencies: DiscordAssetsUrlFamily._dependencies,
        allTransitiveDependencies:
            DiscordAssetsUrlFamily._allTransitiveDependencies,
        activity: activity,
        key: key,
      );

  DiscordAssetsUrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.activity,
    required this.key,
  }) : super.internal();

  final SnPresenceActivity activity;
  final String key;

  @override
  Override overrideWith(
    FutureOr<String?> Function(DiscordAssetsUrlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DiscordAssetsUrlProvider._internal(
        (ref) => create(ref as DiscordAssetsUrlRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        activity: activity,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _DiscordAssetsUrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiscordAssetsUrlProvider &&
        other.activity == activity &&
        other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, activity.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DiscordAssetsUrlRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `activity` of this provider.
  SnPresenceActivity get activity;

  /// The parameter `key` of this provider.
  String get key;
}

class _DiscordAssetsUrlProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with DiscordAssetsUrlRef {
  _DiscordAssetsUrlProviderElement(super.provider);

  @override
  SnPresenceActivity get activity =>
      (origin as DiscordAssetsUrlProvider).activity;
  @override
  String get key => (origin as DiscordAssetsUrlProvider).key;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
