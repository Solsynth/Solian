import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/post_quick_reply.dart';
import 'package:island/widgets/post/post_replies.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'detail.g.dart';

@riverpod
Future<SnPost?> post(Ref ref, int id) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/posts/$id');
  return SnPost.fromJson(resp.data);
}

@RoutePage()
class PostDetailScreen extends HookConsumerWidget {
  final int id;
  const PostDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));

    return AppScaffold(
      appBar: AppBar(title: const Text('Post')),
      body: post.when(
        data:
            (post) => Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    PostItem(item: post!),
                    const Divider(height: 1),
                    Expanded(child: PostRepliesList(postId: id)),
                    Gap(MediaQuery.of(context).padding.bottom),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    elevation: 2,
                    child: PostQuickReply(parent: post).padding(
                      bottom: MediaQuery.of(context).padding.bottom,
                      top: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }
}
