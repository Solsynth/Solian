// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postListNotifierHash() => r'9784b282b3ee14b7109e263c5841a082cf0be78e';

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
  late final String? realm;
  late final int? type;
  late final List<String>? categories;
  late final List<String>? tags;

  FutureOr<CursorPagingData<SnPost>> build({
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
  });
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
  PostListNotifierProvider call({
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
  }) {
    return PostListNotifierProvider(
      pubName: pubName,
      realm: realm,
      type: type,
      categories: categories,
      tags: tags,
    );
  }

  @override
  PostListNotifierProvider getProviderOverride(
    covariant PostListNotifierProvider provider,
  ) {
    return call(
      pubName: provider.pubName,
      realm: provider.realm,
      type: provider.type,
      categories: provider.categories,
      tags: provider.tags,
    );
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
  PostListNotifierProvider({
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
  }) : this._internal(
         () =>
             PostListNotifier()
               ..pubName = pubName
               ..realm = realm
               ..type = type
               ..categories = categories
               ..tags = tags,
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
         realm: realm,
         type: type,
         categories: categories,
         tags: tags,
       );

  PostListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pubName,
    required this.realm,
    required this.type,
    required this.categories,
    required this.tags,
  }) : super.internal();

  final String? pubName;
  final String? realm;
  final int? type;
  final List<String>? categories;
  final List<String>? tags;

  @override
  FutureOr<CursorPagingData<SnPost>> runNotifierBuild(
    covariant PostListNotifier notifier,
  ) {
    return notifier.build(
      pubName: pubName,
      realm: realm,
      type: type,
      categories: categories,
      tags: tags,
    );
  }

  @override
  Override overrideWith(PostListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PostListNotifierProvider._internal(
        () =>
            create()
              ..pubName = pubName
              ..realm = realm
              ..type = type
              ..categories = categories
              ..tags = tags,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pubName: pubName,
        realm: realm,
        type: type,
        categories: categories,
        tags: tags,
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
    return other is PostListNotifierProvider &&
        other.pubName == pubName &&
        other.realm == realm &&
        other.type == type &&
        other.categories == categories &&
        other.tags == tags;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pubName.hashCode);
    hash = _SystemHash.combine(hash, realm.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);
    hash = _SystemHash.combine(hash, categories.hashCode);
    hash = _SystemHash.combine(hash, tags.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnPost>> {
  /// The parameter `pubName` of this provider.
  String? get pubName;

  /// The parameter `realm` of this provider.
  String? get realm;

  /// The parameter `type` of this provider.
  int? get type;

  /// The parameter `categories` of this provider.
  List<String>? get categories;

  /// The parameter `tags` of this provider.
  List<String>? get tags;
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
  @override
  String? get realm => (origin as PostListNotifierProvider).realm;
  @override
  int? get type => (origin as PostListNotifierProvider).type;
  @override
  List<String>? get categories =>
      (origin as PostListNotifierProvider).categories;
  @override
  List<String>? get tags => (origin as PostListNotifierProvider).tags;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
