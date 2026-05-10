import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class CreatorPostListScreen extends HookConsumerWidget {
  final String pubName;

  const CreatorPostListScreen({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTabController = useTabController(initialLength: 3);
    final queryState = useState(PostListQuery(pubName: pubName));
    final isFilterVisible = useState(true);

    useEffect(() {
      final index = switch (queryState.value.type) {
        0 => 1,
        1 => 2,
        _ => 0,
      };
      categoryTabController.index = index;
      return null;
    }, [categoryTabController, queryState.value.type]);

    final provider = postListProvider(
      PostListQueryConfig(
        id: 'creator_post_list_$pubName',
        initialFilter: queryState.value,
      ),
    );

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('posts').tr(),
        actions: [
          IconButton(
            onPressed: () => isFilterVisible.value = !isFilterVisible.value,
            icon: Icon(
              isFilterVisible.value ? Symbols.filter_list_off : Symbols.filter_list,
            ),
            tooltip: isFilterVisible.value ? 'Hide filters' : 'Show filters',
          ),
          const Gap(8)
        ],
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isFilterVisible.value
                ? Padding(
                    key: const ValueKey('filters-visible'),
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                    child: PostFilterWidget(
                      categoryTabController: categoryTabController,
                      initialQuery: queryState.value,
                      onQueryChanged: (newQuery) => queryState.value = newQuery,
                    ),
                  )
                : const SizedBox(key: ValueKey('filters-hidden')),
            ),
          Expanded(
            child: PaginationList<SnPost>(
              key: ValueKey(queryState.value),
              provider: provider,
              notifier: provider.notifier,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              spacing: 0,
              itemBuilder: (context, index, post) => _PostListCard(
                index: index,
                post: post,
                onTap: () => _showPostDetailSheet(context, post),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostDetailSheet(BuildContext context, SnPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _PostDetailSheet(post: post),
    );
  }

}

class _PostListCard extends StatelessWidget {
  final int index;
  final SnPost post;
  final VoidCallback onTap;

  const _PostListCard({
    required this.index,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTitle = post.title?.isNotEmpty == true;
    final surface = index.isEven
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerLow;

    return Material(
      color: surface,
      elevation: 0,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          child: Icon(
                            Symbols.article,
                            size: 24,
                            color: theme.colorScheme.secondary,
                          ),
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
                              child: Icon(
                                Symbols.keep,
                                size: 13,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          if (post.type == 1)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Symbols.article,
                                size: 13,
                                color: theme.colorScheme.tertiary,
                              ),
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
                        _MetricChip(
                          icon: Symbols.schedule,
                          label: post.createdAt?.formatSystem() ?? '-',
                        ),
                        _MetricChip(
                          icon: Symbols.visibility,
                          label: _formatNumber(post.viewsUnique),
                        ),
                        _MetricChip(
                          icon: Icons.bar_chart,
                          label: _formatNumber(post.viewsTotal),
                        ),
                        _MetricChip(
                          icon: Symbols.chat_bubble,
                          label: '${post.repliesCount}',
                        ),
                        _MetricChip(
                          icon: Symbols.thumb_up,
                          label: '${post.upvotes}',
                        ),
                        _MetricChip(
                          icon: Symbols.thumb_down,
                          label: '${post.downvotes}',
                        ),
                        _MetricChip(
                          icon: Symbols.emoji_events,
                          label: '${post.awardedScore}',
                        ),
                        if (post.featuredRecords.isNotEmpty)
                          _MetricChip(
                            icon: Symbols.highlight,
                            label: '${post.featuredRecords.length}',
                          ),
                        _MetricChip(
                          icon: PostVisibilityHelpers.getVisibilityIcon(
                            post.visibility,
                          ),
                          label: PostVisibilityHelpers.getVisibilityText(
                            post.visibility,
                          ).tr(),
                        ),
                        if (post.attachments.isNotEmpty)
                          _MetricChip(
                            icon: Symbols.attach_file,
                            label: '${post.attachments.length}',
                          ),
                        if (post.editedAt != null)
                          _MetricChip(
                            icon: Symbols.edit,
                            label: post.editedAt!.formatSystem(),
                          ),
                      ],
                    ),
                    if (post.tags.isNotEmpty || post.categories.isNotEmpty) ...[
                      const Gap(8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (post.tags.isNotEmpty)
                            ...[
                              const Icon(Symbols.label, size: 16),
                              for (final tag in post.tags.take(4))
                                _PillChip(label: tag.name ?? tag.slug),
                              if (post.tags.length > 4)
                                _PillChip(label: '+${post.tags.length - 4}'),
                            ],
                          if (post.categories.isNotEmpty)
                            ...[
                              const Icon(Symbols.category, size: 16),
                              for (final category in post.categories.take(3))
                                _PillChip(
                                  label: category.categoryTranslationKey.tr(),
                                ),
                              if (post.categories.length > 3)
                                _PillChip(label: '+${post.categories.length - 3}'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentThumbnail(SnCloudFile file) {
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

class _PillChip extends StatelessWidget {
  final String label;

  const _PillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}

class _PostDetailSheet extends StatelessWidget {
  final SnPost post;

  const _PostDetailSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'postDetail'.tr(),
      heightFactor: 0.85,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeader(
              item: post,
              isFullPost: true,
              isCompact: false,
              renderingPadding: EdgeInsets.zero,
            ),
            const Gap(12),
            PostBody(
              item: post,
              isFullPost: true,
              isTextSelectable: true,
              renderingPadding: EdgeInsets.zero,
            ),
            const Gap(16),
            _buildAnalyticsCard(context, post),
            if (post.reactionsCount.isNotEmpty) ...[
              const Gap(16),
              _buildReactionsCard(context, post),
            ],
            const Gap(16),
            _buildMetricsCard(context, post),
            const Gap(16),
            _buildActionsSection(context, post),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, SnPost post) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics', style: Theme.of(context).textTheme.titleSmall),
            const Gap(12),
            Row(
              children: [
                _buildMetricChip(
                  context,
                  Symbols.visibility,
                  '${post.viewsUnique}',
                  'Unique',
                ),
                const Gap(8),
                _buildMetricChip(
                  context,
                  Icons.bar_chart,
                  '${post.viewsTotal}',
                  'Total',
                ),
                const Gap(8),
                _buildMetricChip(
                  context,
                  Symbols.thumb_up,
                  '${post.upvotes}',
                  'Up',
                ),
                const Gap(8),
                _buildMetricChip(
                  context,
                  Symbols.thumb_down,
                  '${post.downvotes}',
                  'Down',
                ),
              ],
            ),
            const Gap(8),
            Row(
              children: [
                Icon(
                  Symbols.chat_bubble,
                  size: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const Gap(4),
                Text(
                  '${post.repliesCount} replies',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${post.createdAt?.formatSystem() ?? '-'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                if (post.editedAt != null)
                  Text(
                    'Edited: ${post.editedAt!.formatSystem()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionsCard(BuildContext context, SnPost post) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reactions', style: Theme.of(context).textTheme.titleSmall),
            const Gap(10),
            PostReactionList(
              item: post,
              reactions: post.reactionsCount,
              reactionsMade: post.reactionsMade,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context, SnPost post) {
    final theme = Theme.of(context);
    final details = <({String label, String value, IconData icon})>[
      (
        label: 'Published',
        value: post.publishedAt?.formatSystem() ?? '-',
        icon: Symbols.schedule,
      ),
      (
        label: 'Created',
        value: post.createdAt?.formatSystem() ?? '-',
        icon: Symbols.event,
      ),
      (
        label: 'Edited',
        value: post.editedAt?.formatSystem() ?? '-',
        icon: Symbols.edit,
      ),
      (
        label: 'Visibility',
        value: PostVisibilityHelpers.getVisibilityText(post.visibility).tr(),
        icon: PostVisibilityHelpers.getVisibilityIcon(post.visibility),
      ),
      (
        label: 'Replies',
        value: '${post.repliesCount}',
        icon: Symbols.chat_bubble,
      ),
      (
        label: 'Attachments',
        value: '${post.attachments.length}',
        icon: Symbols.attach_file,
      ),
      (
        label: 'Tags',
        value: '${post.tags.length}',
        icon: Symbols.label,
      ),
      (
        label: 'Categories',
        value: '${post.categories.length}',
        icon: Symbols.category,
      ),
      (
        label: 'Featured',
        value: '${post.featuredRecords.length}',
        icon: Symbols.highlight,
      ),
      (
        label: 'Score',
        value: '${post.awardedScore}',
        icon: Symbols.emoji_events,
      ),
    ];

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: theme.textTheme.titleSmall),
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final detail in details)
                  Container(
                    constraints: const BoxConstraints(minWidth: 140),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(detail.icon, size: 14, color: theme.colorScheme.secondary),
                        const Gap(8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              Text(
                                detail.value,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (post.tags.isNotEmpty || post.categories.isNotEmpty) ...[
              const Gap(12),
              if (post.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Text('Tags:', style: theme.textTheme.labelSmall),
                    for (final tag in post.tags)
                      Chip(label: Text(tag.name ?? tag.slug)),
                  ],
                ),
              if (post.categories.isNotEmpty) ...[
                const Gap(8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Text('Categories:', style: theme.textTheme.labelSmall),
                    for (final category in post.categories)
                      Chip(label: Text(category.categoryTranslationKey.tr())),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const Gap(4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, SnPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            context.router.push(PostDetailRoute(id: post.id));
          },
          icon: const Icon(Symbols.open_in_full, size: 18),
          label: const Text('openFullPost').tr(),
        ),
        const Gap(8),
        if (post.reactionsCount.isNotEmpty)
          PostReactionList(
            item: post,
            reactions: post.reactionsCount,
            reactionsMade: post.reactionsMade,
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }
}
