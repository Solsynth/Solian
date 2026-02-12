import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'post_list.freezed.dart';

@freezed
sealed class PostListQuery with _$PostListQuery {
  const factory PostListQuery({
    String? pubName,
    List<String>? publishers,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
    bool? pinned,
    @Default(false) bool shuffle,
    bool? includeReplies,
    bool? mediaOnly,
    String? queryTerm,
    String? order,
    int? periodStart,
    int? periodEnd,
    @Default(true) bool orderDesc,
  }) = _PostListQuery;
}

@freezed
sealed class PostListQueryConfig with _$PostListQueryConfig {
  const factory PostListQueryConfig({
    String? id,
    @Default(PostListQuery()) PostListQuery initialFilter,
  }) = _PostListQueryConfig;
}

final postListProvider = AsyncNotifierProvider.autoDispose.family(
  PostListNotifier.new,
);

class PostListNotifier extends AsyncNotifier<PaginationState<SnPost>>
    with
        AsyncPaginationController<SnPost>,
        AsyncPaginationFilter<PostListQuery, SnPost> {
  static const int pageSize = 20;

  final String? id;
  final PostListQueryConfig config;
  PostListNotifier(this.config) : id = config.id;

  @override
  late PostListQuery currentFilter;

  @override
  FutureOr<PaginationState<SnPost>> build() async {
    currentFilter = config.initialFilter;
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(apiClientProvider);

    // Handle multiple publishers by making separate requests and combining results
    if (currentFilter.publishers != null &&
        currentFilter.publishers!.isNotEmpty) {
      final allPosts = <SnPost>[];
      var totalPostsCount = 0;

      for (final publisherName in currentFilter.publishers!) {
        final queryParams = {
          'offset': fetchedCount,
          'take': pageSize,
          'replies': currentFilter.includeReplies,
          'orderDesc': currentFilter.orderDesc,
          if (currentFilter.shuffle) 'shuffle': currentFilter.shuffle,
          'pub': publisherName,
          if (currentFilter.realm != null) 'realm': currentFilter.realm,
          if (currentFilter.type != null) 'type': currentFilter.type,
          if (currentFilter.tags != null) 'tags': currentFilter.tags,
          if (currentFilter.categories != null)
            'categories': currentFilter.categories,
          if (currentFilter.pinned != null) 'pinned': currentFilter.pinned,
          if (currentFilter.order != null) 'order': currentFilter.order,
          if (currentFilter.periodStart != null)
            'periodStart': currentFilter.periodStart,
          if (currentFilter.periodEnd != null)
            'periodEnd': currentFilter.periodEnd,
          if (currentFilter.queryTerm != null) 'query': currentFilter.queryTerm,
          if (currentFilter.mediaOnly != null) 'media': currentFilter.mediaOnly,
        };

        final response = await client.get(
          '/sphere/posts',
          queryParameters: queryParams,
        );

        final posts = response.data
            .map((json) => SnPost.fromJson(json))
            .cast<SnPost>()
            .toList();

        allPosts.addAll(posts);
        totalPostsCount += int.parse(response.headers.value('X-Total') ?? '0');
      }

      // Sort combined results by creation date (newest first)
      allPosts.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );

      // Apply pagination to combined results
      final startIndex = fetchedCount;
      final endIndex = (fetchedCount + pageSize).clamp(0, allPosts.length);
      final paginatedPosts = startIndex < allPosts.length
          ? allPosts.sublist(startIndex, endIndex)
          : <SnPost>[];

      totalCount = totalPostsCount;
      return paginatedPosts;
    } else {
      // Single publisher or no publisher filter
      final queryParams = {
        'offset': fetchedCount,
        'take': pageSize,
        'replies': currentFilter.includeReplies,
        'orderDesc': currentFilter.orderDesc,
        if (currentFilter.shuffle) 'shuffle': currentFilter.shuffle,
        if (currentFilter.pubName != null) 'pub': currentFilter.pubName,
        if (currentFilter.realm != null) 'realm': currentFilter.realm,
        if (currentFilter.type != null) 'type': currentFilter.type,
        if (currentFilter.tags != null) 'tags': currentFilter.tags,
        if (currentFilter.categories != null)
          'categories': currentFilter.categories,
        if (currentFilter.pinned != null) 'pinned': currentFilter.pinned,
        if (currentFilter.order != null) 'order': currentFilter.order,
        if (currentFilter.periodStart != null)
          'periodStart': currentFilter.periodStart,
        if (currentFilter.periodEnd != null)
          'periodEnd': currentFilter.periodEnd,
        if (currentFilter.queryTerm != null) 'query': currentFilter.queryTerm,
        if (currentFilter.mediaOnly != null) 'media': currentFilter.mediaOnly,
      };

      final response = await client.get(
        '/sphere/posts',
        queryParameters: queryParams,
      );
      totalCount = int.parse(response.headers.value('X-Total') ?? '0');
      return response.data
          .map((json) => SnPost.fromJson(json))
          .cast<SnPost>()
          .toList();
    }
  }

  void addPost(SnPost post) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedItems = [post, ...currentState.items];
    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void updatePostById(SnPost post) {
    final currentState = state.value;
    if (currentState == null) return;

    final index = currentState.items.indexWhere((p) => p.id == post.id);
    if (index == -1) return;

    final updatedItems = [...currentState.items];
    updatedItems[index] = post;

    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void removePost(String postId) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedItems = currentState.items
        .where((p) => p.id != postId)
        .toList();
    state = AsyncData(currentState.copyWith(items: updatedItems));
  }
}
