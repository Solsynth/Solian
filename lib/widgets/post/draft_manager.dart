import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/services/compose_storage_db.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';

class DraftManagerSheet extends HookConsumerWidget {
  final Function(String draftId)? onDraftSelected;

  const DraftManagerSheet({super.key, this.onDraftSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = useState(true);

    final drafts = ref.watch(composeStorageNotifierProvider);

    // Track loading state based on drafts being loaded
    useEffect(() {
      // Set loading to false after drafts are loaded
      // We consider drafts loaded when the provider has been initialized
      Future.microtask(() {
        if (isLoading.value) {
          isLoading.value = false;
        }
      });
      return null;
    }, [drafts]);

    final sortedDrafts = useMemoized(
      () {
        final draftList = drafts.values.toList();
        draftList.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
        return draftList;
      },
      [
        drafts.length,
        drafts.values.map((e) => e.updatedAt!.millisecondsSinceEpoch).join(),
      ],
    );

    return SheetScaffold(
      titleText: 'drafts'.tr(),
      child:
          isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                            onTap: () {
                              Navigator.of(context).pop();
                              onDraftSelected?.call(draft.id);
                            },
                            onDelete: () async {
                              await ref
                                  .read(composeStorageNotifierProvider.notifier)
                                  .deleteDraft(draft.id);
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
                                        content: Text(
                                          'clearAllDraftsConfirm'.tr(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                            child: Text('cancel'.tr()),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                            child: Text('confirm'.tr()),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirmed == true) {
                                  await ref
                                      .read(
                                        composeStorageNotifierProvider.notifier,
                                      )
                                      .clearAllDrafts();
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
  final dynamic draft;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _DraftItem({required this.draft, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = draft.title ?? 'untitled'.tr();
    final content = draft.content ?? (draft.description ?? 'noContent'.tr());
    final preview =
        content.length > 100 ? '${content.substring(0, 100)}...' : content;
    final timeAgo = _formatTimeAgo(draft.updatedAt!);
    final visibility = _parseVisibility(draft.visibility);

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
                    draft.type == 1 ? Symbols.article : Symbols.post_add,
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

  String _parseVisibility(int visibility) {
    switch (visibility) {
      case 1:
        return 'postVisibilityFriends';
      case 2:
        return 'postVisibilityUnlisted';
      case 3:
        return 'postVisibilityPrivate';
      default:
        return 'postVisibilityPublic';
    }
  }
}
