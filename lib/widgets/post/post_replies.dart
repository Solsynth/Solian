import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/response.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class PostRepliesList extends HookConsumerWidget {
  final String postId;
  const PostRepliesList({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postRepliesProvider(postId));
    final isWide = isWideScreen(context);

    return RefreshIndicator(
      onRefresh:
          () => Future.sync((() {
            ref.invalidate(postRepliesProvider(postId));
          })),
      child: postAsync.when(
        data:
            (controller) => RefreshIndicator(
              onRefresh:
                  () => Future.sync((() {
                    ref.invalidate(postRepliesProvider(postId));
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
                  return PostItem(
                    item: post,
                    backgroundColor: isWide ? Colors.transparent : null,
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                emptyBuilder: (context) {
                  return Column(
                    children: [
                      Text(
                        'No replies',
                        textAlign: TextAlign.center,
                      ).fontSize(18).bold(),
                      Text('Why not start a discussion?'),
                    ],
                  ).padding(vertical: 16);
                },
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => ResponseErrorWidget(
              error: e,
              onRetry: () {
                ref.invalidate(postRepliesProvider(postId));
              },
            ),
      ),
    );
  }
}

final postRepliesProvider =
    FutureProviderFamily<_PostRepliesController, String>((ref, postId) async {
      final client = ref.watch(apiClientProvider);
      final controller = _PostRepliesController(client, postId);
      await controller.fetchMore();
      return controller;
    });

class _PostRepliesController {
  _PostRepliesController(this._dio, this.parentId);

  final Dio _dio;
  final String parentId;
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
      '/posts/$parentId/replies',
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
