// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_rpc.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presenceActivitiesHash() =>
    r'3bfaa638eeb961ecd62a32d6a7760a6a7e7bf6f2';

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

/// See also [presenceActivities].
@ProviderFor(presenceActivities)
const presenceActivitiesProvider = PresenceActivitiesFamily();

/// See also [presenceActivities].
class PresenceActivitiesFamily
    extends Family<AsyncValue<List<SnPresenceActivity>>> {
  /// See also [presenceActivities].
  const PresenceActivitiesFamily();

  /// See also [presenceActivities].
  PresenceActivitiesProvider call(String uname) {
    return PresenceActivitiesProvider(uname);
  }

  @override
  PresenceActivitiesProvider getProviderOverride(
    covariant PresenceActivitiesProvider provider,
  ) {
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
  String? get name => r'presenceActivitiesProvider';
}

/// See also [presenceActivities].
class PresenceActivitiesProvider
    extends AutoDisposeFutureProvider<List<SnPresenceActivity>> {
  /// See also [presenceActivities].
  PresenceActivitiesProvider(String uname)
    : this._internal(
        (ref) => presenceActivities(ref as PresenceActivitiesRef, uname),
        from: presenceActivitiesProvider,
        name: r'presenceActivitiesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$presenceActivitiesHash,
        dependencies: PresenceActivitiesFamily._dependencies,
        allTransitiveDependencies:
            PresenceActivitiesFamily._allTransitiveDependencies,
        uname: uname,
      );

  PresenceActivitiesProvider._internal(
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
    FutureOr<List<SnPresenceActivity>> Function(PresenceActivitiesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PresenceActivitiesProvider._internal(
        (ref) => create(ref as PresenceActivitiesRef),
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
  AutoDisposeFutureProviderElement<List<SnPresenceActivity>> createElement() {
    return _PresenceActivitiesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PresenceActivitiesProvider && other.uname == uname;
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
mixin PresenceActivitiesRef
    on AutoDisposeFutureProviderRef<List<SnPresenceActivity>> {
  /// The parameter `uname` of this provider.
  String get uname;
}

class _PresenceActivitiesProviderElement
    extends AutoDisposeFutureProviderElement<List<SnPresenceActivity>>
    with PresenceActivitiesRef {
  _PresenceActivitiesProviderElement(super.provider);

  @override
  String get uname => (origin as PresenceActivitiesProvider).uname;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
