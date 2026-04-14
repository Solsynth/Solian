import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/leveling_progress.dart';
import 'package:island/accounts/widgets/account/stellar_program_tab.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/screens/credits.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:easy_localization/easy_localization.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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
      length: 3,
      child: AppScaffold(
        appBar: AppBar(
          title: Text('levelingProgress'.tr()),
          leading: const AutoLeadingButton(),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'leveling'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor!,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'socialCredits'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor!,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'stellarProgram'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor!,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLevelingTab(context, ref, user.value!),
            const SocialCreditsTab(),
            const StellarProgramTab(),
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
    final currentLevel = user.profile.level;
    final currentExp = user.profile.experience;
    final progress = user.profile.levelingProgress;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LevelingProgressCard(
              level: currentLevel,
              experience: currentExp,
              progress: progress,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              spacing: 8,
              children: [
                const Icon(Symbols.stairs),
                Text(
                  'levelProgress'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'levelingProgressLevel'.tr(args: [currentLevel.toString()])} / 120',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: currentLevel / 120,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(32),
                      color: theme.colorScheme.primary,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              spacing: 8,
              children: [
                const Icon(Symbols.history),
                Text(
                  'levelingHistory'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        PaginationList(
          provider: levelingHistoryNotifierProvider,
          notifier: levelingHistoryNotifierProvider.notifier,
          isRefreshable: false,
          isSliver: true,
          itemBuilder: (context, idx, record) => ListTile(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(record.reason),
                const SizedBox(height: 4),
                Opacity(
                  opacity: 0.8,
                  child: Row(
                    children: [
                      Text(
                        record.createdAt.formatRelative(context),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const Text(' · ', style: TextStyle(fontSize: 13)),
                      Text(
                        record.createdAt.formatSystem(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Row(
              spacing: 4,
              children: [
                Text('${record.delta > 0 ? '+' : ''}${record.delta} EXP'),
                if (record.bonusMultiplier != 1.0)
                  Text('x${record.bonusMultiplier}'),
              ],
            ),
            minTileHeight: 56,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class LevelStairsPainter extends CustomPainter {
  final int currentLevel;
  final int totalLevels;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final double stairHeight;
  final double stairWidth;

  LevelStairsPainter({
    required this.currentLevel,
    required this.totalLevels,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.stairHeight,
    required this.stairWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = surfaceColor.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw connecting lines between stairs
    for (int i = 0; i < totalLevels - 1; i++) {
      final startX = 20.0 + (i * (stairWidth + 8)) + stairWidth;
      final startHeight =
          40.0 + (i * 15.0); // Progressive height for current stair
      final startY = size.height - (20.0 + startHeight);

      final endX = 20.0 + ((i + 1) * (stairWidth + 8));
      final endHeight =
          40.0 + ((i + 1) * 15.0); // Progressive height for next stair
      final endY = size.height - (20.0 + endHeight);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
