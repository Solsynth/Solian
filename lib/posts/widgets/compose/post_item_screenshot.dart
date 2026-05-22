import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

const _kScreenshotVisibleMainAttachments = 3;

class PostItemScreenshot extends ConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final PostThreadData? thread;
  final bool showThreadScreenshot;
  const PostItemScreenshot({
    super.key,
    required this.item,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = true,
    this.thread,
    this.showThreadScreenshot = true,
  });

  Widget _buildScreenshotAttachments(
    BuildContext context,
    List<IDisplayableCloudFile> attachments, {
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
            final file = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == visibleAttachments.length - 1 ? 0 : 8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: file.ratio?.toDouble() ?? 1,
                  child: CloudFileWidget(
                    item: file,
                    fit: BoxFit.contain,
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

  Widget _buildThreadScreenshot(BuildContext context, PostThreadData thread) {
    final theme = Theme.of(context);
    final childrenByParentId = buildThreadChildrenMap(
      thread.allNodes,
      hiddenParentId: item.id,
      hiddenNodeId: item.id,
      hiddenNodeParentId: item.repliedPostId ?? item.forwardedPostId,
    );
    final rootNodes = childrenByParentId[null] ?? const [];

    if (rootNodes.isEmpty) return const SizedBox.shrink();

    Color depthColor(int depth) {
      final tint = theme.colorScheme.primary.withOpacity(
        (0.04 + (depth % 4) * 0.035).clamp(0.04, 0.18),
      );
      return Color.alphaBlend(tint, theme.colorScheme.surfaceContainerLow);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'fullThread'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(8),
          for (final node in rootNodes)
            _buildThreadNode(context, node, childrenByParentId, depthColor),
        ],
      ),
    );
  }

  Widget _buildThreadNode(
    BuildContext context,
    ThreadedReplyNode node,
    Map<String?, List<ThreadedReplyNode>> childrenByParentId,
    Color Function(int depth) depthColor,
  ) {
    final children = childrenByParentId[node.post.id] ?? const [];
    final isRoot = node.depth == 0;

    return Padding(
      padding: EdgeInsets.only(left: isRoot ? 0 : 12),
      child: Material(
        color: depthColor(node.depth),
        borderRadius: isRoot
            ? BorderRadius.zero
            : const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostHeader(
                    item: node.post,
                    isFullPost: false,
                    isCompact: true,
                    hideOverlay: true,
                    isInteractive: false,
                    renderingPadding: EdgeInsets.zero,
                    isRelativeTime: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, top: 6),
                    child: _buildReplyContent(context, node.post),
                  ),
                ],
              ),
            ),
            for (final child in children)
              _buildThreadNode(context, child, childrenByParentId, depthColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

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
          if (showThreadScreenshot && thread != null)
            _buildThreadScreenshot(context, thread!),
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
                    'assets/icons/icon${isDark ? '-dark' : ''}.webp',
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
