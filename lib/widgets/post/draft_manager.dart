import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:material_symbols_icons/symbols.dart';

class DraftManagerSheet extends HookConsumerWidget {
  final bool isArticle;
  final Function(String draftId)? onDraftSelected;

  const DraftManagerSheet({
    super.key,
    this.isArticle = false,
    this.onDraftSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final drafts =
        isArticle
            ? ref.watch(articleStorageNotifierProvider)
            : ref.watch(composeStorageNotifierProvider);

    final sortedDrafts = useMemoized(() {
      if (isArticle) {
        final draftList = drafts.values.cast<ArticleDraftModel>().toList();
        draftList.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        return draftList;
      } else {
        final draftList = drafts.values.cast<ComposeDraftModel>().toList();
        draftList.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        return draftList;
      }
    }, [drafts]);

    return Scaffold(
      appBar: AppBar(
        title: Text(isArticle ? 'articleDrafts'.tr() : 'postDrafts'.tr()),
      ),
      body: Column(
        children: [
          if (sortedDrafts.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.draft,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const Gap(16),
                    Text(
                      'noDrafts'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: sortedDrafts.length,
                itemBuilder: (context, index) {
                  final draft = sortedDrafts[index];
                  return _DraftItem(
                    draft: draft,
                    isArticle: isArticle,
                    onTap: () {
                      Navigator.of(context).pop();
                      final draftId =
                          isArticle
                              ? (draft as ArticleDraftModel).id
                              : (draft as ComposeDraftModel).id;
                      onDraftSelected?.call(draftId);
                    },
                    onDelete: () async {
                      final draftId =
                          isArticle
                              ? (draft as ArticleDraftModel).id
                              : (draft as ComposeDraftModel).id;
                      if (isArticle) {
                        await ref
                            .read(articleStorageNotifierProvider.notifier)
                            .deleteDraft(draftId);
                      } else {
                        await ref
                            .read(composeStorageNotifierProvider.notifier)
                            .deleteDraft(draftId);
                      }
                    },
                  );
                },
              ),
            ),
          if (sortedDrafts.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('clearAllDrafts'.tr()),
                                content: Text('clearAllDraftsConfirm'.tr()),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text('cancel'.tr()),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text('confirm'.tr()),
                                  ),
                                ],
                              ),
                        );

                        if (confirmed == true) {
                          if (isArticle) {
                            await ref
                                .read(articleStorageNotifierProvider.notifier)
                                .clearAllDrafts();
                          } else {
                            await ref
                                .read(composeStorageNotifierProvider.notifier)
                                .clearAllDrafts();
                          }
                        }
                      },
                      icon: const Icon(Symbols.delete_sweep),
                      label: Text('clearAll'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DraftItem extends StatelessWidget {
  final dynamic draft; // ComposeDraft or ArticleDraft
  final bool isArticle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _DraftItem({
    required this.draft,
    required this.isArticle,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String title;
    final String content;
    final DateTime lastModified;
    final String visibility;

    if (isArticle) {
      final articleDraft = draft as ArticleDraftModel;
      title =
          articleDraft.title.isNotEmpty ? articleDraft.title : 'untitled'.tr();
      content =
          articleDraft.content.isNotEmpty
              ? articleDraft.content
              : (articleDraft.description.isNotEmpty
                  ? articleDraft.description
                  : 'noContent'.tr());
      lastModified = articleDraft.lastModified;
      visibility = _parseArticleVisibility(articleDraft.visibility);
    } else {
      final postDraft = draft as ComposeDraftModel;
      title = postDraft.title.isNotEmpty ? postDraft.title : 'untitled'.tr();
      content =
          postDraft.content.isNotEmpty
              ? postDraft.content
              : (postDraft.description.isNotEmpty
                  ? postDraft.description
                  : 'noContent'.tr());
      lastModified = postDraft.lastModified;
      visibility = postDraft.visibility;
    }

    final preview =
        content.length > 100 ? '${content.substring(0, 100)}...' : content;
    final timeAgo = _formatTimeAgo(lastModified);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isArticle ? Symbols.article : Symbols.post_add,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Symbols.delete),
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (preview.isNotEmpty) ...[
                const Gap(8),
                Text(
                  preview,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Gap(8),
              Row(
                children: [
                  Icon(
                    Symbols.schedule,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const Gap(4),
                  Text(
                    timeAgo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      visibility,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'justNow'.tr();
    } else if (difference.inHours < 1) {
      return 'minutesAgo'.tr(args: [difference.inMinutes.toString()]);
    } else if (difference.inDays < 1) {
      return 'hoursAgo'.tr(args: [difference.inHours.toString()]);
    } else if (difference.inDays < 7) {
      return 'daysAgo'.tr(args: [difference.inDays.toString()]);
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  String _parseArticleVisibility(String visibility) {
    switch (visibility.toLowerCase()) {
      case 'public':
        return 'public'.tr();
      case 'unlisted':
        return 'unlisted'.tr();
      case 'friends':
        return 'friends'.tr();
      case 'selected':
        return 'selected'.tr();
      case 'private':
        return 'private'.tr();
      default:
        return 'unknown'.tr();
    }
  }
}
