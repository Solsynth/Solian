// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activityListNotifierHash() =>
    r'77ffc7852feffa5438b56fa26123d453b7c310cf';

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

abstract class _$ActivityListNotifier
    extends
        BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnTimelineEvent>> {
  late final String? filter;

  FutureOr<CursorPagingData<SnTimelineEvent>> build(String? filter);
}

/// See also [ActivityListNotifier].
@ProviderFor(ActivityListNotifier)
const activityListNotifierProvider = ActivityListNotifierFamily();

/// See also [ActivityListNotifier].
class ActivityListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnTimelineEvent>>> {
  /// See also [ActivityListNotifier].
  const ActivityListNotifierFamily();

  /// See also [ActivityListNotifier].
  ActivityListNotifierProvider call(String? filter) {
    return ActivityListNotifierProvider(filter);
  }

  @override
  ActivityListNotifierProvider getProviderOverride(
    covariant ActivityListNotifierProvider provider,
  ) {
    return call(provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activityListNotifierProvider';
}

/// See also [ActivityListNotifier].
class ActivityListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ActivityListNotifier,
          CursorPagingData<SnTimelineEvent>
        > {
  /// See also [ActivityListNotifier].
  ActivityListNotifierProvider(String? filter)
    : this._internal(
        () => ActivityListNotifier()..filter = filter,
        from: activityListNotifierProvider,
        name: r'activityListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$activityListNotifierHash,
        dependencies: ActivityListNotifierFamily._dependencies,
        allTransitiveDependencies:
            ActivityListNotifierFamily._allTransitiveDependencies,
        filter: filter,
      );

  ActivityListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final String? filter;

  @override
  FutureOr<CursorPagingData<SnTimelineEvent>> runNotifierBuild(
    covariant ActivityListNotifier notifier,
  ) {
    return notifier.build(filter);
  }

  @override
  Override overrideWith(ActivityListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ActivityListNotifierProvider._internal(
        () => create()..filter = filter,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ActivityListNotifier,
    CursorPagingData<SnTimelineEvent>
  >
  createElement() {
    return _ActivityListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityListNotifierProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActivityListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnTimelineEvent>> {
  /// The parameter `filter` of this provider.
  String? get filter;
}

class _ActivityListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ActivityListNotifier,
          CursorPagingData<SnTimelineEvent>
        >
    with ActivityListNotifierRef {
  _ActivityListNotifierProviderElement(super.provider);

  @override
  String? get filter => (origin as ActivityListNotifierProvider).filter;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
