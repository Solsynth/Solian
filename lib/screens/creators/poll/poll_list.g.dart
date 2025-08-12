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

String _$pollListNotifierHash() => r'd5b822e737788be8982f5cb3b501d460441930c1';

abstract class _$PollListNotifier
    extends
        BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnPollWithStats>> {
  late final String? pubName;

  FutureOr<CursorPagingData<SnPollWithStats>> build(String? pubName);
}

/// See also [PollListNotifier].
@ProviderFor(PollListNotifier)
const pollListNotifierProvider = PollListNotifierFamily();

/// See also [PollListNotifier].
class PollListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnPollWithStats>>> {
  /// See also [PollListNotifier].
  const PollListNotifierFamily();

  /// See also [PollListNotifier].
  PollListNotifierProvider call(String? pubName) {
    return PollListNotifierProvider(pubName);
  }

  @override
  PollListNotifierProvider getProviderOverride(
    covariant PollListNotifierProvider provider,
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
  String? get name => r'pollListNotifierProvider';
}

/// See also [PollListNotifier].
class PollListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PollListNotifier,
          CursorPagingData<SnPollWithStats>
        > {
  /// See also [PollListNotifier].
  PollListNotifierProvider(String? pubName)
    : this._internal(
        () => PollListNotifier()..pubName = pubName,
        from: pollListNotifierProvider,
        name: r'pollListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$pollListNotifierHash,
        dependencies: PollListNotifierFamily._dependencies,
        allTransitiveDependencies:
            PollListNotifierFamily._allTransitiveDependencies,
        pubName: pubName,
      );

  PollListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pubName,
  }) : super.internal();

  final String? pubName;

  @override
  FutureOr<CursorPagingData<SnPollWithStats>> runNotifierBuild(
    covariant PollListNotifier notifier,
  ) {
    return notifier.build(pubName);
  }

  @override
  Override overrideWith(PollListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PollListNotifierProvider._internal(
        () => create()..pubName = pubName,
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
  AutoDisposeAsyncNotifierProviderElement<
    PollListNotifier,
    CursorPagingData<SnPollWithStats>
  >
  createElement() {
    return _PollListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PollListNotifierProvider && other.pubName == pubName;
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
mixin PollListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnPollWithStats>> {
  /// The parameter `pubName` of this provider.
  String? get pubName;
}

class _PollListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PollListNotifier,
          CursorPagingData<SnPollWithStats>
        >
    with PollListNotifierRef {
  _PollListNotifierProviderElement(super.provider);

  @override
  String? get pubName => (origin as PollListNotifierProvider).pubName;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
