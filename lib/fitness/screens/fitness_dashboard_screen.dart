import 'dart:io' show Platform;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/fitness/pods/health_sync_providers.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class FitnessDashboardScreen extends ConsumerWidget {
  const FitnessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(goalStatsProvider);
    final workoutsAsync = ref.watch(workoutsProvider((skip: 0, take: 5)));
    final hasNewData = ref.watch(hasNewHealthDataProvider);
    final isDismissed = ref.watch(dismissNewDataCardProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Fitness')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(goalStatsProvider);
          ref.invalidate(workoutsProvider((skip: 0, take: 5)));
          ref.invalidate(hasNewHealthDataProvider);
          ref.read(dismissNewDataCardProvider.notifier).show();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSyncSuggestionCard(context, ref, hasNewData, isDismissed),
            _buildStatsSection(context, statsAsync),
            const SizedBox(height: 24),
            _buildQuickActionsSection(context),
            const SizedBox(height: 24),
            _buildRecentWorkoutsSection(context, workoutsAsync),
            const SizedBox(height: 24),
            _buildGoalsSection(context),
            const SizedBox(height: 24),
            _buildMetricsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSuggestionCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<bool> hasNewData,
    bool isDismissed,
  ) {
    if (isDismissed) return const SizedBox.shrink();

    return hasNewData.when(
      data: (hasNew) {
        if (!hasNew) return const SizedBox.shrink();
        return Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_sync,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New health data available',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tap to sync your latest workouts and metrics',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.router.push(const HealthSyncRoute());
                  },
                  child: const Text('Sync'),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(dismissNewDataCardProvider.notifier).dismiss();
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    AsyncValue<GoalStats> statsAsync,
  ) {
    return statsAsync.when(
      data: (stats) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Active Goals',
                  value: stats.activeCount.toString(),
                  icon: Icons.flag,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Expanded(
                child: _StatItem(
                  label: 'Completed',
                  value: stats.completedCount.toString(),
                  icon: Icons.check_circle,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading stats: $e'),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final actions = <Widget>[
      Expanded(
        child: _ActionCard(
          icon: Icons.flag_outlined,
          label: 'Goals',
          onTap: () => context.router.push(const GoalsRoute()),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _ActionCard(
          icon: Icons.show_chart,
          label: 'Metrics',
          onTap: () => context.router.push(const MetricsRoute()),
        ),
      ),
    ];

    if (Platform.isIOS) {
      actions.addAll([
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.cloud_upload_outlined,
            label: 'Import',
            onTap: () => context.router.push(const HealthSyncRoute()),
          ),
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(children: actions),
      ],
    );
  }

  Widget _buildRecentWorkoutsSection(
    BuildContext context,
    AsyncValue<PaginatedResult<SnWorkout>> workoutsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Workouts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            FilledButton.tonal(
              onPressed: () => context.router.push(const WorkoutsRoute()),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        workoutsAsync.when(
          data: (result) {
            if (result.items.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No workouts yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Card(
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: result.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final workout = result.items[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(
                        _getWorkoutIcon(workout.type),
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(workout.name),
                    subtitle: Text(_formatDate(workout.startTime)),
                    trailing: workout.caloriesBurned != null
                        ? Text(
                            '${workout.caloriesBurned} cal',
                            style: Theme.of(context).textTheme.labelLarge,
                          )
                        : null,
                  );
                },
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Goals',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            FilledButton.tonal(
              onPressed: () => context.router.push(const GoalsRoute()),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.flag_outlined,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: const Text('View Goals'),
            subtitle: const Text('Track your fitness goals'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.router.push(const GoalsRoute()),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Metrics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            FilledButton.tonal(
              onPressed: () => context.router.push(const MetricsRoute()),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.show_chart,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: const Text('View Metrics'),
            subtitle: const Text('Track weight, steps, and more'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.router.push(const MetricsRoute()),
          ),
        ),
      ],
    );
  }

  IconData _getWorkoutIcon(WorkoutType type) {
    switch (type) {
      case WorkoutType.strength:
        return Icons.fitness_center;
      case WorkoutType.cardio:
        return Icons.directions_run;
      case WorkoutType.hiit:
        return Icons.flash_on;
      case WorkoutType.yoga:
        return Icons.self_improvement;
      case WorkoutType.other:
        return Icons.sports;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
