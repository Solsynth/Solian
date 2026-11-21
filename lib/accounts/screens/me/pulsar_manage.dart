import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/pulsar_shelf.dart';
import 'package:island/activity/pulsar_artwork.dart';
import 'package:island/activity/pulsar_models.dart';
import 'package:island/activity/pulsar_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

@RoutePage()
class PulsarManageScreen extends HookConsumerWidget {
  const PulsarManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final uname = user.value?.name ?? 'me';
    final historyDomain = useState<String?>(null);

    final historyAsync = ref.watch(
      pulsarUserHistoryProvider((
        uname: uname,
        domain: historyDomain.value,
        take: 10,
      )),
    );

    Future<void> refreshAll() async {
      ref.invalidate(pulsarMyWorkCollectionsProvider);
      ref.invalidate(pulsarUserHistoryProvider);
      for (final domain in PulsarDomain.mediaDomains) {
        ref.invalidate(pulsarFavouritesProvider(domain));
      }
      await Future.wait([
        ref.read(pulsarMyWorkCollectionsProvider.future),
        for (final domain in PulsarDomain.mediaDomains)
          ref.read(pulsarFavouritesProvider(domain).future),
        ref.read(
          pulsarUserHistoryProvider((
            uname: uname,
            domain: historyDomain.value,
            take: 10,
          )).future,
        ),
      ]);
    }

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('pulsar').tr(),
      ),
      body: ExtendedRefreshIndicator(
        onRefresh: refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: explorePageGutter(context).copyWith(
            top: kExploreCardGap,
            bottom: MediaQuery.paddingOf(context).bottom + kExploreCardGap,
          ),
          child: Column(
            spacing: kExploreCardGap,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FavoritesManageCard(),
              const _WorkStatusesManageCard(),
              _HistoryQuickActionsCard(
                uname: uname,
                selectedDomain: historyDomain.value,
                onDomainChanged: (d) => historyDomain.value = d,
                historyAsync: historyAsync,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsarManageCard extends StatelessWidget {
  final Widget child;
  const _PulsarManageCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolRadius.card),
      ),
      child: Padding(padding: const EdgeInsets.all(SolSpace.lg), child: child),
    );
  }
}

class _ManageSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _ManageSectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const Gap(SolSpace.sm),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A square 44 px case, for the list-style editors where a full shelf would
/// take more room than the form beside it.
class _ManageArtworkThumb extends StatelessWidget {
  final List<String> artwork;
  final IconData fallbackIcon;
  static const double _size = 44;

  const _ManageArtworkThumb({
    required this.artwork,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: PulsarCover(artwork: artwork, fallbackIcon: fallbackIcon),
    );
  }
}

class _FavoritesManageCard extends HookConsumerWidget {
  const _FavoritesManageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final domain = useState(PulsarDomain.music);
    final favsAsync = ref.watch(pulsarFavouritesProvider(domain.value));

    Future<void> removeFavorite(PulsarCollectionItem item) async {
      final catalogId = item.catalogId ?? item.catalogItem?.id;
      if (catalogId == null || catalogId.isEmpty) return;
      try {
        await ref
            .read(pulsarClientProvider)
            .unsetFavourite(catalogId, domain: domain.value);
        ref.invalidate(pulsarFavouritesProvider(domain.value));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> openAddFavoriteSheet() async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => _AddFavoriteSheet(initialDomain: domain.value),
      );
    }

