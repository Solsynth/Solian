import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/post_item_creator.dart';

part 'post_list.freezed.dart';

@freezed
sealed class PostListQuery with _$PostListQuery {
  const factory PostListQuery({
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
    bool? pinned,
    @Default(false) bool shuffle,
    bool? includeReplies,
    bool? mediaOnly,
    String? queryTerm,
    String? order,
    int? periodStart,
    int? periodEnd,
    @Default(true) bool orderDesc,
  }) = _PostListQuery;
}

final postListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<PostListNotifier, List<SnPost>, PostListQuery>(
      PostListNotifier.new,
    );

class PostListNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<SnPost>, PostListQuery>
    with FamilyAsyncPaginationController<SnPost, PostListQuery> {
  static const int _pageSize = 20;

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {
      'offset': fetchedCount,
      'take': _pageSize,
      'replies': arg.includeReplies,
      'orderDesc': arg.orderDesc,
      if (arg.shuffle) 'shuffle': arg.shuffle,
      if (arg.pubName != null) 'pub': arg.pubName,
      if (arg.realm != null) 'realm': arg.realm,
      if (arg.type != null) 'type': arg.type,
      if (arg.tags != null) 'tags': arg.tags,
      if (arg.categories != null) 'categories': arg.categories,
      if (arg.pinned != null) 'pinned': arg.pinned,
      if (arg.order != null) 'order': arg.order,
      if (arg.periodStart != null) 'periodStart': arg.periodStart,
      if (arg.periodEnd != null) 'periodEnd': arg.periodEnd,
      if (arg.queryTerm != null) 'query': arg.queryTerm,
      if (arg.mediaOnly != null) 'media': arg.mediaOnly,
    };

    final response = await client.get(
      '/sphere/posts',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnPost.fromJson(json)).toList();
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
  final bool? includeReplies;
  final bool? mediaOnly;
  final String? queryTerm;
  // Can be "populaurity", other value will be treated as "date"
  final String? order;
  final int? periodStart;
  final int? periodEnd;
  final bool? orderDesc;
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
    this.includeReplies,
    this.mediaOnly,
    this.queryTerm,
    this.order,
    this.orderDesc = true,
    this.periodStart,
    this.periodEnd,
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
    final params = PostListQuery(
      pubName: pubName,
      realm: realm,
      type: type,
      categories: categories,
      tags: tags,
      shuffle: shuffle,
      pinned: pinned,
      includeReplies: includeReplies,
      mediaOnly: mediaOnly,
      queryTerm: queryTerm,
      order: order,
      periodStart: periodStart,
      periodEnd: periodEnd,
      orderDesc: orderDesc ?? true,
    );
    final provider = postListNotifierProvider(params);
    final notifier = provider.notifier;

    return PaginationList(
      provider: provider,
      notifier: notifier,
      isRefreshable: false,
      isSliver: true,
      itemBuilder: (context, index, post) {
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
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: PostActionableItem(item: post, borderRadius: 8),
        );
    }
  }
}
