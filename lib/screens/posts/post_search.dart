import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/response.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

final postSearchNotifierProvider = StateNotifierProvider.autoDispose<
  PostSearchNotifier,
  AsyncValue<CursorPagingData<SnPost>>
>((ref) => PostSearchNotifier(ref));

class PostSearchNotifier
    extends StateNotifier<AsyncValue<CursorPagingData<SnPost>>> {
  final AutoDisposeRef ref;
  static const int _pageSize = 20;
  String _currentQuery = '';
  bool _isLoading = false;

  PostSearchNotifier(this.ref) : super(const AsyncValue.loading()) {
    state = const AsyncValue.data(
      CursorPagingData(items: [], hasMore: false, nextCursor: null),
    );
  }

  Future<void> search(String query) async {
    if (_isLoading) return;

    _currentQuery = query.trim();
    if (_currentQuery.isEmpty) {
      state = AsyncValue.data(
        CursorPagingData(items: [], hasMore: false, nextCursor: null),
      );
      return;
    }

    await fetch(cursor: null);
  }

  Future<void> fetch({String? cursor}) async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();

    try {
      final client = ref.read(apiClientProvider);
      final offset = cursor == null ? 0 : int.parse(cursor);

      final response = await client.get(
        '/sphere/posts/search',
        queryParameters: {
          'query': _currentQuery,
          'offset': offset,
          'take': _pageSize,
          'useVector': false,
        },
      );

      final data = response.data as List;
      final posts = data.map((json) => SnPost.fromJson(json)).toList();
      final hasMore = posts.length == _pageSize;
      final nextCursor = hasMore ? (offset + posts.length).toString() : null;

      state = AsyncValue.data(
        CursorPagingData(
          items: posts,
          hasMore: hasMore,
          nextCursor: nextCursor,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } finally {
      _isLoading = false;
    }
  }
}

class PostSearchScreen extends ConsumerStatefulWidget {
  const PostSearchScreen({super.key});

  @override
  ConsumerState<PostSearchScreen> createState() => _PostSearchScreenState();
}

class _PostSearchScreenState extends ConsumerState<PostSearchScreen> {
  final _searchController = TextEditingController();
  final _debounce = Duration(milliseconds: 500);
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(_debounce, () {
      ref.read(postSearchNotifierProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: false,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search posts...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: (value) {
            ref.read(postSearchNotifierProvider.notifier).search(value);
          },
          autofocus: true,
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final searchState = ref.watch(postSearchNotifierProvider);

          return searchState.when(
            data: (data) {
              if (data.items.isEmpty && _searchController.text.isNotEmpty) {
                return const Center(child: Text('No results found'));
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: data.items.length + (data.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= data.items.length) {
                    ref
                        .read(postSearchNotifierProvider.notifier)
                        .fetch(cursor: data.nextCursor);
                    return const Center(child: CircularProgressIndicator());
                  }

                  final post = data.items[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: PostActionableItem(item: post, borderRadius: 8),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => ResponseErrorWidget(
                  error: error,
                  onRetry: () => ref.invalidate(postSearchNotifierProvider),
                ),
          );
        },
      ),
    );
  }
}
