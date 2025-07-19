import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'post_replies.g.dart';

@riverpod
class PostRepliesNotifier extends _$PostRepliesNotifier
    with CursorPagingNotifierMixin<SnPost> {
  static const int _pageSize = 20;

  PostRepliesNotifier();

  String? _postId;

  @override
  Future<CursorPagingData<SnPost>> build(String postId) {
    _postId = postId;
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnPost>> fetch({required String? cursor}) async {
    if (_postId == null) {
      throw StateError('PostRepliesNotifier must be initialized with postId');
    }

    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final response = await client.get(
      '/sphere/posts/$_postId/replies',
      queryParameters: {'offset': offset, 'take': _pageSize},
    );

    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final posts = data.map((json) => SnPost.fromJson(json)).toList();

    final hasMore = offset + posts.length < total;
    final nextCursor = hasMore ? (offset + posts.length).toString() : null;

    return CursorPagingData(
      items: posts,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class PostRepliesList extends HookConsumerWidget {
  final String postId;
  final Color? backgroundColor;
  const PostRepliesList({
    super.key,
    required this.postId,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    return PagingHelperSliverView(
      provider: postRepliesNotifierProvider(postId),
      futureRefreshable: postRepliesNotifierProvider(postId).future,
      notifierRefreshable: postRepliesNotifierProvider(postId).notifier,
      contentBuilder: (data, widgetCount, endItemView) {
        if (data.items.isEmpty) {
          return SliverToBoxAdapter(
            child: Column(
              children: [
                Text(
                  'No replies',
                  textAlign: TextAlign.center,
                ).fontSize(18).bold(),
                const Text('Why not start a discussion?'),
              ],
            ).padding(vertical: 16),
          );
        }

        return SliverList.builder(
          itemCount: widgetCount,
          itemBuilder: (context, index) {
            if (index == widgetCount - 1) {
              return endItemView;
            }

            return Column(
              children: [
                PostItem(
                  item: data.items[index],
                  backgroundColor:
                      backgroundColor ?? (isWide ? Colors.transparent : null),
                  showReferencePost: false,
                ),
                const Divider(height: 1),
              ],
            );
          },
        );
      },
    );
  }
}
