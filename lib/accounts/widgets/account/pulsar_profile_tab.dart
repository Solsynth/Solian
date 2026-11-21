import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_nameplate.dart';
import 'package:island/accounts/widgets/account/pulsar_shelf.dart';
import 'package:island/activity/pulsar_artwork.dart';
import 'package:island/activity/pulsar_models.dart';
import 'package:island/activity/pulsar_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Read-only Solink tab for viewing any user's profile: what they are playing
/// now, what they play most, the works they are working through, and their
/// recent history.
///
/// Everything here is a shelf: the subjects are things a person collects, so
/// they are shown as covers standing on a ledge rather than as rows of text.
class PulsarProfileTab extends HookConsumerWidget {
  final String uname;

  /// Whether this is the signed-in account's own profile. Work statuses come
  /// from the account's own collections, which the server only exposes to that
  /// account, so they are shown on one's own profile only.
  final bool showWorkStatuses;
  final Future<void> Function() onRefresh;

  const PulsarProfileTab({
    super.key,
    required this.uname,
    this.showWorkStatuses = false,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlayingAsync = ref.watch(pulsarUserNowPlayingProvider(uname));
    final statsAsync = ref.watch(pulsarUserStatsProvider(uname));
    final historyDomain = useState<String?>(null);
    final historyAsync = ref.watch(
      pulsarUserHistoryProvider((
        uname: uname,
        domain: historyDomain.value,
        take: 10,
      )),
    );
    final serverUrl = ref.watch(serverUrlProvider);
    final collections = showWorkStatuses
        ? ref.watch(pulsarMyWorkCollectionsProvider).asData?.value
        : null;

    final fallbackArtworks =
        <String, ({List<String> urls, String? domain})>{};
    void addFallback(String? title, List<String> urls, String? domain) {
      final key = title?.trim().toLowerCase();
      if (key == null || key.isEmpty || urls.isEmpty) return;
      fallbackArtworks.putIfAbsent(key, () => (urls: urls, domain: domain));
    }

    for (final s in nowPlayingAsync.asData?.value ?? const <SnPresenceActivity>[]) {
      addFallback(
        s.title,
        PulsarArtwork.presenceUrls(s, serverUrl: serverUrl),
        s.type,
      );
    }
    for (final s in historyAsync.asData?.value ?? const <PulsarScrobble>[]) {
      addFallback(
        s.title,
        PulsarArtwork.scrobbleUrls(s, serverUrl: serverUrl),
        s.domain,
      );
    }
    for (final col in collections ?? const <PulsarCollection>[]) {
      for (final item in col.items) {
        addFallback(
          item.displayTitle,
          PulsarArtwork.collectionUrls(item, serverUrl: serverUrl),
          item.catalogItem?.domain ?? col.domain,
        );
      }
    }

    return ExtendedRefreshIndicator(
      onRefresh: onRefresh,
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
            nowPlayingAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) return const SizedBox.shrink();
                return _NowPlayingCard(sessions: sessions);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            if (showWorkStatuses) _WorkStatusesCard(uname: uname),
            statsAsync.when(
              data: (stats) => _StatsCard(
                stats: stats,
                fallbackArtworks: fallbackArtworks,
              ),
              loading: () => const _SectionLoadingCard(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            _HistoryCard(
              uname: uname,
              selectedDomain: historyDomain.value,
              onDomainChanged: (d) => historyDomain.value = d,
              historyAsync: historyAsync,
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsarCard extends StatelessWidget {
  final Widget child;
  const _PulsarCard({required this.child});

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

class _SectionLoadingCard extends StatelessWidget {
  const _SectionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const _PulsarCard(child: PulsarShelfLoading());
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _SectionHeader({
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

class _NowPlayingCard extends ConsumerWidget {
  final List<SnPresenceActivity> sessions;
  const _NowPlayingCard({required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serverUrl = ref.watch(serverUrlProvider);

    return _PulsarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SolSpace.sm,
        children: [
          _SectionHeader(
            icon: Symbols.podcasts,
            title: 'pulsarNowPlaying'.tr(),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SolSpace.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(SolRadius.chip),
              ),
              child: Text(
                '${sessions.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          PulsarShelf(
            aspectRatio: 2 / 3,
            tileWidth: 104,
            entries: [
              for (final s in sessions)
                PulsarShelfEntry(
                  title: s.title ?? 'Unknown',
                  subtitle: (s.subtitle?.isNotEmpty ?? false)
                      ? s.subtitle
                      : s.caption,
                  artwork: PulsarArtwork.presenceUrls(s, serverUrl: serverUrl),
                  fallbackIcon: PulsarDomain.icon(_presenceDomain(s)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _presenceDomain(SnPresenceActivity session) {
    // Pulsar sessions already carry the media domain as their type; the
    // presence taxonomy collapses video/anime onto `entertainment`, so read
    // the domain back off the caption-less fallback order.
    return switch (session.type) {
      'entertainment' => PulsarDomain.video,
      'reading' => PulsarDomain.book,
      'other' => PulsarDomain.custom,
      final value => value,
    };
  }
}

class _StatsCard extends ConsumerWidget {
  final PulsarMediaStats? stats;
  final Map<String, ({List<String> urls, String? domain})> fallbackArtworks;
  const _StatsCard({required this.stats, this.fallbackArtworks = const {}});

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (stats == null || stats!.totalScrobbles == 0) {
      return _PulsarCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SolSpace.sm,
          children: [
            _SectionHeader(icon: Symbols.equalizer, title: 'pulsarStats'.tr()),
            Text(
              'pulsarStatsEmpty'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final data = stats!;
    final serverUrl = ref.watch(serverUrlProvider);

    return _PulsarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SolSpace.md,
        children: [
          _SectionHeader(icon: Symbols.equalizer, title: 'pulsarStats'.tr()),
          Row(
            spacing: SolSpace.sm,
            children: [
              Expanded(
                child: _StatMetricTile(
                  label: 'pulsarTotalScrobbles'.tr(),
                  value: '${data.totalScrobbles}',
                ),
              ),
              Expanded(
                child: _StatMetricTile(
                  label: 'pulsarTotalTime'.tr(),
                  value: _formatDuration(data.totalSeconds),
                ),
              ),
              Expanded(
                child: _StatMetricTile(
                  label: 'pulsarDaysActive'.tr(),
                  value: '${data.daysActive}',
                ),
              ),
            ],
          ),
          if (data.domainBreakdown.isNotEmpty)
            Wrap(
              spacing: SolSpace.xs,
              runSpacing: SolSpace.xs,
              children: [
                for (final entry in data.domainBreakdown.entries)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(PulsarDomain.icon(entry.key), size: 16),
                    label: Text(
                      '${PulsarDomain.label(entry.key)} · ${entry.value}',
                    ),
                  ),
              ],
            ),
          if (data.topItems.isNotEmpty) ...[
            Text(
              'pulsarTopWorks'.tr(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            PulsarShelf(
              aspectRatio: 1,
              tileWidth: 96,
              entries: [
                for (final item in data.topItems.take(10))
                  () {
                    final directArtwork = PulsarArtwork.topEntityUrls(
                      item,
                      serverUrl: serverUrl,
                    );
                    final fallback =
                        fallbackArtworks[item.name.trim().toLowerCase()];
                    final artwork = directArtwork.isNotEmpty
                        ? directArtwork
                        : (fallback?.urls ?? const <String>[]);
                    final domain =
                        item.domain ??
                        item.catalogItem?.domain ??
                        fallback?.domain;
                    return PulsarShelfEntry(
                      title: item.name,
                      subtitle: item.subtitle,
                      artwork: artwork,
                      fallbackIcon: domain != null
                          ? PulsarDomain.icon(domain)
                          : Symbols.equalizer,
                      cornerLabel: '${item.count}×',
                    );
                  }(),
              ],
            ),
          ],
          if (data.topCreators.isNotEmpty) ...[
            Text(
              'pulsarTopCreators'.tr(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Wrap(
              spacing: SolSpace.xs,
              runSpacing: SolSpace.xs,
              children: [
                for (final c in data.topCreators.take(6))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SolSpace.sm,
                      vertical: SolSpace.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(SolRadius.chip),
                    ),
                    child: Text(
                      '${c.name} (${c.count})',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatMetricTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatMetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SolSpace.md,
        vertical: SolSpace.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SolRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The account's tracked works, one shelf per collection.
///
/// Only shown on your own profile: Pulsar keeps collections private to their
/// owner and exposes no per-account listing, so another viewer has no way to
/// read these.
class _WorkStatusesCard extends HookConsumerWidget {
  final String uname;
  const _WorkStatusesCard({required this.uname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionsAsync = ref.watch(pulsarMyWorkCollectionsProvider);

    return _PulsarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SolSpace.md,
        children: [
          _SectionHeader(
            icon: Symbols.checklist,
            title: 'pulsarWorkStatuses'.tr(),
          ),
          collectionsAsync.when(
            data: (collections) {
              final shelves =
                  <
                    ({PulsarCollection col, List<PulsarCollectionItem> items})
                  >[];
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
                      entries: [
                        for (final item in shelf.items)
                          () {
                            final hasNote =
                                item.note != null &&
                                item.note!.trim().isNotEmpty;
                            return PulsarShelfEntry(
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
                              actionIcon: hasNote
                                  ? Symbols.sticky_note_2
                                  : null,
                              actionTooltip: hasNote
                                  ? 'pulsarNote'.tr()
                                  : null,
                              onAction: hasNote
                                  ? () => _showWorkNoteSheet(
                                      context,
                                      item,
                                      shelf.col,
                                      serverUrl,
                                      uname: uname,
                                    )
                                  : null,
                              onTap: hasNote
                                  ? () => _showWorkNoteSheet(
                                      context,
                                      item,
                                      shelf.col,
                                      serverUrl,
                                      uname: uname,
                                    )
                                  : null,
                            );
                          }(),
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

void _showWorkNoteSheet(
  BuildContext context,
  PulsarCollectionItem item,
  PulsarCollection collection,
  String serverUrl, {
  required String uname,
}) {
  final note = item.note?.trim();
  if (note == null || note.isEmpty) return;

  final theme = Theme.of(context);
  final domain = item.catalogItem?.domain ?? collection.domain;
  final statusColor = PulsarWorkStatus.color(context, item.status);
  final metaParts = <String>[
    collection.name,
    if (item.displaySubtitle != null && item.displaySubtitle!.isNotEmpty)
      item.displaySubtitle!,
  ];

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => SheetScaffold(
      titleText: 'pulsarNote'.tr(),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SolSpace.lg,
          SolSpace.md,
          SolSpace.lg,
          MediaQuery.paddingOf(context).bottom + SolSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SolSpace.md,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SolSpace.md,
              children: [
                SizedBox(
                  width: 56,
                  height: domain == PulsarDomain.music ? 56 : 84,
                  child: PulsarCover(
                    artwork: PulsarArtwork.collectionUrls(
                      item,
                      serverUrl: serverUrl,
                    ),
                    fallbackIcon: PulsarDomain.icon(domain),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: SolSpace.xs,
                    children: [
                      Text(
                        item.displayTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (metaParts.isNotEmpty)
                        Text(
                          metaParts.join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (item.status != null || item.rating != null)
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
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(SolSpace.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(SolRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: SolSpace.sm,
                children: [
                  AccountNameplate(
                    name: uname,
                    isCompact: true,
                    isOutlined: false,
                    padding: EdgeInsets.zero,
                  ),
                  SelectableText(
                    note,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HistoryCard extends HookConsumerWidget {
  final String uname;
  final String? selectedDomain;
  final ValueChanged<String?> onDomainChanged;
  final AsyncValue<List<PulsarScrobble>> historyAsync;

  const _HistoryCard({
    required this.uname,
    required this.selectedDomain,
    required this.onDomainChanged,
    required this.historyAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serverUrl = ref.watch(serverUrlProvider);

    void openFullHistory() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => SheetScaffold(
          titleText: 'pulsarHistory'.tr(),
          child: _FullHistorySheetBody(
            uname: uname,
            initialDomain: selectedDomain,
          ),
        ),
      );
    }

    return _PulsarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SolSpace.md,
        children: [
          _SectionHeader(icon: Symbols.history, title: 'pulsarHistory'.tr()),
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

class _FullHistorySheetBody extends HookConsumerWidget {
  final String uname;
  final String? initialDomain;

  const _FullHistorySheetBody({
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
    final serverUrl = ref.watch(serverUrlProvider);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PulsarDomainFilterRow(
          selectedDomain: selectedDomain.value,
          domains: PulsarDomain.mediaDomains,
          includeAll: true,
          onChanged: (value) => selectedDomain.value = value,
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
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: PulsarCover(
                            artwork: PulsarArtwork.scrobbleUrls(
                              s,
                              serverUrl: serverUrl,
                            ),
                            fallbackIcon: PulsarDomain.icon(s.domain),
                          ),
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
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
