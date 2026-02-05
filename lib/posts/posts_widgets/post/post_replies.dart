import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pagination/pagination.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/posts_widgets/post/post_item.dart';
import 'package:island/posts/posts_widgets/post/post_item_skeleton.dart';
import 'package:island/shared/widgets/pagination_list.dart';

final postRepliesProvider = AsyncNotifierProvider.autoDispose.family(
  PostRepliesNotifier.new,
);

class PostRepliesNotifier extends AsyncNotifier<PaginationState<SnPost>>
    with AsyncPaginationController<SnPost> {
  static const int pageSize = 20;

  final String arg;
  PostRepliesNotifier(this.arg);

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/posts/$arg/replies',
      queryParameters: {'offset': fetchedCount, 'take': pageSize},
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnPost.fromJson(json)).toList();
  }
}

class PostRepliesList extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  final VoidCallback? onOpen;
  const PostRepliesList({
    super.key,
    required this.postId,
    this.maxWidth,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postRepliesProvider(postId);

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: PostItemSkeleton(maxWidth: maxWidth ?? double.infinity),
    );

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      footerSkeletonChild: maxWidth == null
          ? skeletonItem
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: skeletonItem,
              ),
            ),
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: PostActionableItem(
            borderRadius: 8,
            item: item,
            isShowReference: false,
            isEmbedOpenable: true,
            onOpen: onOpen,
            onUpdate: (newPost) {},
          ),
        );

        if (maxWidth == null) return contentWidget;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: contentWidget,
          ),
        );
      },
    );
  }
}
