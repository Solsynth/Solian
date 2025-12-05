// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pollWithStatsHash() => r'6bb910046ce1e09368f9922dbec52fdc2cc86740';

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

/// See also [pollWithStats].
@ProviderFor(pollWithStats)
const pollWithStatsProvider = PollWithStatsFamily();

/// See also [pollWithStats].
class PollWithStatsFamily extends Family<AsyncValue<SnPollWithStats>> {
  /// See also [pollWithStats].
  const PollWithStatsFamily();

  /// See also [pollWithStats].
  PollWithStatsProvider call(String id) {
    return PollWithStatsProvider(id);
  }

  @override
  PollWithStatsProvider getProviderOverride(
    covariant PollWithStatsProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pollWithStatsProvider';
}

/// See also [pollWithStats].
class PollWithStatsProvider extends AutoDisposeFutureProvider<SnPollWithStats> {
  /// See also [pollWithStats].
  PollWithStatsProvider(String id)
    : this._internal(
        (ref) => pollWithStats(ref as PollWithStatsRef, id),
        from: pollWithStatsProvider,
        name: r'pollWithStatsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$pollWithStatsHash,
        dependencies: PollWithStatsFamily._dependencies,
        allTransitiveDependencies:
            PollWithStatsFamily._allTransitiveDependencies,
        id: id,
      );

  PollWithStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<SnPollWithStats> Function(PollWithStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PollWithStatsProvider._internal(
        (ref) => create(ref as PollWithStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnPollWithStats> createElement() {
    return _PollWithStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PollWithStatsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PollWithStatsRef on AutoDisposeFutureProviderRef<SnPollWithStats> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PollWithStatsProviderElement
    extends AutoDisposeFutureProviderElement<SnPollWithStats>
    with PollWithStatsRef {
  _PollWithStatsProviderElement(super.provider);

  @override
  String get id => (origin as PollWithStatsProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
