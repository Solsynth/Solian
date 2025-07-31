// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_item.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postFeaturedReplyHash() => r'3f0ac0d51ad21f8754a63dd94109eb8ac4812293';

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

/// See also [postFeaturedReply].
@ProviderFor(postFeaturedReply)
const postFeaturedReplyProvider = PostFeaturedReplyFamily();

/// See also [postFeaturedReply].
class PostFeaturedReplyFamily extends Family<AsyncValue<SnPost?>> {
  /// See also [postFeaturedReply].
  const PostFeaturedReplyFamily();

  /// See also [postFeaturedReply].
  PostFeaturedReplyProvider call(String id) {
    return PostFeaturedReplyProvider(id);
  }

  @override
  PostFeaturedReplyProvider getProviderOverride(
    covariant PostFeaturedReplyProvider provider,
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
  String? get name => r'postFeaturedReplyProvider';
}

/// See also [postFeaturedReply].
class PostFeaturedReplyProvider extends AutoDisposeFutureProvider<SnPost?> {
  /// See also [postFeaturedReply].
  PostFeaturedReplyProvider(String id)
    : this._internal(
        (ref) => postFeaturedReply(ref as PostFeaturedReplyRef, id),
        from: postFeaturedReplyProvider,
        name: r'postFeaturedReplyProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$postFeaturedReplyHash,
        dependencies: PostFeaturedReplyFamily._dependencies,
        allTransitiveDependencies:
            PostFeaturedReplyFamily._allTransitiveDependencies,
        id: id,
      );

  PostFeaturedReplyProvider._internal(
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
    FutureOr<SnPost?> Function(PostFeaturedReplyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostFeaturedReplyProvider._internal(
        (ref) => create(ref as PostFeaturedReplyRef),
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
  AutoDisposeFutureProviderElement<SnPost?> createElement() {
    return _PostFeaturedReplyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostFeaturedReplyProvider && other.id == id;
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
mixin PostFeaturedReplyRef on AutoDisposeFutureProviderRef<SnPost?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PostFeaturedReplyProviderElement
    extends AutoDisposeFutureProviderElement<SnPost?>
    with PostFeaturedReplyRef {
  _PostFeaturedReplyProviderElement(super.provider);

  @override
  String get id => (origin as PostFeaturedReplyProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
