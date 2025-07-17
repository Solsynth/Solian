// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_button.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ongoingCallHash() => r'48031badb79efa07aefb3a4fc51635be457bd3f9';

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

/// See also [ongoingCall].
@ProviderFor(ongoingCall)
const ongoingCallProvider = OngoingCallFamily();

/// See also [ongoingCall].
class OngoingCallFamily extends Family<AsyncValue<SnRealtimeCall?>> {
  /// See also [ongoingCall].
  const OngoingCallFamily();

  /// See also [ongoingCall].
  OngoingCallProvider call(String roomId) {
    return OngoingCallProvider(roomId);
  }

  @override
  OngoingCallProvider getProviderOverride(
    covariant OngoingCallProvider provider,
  ) {
    return call(provider.roomId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ongoingCallProvider';
}

/// See also [ongoingCall].
class OngoingCallProvider extends AutoDisposeFutureProvider<SnRealtimeCall?> {
  /// See also [ongoingCall].
  OngoingCallProvider(String roomId)
    : this._internal(
        (ref) => ongoingCall(ref as OngoingCallRef, roomId),
        from: ongoingCallProvider,
        name: r'ongoingCallProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$ongoingCallHash,
        dependencies: OngoingCallFamily._dependencies,
        allTransitiveDependencies: OngoingCallFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  OngoingCallProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String roomId;

  @override
  Override overrideWith(
    FutureOr<SnRealtimeCall?> Function(OngoingCallRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OngoingCallProvider._internal(
        (ref) => create(ref as OngoingCallRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnRealtimeCall?> createElement() {
    return _OngoingCallProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OngoingCallProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OngoingCallRef on AutoDisposeFutureProviderRef<SnRealtimeCall?> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _OngoingCallProviderElement
    extends AutoDisposeFutureProviderElement<SnRealtimeCall?>
    with OngoingCallRef {
  _OngoingCallProviderElement(super.provider);

  @override
  String get roomId => (origin as OngoingCallProvider).roomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
