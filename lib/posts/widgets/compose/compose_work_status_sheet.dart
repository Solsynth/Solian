import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/pulsar_shelf.dart';
import 'package:island/activity/pulsar_artwork.dart';
import 'package:island/activity/pulsar_models.dart';
import 'package:island/activity/pulsar_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

Map<String, dynamic> buildWorkStatusEmbed(
  PulsarCollection collection,
  PulsarCollectionItem item, {
  String? serverUrl,
}) {
  final domain = item.catalogItem?.domain ?? collection.domain;
  final artworkUrls = PulsarArtwork.collectionUrls(item, serverUrl: serverUrl);
  final subtitle = item.displaySubtitle?.trim();
  final note = item.note?.trim();

  return {
    'type': 'work_status',
    if (item.id.isNotEmpty) 'id': item.id,
    if (collection.id.isNotEmpty) 'collection_id': collection.id,
    if (collection.name.isNotEmpty) 'collection_name': collection.name,
    'domain': domain,
    'title': item.displayTitle,
    if (subtitle != null && subtitle.isNotEmpty) 'subtitle': subtitle,
    if (artworkUrls.isNotEmpty) 'artwork': artworkUrls.first,
    if (artworkUrls.length > 1) 'artwork_urls': artworkUrls,
    if (item.status != null && item.status!.isNotEmpty) 'status': item.status,
    if (item.rating != null) 'rating': item.rating,
    if (item.progress != null) 'progress': item.progress,
    if (item.volumeProgress != null) 'volume_progress': item.volumeProgress,
    if (note != null && note.isNotEmpty) 'note': note,
    if (item.catalogId != null && item.catalogId!.isNotEmpty)
      'catalog_id': item.catalogId,
  };
}

class ComposeWorkStatusSheet extends HookConsumerWidget {
  const ComposeWorkStatusSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(pulsarMyWorkCollectionsProvider);
    final serverUrl = ref.watch(serverUrlProvider);
    final theme = Theme.of(context);

    return SheetScaffold(
      heightFactor: 0.7,
      titleText: 'pulsarWorkStatuses'.tr(),
      child: collectionsAsync.when(
        data: (collections) {
          final shelves =
              <({PulsarCollection col, List<PulsarCollectionItem> items})>[];
          for (final col in collections) {
            final items = col.items
                .where(
                  (item) =>
                      item.status != null ||
                      item.rating != null ||
                      (item.note?.isNotEmpty ?? false),
                )
                .toList();
            if (items.isNotEmpty) shelves.add((col: col, items: items));
          }

          if (shelves.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.checklist,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const Gap(16),
                    Text(
                      'pulsarWorkStatusesEmpty'.tr(),
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.paddingOf(context).bottom + 16,
            ),
            children: [
              for (final shelf in shelves) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        PulsarDomain.icon(shelf.col.domain),
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          shelf.col.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${shelf.items.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final item in shelf.items)
                  _WorkStatusPickerTile(
                    collection: shelf.col,
                    item: item,
                    serverUrl: serverUrl,
                    onTap: () => Navigator.of(context).pop(
                      buildWorkStatusEmbed(
                        shelf.col,
                        item,
                        serverUrl: serverUrl,
                      ),
                    ),
                  ),
                const Gap(8),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkStatusPickerTile extends StatelessWidget {
  final PulsarCollection collection;
  final PulsarCollectionItem item;
  final String serverUrl;
  final VoidCallback onTap;

  const _WorkStatusPickerTile({
    required this.collection,
    required this.item,
    required this.serverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final domain = item.catalogItem?.domain ?? collection.domain;
    final statusColor = PulsarWorkStatus.color(context, item.status);
    final subtitle = item.displaySubtitle?.trim();
    final note = item.note?.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                height: domain == PulsarDomain.music ? 48 : 68,
                child: PulsarCover(
                  artwork: PulsarArtwork.collectionUrls(
                    item,
                    serverUrl: serverUrl,
                  ),
                  fallbackIcon: PulsarDomain.icon(domain),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const Gap(2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (item.status != null ||
                        item.rating != null ||
                        item.progress != null) ...[
                      const Gap(6),
                      Wrap(
                        spacing: SolSpace.xs,
                        runSpacing: SolSpace.xs,
                        children: [
                          if (item.status != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SolSpace.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(
                                  SolRadius.chip,
                                ),
                              ),
                              child: Text(
                                PulsarWorkStatus.label(item.status),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (item.rating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SolSpace.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(
                                  SolRadius.chip,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 2,
                                children: [
                                  Icon(
                                    Symbols.star_rounded,
                                    size: 13,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    '${item.rating}/10',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (item.progress != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SolSpace.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(
                                  SolRadius.chip,
                                ),
                              ),
                              child: Text(
                                item.volumeProgress != null
                                    ? '${item.volumeProgress} vol · ${item.progress}'
                                    : '${item.progress}',
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (note != null && note.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        note,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(8),
              Icon(
                Symbols.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
