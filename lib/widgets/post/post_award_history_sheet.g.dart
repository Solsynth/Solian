// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_award_history_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postAwardListNotifierHash() =>
    r'834d08f90ef352a2dfb0192455c75b1620e859c2';

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

abstract class _$PostAwardListNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnPostAward>> {
  late final String postId;

  FutureOr<CursorPagingData<SnPostAward>> build({required String postId});
}

/// See also [PostAwardListNotifier].
@ProviderFor(PostAwardListNotifier)
const postAwardListNotifierProvider = PostAwardListNotifierFamily();

/// See also [PostAwardListNotifier].
class PostAwardListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnPostAward>>> {
  /// See also [PostAwardListNotifier].
  const PostAwardListNotifierFamily();

  /// See also [PostAwardListNotifier].
  PostAwardListNotifierProvider call({required String postId}) {
    return PostAwardListNotifierProvider(postId: postId);
  }

  @override
  PostAwardListNotifierProvider getProviderOverride(
    covariant PostAwardListNotifierProvider provider,
  ) {
    return call(postId: provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postAwardListNotifierProvider';
}

/// See also [PostAwardListNotifier].
class PostAwardListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PostAwardListNotifier,
          CursorPagingData<SnPostAward>
        > {
  /// See also [PostAwardListNotifier].
  PostAwardListNotifierProvider({required String postId})
    : this._internal(
        () => PostAwardListNotifier()..postId = postId,
        from: postAwardListNotifierProvider,
        name: r'postAwardListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$postAwardListNotifierHash,
        dependencies: PostAwardListNotifierFamily._dependencies,
        allTransitiveDependencies:
            PostAwardListNotifierFamily._allTransitiveDependencies,
        postId: postId,
      );

  PostAwardListNotifierProvider._internal(
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
  FutureOr<CursorPagingData<SnPostAward>> runNotifierBuild(
    covariant PostAwardListNotifier notifier,
  ) {
    return notifier.build(postId: postId);
  }

  @override
  Override overrideWith(PostAwardListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PostAwardListNotifierProvider._internal(
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
    PostAwardListNotifier,
    CursorPagingData<SnPostAward>
  >
  createElement() {
    return _PostAwardListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostAwardListNotifierProvider && other.postId == postId;
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
mixin PostAwardListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnPostAward>> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _PostAwardListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PostAwardListNotifier,
          CursorPagingData<SnPostAward>
        >
    with PostAwardListNotifierRef {
  _PostAwardListNotifierProviderElement(super.provider);

  @override
  String get postId => (origin as PostAwardListNotifierProvider).postId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
