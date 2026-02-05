import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/post/post_list.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/posts/posts_widgets/post/post_item.dart';
import 'package:island/posts/posts_widgets/post/post_item_creator.dart';
import 'package:island/posts/posts_widgets/post/post_item_skeleton.dart';
import 'package:island/shared/widgets/pagination_list.dart';

/// Defines which post item widget to use in the list
enum PostItemType {
  /// Regular post item with user information
  regular,

  /// Creator view with analytics and metadata
  creator,
}

class SliverPostList extends HookConsumerWidget {
  final PostListQuery? query;
  final PostItemType itemType;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? itemPadding;
  final bool isOpenable;
  final Function? onRefresh;
  final Function(SnPost)? onUpdate;
  final double? maxWidth;
  final String? queryKey;

  const SliverPostList({
    super.key,
    this.query,
    this.itemType = PostItemType.regular,
    this.backgroundColor,
    this.padding,
    this.itemPadding,
    this.isOpenable = true,
    this.onRefresh,
    this.onUpdate,
    this.maxWidth,
    this.queryKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postListProvider(
      PostListQueryConfig(
        id: queryKey,
        initialFilter: query ?? PostListQuery(),
      ),
    );
    final notifier = ref.watch(provider.notifier);

    final currentFilter = useState(query ?? PostListQuery());

    useEffect(() {
      if (currentFilter.value != query) {
        notifier.applyFilter(query ?? PostListQuery());
      }
      return null;
    }, [query, queryKey]);

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      footerSkeletonChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: PostItemSkeleton(maxWidth: maxWidth ?? double.infinity),
      ),
      itemBuilder: (context, index, post) {
        if (maxWidth != null) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth!),
              child: _buildPostItem(post, itemPadding),
            ),
          );
        }

        return _buildPostItem(post, itemPadding);
      },
    );
  }

  Widget _buildPostItem(SnPost post, EdgeInsets? padding) {
    switch (itemType) {
      case PostItemType.creator:
        return PostItemCreator(
          item: post,
          backgroundColor: backgroundColor,
          padding: padding,
          isOpenable: isOpenable,
          onRefresh: onRefresh,
          onUpdate: onUpdate,
        );
      case PostItemType.regular:
        return Card(
          margin:
              itemPadding ?? EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: PostActionableItem(item: post, borderRadius: 8),
        );
    }
  }
}
