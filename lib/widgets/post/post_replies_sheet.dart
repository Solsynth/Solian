import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/post/post_replies.dart';
import 'package:island/widgets/post/post_quick_reply.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:styled_widget/styled_widget.dart';

class PostRepliesSheet extends HookConsumerWidget {
  final SnPost post;

  const PostRepliesSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    return SheetScaffold(
      titleText: 'repliesCount'.plural(post.repliesCount),
      child: Column(
        children: [
          // Replies list
          Expanded(
            child: CustomScrollView(
              slivers: [PostRepliesList(postId: post.id.toString())],
            ),
          ),
          // Quick reply section
          if (user.value != null)
            Material(
              elevation: 2,
              child: PostQuickReply(
                parent: post,
                onPosted: () {
                  ref.invalidate(postRepliesNotifierProvider(post.id));
                },
              ).padding(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 16,
                horizontal: 16,
              ),
            ),
        ],
      ),
    );
  }
}
