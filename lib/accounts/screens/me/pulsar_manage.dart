import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/activity/pulsar_models.dart';
import 'package:island/activity/pulsar_pod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

@RoutePage()
class PulsarManageScreen extends HookConsumerWidget {
  const PulsarManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final uname = user.value?.name ?? 'me';
    final favDomain = useState<String>(PulsarDomain.music);
    final statusFilter = useState<String?>(null);
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
      ref.invalidate(pulsarBangumiConnectionProvider);
      for (final domain in PulsarDomain.mediaDomains) {
        ref.invalidate(pulsarFavouritesProvider(domain));
      }
      await Future.wait([
        ref.read(pulsarMyWorkCollectionsProvider.future),
        ref.read(pulsarBangumiConnectionProvider.future),
        ref.read(pulsarFavouritesProvider(favDomain.value).future),
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
              const _BangumiSyncCard(),
              _FavoritesManageCard(
                selectedDomain: favDomain.value,
                onDomainChanged: (d) => favDomain.value = d,
              ),
              _WorkStatusesManageCard(
                statusFilter: statusFilter.value,
                onStatusFilterChanged: (s) => statusFilter.value = s,
              ),
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

class _ManageArtworkThumb extends StatelessWidget {
  final String? url;
  final IconData fallbackIcon;
  static const double _size = 44;

  const _ManageArtworkThumb({required this.url, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SolRadius.sm),
      ),
      child: Icon(
        fallbackIcon,
        size: _size * 0.48,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    if (url == null || url!.isEmpty || !url!.startsWith('http')) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(SolRadius.sm),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => placeholder,
        placeholder: (_, _) => placeholder,
      ),
    );
  }
}

class _BangumiSyncCard extends HookConsumerWidget {
  const _BangumiSyncCard();

