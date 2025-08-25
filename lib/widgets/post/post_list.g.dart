// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postListNotifierHash() => r'3c0a8154ded4bcd8f5456f7a4ea2e542f57efa85';

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
  late final bool? pinned;
  late final bool shuffle;

  FutureOr<CursorPagingData<SnPost>> build({
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
    bool? pinned,
    bool shuffle = false,
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
    bool? pinned,
    bool shuffle = false,
  }) {
    return PostListNotifierProvider(
      pubName: pubName,
      realm: realm,
      type: type,
      categories: categories,
      tags: tags,
      pinned: pinned,
      shuffle: shuffle,
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
      pinned: provider.pinned,
      shuffle: provider.shuffle,
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
    bool? pinned,
    bool shuffle = false,
  }) : this._internal(
         () =>
             PostListNotifier()
               ..pubName = pubName
               ..realm = realm
               ..type = type
               ..categories = categories
               ..tags = tags
               ..pinned = pinned
               ..shuffle = shuffle,
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
         pinned: pinned,
         shuffle: shuffle,
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
    required this.pinned,
    required this.shuffle,
  }) : super.internal();

  final String? pubName;
  final String? realm;
  final int? type;
  final List<String>? categories;
  final List<String>? tags;
  final bool? pinned;
  final bool shuffle;

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
      pinned: pinned,
      shuffle: shuffle,
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
              ..tags = tags
              ..pinned = pinned
              ..shuffle = shuffle,
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
        pinned: pinned,
        shuffle: shuffle,
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
        other.tags == tags &&
        other.pinned == pinned &&
        other.shuffle == shuffle;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pubName.hashCode);
    hash = _SystemHash.combine(hash, realm.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);
    hash = _SystemHash.combine(hash, categories.hashCode);
    hash = _SystemHash.combine(hash, tags.hashCode);
    hash = _SystemHash.combine(hash, pinned.hashCode);
    hash = _SystemHash.combine(hash, shuffle.hashCode);

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

  /// The parameter `pinned` of this provider.
  bool? get pinned;

  /// The parameter `shuffle` of this provider.
  bool get shuffle;
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
  @override
  bool? get pinned => (origin as PostListNotifierProvider).pinned;
  @override
  bool get shuffle => (origin as PostListNotifierProvider).shuffle;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
