import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class CreatorPostListScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorPostListScreen({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postListProvider(
      PostListQueryConfig(
        id: 'creator_post_list_$pubName',
        initialFilter: PostListQuery(pubName: pubName),
      ),
    );
    final postsAsync = ref.watch(provider);
    final notifier = ref.watch(provider.notifier);

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('posts').tr(),
      ),
      body: postsAsync.when(
        data: (state) => _buildTable(
          context,
          state,
          notifier,
          (post) => _showPostDetailSheet(context, post),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
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

  Widget _buildTable(
    BuildContext context,
    PaginationState<SnPost> state,
    PostListNotifier notifier,
    Function(SnPost) onRowTap,
  ) {
    final scrollController = useCallback(() {
      final controller = ScrollController();
      controller.addListener(() {
        if (controller.position.pixels >=
            controller.position.maxScrollExtent - 200) {
          if (!state.isLoading && state.hasMore) {
            notifier.fetchFurther();
          }
        }
      });
      return controller;
    }, []);

    final posts = state.items;
    final isLoading = state.isLoading;
    final hasMore = state.hasMore;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 80,
                columnSpacing: 20,
                horizontalMargin: 16,
                headingRowHeight: 48,
                columns: const [
                  DataColumn(
                    label: _TableHeaderIcon(
                      icon: Symbols.article,
                      label: 'Content',
                    ),
                  ),
                  DataColumn(label: SizedBox.shrink()),
                  DataColumn(
                    label: _TableHeaderIcon(
                      icon: Symbols.schedule,
                      label: 'Created',
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: _TableHeaderIcon(
                      icon: Symbols.visibility,
                      label: 'Views',
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: _TableHeaderIcon(
                      icon: Symbols.thumb_up,
                      label: 'Up',
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: _TableHeaderIcon(
                      icon: Symbols.thumb_down,
                      label: 'Down',
                    ),
                    numeric: true,
                  ),
                ],
                rows: posts.map((post) {
                  final title = post.title?.isNotEmpty == true
                      ? post.title!
                      : _truncateContent(post.content ?? '', 40);
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: post.attachments.isNotEmpty
                              ? _buildAttachmentThumbnail(
                                  post.attachments.first,
                                )
                              : Icon(
                                  Symbols.article,
                                  size: 24,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                        ),
                        onTap: () => onRowTap(post),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (post.pinMode != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(
                                        Symbols.keep,
                                        size: 14,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  if (post.type == 1)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(
                                        Symbols.article,
                                        size: 14,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.tertiary,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              if (post.attachments.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Symbols.attach_file,
                                      size: 10,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                    const Gap(2),
                                    Text(
                                      '${post.attachments.length}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        onTap: () => onRowTap(post),
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.createdAt?.formatSystem() ?? '-',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (post.editedAt != null)
                              Text(
                                'Edited: ${post.editedAt!.formatSystem()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                          ],
                        ),
                        onTap: () => onRowTap(post),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.visibility,
                              size: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const Gap(4),
                            Text(
                              _formatNumber(post.viewsUnique),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        onTap: () => onRowTap(post),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.thumb_up,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Gap(4),
                            Text(
                              '${post.upvotes}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        onTap: () => onRowTap(post),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.thumb_down,
                              size: 14,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const Gap(4),
                            Text(
                              '${post.downvotes}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                        ),
                        onTap: () => onRowTap(post),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentThumbnail(SnCloudFile file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CloudFileWidget(item: file),
    );
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

class _TableHeaderIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TableHeaderIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
        const Gap(4),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
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
