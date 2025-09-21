// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pub_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$publisherHash() => r'a1da21f0275421382e2882fd52c4e061c4675cf7';

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

String _$publisherBadgesHash() => r'527efad74225fbacf558ac5db160ecce53a60c62';

/// See also [publisherBadges].
@ProviderFor(publisherBadges)
const publisherBadgesProvider = PublisherBadgesFamily();

/// See also [publisherBadges].
class PublisherBadgesFamily extends Family<AsyncValue<List<SnAccountBadge>>> {
  /// See also [publisherBadges].
  const PublisherBadgesFamily();

  /// See also [publisherBadges].
  PublisherBadgesProvider call(String pubName) {
    return PublisherBadgesProvider(pubName);
  }

  @override
  PublisherBadgesProvider getProviderOverride(
    covariant PublisherBadgesProvider provider,
  ) {
    return call(provider.pubName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publisherBadgesProvider';
}

/// See also [publisherBadges].
class PublisherBadgesProvider
    extends AutoDisposeFutureProvider<List<SnAccountBadge>> {
  /// See also [publisherBadges].
  PublisherBadgesProvider(String pubName)
    : this._internal(
        (ref) => publisherBadges(ref as PublisherBadgesRef, pubName),
        from: publisherBadgesProvider,
        name: r'publisherBadgesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherBadgesHash,
        dependencies: PublisherBadgesFamily._dependencies,
        allTransitiveDependencies:
            PublisherBadgesFamily._allTransitiveDependencies,
        pubName: pubName,
      );

  PublisherBadgesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pubName,
  }) : super.internal();

  final String pubName;

