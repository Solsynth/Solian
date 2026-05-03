import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final publisherLeaderboardNotifierProvider =
    AsyncNotifierProvider<
      PublisherLeaderboardNotifier,
      PaginationState<SnPublisherLeaderboardEntry>
    >(PublisherLeaderboardNotifier.new);

class PublisherLeaderboardNotifier
    extends AsyncNotifier<PaginationState<SnPublisherLeaderboardEntry>>
    with AsyncPaginationController<SnPublisherLeaderboardEntry> {
  static const int pageSize = 20;

  @override
  FutureOr<PaginationState<SnPublisherLeaderboardEntry>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnPublisherLeaderboardEntry>> fetch() async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/sphere/publishers/leaderboard',
      queryParameters: {'offset': fetchedCount.toString(), 'take': pageSize},
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final entries = (response.data as List)
        .map(
          (e) => SnPublisherLeaderboardEntry.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
    return entries;
  }
}

class PublisherLeaderboardSheet extends ConsumerWidget {
  const PublisherLeaderboardSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardProvider = publisherLeaderboardNotifierProvider;

    return SheetScaffold(
      titleText: 'publisherLeaderboard'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Symbols.refresh),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          onPressed: () {
            ref.invalidate(leaderboardProvider);
          },
        ),
      ],
      child: PaginationList(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        provider: leaderboardProvider,
        notifier: leaderboardProvider.notifier,
        itemBuilder: (context, index, entry) {
          return _LeaderboardItem(entry: entry);
        },
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final SnPublisherLeaderboardEntry entry;

  const _LeaderboardItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isTopThree = entry.rank <= 3;
    final rankColor = switch (entry.rank) {
      1 => Colors.amber,
      2 => Colors.grey[400],
      3 => Colors.brown[300],
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    final rankIcon = switch (entry.rank) {
      1 => Symbols.emoji_events,
      2 => Symbols.emoji_events,
      3 => Symbols.emoji_events,
      _ => null,
    };

    final textColor = switch (entry.grade) {
      'S++' => Theme.of(context).colorScheme.tertiary,
      'S+' => Theme.of(context).colorScheme.tertiary,
      'S' => Theme.of(context).colorScheme.primary,
      'A++' => Theme.of(context).colorScheme.primary,
      'A+' => Theme.of(context).colorScheme.primary,
      'A' => Theme.of(context).colorScheme.primary,
      'A-' => Theme.of(context).colorScheme.primary,
      'B+' => Theme.of(context).colorScheme.secondary,
      'B' => Theme.of(context).colorScheme.secondary,
      'C' => Theme.of(context).colorScheme.onSurfaceVariant,
      'D' => Theme.of(context).colorScheme.error,
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: rankColor?.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isTopThree && rankIcon != null
                    ? Icon(rankIcon, color: rankColor, size: 20)
                    : Text(
                        '${entry.rank}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rankColor,
                        ),
                      ),
              ),
            ),
            const Gap(12),
            if (entry.picture != null)
              ProfilePictureWidget(file: entry.picture, radius: 18)
            else
              CircleAvatar(
                radius: 18,
                child: Text(
                  entry.nick.isNotEmpty ? entry.nick[0].toUpperCase() : '?',
                ),
              ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.nick,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '@${entry.name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: switch (entry.grade) {
                      'S++' => Theme.of(context).colorScheme.tertiaryContainer,
                      'S+' => Theme.of(context).colorScheme.tertiaryContainer,
                      'S' => Theme.of(context).colorScheme.primaryContainer,
                      'A++' => Theme.of(context).colorScheme.primaryContainer,
                      'A+' => Theme.of(context).colorScheme.primaryContainer,
                      'A' => Theme.of(context).colorScheme.primaryContainer,
                      'A-' => Theme.of(context).colorScheme.primaryContainer,
                      'B+' => Theme.of(context).colorScheme.secondaryContainer,
                      'B' => Theme.of(context).colorScheme.secondaryContainer,
                      'C' => Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      'D' => Theme.of(context).colorScheme.errorContainer,
                      _ => Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    },
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.grade,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: textColor,
                    ),
                  ),
                ),
                const Gap(4),
                Text(
                  _formatRating(entry.rating),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  'ratingPercentile'.tr(
                    args: [entry.percentile.toStringAsFixed(1)],
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatRating(double rating) {
    if (rating >= 1000000) {
      return '${(rating / 1000000).toStringAsFixed(1)}M';
    } else if (rating >= 1000) {
      return '${(rating / 1000).toStringAsFixed(1)}K';
    }
    return rating.toStringAsFixed(0);
  }
}
