import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/screens/credits.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:easy_localization/easy_localization.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final levelingHistoryNotifierProvider =
    AsyncNotifierProvider.autoDispose<
      LevelingHistoryNotifier,
      PaginationState<SnExperienceRecord>
    >(LevelingHistoryNotifier.new);

class LevelingHistoryNotifier
    extends AsyncNotifier<PaginationState<SnExperienceRecord>>
    with AsyncPaginationController<SnExperienceRecord> {
  static const int pageSize = 20;

  @override
  FutureOr<PaginationState<SnExperienceRecord>> build() async {
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
  Future<List<SnExperienceRecord>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {'offset': fetchedCount.toString(), 'take': pageSize};

    final response = await client.get(
      '/passport/accounts/me/leveling',
      queryParameters: queryParams,
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');

    final List<SnExperienceRecord> records = response.data
        .map((json) => SnExperienceRecord.fromJson(json))
        .cast<SnExperienceRecord>()
        .toList();

    return records;
  }
}

const _kTotalLevels = 120;

const _stageColors = [
  Colors.green,
  Colors.blue,
  Colors.teal,
  Colors.cyan,
  Colors.indigo,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.pink,
  Colors.red,
];

int _stageOf(int level) => ((level - 1) ~/ 10 + 1).clamp(1, 12);

String _formatExp(int exp) {
  if (exp >= 1000000) return '${(exp / 1000000).toStringAsFixed(1)}M';
  if (exp >= 1000) return '${(exp / 1000).toStringAsFixed(1)}K';
  return exp.toString();
}

@RoutePage()
class LevelingScreen extends HookConsumerWidget {
  const LevelingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    if (user.value == null) {
      return AppScaffold(
        appBar: AppBar(title: Text('levelingProgress'.tr())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          title: Text('levelingProgress'.tr()),
          leading: const AutoLeadingButton(),
          bottom: TabBar(
            tabs: [
              Tab(child: Text('leveling'.tr())),
              Tab(child: Text('socialCredits'.tr())),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLevelingTab(context, ref, user.value!),
            const SocialCreditsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelingTab(
    BuildContext context,
    WidgetRef ref,
    SnAccount user,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLevel = user.profile.level;
    final currentExp = user.profile.experience;
    final progress = user.profile.levelingProgress;
    final stage = _stageOf(currentLevel);
    final stageColor = _stageColors[stage - 1];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'levelingStage$stage'.tr(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: stageColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$currentLevel',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ $_kTotalLevels',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: stageColor,
                    stopIndicatorColor: stageColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'levelingProgressExperience'.tr(args: [
                        _formatExp(currentExp),
                      ]),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      '${(progress * 100).clamp(0, 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
            child: Text(
              'levelingHistory'.tr(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        PaginationList(
          provider: levelingHistoryNotifierProvider,
          notifier: levelingHistoryNotifierProvider.notifier,
          isRefreshable: false,
          isSliver: true,
          itemBuilder: (context, idx, record) {
            final isGain = record.delta > 0;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(record.reason),
              subtitle: Text(record.createdAt.formatRelative(context)),
              minTileHeight: 56,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isGain ? '+' : ''}${record.delta}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontFeatures: [const FontFeature.tabularFigures()],
                          color: isGain ? null : colorScheme.error,
                        ),
                  ),
                  if (record.bonusMultiplier != 1.0)
                    Text(
                      '×${record.bonusMultiplier}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}
