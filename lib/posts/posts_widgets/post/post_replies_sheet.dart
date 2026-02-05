import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/accounts/accounts_pod.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/posts/posts_widgets/post/post_quick_reply.dart';
import 'package:island/posts/posts_widgets/post/post_replies.dart';
import 'package:styled_widget/styled_widget.dart';

class PostRepliesSheet extends HookConsumerWidget {
  final SnPost post;

  const PostRepliesSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    return SheetScaffold(
      titleText: 'repliesCount'.plural(post.repliesCount),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              PostRepliesList(
                postId: post.id.toString(),
                onOpen: () {
                  Navigator.pop(context);
                },
              ),
              SliverGap(80),
            ],
          ),
          if (user.value != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child:
                  PostQuickReply(
                    parent: post,
                    onPosted: () {
                      ref.invalidate(postRepliesProvider(post.id));
                    },
                    onLaunch: () {
                      Navigator.of(context).pop();
                    },
                  ).padding(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    top: 8,
                    horizontal: 16,
                  ),
            ),
        ],
      ),
    );
  }
}
