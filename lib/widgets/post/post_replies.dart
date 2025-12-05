import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:island/widgets/post/post_item.dart';

final postRepliesNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<PostRepliesNotifier, List<SnPost>, String>(PostRepliesNotifier.new);

class PostRepliesNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<SnPost>, String>
    with FamilyAsyncPaginationController<SnPost, String> {
  static const int _pageSize = 20;

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/posts/$arg/replies',
      queryParameters: {'offset': fetchedCount, 'take': _pageSize},
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
    final provider = postRepliesNotifierProvider(postId);

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: PostActionableItem(
            borderRadius: 8,
            item: item,
            isShowReference: false,
            isEmbedOpenable: true,
            onOpen: onOpen,
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
