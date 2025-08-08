// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_category_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postCategoryHash() => r'0df2de729ba96819ee37377314615abef0c99547';

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

/// See also [postCategory].
@ProviderFor(postCategory)
const postCategoryProvider = PostCategoryFamily();

/// See also [postCategory].
class PostCategoryFamily extends Family<AsyncValue<SnPostCategory>> {
  /// See also [postCategory].
  const PostCategoryFamily();

  /// See also [postCategory].
  PostCategoryProvider call(String slug) {
    return PostCategoryProvider(slug);
  }

  @override
  PostCategoryProvider getProviderOverride(
    covariant PostCategoryProvider provider,
  ) {
    return call(provider.slug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postCategoryProvider';
}

/// See also [postCategory].
class PostCategoryProvider extends AutoDisposeFutureProvider<SnPostCategory> {
  /// See also [postCategory].
  PostCategoryProvider(String slug)
    : this._internal(
        (ref) => postCategory(ref as PostCategoryRef, slug),
        from: postCategoryProvider,
        name: r'postCategoryProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$postCategoryHash,
        dependencies: PostCategoryFamily._dependencies,
        allTransitiveDependencies:
            PostCategoryFamily._allTransitiveDependencies,
        slug: slug,
      );

  PostCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Override overrideWith(
    FutureOr<SnPostCategory> Function(PostCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostCategoryProvider._internal(
        (ref) => create(ref as PostCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnPostCategory> createElement() {
    return _PostCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCategoryProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostCategoryRef on AutoDisposeFutureProviderRef<SnPostCategory> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _PostCategoryProviderElement
    extends AutoDisposeFutureProviderElement<SnPostCategory>
    with PostCategoryRef {
  _PostCategoryProviderElement(super.provider);

  @override
  String get slug => (origin as PostCategoryProvider).slug;
}

String _$postTagHash() => r'e050fdf9af81a843a9abd9cf979dd2672e0a2b93';

/// See also [postTag].
@ProviderFor(postTag)
const postTagProvider = PostTagFamily();

/// See also [postTag].
class PostTagFamily extends Family<AsyncValue<SnPostTag>> {
  /// See also [postTag].
  const PostTagFamily();

  /// See also [postTag].
  PostTagProvider call(String slug) {
    return PostTagProvider(slug);
  }

  @override
  PostTagProvider getProviderOverride(covariant PostTagProvider provider) {
    return call(provider.slug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postTagProvider';
}

/// See also [postTag].
class PostTagProvider extends AutoDisposeFutureProvider<SnPostTag> {
  /// See also [postTag].
  PostTagProvider(String slug)
    : this._internal(
        (ref) => postTag(ref as PostTagRef, slug),
        from: postTagProvider,
        name: r'postTagProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$postTagHash,
        dependencies: PostTagFamily._dependencies,
        allTransitiveDependencies: PostTagFamily._allTransitiveDependencies,
        slug: slug,
      );

  PostTagProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Override overrideWith(
    FutureOr<SnPostTag> Function(PostTagRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostTagProvider._internal(
        (ref) => create(ref as PostTagRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnPostTag> createElement() {
    return _PostTagProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostTagProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostTagRef on AutoDisposeFutureProviderRef<SnPostTag> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _PostTagProviderElement
    extends AutoDisposeFutureProviderElement<SnPostTag>
    with PostTagRef {
  _PostTagProviderElement(super.provider);

  @override
  String get slug => (origin as PostTagProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