    void openFullFavorites() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => SheetScaffold(
          titleText: 'pulsarFavorites'.tr(),
          actions: [
            IconButton(
              icon: const Icon(Symbols.add),
              tooltip: 'pulsarAddFavorite'.tr(),
              onPressed: openAddFavoriteSheet,
            ),
          ],
          child: _FullFavoritesSheetBody(initialDomain: domain.value),
        ),
      );
    }

    return _PulsarManageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SolSpace.md,
        children: [
          _ManageSectionHeader(
            icon: Symbols.favorite,
            title: 'pulsarFavorites'.tr(),
            trailing: IconButton(
              icon: const Icon(Symbols.add, size: 20),
              tooltip: 'pulsarAddFavorite'.tr(),
              onPressed: openAddFavoriteSheet,
              visualDensity: VisualDensity.compact,
            ),
          ),
          PulsarDomainFilterRow(
            selectedDomain: domain.value,
            domains: PulsarDomain.mediaDomains,
            onChanged: (value) => domain.value = value ?? PulsarDomain.music,
          ),
          favsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return PulsarShelfEmptyHint(text: 'pulsarFavoritesEmpty'.tr());
              }
              final serverUrl = ref.watch(serverUrlProvider);
              return PulsarShelf(
                aspectRatio: pulsarShelfAspect(domain.value),
                tileWidth: domain.value == PulsarDomain.music ? 132 : 112,
                onSeeAll: openFullFavorites,
                entries: [
                  for (final item in items)
                    PulsarShelfEntry(
                      title: item.displayTitle,
                      subtitle: item.displaySubtitle,
                      artwork: PulsarArtwork.collectionUrls(
                        item,
                        serverUrl: serverUrl,
                      ),
                      fallbackIcon: PulsarDomain.icon(
                        item.displayDomain == PulsarDomain.custom
                            ? domain.value
                            : item.displayDomain,
                      ),
                      cornerLabel: item.kind.isEmpty
                          ? null
                          : PulsarFavoriteKind.label(item.kind),
                      actionIcon: Symbols.favorite,
                      actionTooltip: 'pulsarRemoveFavorite'.tr(),
                      onAction: () => removeFavorite(item),
                    ),
                ],
              );
            },
            loading: () => const PulsarShelfLoading(),
            error: (err, _) => Text(
              err.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkStatusesManageCard extends HookConsumerWidget {
  const _WorkStatusesManageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionsAsync = ref.watch(pulsarMyWorkCollectionsProvider);
    final statusFilter = useState<String?>(null);

    Future<void> openAddWorkSheet(List<PulsarCollection> collections) async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => _AddWorkStatusSheet(collections: collections),
      );
    }

    Future<void> openItemEditor(
      PulsarCollection collection,
      PulsarCollectionItem item,
    ) async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) =>
            _WorkStatusEditorSheet(collection: collection, item: item),
      );
    }

    void openFullWorkStatuses() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => SheetScaffold(
          titleText: 'pulsarWorkStatuses'.tr(),
          actions: [
            IconButton(
              icon: const Icon(Symbols.add),
              tooltip: 'pulsarTrackWork'.tr(),
              onPressed: () =>
                  openAddWorkSheet(collectionsAsync.asData?.value ?? const []),
            ),
          ],
          child: _FullWorkStatusesSheetBody(initialStatus: statusFilter.value),
        ),
      );
    }

    return _PulsarManageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SolSpace.md,
        children: [
          _ManageSectionHeader(
            icon: Symbols.checklist,
            title: 'pulsarWorkStatuses'.tr(),
            trailing: IconButton(
              icon: const Icon(Symbols.add, size: 20),
              tooltip: 'pulsarTrackWork'.tr(),
              visualDensity: VisualDensity.compact,
              onPressed: () =>
                  openAddWorkSheet(collectionsAsync.asData?.value ?? const []),
            ),
          ),
          PulsarStatusFilterRow(
            selectedStatus: statusFilter.value,
            onChanged: (value) => statusFilter.value = value,
          ),
          collectionsAsync.when(
            data: (collections) {
              final shelves =
                  <
                    ({PulsarCollection col, List<PulsarCollectionItem> items})
                  >[];
              for (final col in collections) {
                final items = col.items.where((item) {
                  if (statusFilter.value != null &&
                      item.status != statusFilter.value) {
                    return false;
                  }
                  // An untracked playlist entry is just a track in a playlist,
                  // not a work someone is working through.
                  if (statusFilter.value == null &&
                      item.status == null &&
                      item.rating == null &&
                      (item.note == null || item.note!.isEmpty) &&
                      col.kind == PulsarCollectionKind.playlist) {
                    return false;
                  }
                  return true;
                }).toList();
                if (items.isNotEmpty) shelves.add((col: col, items: items));
              }

              if (shelves.isEmpty) {
                return PulsarShelfEmptyHint(
                  text: 'pulsarWorkStatusesEmpty'.tr(),
                );
              }

              final serverUrl = ref.watch(serverUrlProvider);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: SolSpace.lg,
                children: [
                  for (final shelf in shelves)
                    PulsarShelf(
                      title: shelf.col.name,
                      icon: PulsarDomain.icon(shelf.col.domain),
                      count: shelf.items.length,
                      aspectRatio: pulsarShelfAspect(shelf.col.domain),
                      tileWidth: shelf.col.domain == PulsarDomain.music
                          ? 132
                          : 112,
                      onSeeAll: openFullWorkStatuses,
                      entries: [
                        for (final item in shelf.items)
                          PulsarShelfEntry(
                            title: item.displayTitle,
                            subtitle: item.displaySubtitle,
                            artwork: PulsarArtwork.collectionUrls(
                              item,
                              serverUrl: serverUrl,
                            ),
                            fallbackIcon: PulsarDomain.icon(
                              item.catalogItem?.domain ?? shelf.col.domain,
                            ),
                            badge: item.status == null
                                ? null
                                : PulsarWorkStatus.label(item.status),
                            badgeColor: PulsarWorkStatus.color(
                              context,
                              item.status,
                            ),
                            cornerLabel: item.rating?.toString(),
                            cornerIcon: item.rating == null
                                ? null
                                : Symbols.star_rounded,
                            onTap: () => openItemEditor(shelf.col, item),
                          ),
                      ],
                    ),
                ],
              );
            },
            loading: () => const PulsarShelfLoading(),
            error: (err, _) => Text(
              err.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryQuickActionsCard extends ConsumerWidget {
  final String uname;
  final String? selectedDomain;
  final ValueChanged<String?> onDomainChanged;
  final AsyncValue<List<PulsarScrobble>> historyAsync;

  const _HistoryQuickActionsCard({
    required this.uname,
    required this.selectedDomain,
    required this.onDomainChanged,
    required this.historyAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Future<void> openManualScrobbleSheet() async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => _ManualScrobbleSheet(
          uname: uname,
          initialDomain: selectedDomain ?? PulsarDomain.book,
        ),
      );
    }

    void openFullHistory() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => SheetScaffold(
          titleText: 'pulsarHistory'.tr(),
          actions: [
            IconButton(
              icon: const Icon(Symbols.add),
              tooltip: 'pulsarManualScrobble'.tr(),
              onPressed: openManualScrobbleSheet,
            ),
          ],
          child: _FullHistoryManageSheetBody(
            uname: uname,
            initialDomain: selectedDomain,
          ),
        ),
      );
    }

    Future<void> quickFavorite(PulsarScrobble scrobble) async {
      try {
        await ref
            .read(pulsarClientProvider)
            .setFavourite(
              domain: scrobble.domain,
              catalogId: scrobble.catalogId,
              title: scrobble.title,
              subtitle: scrobble.subtitle,
              artworkUrl: PulsarArtwork.persistableScrobbleArtwork(
                scrobble,
                serverUrl: ref.watch(serverUrlProvider),
              ),
            );
        ref.invalidate(pulsarFavouritesProvider(scrobble.domain));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('pulsarAddedToFavorites'.tr())),
          );
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> quickTrackStatus(PulsarScrobble scrobble) async {
      final collections =
          ref.read(pulsarMyWorkCollectionsProvider).asData?.value ?? const [];
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => _AddWorkStatusSheet(
          collections: collections,
          initialDomain: scrobble.domain,
          initialCatalogId: scrobble.catalogId,
          initialTitle: scrobble.title,
          initialSubtitle: scrobble.subtitle,
          initialArtworkUrl: PulsarArtwork.persistableScrobbleArtwork(
            scrobble,
            serverUrl: ref.watch(serverUrlProvider),
          ),
        ),
      );
    }

    final serverUrl = ref.watch(serverUrlProvider);
    return _PulsarManageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SolSpace.md,
        children: [
          _ManageSectionHeader(
            icon: Symbols.history,
            title: 'pulsarHistory'.tr(),
            trailing: IconButton(
              icon: const Icon(Symbols.add, size: 20),
              tooltip: 'pulsarManualScrobble'.tr(),
              visualDensity: VisualDensity.compact,
              onPressed: openManualScrobbleSheet,
            ),
          ),
          PulsarDomainFilterRow(
            selectedDomain: selectedDomain,
            domains: PulsarDomain.mediaDomains,
            includeAll: true,
            onChanged: onDomainChanged,
          ),
          historyAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return PulsarShelfEmptyHint(text: 'pulsarHistoryEmpty'.tr());
              }
              return PulsarShelf(
                aspectRatio: 1,
                tileWidth: 96,
                // The card already shows a full page; only offer the sheet
                // when the server had more to give.
                onSeeAll: items.length >= 10 ? openFullHistory : null,
                entries: [
                  for (final s in items)
                    PulsarShelfEntry(
                      title: s.title,
                      subtitle: DateFormat.MMMd().add_Hm().format(
                        s.playedAt.toLocal(),
                      ),
                      artwork: PulsarArtwork.scrobbleUrls(
                        s,
                        serverUrl: serverUrl,
                      ),
                      fallbackIcon: PulsarDomain.icon(s.domain),
                      actionIcon: Symbols.favorite_border,
                      actionTooltip: 'pulsarAddFavorite'.tr(),
                      onAction: () => quickFavorite(s),
                      onTap: () => quickTrackStatus(s),
                    ),
                ],
              );
            },
            loading: () => const PulsarShelfLoading(),
            error: (err, _) => Text(
              err.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFavoriteSheet extends HookConsumerWidget {
  final String initialDomain;
  const _AddFavoriteSheet({required this.initialDomain});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domain = useState(initialDomain);
    final kind = useState('track');
    final selectedMeta = useState<PulsarCatalogItem?>(null);
    final titleController = useTextEditingController();
    final subtitleController = useTextEditingController();
    final isSubmitting = useState(false);

    void applyMeta(PulsarCatalogItem? item) {
      selectedMeta.value = item;
      if (item != null) {
        titleController.text = item.title;
        subtitleController.text = item.subtitle ?? '';
      }
    }

    Future<void> submit() async {
      final title = titleController.text.trim();
      if (title.isEmpty) return;
      isSubmitting.value = true;
      try {
        final meta = selectedMeta.value;
        const zeroUuid = '00000000-0000-0000-0000-000000000000';
        final catalogId =
            meta != null && meta.id.isNotEmpty && meta.id != zeroUuid
            ? meta.id
            : null;
        await ref
            .read(pulsarClientProvider)
            .setFavourite(
              domain: domain.value,
              catalogId: catalogId,
              title: title,
              subtitle: subtitleController.text.trim().isEmpty
                  ? null
                  : subtitleController.text.trim(),
              artworkUrl: meta == null
                  ? null
                  : PulsarArtwork.catalogUrls(
                      meta,
                      serverUrl: ref.watch(serverUrlProvider),
                    ).firstOrNull,
              kind: domain.value == PulsarDomain.music ? kind.value : 'track',
            );
        ref.invalidate(pulsarFavouritesProvider(domain.value));
        if (context.mounted) Navigator.of(context).pop();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isSubmitting.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'pulsarAddFavorite'.tr(),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SolSpace.lg,
          SolSpace.md,
          SolSpace.lg,
          MediaQuery.viewInsetsOf(context).bottom + SolSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SolSpace.md,
          children: [
            DropdownButtonFormField<String>(
              initialValue: domain.value,
              decoration: InputDecoration(labelText: 'pulsarDomain'.tr()),
              items: [
                for (final d in PulsarDomain.mediaDomains)
                  DropdownMenuItem(
                    value: d,
                    child: Text(PulsarDomain.label(d)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) domain.value = v;
              },
            ),
            if (domain.value == PulsarDomain.music)
              SegmentedButton<String>(
                segments: [
                  for (final k in PulsarFavoriteKind.all)
                    ButtonSegment(
                      value: k,
                      label: Text(PulsarFavoriteKind.label(k)),
                    ),
                ],
                selected: {kind.value},
                onSelectionChanged: (v) => kind.value = v.first,
              ),
            _MetadataSearchSection(
              domain: domain.value,
              selected: selectedMeta.value,
              onSelect: applyMeta,
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'pulsarWorkTitle'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: subtitleController,
              decoration: InputDecoration(
                labelText: 'pulsarWorkSubtitle'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            FilledButton(
              onPressed: isSubmitting.value ? null : submit,
              child: isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('save'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddWorkStatusSheet extends HookConsumerWidget {
  final List<PulsarCollection> collections;
  final String? initialDomain;
  final String? initialCatalogId;
  final String? initialTitle;
  final String? initialSubtitle;
  final String? initialArtworkUrl;

  const _AddWorkStatusSheet({
    required this.collections,
    this.initialDomain,
    this.initialCatalogId,
    this.initialTitle,
    this.initialSubtitle,
    this.initialArtworkUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domain = useState(initialDomain ?? PulsarDomain.anime);
    final status = useState(PulsarWorkStatus.watching);
    final rating = useState<int?>(null);
    final selectedMeta = useState<PulsarCatalogItem?>(null);
    final selectedCollectionId = useState<String?>(
      collections
          .where((c) => c.domain == (initialDomain ?? PulsarDomain.anime))
          .firstOrNull
          ?.id,
    );
    final titleController = useTextEditingController(text: initialTitle ?? '');
    final subtitleController = useTextEditingController(
      text: initialSubtitle ?? '',
    );
    final noteController = useTextEditingController();
    final isSubmitting = useState(false);

    void applyMeta(PulsarCatalogItem? item) {
      selectedMeta.value = item;
      if (item != null) {
        titleController.text = item.title;
        subtitleController.text = item.subtitle ?? '';
      }
    }

    Future<void> submit() async {
      final title = titleController.text.trim();
      final meta = selectedMeta.value;
      const zeroUuid = '00000000-0000-0000-0000-000000000000';
      final effectiveCatalogId =
          initialCatalogId ??
          (meta != null && meta.id.isNotEmpty && meta.id != zeroUuid
              ? meta.id
              : null);
      if (title.isEmpty && effectiveCatalogId == null) return;
      isSubmitting.value = true;
      try {
        final client = ref.read(pulsarClientProvider);
        var collectionId = selectedCollectionId.value;
        if (collectionId == null) {
          final created = await client.createCollection(
            name: '${PulsarDomain.label(domain.value)} Watchlist',
            domain: domain.value,
            kind: PulsarCollectionKind.watchlist,
          );
          collectionId = created.id;
        }
        await client.addCollectionItem(
          collectionId,
          catalogId: effectiveCatalogId,
          title: title.isEmpty ? null : title,
          subtitle: subtitleController.text.trim().isEmpty
              ? null
              : subtitleController.text.trim(),
          artworkUrl: (meta == null
              ? initialArtworkUrl
              : PulsarArtwork.catalogUrls(
                  meta,
                  serverUrl: ref.watch(serverUrlProvider),
                ).firstOrNull),
          status: status.value,
          rating: rating.value,
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
        );
        ref.invalidate(pulsarMyWorkCollectionsProvider);
        if (context.mounted) Navigator.of(context).pop();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isSubmitting.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'pulsarTrackWork'.tr(),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SolSpace.lg,
          SolSpace.md,
          SolSpace.lg,
          MediaQuery.viewInsetsOf(context).bottom + SolSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SolSpace.md,
          children: [
            DropdownButtonFormField<String>(
              initialValue: domain.value,
              decoration: InputDecoration(labelText: 'pulsarDomain'.tr()),
              items: [
                for (final d in PulsarDomain.mediaDomains)
                  DropdownMenuItem(
                    value: d,
                    child: Text(PulsarDomain.label(d)),
                  ),
              ],
              onChanged: (v) {
                if (v == null) return;
                domain.value = v;
                selectedCollectionId.value = collections
                    .where((c) => c.domain == v)
                    .firstOrNull
                    ?.id;
              },
            ),
            if (initialTitle == null && initialCatalogId == null)
              _MetadataSearchSection(
                domain: domain.value,
                selected: selectedMeta.value,
                onSelect: applyMeta,
              ),
            if (collections.isNotEmpty)
              DropdownButtonFormField<String?>(
                initialValue: selectedCollectionId.value,
                decoration: InputDecoration(labelText: 'pulsarCollection'.tr()),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('pulsarAutoCreateWatchlist'.tr()),
                  ),
                  for (final col in collections)
                    DropdownMenuItem<String?>(
                      value: col.id,
                      child: Text(
                        '${col.name} (${PulsarDomain.label(col.domain)})',
                      ),
                    ),
                ],
                onChanged: (v) => selectedCollectionId.value = v,
              ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'pulsarWorkTitle'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: subtitleController,
              decoration: InputDecoration(
                labelText: 'pulsarWorkSubtitle'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            DropdownButtonFormField<String>(
              initialValue: status.value,
              decoration: InputDecoration(labelText: 'pulsarStatus'.tr()),
              items: [
                for (final s in PulsarWorkStatus.all)
                  DropdownMenuItem(
                    value: s,
                    child: Text(PulsarWorkStatus.label(s)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) status.value = v;
              },
            ),
            DropdownButtonFormField<int?>(
              initialValue: rating.value,
              decoration: InputDecoration(labelText: 'pulsarRating'.tr()),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('-')),
                for (var r = 10; r >= 1; r--)
                  DropdownMenuItem<int?>(value: r, child: Text('★ $r / 10')),
              ],
              onChanged: (v) => rating.value = v,
            ),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'pulsarNote'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            FilledButton(
              onPressed: isSubmitting.value ? null : submit,
              child: isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('save'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullFavoritesSheetBody extends HookConsumerWidget {
  final String initialDomain;

  const _FullFavoritesSheetBody({required this.initialDomain});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDomain = useState(initialDomain);
    final favsAsync = ref.watch(pulsarFavouritesProvider(selectedDomain.value));
    final serverUrl = ref.watch(serverUrlProvider);

    Future<void> removeFavorite(PulsarCollectionItem item) async {
      final catalogId = item.catalogId ?? item.catalogItem?.id;
      if (catalogId == null || catalogId.isEmpty) return;
      try {
        await ref
            .read(pulsarClientProvider)
            .unsetFavourite(catalogId, domain: selectedDomain.value);
        ref.invalidate(pulsarFavouritesProvider(selectedDomain.value));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: SolSpace.lg,
            vertical: SolSpace.sm,
          ),
          child: Row(
            spacing: SolSpace.xs,
            children: [
              for (final domain in PulsarDomain.mediaDomains)
                ChoiceChip(
                  selected: selectedDomain.value == domain,
                  onSelected: (_) => selectedDomain.value = domain,
                  avatar: Icon(PulsarDomain.icon(domain), size: 16),
                  label: Text(PulsarDomain.label(domain)),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
        Expanded(
          child: favsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'pulsarFavoritesEmpty'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  SolSpace.lg,
                  SolSpace.sm,
                  SolSpace.lg,
                  MediaQuery.paddingOf(context).bottom + SolSpace.lg,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Gap(SolSpace.sm),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Row(
                    spacing: SolSpace.md,
                    children: [
                      _ManageArtworkThumb(
                        artwork: PulsarArtwork.collectionUrls(
                          item,
                          serverUrl: serverUrl,
                        ),
                        fallbackIcon: PulsarDomain.icon(selectedDomain.value),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.displaySubtitle != null &&
                                item.displaySubtitle!.isNotEmpty)
                              Text(
                                item.displaySubtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (item.kind.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SolSpace.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(SolRadius.xs),
                          ),
                          child: Text(
                            PulsarFavoriteKind.label(item.kind),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          Symbols.favorite,
                          size: 18,
                          fill: 1,
                          color: theme.colorScheme.error,
                        ),
                        tooltip: 'pulsarRemoveFavorite'.tr(),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => removeFavorite(item),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(err.toString())),
          ),
        ),
      ],
    );
  }
}

class _FullWorkStatusesSheetBody extends HookConsumerWidget {
  final String? initialStatus;

  const _FullWorkStatusesSheetBody({required this.initialStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusFilter = useState<String?>(initialStatus);
    final collectionsAsync = ref.watch(pulsarMyWorkCollectionsProvider);
    final serverUrl = ref.watch(serverUrlProvider);

    Future<void> openItemEditor(
      PulsarCollection collection,
      PulsarCollectionItem item,
    ) async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) =>
            _WorkStatusEditorSheet(collection: collection, item: item),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: SolSpace.lg,
            vertical: SolSpace.sm,
          ),
          child: Row(
            spacing: SolSpace.xs,
            children: [
              ChoiceChip(
                selected: statusFilter.value == null,
                onSelected: (_) => statusFilter.value = null,
                label: Text('all'.tr()),
                visualDensity: VisualDensity.compact,
              ),
              for (final status in PulsarWorkStatus.all)
                ChoiceChip(
                  selected: statusFilter.value == status,
                  onSelected: (_) => statusFilter.value = status,
                  avatar: Icon(PulsarWorkStatus.icon(status), size: 16),
                  label: Text(PulsarWorkStatus.label(status)),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
        Expanded(
          child: collectionsAsync.when(
            data: (collections) {
              final entries =
                  <({PulsarCollection col, PulsarCollectionItem item})>[];
              for (final col in collections) {
                for (final item in col.items) {
                  if (statusFilter.value != null &&
                      item.status != statusFilter.value) {
                    continue;
                  }
                  if (statusFilter.value == null &&
                      item.status == null &&
                      item.rating == null &&
                      (item.note == null || item.note!.isEmpty) &&
                      col.kind == PulsarCollectionKind.playlist) {
                    continue;
                  }
                  entries.add((col: col, item: item));
                }
              }
              if (entries.isEmpty) {
                return Center(
                  child: Text(
                    'pulsarWorkStatusesEmpty'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  SolSpace.lg,
                  SolSpace.sm,
                  SolSpace.lg,
                  MediaQuery.paddingOf(context).bottom + SolSpace.lg,
                ),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const Gap(SolSpace.sm),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(SolRadius.sm),
                    onTap: () => openItemEditor(entry.col, entry.item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SolSpace.xxs,
                      ),
                      child: Row(
                        spacing: SolSpace.md,
                        children: [
                          _ManageArtworkThumb(
                            artwork: PulsarArtwork.collectionUrls(
                              entry.item,
                              serverUrl: serverUrl,
                            ),
                            fallbackIcon: PulsarDomain.icon(
                              entry.item.catalogItem?.domain ??
                                  entry.col.domain,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.item.displayTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  [
                                    entry.col.name,
                                    if (entry.item.displaySubtitle != null &&
                                        entry.item.displaySubtitle!.isNotEmpty)
                                      entry.item.displaySubtitle!,
                                  ].join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (entry.item.note != null &&
                                    entry.item.note!.isNotEmpty)
                                  Text(
                                    entry.item.note!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            spacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SolSpace.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: PulsarWorkStatus.color(
                                    context,
                                    entry.item.status,
                                  ).withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(
                                    SolRadius.chip,
                                  ),
                                ),
                                child: Text(
                                  PulsarWorkStatus.label(entry.item.status),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: PulsarWorkStatus.color(
                                      context,
                                      entry.item.status,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (entry.item.rating != null)
                                Text(
                                  '★ ${entry.item.rating}/10',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (entry.item.progress != null)
                                Text(
                                  [
                                    '${entry.item.progress}',
                                    if (entry.item.volumeProgress != null)
                                      '${entry.item.volumeProgress} vol',
                                  ].join(' · '),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(err.toString())),
          ),
        ),
      ],
    );
  }
}

class _FullHistoryManageSheetBody extends HookConsumerWidget {
  final String uname;
  final String? initialDomain;

  const _FullHistoryManageSheetBody({
    required this.uname,
    required this.initialDomain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDomain = useState<String?>(initialDomain);
    final serverUrl = ref.watch(serverUrlProvider);
    final items = useState<List<PulsarScrobble>>([]);
    final isLoading = useState<bool>(true);
    final hasMore = useState<bool>(true);
    const pageSize = 20;

    Future<void> loadPage({required bool reset}) async {
      isLoading.value = true;
      final offset = reset ? 0 : items.value.length;
      try {
        final batch = await ref
            .read(pulsarClientProvider)
            .getUserHistory(
              uname,
              domain: selectedDomain.value,
              offset: offset,
              take: pageSize,
            );
        if (!context.mounted) return;
        items.value = reset ? batch : [...items.value, ...batch];
        hasMore.value = batch.length >= pageSize;
      } finally {
        if (context.mounted) isLoading.value = false;
      }
    }

    useEffect(() {
      loadPage(reset: true);
      return null;
    }, [uname, selectedDomain.value]);

    Future<void> quickFavorite(PulsarScrobble scrobble) async {
      try {
        await ref
            .read(pulsarClientProvider)
            .setFavourite(
              domain: scrobble.domain,
              catalogId: scrobble.catalogId,
              title: scrobble.title,
              subtitle: scrobble.subtitle,
              artworkUrl: PulsarArtwork.persistableScrobbleArtwork(
                scrobble,
                serverUrl: ref.watch(serverUrlProvider),
              ),
            );
        ref.invalidate(pulsarFavouritesProvider(scrobble.domain));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('pulsarAddedToFavorites'.tr())),
          );
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> quickTrackStatus(PulsarScrobble scrobble) async {
      final collections =
          ref.read(pulsarMyWorkCollectionsProvider).asData?.value ?? const [];
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => _AddWorkStatusSheet(
          collections: collections,
          initialDomain: scrobble.domain,
          initialCatalogId: scrobble.catalogId,
          initialTitle: scrobble.title,
          initialSubtitle: scrobble.subtitle,
          initialArtworkUrl: PulsarArtwork.persistableScrobbleArtwork(
            scrobble,
            serverUrl: ref.watch(serverUrlProvider),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: SolSpace.lg,
            vertical: SolSpace.sm,
          ),
          child: Row(
            spacing: SolSpace.xs,
            children: [
              ChoiceChip(
                selected: selectedDomain.value == null,
                onSelected: (_) => selectedDomain.value = null,
                label: Text('all'.tr()),
                visualDensity: VisualDensity.compact,
              ),
              for (final domain in PulsarDomain.mediaDomains)
                ChoiceChip(
                  selected: selectedDomain.value == domain,
                  onSelected: (_) => selectedDomain.value = domain,
                  avatar: Icon(PulsarDomain.icon(domain), size: 16),
                  label: Text(PulsarDomain.label(domain)),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
        Expanded(
          child: isLoading.value && items.value.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : items.value.isEmpty
              ? Center(
                  child: Text(
                    'pulsarHistoryEmpty'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    SolSpace.lg,
                    SolSpace.sm,
                    SolSpace.lg,
                    MediaQuery.paddingOf(context).bottom + SolSpace.lg,
                  ),
                  itemCount: items.value.length + (hasMore.value ? 1 : 0),
                  separatorBuilder: (_, _) => const Gap(SolSpace.sm),
                  itemBuilder: (context, index) {
                    if (index >= items.value.length) {
                      return Center(
                        child: TextButton(
                          onPressed: isLoading.value
                              ? null
                              : () => loadPage(reset: false),
                          child: isLoading.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('pulsarShowMore'.tr()),
                        ),
                      );
                    }
                    final s = items.value[index];
                    return Row(
                      spacing: SolSpace.md,
                      children: [
                        _ManageArtworkThumb(
                          artwork: PulsarArtwork.scrobbleUrls(
                            s,
                            serverUrl: serverUrl,
                          ),
                          fallbackIcon: PulsarDomain.icon(s.domain),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                [
                                  if (s.subtitle != null &&
                                      s.subtitle!.isNotEmpty)
                                    s.subtitle!,
                                  DateFormat.MMMd().add_Hm().format(
                                    s.playedAt.toLocal(),
                                  ),
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Symbols.favorite_border, size: 18),
                          tooltip: 'pulsarAddFavorite'.tr(),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => quickFavorite(s),
                        ),
                        IconButton(
                          icon: const Icon(Symbols.bookmark_add, size: 18),
                          tooltip: 'pulsarTrackWork'.tr(),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => quickTrackStatus(s),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _WorkStatusEditorSheet extends HookConsumerWidget {
  final PulsarCollection collection;
  final PulsarCollectionItem item;

  const _WorkStatusEditorSheet({required this.collection, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = useState<String>(item.status ?? PulsarWorkStatus.watching);
    final rating = useState<int?>(item.rating);
    final noteController = useTextEditingController(text: item.note ?? '');
    final progressController = useTextEditingController(
      text: item.progress?.toString() ?? '',
    );
    final volumeProgressController = useTextEditingController(
      text: item.volumeProgress?.toString() ?? '',
    );
    final isSubmitting = useState(false);

    Future<void> save() async {
      isSubmitting.value = true;
      try {
        final client = ref.read(pulsarClientProvider);
        await client.updateCollectionItem(
          collection.id,
          item.id,
          status: status.value,
          rating: rating.value,
          note: noteController.text.trim(),
          progress: int.tryParse(progressController.text.trim()),
          volumeProgress: int.tryParse(volumeProgressController.text.trim()),
        );
        final catalogId = item.catalogId ?? item.catalogItem?.id;
        if (catalogId != null &&
            catalogId.isNotEmpty &&
            (rating.value != null || noteController.text.trim().isNotEmpty)) {
          await client.setReview(
            catalogId,
            rating: rating.value,
            body: noteController.text.trim().isEmpty
                ? null
                : noteController.text.trim(),
          );
        }
        ref.invalidate(pulsarMyWorkCollectionsProvider);
        if (context.mounted) Navigator.of(context).pop();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isSubmitting.value = false;
      }
    }

    Future<void> addFavorite() async {
      final catalogId = item.catalogId ?? item.catalogItem?.id;
      final domain = item.catalogItem?.domain ?? collection.domain;
      try {
        await ref
            .read(pulsarClientProvider)
            .setFavourite(
              domain: domain,
              catalogId: catalogId,
              title: item.displayTitle,
              subtitle: item.displaySubtitle,
              artworkUrl: PulsarArtwork.persistableCollectionArtwork(
                item,
                serverUrl: ref.watch(serverUrlProvider),
              ),
            );
        ref.invalidate(pulsarFavouritesProvider(domain));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('pulsarAddedToFavorites'.tr())),
          );
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: item.displayTitle,
      actions: [
        IconButton(
          icon: const Icon(Symbols.favorite_border),
          tooltip: 'pulsarAddFavorite'.tr(),
          onPressed: addFavorite,
        ),
      ],
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SolSpace.lg,
          SolSpace.md,
          SolSpace.lg,
          MediaQuery.viewInsetsOf(context).bottom + SolSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SolSpace.md,
          children: [
            Row(
              spacing: SolSpace.md,
              children: [
                _ManageArtworkThumb(
                  artwork: PulsarArtwork.collectionUrls(
                    item,
                    serverUrl: ref.watch(serverUrlProvider),
                  ),
                  fallbackIcon: PulsarDomain.icon(
                    item.catalogItem?.domain ?? collection.domain,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        collection.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: PulsarWorkStatus.all.contains(status.value)
                  ? status.value
                  : PulsarWorkStatus.watching,
              decoration: InputDecoration(labelText: 'pulsarStatus'.tr()),
              items: [
                for (final s in PulsarWorkStatus.all)
                  DropdownMenuItem(
                    value: s,
                    child: Text(PulsarWorkStatus.label(s)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) status.value = v;
              },
            ),
            DropdownButtonFormField<int?>(
              initialValue: rating.value,
              decoration: InputDecoration(labelText: 'pulsarRating'.tr()),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('-')),
                for (var r = 10; r >= 1; r--)
                  DropdownMenuItem<int?>(value: r, child: Text('★ $r / 10')),
              ],
              onChanged: (v) => rating.value = v,
            ),
            if (collection.domain == PulsarDomain.book)
              Row(
                spacing: SolSpace.md,
                children: [
                  Expanded(
                    child: TextField(
                      controller: progressController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'pulsarProgressChapters'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: volumeProgressController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'pulsarProgressVolumes'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'pulsarNote'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            FilledButton(
              onPressed: isSubmitting.value ? null : save,
              child: isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('save'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualScrobbleSheet extends HookConsumerWidget {
  final String uname;
  final String initialDomain;

  const _ManualScrobbleSheet({
    required this.uname,
    required this.initialDomain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domain = useState(initialDomain);
    final selectedMeta = useState<PulsarCatalogItem?>(null);
    final titleController = useTextEditingController();
    final subtitleController = useTextEditingController();
    final captionController = useTextEditingController();
    final minutesController = useTextEditingController();
    final isSubmitting = useState(false);

    void applyMeta(PulsarCatalogItem? item) {
      selectedMeta.value = item;
      if (item != null) {
        titleController.text = item.title;
        subtitleController.text = item.subtitle ?? '';
        if (item.caption != null && item.caption!.isNotEmpty) {
          captionController.text = item.caption!;
        }
        if (item.durationSeconds > 0 && minutesController.text.trim().isEmpty) {
          minutesController.text = ((item.durationSeconds + 59) ~/ 60)
              .toString();
        }
      }
    }

    Future<void> submit() async {
      final title = titleController.text.trim();
      if (title.isEmpty) return;
      final minutes = int.tryParse(minutesController.text.trim()) ?? 0;
      final seconds = minutes > 0 ? minutes * 60 : 0;
      final meta = selectedMeta.value;
      isSubmitting.value = true;
      try {
        await ref
            .read(pulsarClientProvider)
            .submitScrobble(
              domain: domain.value,
              title: title,
              subtitle: subtitleController.text.trim().isEmpty
                  ? null
                  : subtitleController.text.trim(),
              caption: captionController.text.trim().isEmpty
                  ? null
                  : captionController.text.trim(),
              artworkUrl: meta == null
                  ? null
                  : PulsarArtwork.catalogUrls(
                      meta,
                      serverUrl: ref.watch(serverUrlProvider),
                    ).firstOrNull,
              catalogId: meta?.id,
              urn: meta?.urn,
              listenedSeconds: seconds,
              durationSeconds: meta?.durationSeconds ?? seconds,
            );
        ref.invalidate(pulsarUserHistoryProvider);
        ref.invalidate(pulsarUserStatsProvider(uname));
        if (context.mounted) Navigator.of(context).pop();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isSubmitting.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'pulsarManualScrobble'.tr(),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SolSpace.lg,
          SolSpace.md,
          SolSpace.lg,
          MediaQuery.viewInsetsOf(context).bottom + SolSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SolSpace.md,
          children: [
            DropdownButtonFormField<String>(
              initialValue: domain.value,
              decoration: InputDecoration(labelText: 'pulsarDomain'.tr()),
              items: [
                for (final d in PulsarDomain.all)
                  DropdownMenuItem(
                    value: d,
                    child: Text(PulsarDomain.label(d)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) domain.value = v;
              },
            ),
            _MetadataSearchSection(
              domain: domain.value,
              selected: selectedMeta.value,
              onSelect: applyMeta,
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'pulsarWorkTitle'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: subtitleController,
              decoration: InputDecoration(
                labelText: 'pulsarWorkSubtitle'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: captionController,
              decoration: InputDecoration(
                labelText: 'pulsarWorkCaption'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'pulsarDurationMinutes'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            FilledButton(
              onPressed: isSubmitting.value ? null : submit,
              child: isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('save'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataSearchSection extends HookConsumerWidget {
  final String domain;
  final PulsarCatalogItem? selected;
  final ValueChanged<PulsarCatalogItem?> onSelect;

  const _MetadataSearchSection({
    required this.domain,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchController = useTextEditingController();
    final results = useState<List<PulsarCatalogItem>>([]);
    final isSearching = useState(false);
    final hasSearched = useState(false);

    Future<void> runSearch() async {
      final query = searchController.text.trim();
      if (query.isEmpty) return;
      isSearching.value = true;
      hasSearched.value = true;
      try {
        final found = await ref
            .read(pulsarClientProvider)
            .searchMetadata(query, domain: domain);
        if (context.mounted) {
          results.value = found;
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) isSearching.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SolSpace.sm,
      children: [
        if (selected != null)
          Container(
            padding: const EdgeInsets.all(SolSpace.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(SolRadius.sm),
            ),
            child: Row(
              spacing: SolSpace.md,
              children: [
                _ManageArtworkThumb(
                  artwork: PulsarArtwork.catalogUrls(
                    selected,
                    serverUrl: ref.watch(serverUrlProvider),
                  ),
                  fallbackIcon: PulsarDomain.icon(selected!.domain),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected!.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (selected!.subtitle != null &&
                          selected!.subtitle!.isNotEmpty)
                        Text(
                          selected!.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Symbols.close, size: 18),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onSelect(null),
                ),
              ],
            ),
          )
        else
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => runSearch(),
            decoration: InputDecoration(
              labelText: 'pulsarSearchMetadata'.tr(),
              hintText: 'pulsarSearchHint'.tr(),
              border: const OutlineInputBorder(),
              suffixIcon: isSearching.value
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Symbols.search),
                      onPressed: runSearch,
                    ),
            ),
          ),
        if (selected == null && hasSearched.value && !isSearching.value)
          if (results.value.isEmpty)
            Text(
              'pulsarNoResults'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Material(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(SolRadius.sm),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: SolSpace.xs),
                  itemCount: results.value.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = results.value[index];
                    return ListTile(
                      dense: true,
                      leading: _ManageArtworkThumb(
                        artwork: PulsarArtwork.catalogUrls(
                          item,
                          serverUrl: ref.watch(serverUrlProvider),
                        ),
                        fallbackIcon: PulsarDomain.icon(item.domain),
                      ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle:
                          (item.subtitle != null &&
                                  item.subtitle!.isNotEmpty) ||
                              (item.releaseDate != null &&
                                  item.releaseDate!.isNotEmpty)
                          ? Text(
                              [
                                if (item.subtitle != null &&
                                    item.subtitle!.isNotEmpty)
                                  item.subtitle!,
                                if (item.releaseDate != null &&
                                    item.releaseDate!.isNotEmpty)
                                  item.releaseDate!,
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        onSelect(item);
                        results.value = const [];
                        hasSearched.value = false;
                      },
                    );
                  },
                ),
              ),
            ),
      ],
    );
  }
}
