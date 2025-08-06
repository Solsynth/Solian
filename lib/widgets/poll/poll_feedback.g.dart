// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_feedback.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pollFeedbackNotifierHash() =>
    r'1bf3925b5b751cfd1a9abafb75274f1e95e7f27e';

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

abstract class _$PollFeedbackNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnPollAnswer>> {
  late final String id;

  FutureOr<CursorPagingData<SnPollAnswer>> build(String id);
}

/// See also [PollFeedbackNotifier].
@ProviderFor(PollFeedbackNotifier)
const pollFeedbackNotifierProvider = PollFeedbackNotifierFamily();

/// See also [PollFeedbackNotifier].
class PollFeedbackNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnPollAnswer>>> {
  /// See also [PollFeedbackNotifier].
  const PollFeedbackNotifierFamily();

  /// See also [PollFeedbackNotifier].
  PollFeedbackNotifierProvider call(String id) {
    return PollFeedbackNotifierProvider(id);
  }

  @override
  PollFeedbackNotifierProvider getProviderOverride(
    covariant PollFeedbackNotifierProvider provider,
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
  String? get name => r'pollFeedbackNotifierProvider';
}

/// See also [PollFeedbackNotifier].
class PollFeedbackNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PollFeedbackNotifier,
          CursorPagingData<SnPollAnswer>
        > {
  /// See also [PollFeedbackNotifier].
  PollFeedbackNotifierProvider(String id)
    : this._internal(
        () => PollFeedbackNotifier()..id = id,
        from: pollFeedbackNotifierProvider,
        name: r'pollFeedbackNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$pollFeedbackNotifierHash,
        dependencies: PollFeedbackNotifierFamily._dependencies,
        allTransitiveDependencies:
            PollFeedbackNotifierFamily._allTransitiveDependencies,
        id: id,
      );

  PollFeedbackNotifierProvider._internal(
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
  FutureOr<CursorPagingData<SnPollAnswer>> runNotifierBuild(
    covariant PollFeedbackNotifier notifier,
  ) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(PollFeedbackNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PollFeedbackNotifierProvider._internal(
        () => create()..id = id,
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
  AutoDisposeAsyncNotifierProviderElement<
    PollFeedbackNotifier,
    CursorPagingData<SnPollAnswer>
  >
  createElement() {
    return _PollFeedbackNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PollFeedbackNotifierProvider && other.id == id;
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
mixin PollFeedbackNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnPollAnswer>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PollFeedbackNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PollFeedbackNotifier,
          CursorPagingData<SnPollAnswer>
        >
    with PollFeedbackNotifierRef {
  _PollFeedbackNotifierProviderElement(super.provider);

  @override
  String get id => (origin as PollFeedbackNotifierProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
