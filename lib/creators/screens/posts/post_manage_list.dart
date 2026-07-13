import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/post_card_tile.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class CreatorPostListScreen extends HookConsumerWidget {
  final String pubName;

  const CreatorPostListScreen({
    super.key,
    @PathParam("pubName") required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTabController = useTabController(initialLength: 3);
    final queryState = useState(PostListQuery(pubName: pubName));
    final isFilterVisible = useState(true);
    final isSelectionMode = useState(false);
    final selectedIds = useState<Set<String>>({});
    final selectionMode = isSelectionMode.value;

    void clearSelection() {
      selectedIds.value = {};
    }

    void enterSelectionMode() {
      isSelectionMode.value = true;
    }

    void exitSelectionMode() {
      isSelectionMode.value = false;
      clearSelection();
    }

    Future<void> runBatchAction(
      Future<void> Function(List<String>) action,
    ) async {
      final ids = selectedIds.value.toList();
      if (ids.isEmpty) return;
      if (context.mounted) showLoadingModal(context);
      try {
        await action(ids);
        clearSelection();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

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
    final loadedPosts = ref.watch(provider).value?.items ?? const <SnPost>[];

    void selectAllLoaded() {
      if (loadedPosts.isEmpty) return;
      selectedIds.value = loadedPosts.map((post) => post.id).toSet();
      isSelectionMode.value = true;
    }

    return AppScaffold(
      appBar: AppBar(
        leading: selectionMode
            ? IconButton(
                onPressed: exitSelectionMode,
                icon: const Icon(Symbols.close),
                tooltip: 'Cancel selection',
              )
            : const AutoLeadingButton(),
        title: selectionMode
            ? Text('${selectedIds.value.length} selected')
            : Text('posts').tr(),
        actions: [
          if (!selectionMode)
            IconButton(
              onPressed: enterSelectionMode,
              icon: const Icon(Symbols.select_all),
              tooltip: 'Select posts',
            ),
          if (selectionMode)
            PopupMenuButton<_BatchAction>(
              icon: const Icon(Symbols.more_vert),
              tooltip: 'Batch actions',
              onSelected: (action) async {
                final ids = selectedIds.value.toList();
                switch (action) {
                  case _BatchAction.selectAllLoaded:
                    selectAllLoaded();
                  case _BatchAction.delete:
                    final confirmed = await showConfirmAlert(
                      'Delete selected posts?',
                      'deletePost'.tr(),
                      isDanger: true,
                    );
                    if (confirmed == true) {
                      await runBatchAction(
                        (ids) => ref
                            .read(solarNetworkClientProvider)
                            .sphere
                            .batchDeletePosts(ids),
                      );
                    }
                  case _BatchAction.changeVisibility:
                    await _showBatchVisibilitySheet(
                      context,
                      ref,
                      ids,
                      exitSelectionMode,
                    );
                  case _BatchAction.addToCollections:
                    await _showBatchCollectionSheet(
                      context,
                      ref,
                      pubName,
                      ids,
                      exitSelectionMode,
                    );
                  case _BatchAction.removeFromCollections:
                    await _showBatchCollectionSheet(
                      context,
                      ref,
                      pubName,
                      ids,
                      exitSelectionMode,
                    );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _BatchAction.selectAllLoaded,
                  enabled: loadedPosts.isNotEmpty,
                  child: const Text('Select all loaded'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: _BatchAction.changeVisibility,
                  child: Text('Change visibility'),
                ),
                const PopupMenuItem(
                  value: _BatchAction.addToCollections,
                  child: Text('Add to collections'),
                ),
                const PopupMenuItem(
                  value: _BatchAction.removeFromCollections,
                  child: Text('Remove from collections'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: _BatchAction.delete,
                  child: Text('Delete selected'),
                ),
              ],
            ),
          IconButton(
            onPressed: () => isFilterVisible.value = !isFilterVisible.value,
            icon: Icon(
              isFilterVisible.value
                  ? Symbols.filter_list_off
                  : Symbols.filter_list,
            ),
            tooltip: isFilterVisible.value ? 'Hide filters' : 'Show filters',
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: isFilterVisible.value ? Offset.zero : const Offset(0, -0.08),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: isFilterVisible.value
                    ? Padding(
                        key: const ValueKey('filters-visible'),
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                        child: PostFilterWidget(
                          categoryTabController: categoryTabController,
                          initialQuery: queryState.value,
                          onQueryChanged: (newQuery) =>
                              queryState.value = newQuery,
                        ),
                      )
                    : const SizedBox(key: ValueKey('filters-hidden')),
              ),
            ),
          ),
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.depth != 0) return false;
                switch (notification.direction) {
                  case ScrollDirection.reverse:
                    if (isFilterVisible.value) {
                      isFilterVisible.value = false;
                    }
                  case ScrollDirection.forward:
                    if (!isFilterVisible.value) {
                      isFilterVisible.value = true;
                    }
                  case ScrollDirection.idle:
                    break;
                }
                return false;
              },
              child: PaginationList<SnPost>(
                key: ValueKey(queryState.value),
                provider: provider,
                notifier: provider.notifier,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                spacing: 0,
                itemBuilder: (context, index, post) => CreatorPostCardTile(
                  index: index,
                  post: post,
                  isSelected: selectedIds.value.contains(post.id),
                  showSelectionControl: selectionMode,
                  onTap: selectionMode
                      ? () {
                          final next = Set<String>.from(selectedIds.value);
                          if (!next.add(post.id)) next.remove(post.id);
                          selectedIds.value = next;
                        }
                      : () => _showPostDetailSheet(context, post),
                  onSelectionToggle: () {
                    final next = Set<String>.from(selectedIds.value);
                    if (!next.add(post.id)) next.remove(post.id);
                    selectedIds.value = next;
                  },
                  onLongPress: () {
                    enterSelectionMode();
                    final next = Set<String>.from(selectedIds.value)
                      ..add(post.id);
                    selectedIds.value = next;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBatchVisibilitySheet(
    BuildContext context,
    WidgetRef ref,
    List<String> postIds,
    VoidCallback clearSelection,
  ) async {
    final visibility = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BatchVisibilitySheet(),
    );
    if (visibility == null) return;
    if (context.mounted) showLoadingModal(context);
    try {
      await ref
          .read(solarNetworkClientProvider)
          .sphere
          .batchUpdatePostVisibility(
            postIds: postIds,
            visibility: switch (visibility) {
              1 => 'friends',
              2 => 'unlisted',
              3 => 'private',
              _ => 'public',
            },
          );
      clearSelection();
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _showBatchCollectionSheet(
    BuildContext context,
    WidgetRef ref,
    String pubName,
    List<String> postIds,
    VoidCallback clearSelection,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _BatchCollectionSheet(pubName: pubName, postIds: postIds),
    );
    clearSelection();
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

class _BatchVisibilitySheet extends StatefulWidget {
  const _BatchVisibilitySheet();

  @override
  State<_BatchVisibilitySheet> createState() => _BatchVisibilitySheetState();
}

class _BatchVisibilitySheetState extends State<_BatchVisibilitySheet> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'Change visibility',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final option in [
            (0, 'Public'),
            (1, 'Friends'),
            (2, 'Unlisted'),
            (3, 'Private'),
          ])
            RadioListTile<int>(
              value: option.$1,
              groupValue: _selected,
              onChanged: (value) => setState(() => _selected = value ?? 0),
              title: Text(option.$2),
            ),
          const Gap(12),
          FilledButton(
            onPressed: () => Navigator.pop(context, _selected),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _BatchCollectionSheet extends HookConsumerWidget {
  final String pubName;
  final List<String> postIds;

  const _BatchCollectionSheet({required this.pubName, required this.postIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final collections = useState<List<SnPostCollection>>([]);

    Future<void> load() async {
      if (isLoading.value) return;
      try {
        isLoading.value = true;
        final client = ref.read(solarNetworkClientProvider);
        collections.value = await client.sphere.listPublisherCollections(
          pubName,
        );
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, [pubName]);

    Future<void> addToCollection(SnPostCollection collection) async {
      if (postIds.isEmpty) return;
      try {
        isLoading.value = true;
        final client = ref.read(solarNetworkClientProvider);
        await client.sphere.batchAddPostsToCollection(
          publisherName: pubName,
          slug: collection.slug,
          postIds: postIds,
        );
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> removeFromCollection(SnPostCollection collection) async {
      if (postIds.isEmpty) return;
      try {
        isLoading.value = true;
        final client = ref.read(solarNetworkClientProvider);
        await client.sphere.batchRemovePostsFromCollection(
          publisherName: pubName,
          slug: collection.slug,
          postIds: postIds,
        );
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isLoading.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'Collections',
      actions: [
        IconButton(
          onPressed: isLoading.value ? null : load,
          icon: const Icon(Symbols.refresh),
        ),
      ],
      child: collections.value.isEmpty && isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: collections.value.length,
              separatorBuilder: (_, _) => const Gap(8),
              itemBuilder: (context, index) {
                final c = collections.value[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Symbols.collections),
                    title: Text(c.name?.isNotEmpty == true ? c.name! : c.slug),
                    subtitle: Text(c.slug),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: isLoading.value
                              ? null
                              : () => addToCollection(c),
                          child: const Text('Add'),
                        ),
                        TextButton(
                          onPressed: isLoading.value
                              ? null
                              : () => removeFromCollection(c),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

enum _BatchAction {
  selectAllLoaded,
  changeVisibility,
  addToCollections,
  removeFromCollections,
  delete,
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
      (label: 'Tags', value: '${post.tags.length}', icon: Symbols.label),
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
                        Icon(
                          detail.icon,
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
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
                      Chip(
                        avatar: tag.isProtected
                            ? const Icon(Symbols.lock, size: 16)
                            : null,
                        label: Text(tag.name ?? tag.slug),
                      ),
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
