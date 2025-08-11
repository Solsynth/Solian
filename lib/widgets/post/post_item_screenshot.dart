import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/post/post_shared.dart';

class PostItemScreenshot extends ConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  const PostItemScreenshot({
    super.key,
    required this.item,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    final mostReaction =
        item.reactionsCount.isEmpty
            ? null
            : item.reactionsCount.entries
                .sortedBy((e) => e.value)
                .map((e) => e.key)
                .last;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostHeader(
          item: item,
          isFullPost: isFullPost,
          isInteractive: false,
          renderingPadding: renderingPadding,
          trailing:
              mostReaction != null
                  ? Row(
                    children: [
                      Text(
                        kReactionTemplates[mostReaction]?.icon ?? '',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Gap(4),
                      Text(
                        'x${item.reactionsCount[mostReaction]}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  )
                  : null,
        ),
        PostBody(
          item: item,
          renderingPadding: renderingPadding,
          isFullPost: isFullPost,
          isTextSelectable: false,
          isInteractive: false,
        ),
        if (isShowReference)
          ReferencedPostWidget(item: item, isInteractive: false),
      ],
    );
  }
}
