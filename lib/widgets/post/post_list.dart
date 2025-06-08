import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/content/paging_helper_ext.dart';
import 'package:island/widgets/post/post_item.dart';
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

class SliverPostList extends HookConsumerWidget {
  final String? pubName;
  const SliverPostList({super.key, this.pubName});

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

              return Column(
                children: [
                  PostItem(item: data.items[index]),
                  const Divider(height: 1),
                ],
              );
            },
          ),
    );
  }
}
