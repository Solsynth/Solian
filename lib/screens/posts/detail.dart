import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/post_quick_reply.dart';
import 'package:island/widgets/post/post_replies.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'detail.g.dart';

@riverpod
Future<SnPost?> post(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/posts/$id');
  return SnPost.fromJson(resp.data);
}

@RoutePage()
class PostDetailScreen extends HookConsumerWidget {
  final String id;
  const PostDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));

    final isWide = isWideScreen(context);

    return AppScaffold(
      appBar: AppBar(title: const Text('Post')),
      body: post.when(
        data: (post) {
          final content = Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  PostItem(
                    item: post!,
                    isOpenable: false,
                    backgroundColor: isWide ? Colors.transparent : null,
                  ),
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
                  color: Colors.transparent,
                  child: PostQuickReply(parent: post).padding(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    top: 16,
                    horizontal: 16,
                  ),
                ),
              ),
            ],
          );

          return isWide
              ? Center(
                child: Card(
                  elevation: 8,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerLow.withOpacity(0.8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: kWideScreenWidth - 160,
                    ),
                    child: content,
                  ),
                ),
              )
              : content;
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }
}
