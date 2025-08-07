import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:styled_widget/styled_widget.dart';

part 'post_featured.g.dart';

@riverpod
Future<List<SnPost>> featuredPosts(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/posts/featured');
  return resp.data.map((e) => SnPost.fromJson(e)).cast<SnPost>().toList();
}

class PostFeaturedList extends HookConsumerWidget {
  const PostFeaturedList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredPostsAsync = ref.watch(featuredPostsProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Row(
              spacing: 8,
              children: [
                const Icon(Symbols.highlight),
                Text('Highlight Posts'),
              ],
            ).padding(horizontal: 16, vertical: 8),
            featuredPostsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (posts) {
                return SizedBox(
                  height: 320,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: PostActionableItem(
                          item: posts[index],
                          borderRadius: 8,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