  String _policyLabel(String value) {
    return switch (value) {
      'local' => 'pulsarBangumiConflictLocal'.tr(),
      'newest' => 'pulsarBangumiConflictNewest'.tr(),
      _ => 'pulsarBangumiConflictRemote'.tr(),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(pulsarBangumiConnectionProvider);
    final busy = useState(false);

    Future<void> run(Future<void> Function() action) async {
      if (busy.value) return;
      busy.value = true;
      try {
        await action();
      } catch (err) {
        if (context.mounted) showErrorAlert(err);
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    Future<void> link() async {
      final client = ref.read(pulsarClientProvider);
      try {
        showLoadingModal(context);
        final url = await client.startBangumiOAuth();
        if (!context.mounted) return;
        hideLoadingModal(context);
        if (url.isEmpty) {
          showSnackBar('pulsarBangumiSyncFailed'.tr());
          return;
        }
        final launched = await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          showSnackBar('pulsarBangumiSyncFailed'.tr());
          return;
        }
        if (context.mounted) {
          showSnackBar('pulsarBangumiLinkHint'.tr());
          ref.invalidate(pulsarBangumiConnectionProvider);
        }
      } catch (err) {
        if (context.mounted) {
          hideLoadingModal(context);
          showErrorAlert(err);
        }
      }
    }

    Future<void> syncNow() async {
      showLoadingModal(context);
      try {
        final result = await ref.read(pulsarClientProvider).syncBangumiNow();
        if (!context.mounted) return;
        showSnackBar(
          '${'pulsarBangumiSyncDone'.tr()} · ${result.pulled}↓ ${result.pushed}↑',
        );
        ref.invalidate(pulsarBangumiConnectionProvider);
        ref.invalidate(pulsarMyWorkCollectionsProvider);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> unlink() async {
      final confirmed = await showConfirmAlert(
        'pulsarBangumiUnlinkConfirm'.tr(),
        'pulsarBangumiUnlink'.tr(),
        isDanger: true,
      );
      if (!confirmed) return;
      await run(() async {
        await ref.read(pulsarClientProvider).unlinkBangumi();
        ref.invalidate(pulsarBangumiConnectionProvider);
      });
    }

    Future<void> update({bool? syncEnabled, String? conflictPolicy}) async {
      await run(() async {
        await ref
            .read(pulsarClientProvider)
            .updateBangumiConnection(
              syncEnabled: syncEnabled,
              conflictPolicy: conflictPolicy,
            );
        ref.invalidate(pulsarBangumiConnectionProvider);
      });
    }

    return _PulsarManageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ManageSectionHeader(
            icon: Symbols.sync_alt,
            title: 'pulsarBangumiSync'.tr(),
            trailing: connectionAsync.value?.linked == true
                ? Badge(
                    label: Text(connectionAsync.value!.remoteUsername),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                  )
                : null,
          ),
          const Gap(SolSpace.md),
          connectionAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(SolSpace.md),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Text(
              err.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            data: (connection) {
              if (!connection.configured) {
                return Text(
                  'pulsarBangumiNotConfigured'.tr(),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }
              if (!connection.linked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'pulsarBangumiDescription'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Gap(SolSpace.md),
                    FilledButton.tonalIcon(
                      onPressed: busy.value ? null : link,
                      icon: const Icon(Symbols.link),
                      label: Text('pulsarBangumiLink'.tr()),
                    ),
                  ],
                );
              }

              final avatarUrl = connection.avatarUrl;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: avatarUrl.startsWith('http')
                            ? CachedNetworkImageProvider(avatarUrl)
                            : null,
                        child: avatarUrl.startsWith('http')
                            ? null
                            : const Icon(Symbols.person),
                      ),
                      const Gap(SolSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connection.nickname.isNotEmpty
                                  ? connection.nickname
                                  : connection.remoteUsername,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '@${connection.remoteUsername}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (connection.lastSyncedAt != null)
                        Text(
                          '${'pulsarBangumiLastSynced'.tr()}\n${connection.lastSyncedAt!.formatSystem()}',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.labelSmall,
                        )
                      else
                        Text(
                          'pulsarBangumiNeverSynced'.tr(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                    ],
                  ),
                  if (connection.collections.isNotEmpty) ...[
                    const Gap(SolSpace.md),
                    Text(
                      'pulsarBangumiCollections'.tr(),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const Gap(SolSpace.xs),
                    Wrap(
                      spacing: SolSpace.xs,
                      runSpacing: SolSpace.xs,
                      children: [
                        for (final collection in connection.collections)
                          Chip(
                            label: Text(
                              '${PulsarDomain.label(collection.domain)} · ${collection.items}',
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                  const Gap(SolSpace.sm),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text('pulsarBangumiSyncEnabled'.tr()),
                    value: connection.syncEnabled,
                    onChanged: busy.value
                        ? null
                        : (value) => update(syncEnabled: value),
                  ),
                  DropdownButtonFormField<String>(
                    key: ValueKey(connection.conflictPolicy),
                    initialValue: connection.conflictPolicy,
                    decoration: InputDecoration(
                      labelText: 'pulsarBangumiConflictPolicy'.tr(),
                    ),
                    items: [
                      for (final policy in const ['remote', 'local', 'newest'])
                        DropdownMenuItem(
                          value: policy,
                          child: Text(_policyLabel(policy)),
                        ),
                    ],
                    onChanged: busy.value
                        ? null
                        : (value) {
                            if (value != null) {
                              update(conflictPolicy: value);
                            }
                          },
                  ),
                  if (connection.lastError.isNotEmpty) ...[
                    const Gap(SolSpace.sm),
                    Text(
                      connection.lastError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const Gap(SolSpace.md),
                  Wrap(
                    spacing: SolSpace.sm,
                    runSpacing: SolSpace.sm,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: busy.value ? null : syncNow,
                        icon: const Icon(Symbols.sync),
                        label: Text('pulsarBangumiSyncNow'.tr()),
                      ),
                      TextButton.icon(
                        onPressed: busy.value ? null : unlink,
                        icon: const Icon(Symbols.link_off),
                        label: Text('pulsarBangumiUnlink'.tr()),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FavoritesManageCard extends HookConsumerWidget {
  final String selectedDomain;
  final ValueChanged<String> onDomainChanged;

  const _FavoritesManageCard({
    required this.selectedDomain,
    required this.onDomainChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favsAsync = ref.watch(pulsarFavouritesProvider(selectedDomain));
    final visibleCount = useState(5);

    Future<void> removeFavorite(PulsarCollectionItem item) async {
      final catalogId = item.catalogId ?? item.catalogItem?.id;
      if (catalogId == null || catalogId.isEmpty) return;
      try {
        await ref
            .read(pulsarClientProvider)
            .unsetFavourite(catalogId, domain: selectedDomain);
        ref.invalidate(pulsarFavouritesProvider(selectedDomain));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> openAddFavoriteSheet() async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => _AddFavoriteSheet(initialDomain: selectedDomain),
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
          child: _FullFavoritesSheetBody(initialDomain: selectedDomain),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: SolSpace.xs,
              children: [
                for (final domain in PulsarDomain.mediaDomains)
                  ChoiceChip(
                    selected: selectedDomain == domain,
                    onSelected: (_) => onDomainChanged(domain),
                    avatar: Icon(PulsarDomain.icon(domain), size: 16),
                    label: Text(PulsarDomain.label(domain)),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          favsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  'pulsarFavoritesEmpty'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }
              final visibleItems = items.take(visibleCount.value).toList();
              return Column(
                spacing: SolSpace.sm,
                children: [
                  for (final item in visibleItems)
                    Row(
                      spacing: SolSpace.md,
                      children: [
                        _ManageArtworkThumb(
                          url: item.displayArtwork,
                          fallbackIcon: PulsarDomain.icon(selectedDomain),
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
                    ),
                  if (items.length > visibleCount.value)
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: openFullFavorites,
                        child: Text('pulsarShowMore'.tr()),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(SolSpace.sm),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
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
  final String? statusFilter;
  final ValueChanged<String?> onStatusFilterChanged;

  const _WorkStatusesManageCard({
    required this.statusFilter,
    required this.onStatusFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionsAsync = ref.watch(pulsarMyWorkCollectionsProvider);
    final visibleCount = useState(5);

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
          child: _FullWorkStatusesSheetBody(initialStatus: statusFilter),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: SolSpace.xs,
              children: [
                ChoiceChip(
                  selected: statusFilter == null,
                  onSelected: (_) {
                    visibleCount.value = 5;
                    onStatusFilterChanged(null);
                  },
                  label: Text('all'.tr()),
                  visualDensity: VisualDensity.compact,
                ),
                for (final status in PulsarWorkStatus.all)
                  ChoiceChip(
                    selected: statusFilter == status,
                    onSelected: (_) {
                      visibleCount.value = 5;
                      onStatusFilterChanged(status);
                    },
                    avatar: Icon(PulsarWorkStatus.icon(status), size: 16),
                    label: Text(PulsarWorkStatus.label(status)),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          collectionsAsync.when(
            data: (collections) {
              final entries =
                  <({PulsarCollection col, PulsarCollectionItem item})>[];
              for (final col in collections) {
                for (final item in col.items) {
                  if (statusFilter != null && item.status != statusFilter) {
                    continue;
                  }
                  if (statusFilter == null &&
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
                return Text(
                  'pulsarWorkStatusesEmpty'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }

              final visibleEntries = entries.take(visibleCount.value).toList();
              return Column(
                spacing: SolSpace.sm,
                children: [
                  for (final entry in visibleEntries)
                    InkWell(
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
                              url: entry.item.displayArtwork,
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
                                          entry
                                              .item
                                              .displaySubtitle!
                                              .isNotEmpty)
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
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
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
                    ),
                  if (entries.length > visibleCount.value)
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: openFullWorkStatuses,
                        child: Text('pulsarShowMore'.tr()),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(SolSpace.sm),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
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
              artworkUrl: scrobble.effectiveArtworkUrl,
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
          initialArtworkUrl: scrobble.effectiveArtworkUrl,
        ),
      );
    }

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: SolSpace.xs,
              children: [
                ChoiceChip(
                  selected: selectedDomain == null,
                  onSelected: (_) => onDomainChanged(null),
                  label: Text('all'.tr()),
                  visualDensity: VisualDensity.compact,
                ),
                for (final domain in PulsarDomain.mediaDomains)
                  ChoiceChip(
                    selected: selectedDomain == domain,
                    onSelected: (_) => onDomainChanged(domain),
                    avatar: Icon(PulsarDomain.icon(domain), size: 16),
                    label: Text(PulsarDomain.label(domain)),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          historyAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  'pulsarHistoryEmpty'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }
              return Column(
                spacing: SolSpace.sm,
                children: [
                  for (final s in items)
                    Row(
                      spacing: SolSpace.md,
                      children: [
                        _ManageArtworkThumb(
                          url: s.effectiveArtworkUrl,
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
                    ),
                  if (items.length >= 10)
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: openFullHistory,
                        child: Text('pulsarShowMore'.tr()),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(SolSpace.sm),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
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
              artworkUrl: meta?.artworkUrl,
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
          artworkUrl: meta?.artworkUrl ?? initialArtworkUrl,
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
                        url: item.displayArtwork,
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
                            url: entry.item.displayArtwork,
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
              artworkUrl: scrobble.effectiveArtworkUrl,
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
          initialArtworkUrl: scrobble.effectiveArtworkUrl,
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
                          url: s.effectiveArtworkUrl,
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
              artworkUrl: item.displayArtwork,
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
                  url: item.displayArtwork,
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
              artworkUrl: meta?.artworkUrl,
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
                  url: selected!.artworkUrl,
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
                        url: item.artworkUrl,
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
