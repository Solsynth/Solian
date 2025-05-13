import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

// State class to hold posts and pagination info
class PostListState {
  final List<SnPost> posts;
  final bool isLoading;
  final String? error;
  final int total;
  final bool hasMore;

  const PostListState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.hasMore = true,
  });

  PostListState copyWith({
    List<SnPost>? posts,
    bool? isLoading,
    String? error,
    int? total,
    bool? hasMore,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Provider for managing post list state
final postListProvider =
    StateNotifierProvider.family<PostListNotifier, PostListState, String?>((
      ref,
      pubName,
    ) {
      final dio = ref.watch(apiClientProvider);
      return PostListNotifier(dio, pubName);
    });

class PostListNotifier extends StateNotifier<PostListState> {
  final Dio _dio;
  final String? pubName;
  static const int _pageSize = 20;

  PostListNotifier(this._dio, this.pubName) : super(const PostListState()) {
    loadInitialPosts();
  }

  Future<void> loadInitialPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _fetchPosts(0);
      state = PostListState(
        posts: result.posts,
        total: result.total,
        hasMore: result.posts.length < result.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMorePosts() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _fetchPosts(state.posts.length);
      state = state.copyWith(
        posts: [...state.posts, ...result.posts],
        total: result.total,
        hasMore: state.posts.length + result.posts.length < result.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<({List<SnPost> posts, int total})> _fetchPosts(int offset) async {
    final queryParams = {
      'offset': offset,
      'take': _pageSize,
      if (pubName != null) 'pub': pubName,
    };

    final response = await _dio.get('/posts', queryParameters: queryParams);
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final posts = data.map((json) => SnPost.fromJson(json)).toList();

    return (posts: posts, total: total);
  }
}

class SliverPostList extends HookConsumerWidget {
  final String? pubName;
  const SliverPostList({super.key, this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListProvider(pubName));
    final notifier = ref.read(postListProvider(pubName).notifier);

    return SliverInfiniteList(
      onFetchData: notifier.loadMorePosts,
      itemCount: state.posts.length,
      hasReachedMax: !state.hasMore,
      isLoading: state.isLoading,
      itemBuilder: (context, index) {
        return PostItem(item: state.posts[index]);
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }
}