  @override
  Override overrideWith(
    FutureOr<List<SnAccountBadge>> Function(PublisherBadgesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublisherBadgesProvider._internal(
        (ref) => create(ref as PublisherBadgesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pubName: pubName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnAccountBadge>> createElement() {
    return _PublisherBadgesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherBadgesProvider && other.pubName == pubName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pubName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublisherBadgesRef on AutoDisposeFutureProviderRef<List<SnAccountBadge>> {
  /// The parameter `pubName` of this provider.
  String get pubName;
}

class _PublisherBadgesProviderElement
    extends AutoDisposeFutureProviderElement<List<SnAccountBadge>>
    with PublisherBadgesRef {
  _PublisherBadgesProviderElement(super.provider);

  @override
  String get pubName => (origin as PublisherBadgesProvider).pubName;
}

String _$publisherSubscriptionStatusHash() =>
    r'634262ce519e1c8288267df11e08e1d4acaa4a44';

/// See also [publisherSubscriptionStatus].
@ProviderFor(publisherSubscriptionStatus)
const publisherSubscriptionStatusProvider = PublisherSubscriptionStatusFamily();

/// See also [publisherSubscriptionStatus].
class PublisherSubscriptionStatusFamily
    extends Family<AsyncValue<SnSubscriptionStatus>> {
  /// See also [publisherSubscriptionStatus].
  const PublisherSubscriptionStatusFamily();

  /// See also [publisherSubscriptionStatus].
  PublisherSubscriptionStatusProvider call(String pubName) {
    return PublisherSubscriptionStatusProvider(pubName);
  }

  @override
  PublisherSubscriptionStatusProvider getProviderOverride(
    covariant PublisherSubscriptionStatusProvider provider,
  ) {
    return call(provider.pubName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publisherSubscriptionStatusProvider';
}

/// See also [publisherSubscriptionStatus].
class PublisherSubscriptionStatusProvider
    extends AutoDisposeFutureProvider<SnSubscriptionStatus> {
  /// See also [publisherSubscriptionStatus].
  PublisherSubscriptionStatusProvider(String pubName)
    : this._internal(
        (ref) => publisherSubscriptionStatus(
          ref as PublisherSubscriptionStatusRef,
          pubName,
        ),
        from: publisherSubscriptionStatusProvider,
        name: r'publisherSubscriptionStatusProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherSubscriptionStatusHash,
        dependencies: PublisherSubscriptionStatusFamily._dependencies,
        allTransitiveDependencies:
            PublisherSubscriptionStatusFamily._allTransitiveDependencies,
        pubName: pubName,
      );

  PublisherSubscriptionStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pubName,
  }) : super.internal();

  final String pubName;

  @override
  Override overrideWith(
    FutureOr<SnSubscriptionStatus> Function(
      PublisherSubscriptionStatusRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublisherSubscriptionStatusProvider._internal(
        (ref) => create(ref as PublisherSubscriptionStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pubName: pubName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnSubscriptionStatus> createElement() {
    return _PublisherSubscriptionStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherSubscriptionStatusProvider &&
        other.pubName == pubName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pubName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublisherSubscriptionStatusRef
    on AutoDisposeFutureProviderRef<SnSubscriptionStatus> {
  /// The parameter `pubName` of this provider.
  String get pubName;
}

class _PublisherSubscriptionStatusProviderElement
    extends AutoDisposeFutureProviderElement<SnSubscriptionStatus>
    with PublisherSubscriptionStatusRef {
  _PublisherSubscriptionStatusProviderElement(super.provider);

  @override
  String get pubName => (origin as PublisherSubscriptionStatusProvider).pubName;
}

String _$publisherAppbarForcegroundColorHash() =>
    r'cd9a9816177a6eecc2bc354acebbbd48892ffdd7';

/// See also [publisherAppbarForcegroundColor].
@ProviderFor(publisherAppbarForcegroundColor)
const publisherAppbarForcegroundColorProvider =
    PublisherAppbarForcegroundColorFamily();

/// See also [publisherAppbarForcegroundColor].
class PublisherAppbarForcegroundColorFamily extends Family<AsyncValue<Color?>> {
  /// See also [publisherAppbarForcegroundColor].
  const PublisherAppbarForcegroundColorFamily();

  /// See also [publisherAppbarForcegroundColor].
  PublisherAppbarForcegroundColorProvider call(String pubName) {
    return PublisherAppbarForcegroundColorProvider(pubName);
  }

  @override
  PublisherAppbarForcegroundColorProvider getProviderOverride(
    covariant PublisherAppbarForcegroundColorProvider provider,
  ) {
    return call(provider.pubName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publisherAppbarForcegroundColorProvider';
}

/// See also [publisherAppbarForcegroundColor].
class PublisherAppbarForcegroundColorProvider
    extends AutoDisposeFutureProvider<Color?> {
  /// See also [publisherAppbarForcegroundColor].
  PublisherAppbarForcegroundColorProvider(String pubName)
    : this._internal(
        (ref) => publisherAppbarForcegroundColor(
          ref as PublisherAppbarForcegroundColorRef,
          pubName,
        ),
        from: publisherAppbarForcegroundColorProvider,
        name: r'publisherAppbarForcegroundColorProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$publisherAppbarForcegroundColorHash,
        dependencies: PublisherAppbarForcegroundColorFamily._dependencies,
        allTransitiveDependencies:
            PublisherAppbarForcegroundColorFamily._allTransitiveDependencies,
        pubName: pubName,
      );

  PublisherAppbarForcegroundColorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pubName,
  }) : super.internal();

  final String pubName;

  @override
  Override overrideWith(
    FutureOr<Color?> Function(PublisherAppbarForcegroundColorRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PublisherAppbarForcegroundColorProvider._internal(
        (ref) => create(ref as PublisherAppbarForcegroundColorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pubName: pubName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Color?> createElement() {
    return _PublisherAppbarForcegroundColorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherAppbarForcegroundColorProvider &&
        other.pubName == pubName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pubName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublisherAppbarForcegroundColorRef
    on AutoDisposeFutureProviderRef<Color?> {
  /// The parameter `pubName` of this provider.
  String get pubName;
}

class _PublisherAppbarForcegroundColorProviderElement
    extends AutoDisposeFutureProviderElement<Color?>
    with PublisherAppbarForcegroundColorRef {
  _PublisherAppbarForcegroundColorProviderElement(super.provider);

  @override
  String get pubName =>
      (origin as PublisherAppbarForcegroundColorProvider).pubName;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
