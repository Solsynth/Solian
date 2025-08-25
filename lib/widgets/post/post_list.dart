import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
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
  Future<CursorPagingData<SnPost>> build({
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
    bool? pinned,
    bool shuffle = false,
  }) {
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
      if (realm != null) 'realm': realm,
      if (type != null) 'type': type,
      if (tags != null) 'tags': tags,
      if (categories != null) 'categories': categories,
      if (shuffle) 'shuffle': true,
      if (pinned != null) 'pinned': pinned,
    };

    final response = await client.get(
      '/sphere/posts',
      queryParameters: queryParams,
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

/// Defines which post item widget to use in the list
enum PostItemType {
  /// Regular post item with user information
  regular,

  /// Creator view with analytics and metadata
  creator,
}

class SliverPostList extends HookConsumerWidget {
  final String? pubName;
  final String? realm;
  final int? type;
  final List<String>? categories;
  final List<String>? tags;
  final bool shuffle;
  final bool? pinned;
  final PostItemType itemType;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool isOpenable;
  final Function? onRefresh;
  final Function(SnPost)? onUpdate;
  final double? maxWidth;

  const SliverPostList({
    super.key,
    this.pubName,
    this.realm,
    this.type,
    this.categories,
    this.tags,
    this.shuffle = false,
    this.pinned,
    this.itemType = PostItemType.regular,
    this.backgroundColor,
    this.padding,
    this.isOpenable = true,
    this.onRefresh,
    this.onUpdate,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postListNotifierProvider(
      pubName: pubName,
      realm: realm,
      type: type,
      categories: categories,
      tags: tags,
      shuffle: shuffle,
      pinned: pinned,
    );
    return PagingHelperSliverView(
      provider: provider,
      futureRefreshable: provider.future,
      notifierRefreshable: provider.notifier,
      contentBuilder:
          (data, widgetCount, endItemView) => SliverList.builder(
            itemCount: widgetCount,
            itemBuilder: (context, index) {
              if (index == widgetCount - 1) {
                return endItemView;
              }

              final post = data.items[index];

              if (maxWidth != null) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth!),
                    child: _buildPostItem(post),
                  ),
                );
              }

              return _buildPostItem(post);
            },
          ),
    );
  }

  Widget _buildPostItem(SnPost post) {
    switch (itemType) {
      case PostItemType.creator:
        return Column(
          children: [
            PostItemCreator(
              item: post,
              backgroundColor: backgroundColor,
              padding: padding,
              isOpenable: isOpenable,
              onRefresh: onRefresh,
              onUpdate: onUpdate,
            ),
            const Divider(),
          ],
        );
      case PostItemType.regular:
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: PostActionableItem(item: post, borderRadius: 8),
        );
    }
  }
}
