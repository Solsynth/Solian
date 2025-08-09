import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/post_quick_reply.dart';
import 'package:island/widgets/post/post_replies.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'post_detail.g.dart';

@riverpod
Future<SnPost?> post(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/posts/$id');
  return SnPost.fromJson(resp.data);
}

final postStateProvider =
    StateNotifierProvider.family<PostState, AsyncValue<SnPost?>, String>(
      (ref, id) => PostState(ref, id),
    );

class PostState extends StateNotifier<AsyncValue<SnPost?>> {
  final Ref _ref;
  final String _id;

  PostState(this._ref, this._id) : super(const AsyncValue.loading()) {
    // Initialize with the initial post data
    _ref.listen<AsyncValue<SnPost?>>(
      postProvider(_id),
      (_, next) => state = next,
    );
  }

  void updatePost(SnPost? newPost) {
    if (newPost != null) {
      state = AsyncData(newPost);
    }
  }
}

class PostDetailScreen extends HookConsumerWidget {
  final String id;
  const PostDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postStateProvider(id));
    final user = ref.watch(userInfoProvider);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: const Text('Post')),
      body: postState.when(
        data: (post) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: PostItem(
                          item: post!,
                          isFullPost: true,
                          isEmbedReply: false,
                          onUpdate: (newItem) {
                            // Update the local state with the new post data
                            ref
                                .read(postStateProvider(id).notifier)
                                .updatePost(newItem);
                          },
                        ),
                      ),
                    ),
                  ),
                  PostRepliesList(postId: id, maxWidth: 600),
                  SliverGap(MediaQuery.of(context).padding.bottom + 80),
                ],
              ),
              if (user.value != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    elevation: 2,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: postState
                        .when(
                          data:
                              (post) => PostQuickReply(
                                parent: post!,
                                onPosted: () {
                                  ref.invalidate(
                                    postRepliesNotifierProvider(id),
                                  );
                                },
                              ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        )
                        .padding(
                          bottom: MediaQuery.of(context).padding.bottom + 8,
                          top: 8,
                          horizontal: 16,
                        ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }
}
