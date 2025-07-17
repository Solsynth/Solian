// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postListNotifierHash() => r'2e4fb36123d3f97ac1edf9945043251d4eb519a2';

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

abstract class _$PostListNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnPost>> {
  late final String? pubName;

  FutureOr<CursorPagingData<SnPost>> build(String? pubName);
}

/// See also [PostListNotifier].
@ProviderFor(PostListNotifier)
const postListNotifierProvider = PostListNotifierFamily();

/// See also [PostListNotifier].
class PostListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnPost>>> {
  /// See also [PostListNotifier].
  const PostListNotifierFamily();

  /// See also [PostListNotifier].
  PostListNotifierProvider call(String? pubName) {
    return PostListNotifierProvider(pubName);
  }

  @override
  PostListNotifierProvider getProviderOverride(
    covariant PostListNotifierProvider provider,
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
  String? get name => r'postListNotifierProvider';
}

/// See also [PostListNotifier].
class PostListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          PostListNotifier,
          CursorPagingData<SnPost>
        > {
  /// See also [PostListNotifier].
  PostListNotifierProvider(String? pubName)
    : this._internal(
        () => PostListNotifier()..pubName = pubName,
        from: postListNotifierProvider,
        name: r'postListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$postListNotifierHash,
        dependencies: PostListNotifierFamily._dependencies,
        allTransitiveDependencies:
            PostListNotifierFamily._allTransitiveDependencies,
        pubName: pubName,
      );

  PostListNotifierProvider._internal(
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
  FutureOr<CursorPagingData<SnPost>> runNotifierBuild(
    covariant PostListNotifier notifier,
  ) {
    return notifier.build(pubName);
  }

  @override
  Override overrideWith(PostListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PostListNotifierProvider._internal(
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
    PostListNotifier,
    CursorPagingData<SnPost>
  >
  createElement() {
    return _PostListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostListNotifierProvider && other.pubName == pubName;
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
mixin PostListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnPost>> {
  /// The parameter `pubName` of this provider.
  String? get pubName;
}

class _PostListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          PostListNotifier,
          CursorPagingData<SnPost>
        >
    with PostListNotifierRef {
  _PostListNotifierProviderElement(super.provider);

  @override
  String? get pubName => (origin as PostListNotifierProvider).pubName;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
