import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

String _getAchievementTitle(String identifier, String defaultTitle) {
  final key = 'achievementTitle${identifier.toCamelCase()}';
  final translated = key.tr();
  return translated == key ? defaultTitle : translated;
}

String _getAchievementSummary(String identifier, String defaultSummary) {
  final key = 'achievementSummary${identifier.toCamelCase()}';
  final translated = key.tr();
  return translated == key ? defaultSummary : translated;
}

String _getQuestTitle(String identifier, String defaultTitle) {
  final key = 'questTitle${identifier.toCamelCase()}';
  final translated = key.tr();
  return translated == key ? defaultTitle : translated;
}

String _getQuestSummary(String identifier, String defaultSummary) {
  final key = 'questSummary${identifier.toCamelCase()}';
  final translated = key.tr();
  return translated == key ? defaultSummary : translated;
}

final achievementsProvider =
    FutureProvider.autoDispose<List<SnAchievementState>>((ref) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get(
        '/passport/accounts/me/progression/achievements',
      );
      final data = response.data;
      if (data is List) {
        return data
            .map(
              (e) => SnAchievementState.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
      return [];
    });

final questsProvider = FutureProvider.autoDispose<List<SnQuestState>>((
  ref,
) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/passport/accounts/me/progression/quests');
  final data = response.data;
  if (data is List) {
    return data
        .map((e) => SnQuestState.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return [];
});

final rewardGrantsNotifierProvider =
    AsyncNotifierProvider.autoDispose<
      RewardGrantsNotifier,
      PaginationState<SnProgressRewardGrant>
    >(RewardGrantsNotifier.new);

class RewardGrantsNotifier
    extends AsyncNotifier<PaginationState<SnProgressRewardGrant>>
    with AsyncPaginationController<SnProgressRewardGrant> {
  static const int pageSize = 20;

  @override
  FutureOr<PaginationState<SnProgressRewardGrant>> build() async {
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
  Future<List<SnProgressRewardGrant>> fetch() async {
    final client = ref.read(apiClientProvider);
    final response = await client.get(
      '/passport/accounts/me/progression/grants',
      queryParameters: {'offset': fetchedCount.toString(), 'take': pageSize},
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    return (response.data as List)
        .map(
          (e) => SnProgressRewardGrant.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }
}

@RoutePage()
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        appBar: AppBar(
          title: Text('progress').tr(),
          leading: const AutoLeadingButton(),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'achievements',
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ).tr(),
              ),
              Tab(
                child: Text(
                  'quests',
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ).tr(),
              ),
              Tab(
                child: Text(
                  'rewards',
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ).tr(),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [_AchievementsTab(), _QuestsTab(), _RewardsTab()],
        ),
      ),
    );
  }
}

class _AchievementsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return achievementsAsync.when(
      data: (achievements) {
        if (achievements.isEmpty) {
          return _EmptyState(
            icon: Symbols.military_tech,
            message: 'noAchievements'.tr(),
          );
        }

        final completedCount = achievements.where((a) => a.isCompleted).length;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProgressHeader(
                completed: completedCount,
                total: achievements.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemCount: achievements.length,
                separatorBuilder: (context, index) => const Gap(12),
                itemBuilder: (context, index) =>
                    _AchievementCard(achievement: achievements[index]),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ResponseErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(achievementsProvider),
      ),
    );
  }
}

class _QuestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(questsProvider);

    return questsAsync.when(
      data: (quests) {
        if (quests.isEmpty) {
          return _EmptyState(
            icon: Symbols.assignment,
            message: 'noQuests'.tr(),
          );
        }

        final completedCount = quests.where((q) => q.isCompleted).length;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProgressHeader(
                completed: completedCount,
                total: quests.length,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.separated(
                itemCount: quests.length,
                separatorBuilder: (context, index) => const Gap(12),
                itemBuilder: (context, index) =>
                    _QuestCard(quest: quests[index]),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ResponseErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(questsProvider),
      ),
    );
  }
}

