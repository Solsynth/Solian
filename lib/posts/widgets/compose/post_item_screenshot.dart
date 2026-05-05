import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/posts/widgets/compose/post_reaction_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _kScreenshotMainAttachmentMaxHeight = 220.0;
const _kScreenshotReplyAttachmentMaxHeight = 140.0;
const _kScreenshotVisibleMainAttachments = 2;
const _kScreenshotVisibleReplyAttachments = 1;

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

  Widget _buildScreenshotAttachments(
    BuildContext context,
    List<SnCloudFile> attachments, {
    required double maxHeight,
    required int maxVisible,
    required EdgeInsets padding,
  }) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final visibleAttachments = attachments.take(maxVisible).toList();
    final hiddenCount = attachments.length - visibleAttachments.length;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...visibleAttachments.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            final itemHeight = visibleAttachments.length == 1
                ? maxHeight
                : (maxHeight - ((visibleAttachments.length - 1) * 8)) /
                    visibleAttachments.length;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == visibleAttachments.length - 1 ? 0 : 8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: double.infinity,
                  height: itemHeight,
                  child: CloudFileWidget(
                    item: file,
                    fit: BoxFit.cover,
                    useInternalGate: false,
                  ),
                ),
              ),
            );
          }),
          if (hiddenCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.collections,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const Gap(6),
                  Text(
                    '+$hiddenCount more attachment${hiddenCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyContent(BuildContext context, SnPost post) {
    if (post.content?.isNotEmpty ?? false) {
      return MarkdownTextContent(
        content: post.content!,
        noMentionChip: post.fediverseUri != null,
      );
    }

    if (post.attachments.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.attach_file,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const Gap(4),
          Flexible(
            child: Text(
              'postHasAttachments',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ).plural(post.attachments.length),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildReplyMeta(BuildContext context, SnPost post) {
    final chips = <Widget>[];

    if (post.attachments.isNotEmpty) {
      chips.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.photo_library, size: 12),
            const Gap(4),
            Text('${post.attachments.length}'),
          ],
        ),
      );
    }

    if (post.reactionsCount.isNotEmpty) {
      final totalReactions = post.reactionsCount.values.fold<int>(
        0,
        (sum, count) => sum + count,
      );
      chips.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.favorite, size: 12),
            const Gap(4),
            Text('$totalReactions'),
          ],
        ),
      );
    }

    if (post.threadedRepliesCount > 0) {
      chips.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.reply, size: 12),
            const Gap(4),
            Text('${post.threadedRepliesCount}'),
          ],
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: chips
          .map(
            (chip) => DefaultTextStyle(
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                child: chip,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildReplyNode(
    BuildContext context,
    RepliesState repliesState,
    ThreadedReplyNode node,
  ) {
    final post = node.post;
    final children = repliesState.getChildrenOf(post.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostHeader(
                item: post,
                isFullPost: false,
                isCompact: true,
                hideOverlay: true,
                isInteractive: false,
                renderingPadding: EdgeInsets.zero,
                showLowerLine: children.isNotEmpty,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReplyContent(context, post),
                    if (post.attachments.isNotEmpty)
                      _buildScreenshotAttachments(
                        context,
                        post.attachments,
                        maxHeight: _kScreenshotReplyAttachmentMaxHeight,
                        maxVisible: _kScreenshotVisibleReplyAttachments,
                        padding: const EdgeInsets.only(top: 8),
                      ),
                    if (post.reactionsCount.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final symbol in post.reactionsCount.keys)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    buildReactionIcon(symbol, 16),
                                    const Gap(4),
                                    Text(
                                      'x${post.reactionsCount[symbol]}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildReplyMeta(context, post),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.35),
                  ),
                ),
              ),
              padding: const EdgeInsets.only(left: 10),
              child: _buildReplyNode(context, repliesState, child),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Preload replies for screenshot
    useEffect(() {
      if (item.threadedRepliesCount > 0) {
        Future.microtask(() {
          ref.read(repliesProvider(item.id).notifier).fetchMore(4);
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
            hideAttachments: true,
          ),
          if (item.attachments.isNotEmpty)
            _buildScreenshotAttachments(
              context,
              item.attachments,
              maxHeight: _kScreenshotMainAttachmentMaxHeight,
              maxVisible: _kScreenshotVisibleMainAttachments,
              padding: EdgeInsets.only(
                left: renderingPadding.horizontal,
                right: renderingPadding.horizontal,
                top: 8,
              ),
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
                      Row(
                        children: [
                          Icon(
                            Symbols.forum,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              'repliesCount',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ).plural(item.threadedRepliesCount),
                          ),
                        ],
                      ).padding(horizontal: 5),
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
                        ...topLevelPosts.map(
                          (node) => _buildReplyNode(context, repliesState, node),
                        ),
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
