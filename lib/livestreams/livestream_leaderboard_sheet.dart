import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'livestream_leaderboard_sheet.freezed.dart';
part 'livestream_leaderboard_sheet.g.dart';

final livestreamLeaderboardProvider = FutureProvider.autoDispose
    .family<List<LivestreamAwardLeaderboardEntry>, String>((
      ref,
      livestreamId,
    ) async {
      final client = ref.watch(apiClientProvider);
      try {
        final response = await client.get(
          '/sphere/livestreams/$livestreamId/awards/leaderboard',
          queryParameters: {'limit': 10},
        );
        final data = response.data as List;
        return data
            .map(
              (e) => LivestreamAwardLeaderboardEntry.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      } catch (_) {
        return [];
      }
    });

@freezed
abstract class LivestreamAwardLeaderboardEntry
    with _$LivestreamAwardLeaderboardEntry {
  const factory LivestreamAwardLeaderboardEntry({
    @Default(0) int rank,
    @JsonKey(name: 'account_id') @Default('') String accountId,
    @JsonKey(name: 'sender_name') @Default('Unknown') String senderName,
    @JsonKey(name: 'total_amount') @Default(0.0) double totalAmount,
    @JsonKey(name: 'award_count') @Default(0) int awardCount,
    SnAccount? account,
  }) = _LivestreamAwardLeaderboardEntry;

  factory LivestreamAwardLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LivestreamAwardLeaderboardEntryFromJson(json);
}

class LivestreamLeaderboardSheet extends ConsumerWidget {
  final String livestreamId;

  const LivestreamLeaderboardSheet({super.key, required this.livestreamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(
      livestreamLeaderboardProvider(livestreamId),
    );

    return SheetScaffold(
      titleText: 'livestreamLeaderboard'.tr(),
      child: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.error_outline, size: 48),
              const Gap(12),
              Text('errorLoadingLeaderboard'.tr()),
            ],
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.emoji_events, size: 48),
                  const Gap(12),
                  Text('noAwardsYet'.tr()),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _LeaderboardItem(entry: entry);
            },
          );
        },
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final LivestreamAwardLeaderboardEntry entry;

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
      1 => Icons.emoji_events,
      2 => Icons.emoji_events,
      3 => Icons.emoji_events,
      _ => null,
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
            if (entry.account?.profile.picture != null)
              ProfilePictureWidget(
                file: entry.account!.profile.picture,
                radius: 18,
              )
            else
              CircleAvatar(
                radius: 18,
                child: Text(
                  entry.senderName.isNotEmpty
                      ? entry.senderName[0].toUpperCase()
                      : '?',
                ),
              ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.account != null)
                    AccountName(
                      account: entry.account!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  else
                    Text(
                      entry.senderName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  Text(
                    'awardCount'.tr(args: ['${entry.awardCount}']),
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
                Text(
                  '${entry.totalAmount.toStringAsFixed(0)} NSP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