class _RewardsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationList(
      provider: rewardGrantsNotifierProvider,
      notifier: rewardGrantsNotifierProvider.notifier,
      isRefreshable: false,
      isSliver: false,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, idx, grant) => _RewardGrantCard(grant: grant),
      footerSkeletonChild: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Container(
          height: 12,
          width: 120,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressHeader({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'completed'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$completed / $total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Gap(12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final SnAchievementState achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = achievement.targetCount > 0
        ? achievement.progressCount / achievement.targetCount
        : 0.0;
    final reward = achievement.reward;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAchievementDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: achievement.isCompleted
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getAchievementIcon(achievement.icon),
                      size: 24,
                      color: achievement.isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getAchievementTitle(
                            achievement.identifier,
                            achievement.title,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getAchievementSummary(
                            achievement.identifier,
                            achievement.summary,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (achievement.isCompleted)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Symbols.check,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                ],
              ),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!achievement.isCompleted) ...[
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const Gap(4),
                    Text(
                      '${achievement.progressCount}/${achievement.targetCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'completed'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ).padding(horizontal: 4),
              if (reward != null && _hasRewards(reward)) ...[
                const Gap(12),
                _RewardPreview(reward: reward),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAchievementIcon(String? icon) {
    switch (icon) {
      case 'ink':
      case 'post':
        return Symbols.edit;
      case 'spark':
      case 'reaction':
        return Symbols.favorite;
      case 'message-circle':
      case 'chat':
        return Symbols.chat_bubble;
      case 'flag':
      case 'publisher':
        return Symbols.flag;
      case 'globe':
      case 'realm':
        return Symbols.public;
      case 'messages-square':
        return Symbols.chat;
      default:
        return Symbols.military_tech;
    }
  }

  void _showAchievementDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AchievementDetailSheet(achievement: achievement),
    );
  }
}

class _AchievementDetailSheet extends StatelessWidget {
  final SnAchievementState achievement;

  const _AchievementDetailSheet({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reward = achievement.reward;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: achievement.isCompleted
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getAchievementIcon(achievement.icon),
                  size: 32,
                  color: achievement.isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAchievementTitle(
                        achievement.identifier,
                        achievement.title,
                      ),
                      style: theme.textTheme.titleLarge,
                    ),
                    if (achievement.isCompleted)
                      Text(
                        'completedAt'.tr(
                          args: [
                            achievement.completedAt?.formatRelative(context) ??
                                '-',
                          ],
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            _getAchievementSummary(achievement.identifier, achievement.summary),
          ),
          if (reward != null) ...[
            const Gap(16),
            Text('rewards'.tr(), style: theme.textTheme.titleMedium),
            const Gap(12),
            if (reward.experience > 0)
              _RewardRow(
                icon: Symbols.star,
                label: 'experience',
                value: '+${reward.experience} EXP',
              ),
            if (reward.sourcePoints > 0)
              _RewardRow(
                icon: Symbols.toll,
                label: 'sourcePoints',
                value: '+${reward.sourcePoints}',
              ),
            if (reward.badge != null)
              _RewardRow(
                icon: Symbols.military_tech,
                label: 'badge',
                value: reward.badge!.label ?? reward.badge!.type,
              ),
          ],
          const Gap(24),
        ],
      ),
    );
  }

  IconData _getAchievementIcon(String? icon) {
    switch (icon) {
      case 'ink':
      case 'post':
        return Symbols.edit;
      case 'spark':
      case 'reaction':
        return Symbols.favorite;
      case 'message-circle':
      case 'chat':
        return Symbols.chat_bubble;
      case 'flag':
      case 'publisher':
        return Symbols.flag;
      case 'globe':
      case 'realm':
        return Symbols.public;
      case 'messages-square':
        return Symbols.chat;
      default:
        return Symbols.military_tech;
    }
  }
}

class _QuestCard extends StatelessWidget {
  final SnQuestState quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = quest.targetCount > 0
        ? quest.progressCount / quest.targetCount
        : 0.0;
    final reward = quest.reward;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showQuestDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: quest.isCompleted
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getQuestIcon(quest.icon),
                      size: 24,
                      color: quest.isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getQuestTitle(quest.identifier, quest.title),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                _getQuestSummary(
                                  quest.identifier,
                                  quest.summary,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        _ScheduleBadge(schedule: quest.schedule),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Icon(
                    quest.isCompleted
                        ? Symbols.check_circle
                        : Symbols.radio_button_unchecked,
                    fill: quest.isCompleted ? 1 : 0,
                    color: quest.isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!quest.isCompleted) ...[
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const Gap(8),
                        Text(
                          '${quest.progressCount}/${quest.targetCount}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'completed'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                  if (!quest.isCompleted && quest.nextResetAt != null) ...[
                    const Gap(4),
                    Text(
                      'nextReset'.tr(
                        args: [quest.nextResetAt!.formatRelative(context)],
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ).padding(horizontal: 4),
              if (reward != null && _hasRewards(reward)) ...[
                const Gap(12),
                _RewardPreview(reward: reward),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getQuestIcon(String? icon) {
    switch (icon) {
      case 'calendar':
        return Symbols.calendar_today;
      default:
        return Symbols.assignment;
    }
  }

  void _showQuestDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _QuestDetailSheet(quest: quest),
    );
  }
}

class _ScheduleBadge extends StatelessWidget {
  final SnQuestScheduleConfig? schedule;

  const _ScheduleBadge({this.schedule});

  @override
  Widget build(BuildContext context) {
    if (schedule == null) return const SizedBox.shrink();

    String label;
    Color color;

    switch (schedule!.repeatability) {
      case 'daily':
        label = 'daily'.tr();
        color = Colors.green;
        break;
      case 'weekly':
        label = 'weekly'.tr();
        color = Colors.blue;
        break;
      case 'monthly':
        label = 'monthly'.tr();
        color = Colors.purple;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _QuestDetailSheet extends StatelessWidget {
  final SnQuestState quest;

  const _QuestDetailSheet({required this.quest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reward = quest.reward;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: quest.isCompleted
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getQuestIcon(quest.icon),
                  size: 32,
                  color: quest.isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getQuestTitle(quest.identifier, quest.title),
                      style: theme.textTheme.titleLarge,
                    ),
                    const Gap(4),
                    _ScheduleBadge(schedule: quest.schedule),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(_getQuestSummary(quest.identifier, quest.summary)),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('progress'.tr()),
                    const Gap(4),
                    LinearProgressIndicator(
                      value: quest.targetCount > 0
                          ? quest.progressCount / quest.targetCount
                          : 0,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const Gap(4),
                    Text('${quest.progressCount}/${quest.targetCount}'),
                  ],
                ),
              ),
              const Gap(24),
              if (quest.isCompleted)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Symbols.check,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
            ],
          ),
          if (quest.nextResetAt != null && !quest.isCompleted) ...[
            const Gap(8),
            Text(
              'nextReset'.tr(
                args: [quest.nextResetAt!.formatRelative(context)],
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
          if (reward != null) ...[
            const Gap(16),
            const Divider(),
            const Gap(16),
            Text('rewards'.tr(), style: theme.textTheme.titleMedium),
            const Gap(12),
            if (reward.experience > 0)
              _RewardRow(
                icon: Symbols.star,
                label: 'experience',
                value: '+${reward.experience} EXP',
              ),
            if (reward.sourcePoints > 0)
              _RewardRow(
                icon: Symbols.toll,
                label: 'sourcePoints',
                value: '+${reward.sourcePoints}',
              ),
            if (reward.badge != null)
              _RewardRow(
                icon: Symbols.military_tech,
                label: 'badge',
                value: reward.badge!.label ?? reward.badge!.type,
              ),
          ],
          const Gap(24),
        ],
      ),
    );
  }

  IconData _getQuestIcon(String? icon) {
    switch (icon) {
      case 'calendar':
        return Symbols.calendar_today;
      default:
        return Symbols.assignment;
    }
  }
}

class _RewardGrantCard extends StatelessWidget {
  final SnProgressRewardGrant grant;

  const _RewardGrantCard({required this.grant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAchievement = grant.definitionType == 'achievement';
    final reward = grant.reward;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isAchievement ? Colors.amber : Colors.blue)
                        .withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAchievement ? Symbols.military_tech : Symbols.assignment,
                    color: isAchievement ? Colors.amber : Colors.blue,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grant.definitionTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isAchievement ? Colors.amber : Colors.blue)
                                      .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isAchievement
                                  ? 'achievements'.tr()
                                  : 'quests'.tr(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isAchievement
                                    ? Colors.amber.shade700
                                    : Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Gap(8),
                          Text(
                            grant.createdAt.formatRelative(context),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (reward != null && _hasRewards(reward)) ...[
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (reward.experience > 0)
                    _RewardChip(
                      icon: Symbols.star,
                      label: '+${reward.experience} EXP',
                    ),
                  if (reward.sourcePoints > 0)
                    _RewardChip(
                      icon: Symbols.toll,
                      label: '+${reward.sourcePoints}',
                    ),
                  if (reward.badge != null)
                    _RewardChip(
                      icon: Symbols.military_tech,
                      label: reward.badge!.label ?? 'badge'.tr(),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RewardRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const Gap(8),
          Text(label.tr()),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RewardChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const Gap(4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RewardPreview extends StatelessWidget {
  final SnProgressRewardDefinition reward;

  const _RewardPreview({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (reward.experience > 0)
          _RewardChip(icon: Symbols.star, label: '+${reward.experience} EXP'),
        if (reward.sourcePoints > 0)
          _RewardChip(icon: Symbols.toll, label: '+${reward.sourcePoints}'),
        if (reward.badge != null)
          _RewardChip(
            icon: Symbols.military_tech,
            label: reward.badge!.label ?? 'badge'.tr(),
          ),
      ],
    );
  }
}

bool _hasRewards(SnProgressRewardDefinition reward) {
  return reward.experience > 0 ||
      reward.sourcePoints > 0 ||
      reward.badge != null;
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const Gap(16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
