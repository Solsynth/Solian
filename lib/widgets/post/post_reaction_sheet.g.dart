// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_reaction_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reactionListNotifierHash() =>
    r'92cf80d2461e46ca62cf6e6a37f8b16c239e7449';

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

abstract class _$ReactionListNotifier
    extends
        BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnPostReaction>> {
  late final String symbol;
  late final String postId;

  FutureOr<CursorPagingData<SnPostReaction>> build({
    required String symbol,
    required String postId,
  });
}

/// See also [ReactionListNotifier].
@ProviderFor(ReactionListNotifier)
const reactionListNotifierProvider = ReactionListNotifierFamily();

/// See also [ReactionListNotifier].
class ReactionListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnPostReaction>>> {
  /// See also [ReactionListNotifier].
  const ReactionListNotifierFamily();

  /// See also [ReactionListNotifier].
  ReactionListNotifierProvider call({
    required String symbol,
    required String postId,
  }) {
    return ReactionListNotifierProvider(symbol: symbol, postId: postId);
  }

  @override
  ReactionListNotifierProvider getProviderOverride(
    covariant ReactionListNotifierProvider provider,
  ) {
    return call(symbol: provider.symbol, postId: provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reactionListNotifierProvider';
}

/// See also [ReactionListNotifier].
class ReactionListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ReactionListNotifier,
          CursorPagingData<SnPostReaction>
        > {
  /// See also [ReactionListNotifier].
  ReactionListNotifierProvider({required String symbol, required String postId})
    : this._internal(
        () =>
            ReactionListNotifier()
              ..symbol = symbol
              ..postId = postId,
        from: reactionListNotifierProvider,
        name: r'reactionListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$reactionListNotifierHash,
        dependencies: ReactionListNotifierFamily._dependencies,
        allTransitiveDependencies:
            ReactionListNotifierFamily._allTransitiveDependencies,
        symbol: symbol,
        postId: postId,
      );

  ReactionListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
    required this.postId,
  }) : super.internal();

  final String symbol;
  final String postId;

  @override
  FutureOr<CursorPagingData<SnPostReaction>> runNotifierBuild(
    covariant ReactionListNotifier notifier,
  ) {
    return notifier.build(symbol: symbol, postId: postId);
  }

  @override
  Override overrideWith(ReactionListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReactionListNotifierProvider._internal(
        () =>
            create()
              ..symbol = symbol
              ..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ReactionListNotifier,
    CursorPagingData<SnPostReaction>
  >
  createElement() {
    return _ReactionListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReactionListNotifierProvider &&
        other.symbol == symbol &&
        other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReactionListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnPostReaction>> {
  /// The parameter `symbol` of this provider.
  String get symbol;

  /// The parameter `postId` of this provider.
  String get postId;
}

class _ReactionListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ReactionListNotifier,
          CursorPagingData<SnPostReaction>
        >
    with ReactionListNotifierRef {
  _ReactionListNotifierProviderElement(super.provider);

  @override
  String get symbol => (origin as ReactionListNotifierProvider).symbol;
  @override
  String get postId => (origin as ReactionListNotifierProvider).postId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
