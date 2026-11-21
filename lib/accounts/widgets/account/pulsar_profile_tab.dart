import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/activity/pulsar_models.dart';
import 'package:island/activity/pulsar_pod.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Read-only Pulsar tab for viewing any user's profile (now playing, stats,
/// and recent scrobble history).
class PulsarProfileTab extends HookConsumerWidget {
  final String uname;
  final Future<void> Function() onRefresh;

  const PulsarProfileTab({
    super.key,
    required this.uname,
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
            statsAsync.when(
              data: (stats) => _StatsCard(stats: stats),
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
    return const _PulsarCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: SolSpace.md),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

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
      ],
    );
  }
}

class _ArtworkThumb extends StatelessWidget {
  final String? url;
  final IconData fallbackIcon;
  final double size;

  const _ArtworkThumb({
    required this.url,
    required this.fallbackIcon,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SolRadius.sm),
      ),
      child: Icon(
        fallbackIcon,
        size: size * 0.48,
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
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => placeholder,
        placeholder: (_, _) => placeholder,
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  final List<SnPresenceActivity> sessions;
  const _NowPlayingCard({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PulsarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SolSpace.md,
        children: [
          _SectionHeader(
            icon: Symbols.podcasts,
            title: 'pulsarNowPlaying'.tr(),
          ),
          for (final s in sessions)
            Row(
              spacing: SolSpace.md,
              children: [
                _ArtworkThumb(
                  url: s.largeImage,
                  fallbackIcon: PulsarDomain.icon(s.type),
                  size: 48,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (s.subtitle != null && s.subtitle!.isNotEmpty)
                        Text(
                          s.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (s.caption != null && s.caption!.isNotEmpty)
                        Text(
                          s.caption!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SolSpace.sm,
                    vertical: SolSpace.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(SolRadius.chip),
                  ),
                  child: Text(
                    PulsarDomain.label(s.type),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final PulsarMediaStats? stats;
  const _StatsCard({required this.stats});

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (stats == null || stats!.totalScrobbles == 0) {
      return _PulsarCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SolSpace.sm,
          children: [
            _SectionHeader(
              icon: Symbols.equalizer,
              title: 'pulsarStats'.tr(),
            ),
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
    return _PulsarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: SolSpace.md,
        children: [
          _SectionHeader(
            icon: Symbols.equalizer,
            title: 'pulsarStats'.tr(),
          ),
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
            Column(
              spacing: SolSpace.xs,
              children: [
                for (var i = 0; i < data.topItems.take(5).length; i++)
                  Row(
                    spacing: SolSpace.sm,
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          '${i + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          data.topItems[i].subtitle?.isNotEmpty == true
                              ? '${data.topItems[i].name} — ${data.topItems[i].subtitle}'
                              : data.topItems[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        '${data.topItems[i].count}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
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

class _HistoryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          _SectionHeader(
            icon: Symbols.history,
            title: 'pulsarHistory'.tr(),
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
                        _ArtworkThumb(
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
                                  DateFormat.MMMd()
                                      .add_Hm()
                                      .format(s.playedAt.toLocal()),
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
    const pageSize = 20;

    Future<void> loadPage({required bool reset}) async {
      isLoading.value = true;
      final offset = reset ? 0 : items.value.length;
      try {
        final batch = await ref.read(pulsarClientProvider).getUserHistory(
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
                        _ArtworkThumb(
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
                                  DateFormat.MMMd()
                                      .add_Hm()
                                      .format(s.playedAt.toLocal()),
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
