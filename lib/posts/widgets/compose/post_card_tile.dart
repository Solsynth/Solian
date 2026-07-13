import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class CreatorPostCardTile extends StatelessWidget {
  final SnPost post;
  final int index;
  final bool isSelected;
  final bool showSelectionControl;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectionToggle;
  final Widget? trailing;

  const CreatorPostCardTile({
    super.key,
    required this.post,
    required this.index,
    this.isSelected = false,
    this.showSelectionControl = false,
    this.onTap,
    this.onLongPress,
    this.onSelectionToggle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTitle = post.title?.isNotEmpty == true;
    final surface = index.isEven ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerLow;

    return Material(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSelectionControl)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: onSelectionToggle,
                    icon: Icon(
                      isSelected ? Symbols.check_circle : Symbols.circle,
                      fill: 1,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                    ),
                  ),
                ),
              SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: post.attachments.isNotEmpty
                      ? _buildAttachmentThumbnail(post.attachments.first)
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: Icon(Symbols.article, size: 24, color: theme.colorScheme.secondary),
                        ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasTitle) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post.pinMode != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Symbols.keep, size: 13, color: theme.colorScheme.primary),
                            ),
                          if (post.type == 1)
                            Padding(
                              padding: const EdgeInsets.only(right: 4, top: 3),
                              child: Icon(Symbols.article, size: 13, color: theme.colorScheme.tertiary),
                            ),
                          Expanded(
                            child: Text(
                              post.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const Gap(2),
                    ],
                    Text(
                      post.content != null && post.content!.isNotEmpty
                          ? _truncateContent(post.content!, 180)
                          : 'No content',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetricChip(icon: Symbols.schedule, label: post.createdAt?.formatSystem() ?? '-'),
                        _MetricChip(icon: Symbols.visibility, label: _formatNumber(post.viewsUnique)),
                        _MetricChip(icon: Symbols.bar_chart, label: _formatNumber(post.viewsTotal)),
                        _MetricChip(icon: Symbols.chat_bubble, label: '${post.repliesCount}'),
                        _MetricChip(icon: Symbols.thumb_up, label: '${post.upvotes}'),
                        _MetricChip(icon: Symbols.thumb_down, label: '${post.downvotes}'),
                        _MetricChip(icon: Symbols.emoji_events, label: '${post.awardedScore}'),
                        if (post.featuredRecords.isNotEmpty)
                          _MetricChip(icon: Symbols.highlight, label: '${post.featuredRecords.length}'),
                        _MetricChip(
                          icon: PostVisibilityHelpers.getVisibilityIcon(post.visibility),
                          label: PostVisibilityHelpers.getVisibilityText(post.visibility).tr(),
                        ),
                        if (post.attachments.isNotEmpty)
                          _MetricChip(icon: Symbols.attach_file, label: '${post.attachments.length}'),
                        if (post.editedAt != null)
                          _MetricChip(icon: Symbols.edit, label: post.editedAt!.formatSystem()),
                      ],
                    ),
                    if (post.tags.isNotEmpty || post.categories.isNotEmpty) ...[
                      const Gap(8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (post.tags.isNotEmpty) ...[
                            const Icon(Symbols.label, size: 16),
                            for (final tag in post.tags.take(4))
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (tag.isProtected) ...[
                                    const Icon(Symbols.lock, size: 12),
                                    const Gap(2),
                                  ],
                                  Text(
                                    '#${tag.name ?? tag.slug}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            if (post.tags.length > 4) Text('+${post.tags.length - 4}', style: TextStyle(fontSize: 13)),
                          ],
                          if (post.categories.isNotEmpty) ...[
                            const Icon(Symbols.category, size: 16),
                            for (final category in post.categories.take(3))
                              Text(category.categoryTranslationKey.tr(), style: TextStyle(fontSize: 13)),
                            if (post.categories.length > 3)
                              Text('+${post.categories.length - 3}', style: TextStyle(fontSize: 13)),
                          ],
                        ],
                      ),
                    ],
                    if (post.reactionsCount.isNotEmpty) ...[
                      const Gap(8),
                      PostReactionList(
                        item: post,
                        reactions: post.reactionsCount,
                        reactionsMade: post.reactionsMade,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const Gap(8), trailing!],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentThumbnail(IDisplayableCloudFile file) {
    return CloudFileWidget(item: file);
  }

  String _truncateContent(String content, int maxLength) {
    if (content.isEmpty) return '';
    final stripped = content.replaceAll(RegExp(r'<[^>]*>'), '');
    if (stripped.length <= maxLength) return stripped;
    return '${stripped.substring(0, maxLength)}...';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.secondary),
          const Gap(4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

