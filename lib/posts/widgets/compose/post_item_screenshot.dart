import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/posts/widgets/compose/post_reaction_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PostItemScreenshot extends HookConsumerWidget {
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

    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Preload replies for screenshot
    useEffect(() {
      if (item.threadedRepliesCount > 0) {
        Future.microtask(() {
          ref.read(repliesProvider(item.id).notifier).fetchMore(3);
        });
      }
      return null;
    }, [item.id, item.threadedRepliesCount]);

    return Material(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(renderingPadding.vertical),
          PostHeader(
            hideOverlay: true,
            item: item,
            isFullPost: isFullPost,
            isInteractive: false,
            renderingPadding: renderingPadding,
            isRelativeTime: false,
          ),
          PostBody(
            item: item,
            renderingPadding: renderingPadding,
            isFullPost: isFullPost,
            isRelativeTime: false,
            isTextSelectable: false,
            isInteractive: false,
            hideOverlay: true,
          ),
          if (isShowReference)
            ReferencedPostWidget(
              item: item,
              isInteractive: false,
              renderingPadding: renderingPadding,
            ),
          if (item.reactionsCount.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: renderingPadding.horizontal,
                right: renderingPadding.horizontal,
                top: 8,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final symbol in item.reactionsCount.keys)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (item.reactionsMade[symbol] ?? false)
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildReactionIcon(symbol, 20),
                          const Gap(4),
                          Text(
                            'x${item.reactionsCount[symbol]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (item.threadedRepliesCount > 0)
            Consumer(
              builder: (context, ref, child) {
                final repliesState = ref.watch(repliesProvider(item.id));
                final topLevelPosts = repliesState.flatNodes
                    .where((n) => n.depth == 0)
                    .toList();

                Widget buildReplyNode(
                  ThreadedReplyNode node, {
                  double indent = 20,
                }) {
                  final post = node.post;
                  final children = repliesState.getChildrenOf(post.id);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            ProfilePictureWidget(
                              file:
                                  post.publisher?.picture ??
                                  post.publisher?.account?.profile.picture,
                              radius: 12,
                            ).padding(top: 4),
                            if (post.content?.isNotEmpty ?? false)
                              Expanded(
                                child: MarkdownTextContent(
                                  content: post.content!,
                                  attachments: post.attachments,
                                  noMentionChip: post.fediverseUri != null,
                                ).padding(top: 2),
                              )
                            else
                              Expanded(
                                child:
                                    Text(
                                          'postHasAttachments',
                                          style: const TextStyle(height: 2),
                                        )
                                        .plural(post.attachments.length)
                                        .padding(top: 2),
                              ),
                          ],
                        ),
                      ),
                      for (final child in children)
                        buildReplyNode(
                          child,
                          indent: indent,
                        ).padding(left: indent, top: 4),
                    ],
                  );
                }

                return Container(
                  margin: EdgeInsets.only(
                    left: renderingPadding.horizontal,
                    right: renderingPadding.horizontal,
                    top: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                            'repliesCount',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          .plural(item.threadedRepliesCount)
                          .padding(horizontal: 5),
                      if (topLevelPosts.isEmpty && repliesState.loading)
                        Row(
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const Gap(8),
                            const Text('loading').tr(),
                          ],
                        ).padding(horizontal: 5),
                      if (topLevelPosts.isNotEmpty)
                        ...topLevelPosts.map((post) => buildReplyNode(post)),
                      if (topLevelPosts.isEmpty && !repliesState.loading)
                        Text(
                          'viewRepliesHint',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ).tr().padding(horizontal: 5),
                    ],
                  ),
                );
              },
            ),
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            margin: const EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(
              horizontal: renderingPadding.horizontal,
              vertical: 4,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Image.asset(
                    'assets/icons/icon${isDark ? '-dark' : ''}.png',
                    width: 40,
                    height: 40,
                  ),
                ).padding(vertical: 8, right: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solar Network',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'sharePostSlogan',
                        style: TextStyle(fontSize: 12),
                      ).tr().opacity(0.9),
                    ],
                  ),
                ),
                QrImageView(
                  data: 'https://solian.app/posts/${item.id}',
                  version: QrVersions.auto,
                  size: 60,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
