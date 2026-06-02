import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

class DraftManagerSheet extends HookConsumerWidget {
  final Function(String draftId)? onDraftSelected;

  const DraftManagerSheet({super.key, this.onDraftSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final uploadingDraftId = useState<String?>(null);

    final drafts = ref.watch(composeStorageProvider);

    // Search functionality
    final filteredDrafts = useMemoized(() {
      if (searchQuery.value.isEmpty) {
        return drafts.values.toList()..sort(
          (a, b) => (b.updatedAt ?? DateTime(0)).compareTo(
            a.updatedAt ?? DateTime(0),
          ),
        );
      }

      final query = searchQuery.value.toLowerCase();
      return drafts.values.where((draft) {
        return (draft.title?.toLowerCase().contains(query) ?? false) ||
            (draft.description?.toLowerCase().contains(query) ?? false) ||
            (draft.content?.toLowerCase().contains(query) ?? false);
      }).toList()..sort(
        (a, b) =>
            (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
      );
    }, [drafts, searchQuery.value]);

    return SheetScaffold(
      titleText: 'drafts'.tr(),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'searchDrafts'.tr(),
                prefixIcon: const Icon(Symbols.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => searchQuery.value = value,
            ),
          ),

          // Drafts list
          if (filteredDrafts.isEmpty)
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
                      searchQuery.value.isEmpty
                          ? 'noDrafts'.tr()
                          : 'noSearchResults'.tr(),
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
                itemCount: filteredDrafts.length,
                itemBuilder: (context, index) {
                  final draft = filteredDrafts[index];
                  return _DraftItem(
                    draft: draft,
                    onTap: () {
                      Navigator.of(context).pop();
                      onDraftSelected?.call(draft.id);
                    },
                    uploading: uploadingDraftId.value == draft.id,
                    onUpload: draft.draftedAt == null
                        ? () async {
                            uploadingDraftId.value = draft.id;
                            try {
                              await ref
                                  .read(composeStorageProvider.notifier)
                                  .uploadDraftToCloud(draft.id);
                              showSnackBar('Uploaded to cloud');
                            } catch (e) {
                              showErrorAlert(e);
                            } finally {
                              uploadingDraftId.value = null;
                            }
                          }
                        : null,
                    onDelete: () async {
                      await ref
                          .read(composeStorageProvider.notifier)
                          .deleteDraft(draft.id);
                    },
                  );
                },
              ),
            ),

          // Clear all button
          if (filteredDrafts.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showConfirmAlert(
                          'clearAllDraftsConfirm'.tr(),
                          'clearAllDrafts'.tr(),
                          isDanger: true,
                        );

                        if (confirmed == true) {
                          await ref
                              .read(composeStorageProvider.notifier)
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
  final VoidCallback? onUpload;
  final bool uploading;
  final VoidCallback? onDelete;

  const _DraftItem({
    required this.draft,
    this.onTap,
    this.onUpload,
    this.uploading = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = draft.title ?? 'untitled'.tr();
    final content = draft.content ?? (draft.description ?? 'noContent'.tr());
    final preview = content.length > 100
        ? '${content.substring(0, 100)}...'
        : content;
    final timeAgo = _formatTimeAgo(draft.updatedAt ?? DateTime.now());
    final visibility = _parseVisibility(draft.visibility).tr();
    final isCloudDraft = draft.draftedAt != null;
    final attachmentCount = (draft.attachments as List?)?.length ?? 0;
    final slug = (draft.slug as String?)?.trim() ?? '';
    final realmName =
        draft.realm?.name?.toString() ?? draft.realm?.slug?.toString() ?? '';
    final tagSlugs = (draft.tags as List? ?? [])
        .map((e) => e.slug?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .cast<String>()
        .toList();
    final categorySlugs = (draft.categories as List? ?? [])
        .map((e) => e.slug?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .cast<String>()
        .toList();

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
                    onPressed: onUpload,
                    icon: uploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Symbols.cloud_upload),
                    tooltip: onUpload != null ? 'Upload to cloud' : null,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
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
              if (slug.isNotEmpty ||
                  realmName.isNotEmpty ||
                  tagSlugs.isNotEmpty ||
                  categorySlugs.isNotEmpty ||
                  attachmentCount > 0) ...[
                const Gap(8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (attachmentCount > 0)
                      _metaChip(
                        context,
                        icon: Symbols.attach_file,
                        label:
                            '$attachmentCount attachment${attachmentCount > 1 ? 's' : ''}',
                      ),
                    if (slug.isNotEmpty)
                      _metaChip(context, icon: Symbols.link, label: '/$slug'),
                    if (realmName.isNotEmpty)
                      _metaChip(
                        context,
                        icon: Symbols.language,
                        label: realmName,
                      ),
                    ...tagSlugs
                        .take(2)
                        .map(
                          (tag) => _metaChip(
                            context,
                            icon: Symbols.sell,
                            label: '#$tag',
                          ),
                        ),
                    ...categorySlugs
                        .take(2)
                        .map(
                          (cat) => _metaChip(
                            context,
                            icon: Symbols.category,
                            label: cat,
                          ),
                        ),
                  ],
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
                  if (isCloudDraft)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cloud Draft',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

  Widget _metaChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const Gap(4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
      case 4:
        return 'postVisibilityCloseFriends';
      case 5:
        return 'postVisibilityQuitePublic';
      default:
        return 'postVisibilityPublic';
    }
  }
}
