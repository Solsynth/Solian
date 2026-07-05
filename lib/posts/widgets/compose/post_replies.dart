import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

typedef PostRepliesQuery = ({String postId, String? order, bool orderDesc});

PostRepliesQuery postRepliesQuery(
  String postId, {
  String? order,
  bool orderDesc = true,
}) => (postId: postId, order: order, orderDesc: orderDesc);

final postRepliesProvider = AsyncNotifierProvider.autoDispose.family(
  PostRepliesNotifier.new,
);

class PostRepliesNotifier extends AsyncNotifier<PaginationState<SnPost>>
    with AsyncPaginationController<SnPost> {
  static const int pageSize = 20;

  final PostRepliesQuery arg;
  PostRepliesNotifier(this.arg);

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final result = await client.sphere.getPostReplies(
      postId: arg.postId,
      offset: fetchedCount,
      take: pageSize,
      order: arg.order,
      orderDesc: arg.orderDesc,
    );
    totalCount = result.totalCount;
    return result.items;
  }

  void updatePost(SnPost updatedPost) {
    if (state is! AsyncData) return;
    final currentState = (state as AsyncData).value;
    final items = currentState.items.map((post) {
      if (post.id == updatedPost.id) {
        return updatedPost;
      }
      return post;
    }).toList();
    state = AsyncData(currentState.copyWith(items: items));
  }
}

class PostRepliesList extends HookConsumerWidget {
  final String postId;
  final String? order;
  final bool orderDesc;
  final double? maxWidth;
  final VoidCallback? onOpen;
  const PostRepliesList({
    super.key,
    required this.postId,
    this.order,
    this.orderDesc = true,
    this.maxWidth,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postRepliesProvider(
      postRepliesQuery(postId, order: order, orderDesc: orderDesc),
    );
    final notifier = ref.read(provider.notifier);

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
        final theme = Theme.of(context);
        final contentWidget = Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.dividerColor.withOpacity(0.45)),
          ),
          child: PostActionableItem(
            borderRadius: 8,
            item: item,
            isShowReference: false,
            isEmbedOpenable: true,
            onOpen: onOpen,
            onUpdate: (newPost) {
              notifier.updatePost(newPost);
            },
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
