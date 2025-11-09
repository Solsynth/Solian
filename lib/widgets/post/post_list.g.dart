// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postListNotifierHash() => r'bfc3d652dffc5ff3a94a6c3d04aac65354fe63b5';

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
  late final bool? includeReplies;
  late final bool? mediaOnly;
  late final String? queryTerm;
  late final String? order;
  late final int? periodStart;
  late final int? periodEnd;
  late final bool orderDesc;

  FutureOr<CursorPagingData<SnPost>> build({
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
    bool? pinned,
    bool shuffle = false,
    bool? includeReplies,
    bool? mediaOnly,
    String? queryTerm,
    String? order,
    int? periodStart,
    int? periodEnd,
    bool orderDesc = true,
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
    bool? includeReplies,
    bool? mediaOnly,
    String? queryTerm,
    String? order,
    int? periodStart,
    int? periodEnd,
    bool orderDesc = true,
  }) {
    return PostListNotifierProvider(
      pubName: pubName,
      realm: realm,
      type: type,
      categories: categories,
      tags: tags,
      pinned: pinned,
      shuffle: shuffle,
      includeReplies: includeReplies,
      mediaOnly: mediaOnly,
      queryTerm: queryTerm,
      order: order,
      periodStart: periodStart,
      periodEnd: periodEnd,
      orderDesc: orderDesc,
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
      includeReplies: provider.includeReplies,
      mediaOnly: provider.mediaOnly,
      queryTerm: provider.queryTerm,
      order: provider.order,
      periodStart: provider.periodStart,
      periodEnd: provider.periodEnd,
      orderDesc: provider.orderDesc,
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
    bool? includeReplies,
    bool? mediaOnly,
    String? queryTerm,
    String? order,
    int? periodStart,
    int? periodEnd,
    bool orderDesc = true,
  }) : this._internal(
         () =>
             PostListNotifier()
               ..pubName = pubName
               ..realm = realm
               ..type = type
               ..categories = categories
               ..tags = tags
               ..pinned = pinned
               ..shuffle = shuffle
               ..includeReplies = includeReplies
               ..mediaOnly = mediaOnly
               ..queryTerm = queryTerm
               ..order = order
               ..periodStart = periodStart
               ..periodEnd = periodEnd
               ..orderDesc = orderDesc,
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
         includeReplies: includeReplies,
         mediaOnly: mediaOnly,
         queryTerm: queryTerm,
         order: order,
         periodStart: periodStart,
         periodEnd: periodEnd,
         orderDesc: orderDesc,
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
    required this.includeReplies,
    required this.mediaOnly,
    required this.queryTerm,
    required this.order,
    required this.periodStart,
    required this.periodEnd,
    required this.orderDesc,
  }) : super.internal();

  final String? pubName;
  final String? realm;
  final int? type;
  final List<String>? categories;
  final List<String>? tags;
  final bool? pinned;
  final bool shuffle;
  final bool? includeReplies;
  final bool? mediaOnly;
  final String? queryTerm;
  final String? order;
  final int? periodStart;
  final int? periodEnd;
  final bool orderDesc;

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
      includeReplies: includeReplies,
      mediaOnly: mediaOnly,
      queryTerm: queryTerm,
      order: order,
      periodStart: periodStart,
      periodEnd: periodEnd,
      orderDesc: orderDesc,
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
              ..shuffle = shuffle
              ..includeReplies = includeReplies
              ..mediaOnly = mediaOnly
              ..queryTerm = queryTerm
              ..order = order
              ..periodStart = periodStart
              ..periodEnd = periodEnd
              ..orderDesc = orderDesc,
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
        includeReplies: includeReplies,
        mediaOnly: mediaOnly,
        queryTerm: queryTerm,
        order: order,
        periodStart: periodStart,
        periodEnd: periodEnd,
        orderDesc: orderDesc,
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
        other.shuffle == shuffle &&
        other.includeReplies == includeReplies &&
        other.mediaOnly == mediaOnly &&
        other.queryTerm == queryTerm &&
        other.order == order &&
        other.periodStart == periodStart &&
        other.periodEnd == periodEnd &&
        other.orderDesc == orderDesc;
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
    hash = _SystemHash.combine(hash, includeReplies.hashCode);
    hash = _SystemHash.combine(hash, mediaOnly.hashCode);
    hash = _SystemHash.combine(hash, queryTerm.hashCode);
    hash = _SystemHash.combine(hash, order.hashCode);
    hash = _SystemHash.combine(hash, periodStart.hashCode);
    hash = _SystemHash.combine(hash, periodEnd.hashCode);
    hash = _SystemHash.combine(hash, orderDesc.hashCode);

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

  /// The parameter `includeReplies` of this provider.
  bool? get includeReplies;

  /// The parameter `mediaOnly` of this provider.
  bool? get mediaOnly;

  /// The parameter `queryTerm` of this provider.
  String? get queryTerm;

  /// The parameter `order` of this provider.
  String? get order;

  /// The parameter `periodStart` of this provider.
  int? get periodStart;

  /// The parameter `periodEnd` of this provider.
  int? get periodEnd;

  /// The parameter `orderDesc` of this provider.
  bool get orderDesc;
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
  @override
  bool? get includeReplies =>
      (origin as PostListNotifierProvider).includeReplies;
  @override
  bool? get mediaOnly => (origin as PostListNotifierProvider).mediaOnly;
  @override
  String? get queryTerm => (origin as PostListNotifierProvider).queryTerm;
  @override
  String? get order => (origin as PostListNotifierProvider).order;
  @override
  int? get periodStart => (origin as PostListNotifierProvider).periodStart;
  @override
  int? get periodEnd => (origin as PostListNotifierProvider).periodEnd;
  @override
  bool get orderDesc => (origin as PostListNotifierProvider).orderDesc;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
