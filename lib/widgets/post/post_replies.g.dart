// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_replies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postRepliesNotifierHash() =>
    r'1cdda919249e3bf34459369e033ad5de8dbcf3f8';

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

abstract class _$PostRepliesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnPost>> {
  late final String postId;

  FutureOr<CursorPagingData<SnPost>> build(String postId);
}

/// See also [PostRepliesNotifier].
@ProviderFor(PostRepliesNotifier)
const postRepliesNotifierProvider = PostRepliesNotifierFamily();

/// See also [PostRepliesNotifier].
class PostRepliesNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnPost>>> {
  /// See also [PostRepliesNotifier].
  const PostRepliesNotifierFamily();

  /// See also [PostRepliesNotifier].
  PostRepliesNotifierProvider call(String postId) {
    return PostRepliesNotifierProvider(postId);
  }

  @override
  PostRepliesNotifierProvider getProviderOverride(
    covariant PostRepliesNotifierProvider provider,
  ) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postRepliesNotifierProvider';
}

/// See also [PostRepliesNotifier].
class PostRepliesNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PostRepliesNotifier,
          CursorPagingData<SnPost>
        > {
  /// See also [PostRepliesNotifier].
  PostRepliesNotifierProvider(String postId)
    : this._internal(
        () => PostRepliesNotifier()..postId = postId,
        from: postRepliesNotifierProvider,
        name: r'postRepliesNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$postRepliesNotifierHash,
        dependencies: PostRepliesNotifierFamily._dependencies,
        allTransitiveDependencies:
            PostRepliesNotifierFamily._allTransitiveDependencies,
        postId: postId,
      );

  PostRepliesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  FutureOr<CursorPagingData<SnPost>> runNotifierBuild(
    covariant PostRepliesNotifier notifier,
  ) {
    return notifier.build(postId);
  }

  @override
  Override overrideWith(PostRepliesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PostRepliesNotifierProvider._internal(
        () => create()..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    PostRepliesNotifier,
    CursorPagingData<SnPost>
  >
  createElement() {
    return _PostRepliesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostRepliesNotifierProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostRepliesNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnPost>> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _PostRepliesNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PostRepliesNotifier,
          CursorPagingData<SnPost>
        >
    with PostRepliesNotifierRef {
  _PostRepliesNotifierProviderElement(super.provider);

  @override
  String get postId => (origin as PostRepliesNotifierProvider).postId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
