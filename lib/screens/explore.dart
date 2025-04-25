import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';
import 'package:dio/dio.dart';
import 'package:island/pods/network.dart';

@RoutePage()
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postListProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Explore')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(PostComposeRoute()).then((value) {
            if (value != null) {
              ref.invalidate(postListProvider);
            }
          });
        },
        child: const Icon(LucideIcons.pencil),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: postAsync.when(
        data:
            (controller) => RefreshIndicator(
              onRefresh:
                  () => Future.sync((() {
                    ref.invalidate(postListProvider);
                  })),
              child: InfiniteList(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                itemCount: controller.posts.length,
                isLoading: controller.isLoading,
                hasReachedMax: controller.hasReachedMax,
                onFetchData: controller.fetchMore,
                itemBuilder: (context, index) {
                  final post = controller.posts[index];
                  return PostItem(item: post);
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => GestureDetector(
              child: Center(
                child: Text('Error: $e', textAlign: TextAlign.center),
              ),
              onTap: () {
                ref.invalidate(postListProvider);
              },
            ),
      ),
    );
  }
}

final postListProvider = FutureProvider<_PostListController>((ref) async {
  final client = ref.watch(apiClientProvider);
  final controller = _PostListController(client);
  await controller.fetchMore();
  return controller;
});

class _PostListController {
  _PostListController(this._dio);

  final Dio _dio;
  final List<SnPost> posts = [];
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

    posts.addAll(fetched);
    offset += fetched.length;
    if (posts.length >= total) hasReachedMax = true;

    isLoading = false;
  }
}
