import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/posts/widgets/compose/post_quick_reply.dart';
import 'package:island/posts/widgets/compose/post_replies.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PostRepliesSheet extends HookConsumerWidget {
  final SnPost post;

  const PostRepliesSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final repliesKey = useState(0);

    return SheetScaffold(
      titleText: 'repliesCount'.plural(post.repliesCount),
      child: Stack(
        children: [
          CustomScrollView(
            key: ValueKey('post-replies-sheet-${repliesKey.value}'),
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
                      repliesKey.value++;
                      ref
                          .read(
                            postRepliesProvider(post.id.toString()).notifier,
                          )
                          .refresh();
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
