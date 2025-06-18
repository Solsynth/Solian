import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/content/paging_helper_ext.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/post_item_creator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'post_list.g.dart';

@riverpod
class PostListNotifier extends _$PostListNotifier
    with CursorPagingNotifierMixin<SnPost> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnPost>> build(String? pubName) {
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnPost>> fetch({required String? cursor}) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {
      'offset': offset,
      'take': _pageSize,
      if (pubName != null) 'pub': pubName,
    };

    final response = await client.get('/posts', queryParameters: queryParams);
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

/// Defines which post item widget to use in the list
enum PostItemType {
  /// Regular post item with user information
  regular,

  /// Creator view with analytics and metadata
  creator,
}

class SliverPostList extends HookConsumerWidget {
  final String? pubName;
  final PostItemType itemType;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool isOpenable;
  final Function? onRefresh;
  final Function(SnPost)? onUpdate;

  const SliverPostList({
    super.key,
    this.pubName,
    this.itemType = PostItemType.regular,
    this.backgroundColor,
    this.padding,
    this.isOpenable = true,
    this.onRefresh,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PagingHelperSliverView(
      provider: postListNotifierProvider(pubName),
      futureRefreshable: postListNotifierProvider(pubName).future,
      notifierRefreshable: postListNotifierProvider(pubName).notifier,
      contentBuilder:
          (data, widgetCount, endItemView) => SliverList.builder(
            itemCount: widgetCount,
            itemBuilder: (context, index) {
              if (index == widgetCount - 1) {
                return endItemView;
              }

              final post = data.items[index];

              return Column(
                children: [_buildPostItem(post), const Divider(height: 1)],
              );
            },
          ),
    );
  }

  Widget _buildPostItem(SnPost post) {
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
        return PostItem(item: post);
    }
  }
}
