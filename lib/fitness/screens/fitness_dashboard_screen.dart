import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class FitnessDashboardScreen extends ConsumerWidget {
  const FitnessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(goalStatsProvider);
    final workoutsAsync = ref.watch(workoutsProvider((skip: 0, take: 5)));

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Fitness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ref.invalidate(goalStatsProvider);
              ref.invalidate(workoutsProvider((skip: 0, take: 5)));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(goalStatsProvider);
          ref.invalidate(workoutsProvider((skip: 0, take: 5)));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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

  Widget _buildStatsSection(
    BuildContext context,
    AsyncValue<GoalStats> statsAsync,
  ) {
    return statsAsync.when(
      data: (stats) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Active Goals',
                stats.activeCount.toString(),
                Icons.flag_outlined,
              ),
              _buildStatItem(
                context,
                'Completed',
                stats.completedCount.toString(),
                Icons.check_circle_outline,
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.flag_outlined,
                label: 'Goals',
                onTap: () => context.router.push(const GoalsRoute()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.show_chart,
                label: 'Metrics',
                onTap: () => context.router.push(const MetricsRoute()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.cloud_upload,
                label: 'Import',
                onTap: () => context.router.push(const HealthSyncRoute()),
              ),
            ),
          ],
        ),
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
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.router.push(const WorkoutsRoute()),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        workoutsAsync.when(
          data: (result) {
            if (result.items.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No workouts yet')),
                ),
              );
            }
            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: result.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final workout = result.items[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(_getWorkoutIcon(workout.type)),
                    ),
                    title: Text(workout.name),
                    subtitle: Text(_formatDate(workout.startTime)),
                    trailing: workout.caloriesBurned != null
                        ? Text('${workout.caloriesBurned} cal')
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
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.router.push(const GoalsRoute()),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.flag_outlined)),
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
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.router.push(const MetricsRoute()),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.show_chart)),
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
