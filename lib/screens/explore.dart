import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';
import 'package:dio/dio.dart';
import 'package:island/pods/network.dart';

@RoutePage()
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postListProvider);
    final postsNotifier = ref.watch(postListProvider.notifier);

    return AppScaffold(
      appBar: AppBar(title: const Text('Explore')),
      floatingActionButton: FloatingActionButton(
        heroTag: Key("explore-page-fab"),
        onPressed: () {
          context.router.push(PostComposeRoute()).then((value) {
            if (value != null) {
              ref.invalidate(postListProvider);
            }
          });
        },
        child: const Icon(Symbols.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh:
            () => Future.sync((() {
              ref.invalidate(postListProvider);
            })),
        child: InfiniteList(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          itemCount: posts.length,
          isLoading: postsNotifier.isLoading,
          hasReachedMax: postsNotifier.hasReachedMax,
          onFetchData: postsNotifier.fetchMore,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostItem(
              item: post,
              onRefresh: (_) {
                ref.invalidate(postListProvider);
              },
              onUpdate: (post) {
                postsNotifier.updateOne(index, post);
              },
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
        ),
      ),
    );
  }
}

final postListProvider =
    StateNotifierProvider<_PostListController, List<SnPost>>((ref) {
      final client = ref.watch(apiClientProvider);
      return _PostListController(client);
    });

class _PostListController extends StateNotifier<List<SnPost>> {
  _PostListController(this._dio) : super([]);

  final Dio _dio;
  bool isLoading = false;
  bool hasReachedMax = false;
  int offset = 0;
  final int take = 20;
  int total = 0;

  Future<void> fetchMore() async {
    if (isLoading || hasReachedMax) return;
    isLoading = true;

    final response = await _dio.get(
      '/posts',
      queryParameters: {'offset': offset, 'take': take},
    );

    final List<SnPost> fetched =
        (response.data as List)
            .map((e) => SnPost.fromJson(e as Map<String, dynamic>))
            .toList();

    final headerTotal = int.tryParse(response.headers['x-total']?.first ?? '');
    if (headerTotal != null) total = headerTotal;

    state = [...state, ...fetched];
    offset += fetched.length;
    if (state.length >= total) hasReachedMax = true;

    isLoading = false;
  }

  void updateOne(int index, SnPost post) {
    final updatedPosts = [...state];
    updatedPosts[index] = post;
    state = updatedPosts;
  }
}
