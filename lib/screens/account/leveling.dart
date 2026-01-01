import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/account/credits.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/leveling_progress.dart';
import 'package:island/widgets/account/stellar_program_tab.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:styled_widget/styled_widget.dart';

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
      '/pass/accounts/me/leveling',
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
    final currentLevel = user.profile.level;
    final currentExp = user.profile.experience;
    final progress = user.profile.levelingProgress;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomScrollView(
          slivers: [
            const SliverGap(20),

            // Current Progress Card
            SliverToBoxAdapter(
              child: LevelingProgressCard(
                level: currentLevel,
                experience: currentExp,
                progress: progress,
              ),
            ),
            const SliverGap(24),

            // Level Stairs Graph
            SliverToBoxAdapter(
              child: Text(
                'levelProgress'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SliverGap(16),

            SliverToBoxAdapter(
              child: Card(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${'levelingProgressLevel'.tr(args: [currentLevel.toString()])} / 120',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Gap(8),
                    LinearProgressIndicator(
                      value: currentLevel / 120,
                      minHeight: 10,
                      stopIndicatorRadius: 0,
                      trackGap: 0,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ],
                ).padding(horizontal: 16, top: 16, bottom: 12),
              ),
            ),
            const SliverGap(16),
            // Leveling History
            SliverToBoxAdapter(
              child: Text(
                'levelingHistory'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SliverGap(8),
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
                    Row(
                      spacing: 4,
                      children: [
                        Text(
                          record.createdAt.formatRelative(context),
                        ).fontSize(13),
                        Text('·').fontSize(13).bold(),
                        Text(record.createdAt.formatSystem()).fontSize(13),
                      ],
                    ).opacity(0.8),
                  ],
                ),
                subtitle: Row(
                  spacing: 8,
                  children: [
                    Text('${record.delta > 0 ? '+' : ''}${record.delta} EXP'),
                    if (record.bonusMultiplier != 1.0)
                      Text('x${record.bonusMultiplier}'),
                  ],
                ),
                minTileHeight: 56,
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
              ),
            ),

            SliverGap(20),
          ],
        ),
      ),
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
