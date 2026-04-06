import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/fitness/screens/goal_create_screen.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(
      workoutGoalsProvider((status: null, skip: 0, take: 50)),
    );

    return AppScaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            workoutGoalsProvider((status: null, skip: 0, take: 50)),
          );
        },
        child: goalsAsync.when(
          data: (result) {
            if (result.items.isEmpty) {
              return Center(
                child: Text(
                  'No goals yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: result.items.length,
              itemBuilder: (context, index) {
                final goal = result.items[index];
                return _GoalCard(goal: goal);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => const GoalCreateScreen(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SnFitnessGoal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress =
        goal.targetValue != null &&
            goal.currentValue != null &&
            goal.targetValue! > 0
        ? (goal.currentValue! / goal.targetValue! * 100).clamp(0.0, 100.0)
        : 0.0;

    final statusColor = switch (goal.status) {
      FitnessGoalStatus.active => Colors.green,
      FitnessGoalStatus.completed => Colors.blue,
      FitnessGoalStatus.paused => Colors.orange,
      FitnessGoalStatus.cancelled => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.router.push(GoalDetailRoute(id: goal.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      _getGoalIcon(goal.goalType),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (goal.description != null)
                          Text(
                            goal.description!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusName(goal.status),
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (goal.targetValue != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 8,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${goal.currentValue?.toStringAsFixed(0) ?? '0'} / ${goal.targetValue!.toStringAsFixed(0)} ${goal.unit ?? ''}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
              if (goal.autoUpdateProgress) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.sync,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Auto-updates from ${_getBindingLabel(goal)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Until ${goal.endDate != null ? _formatDate(goal.endDate!) : 'No deadline'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGoalIcon(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.weightLoss => Icons.monitor_weight,
      FitnessGoalType.weightGain => Icons.fitness_center,
      FitnessGoalType.steps => Icons.directions_walk,
      FitnessGoalType.distance => Icons.directions_run,
      FitnessGoalType.duration => Icons.timer,
      FitnessGoalType.reps => Icons.repeat,
      FitnessGoalType.strength => Icons.fitness_center,
      FitnessGoalType.cardio => Icons.favorite,
      FitnessGoalType.flexibility => Icons.self_improvement,
      FitnessGoalType.custom => Icons.flag,
    };
  }

  String _getStatusName(FitnessGoalStatus status) {
    return switch (status) {
      FitnessGoalStatus.active => 'Active',
      FitnessGoalStatus.completed => 'Completed',
      FitnessGoalStatus.paused => 'Paused',
      FitnessGoalStatus.cancelled => 'Cancelled',
    };
  }

  String _getBindingLabel(SnFitnessGoal goal) {
    if (goal.boundWorkoutType != null) {
      final type = WorkoutType.values[goal.boundWorkoutType!];
      return switch (type) {
        WorkoutType.strength => 'strength workouts',
        WorkoutType.cardio => 'cardio workouts',
        WorkoutType.hiit => 'HIIT workouts',
        WorkoutType.yoga => 'yoga sessions',
        WorkoutType.other => 'workouts',
      };
    }
    if (goal.boundMetricType != null) {
      final type = FitnessMetricType.values[goal.boundMetricType!];
      return switch (type) {
        FitnessMetricType.weight => 'weight',
        FitnessMetricType.bodyFat => 'body fat',
        FitnessMetricType.steps => 'steps',
        FitnessMetricType.heartRate => 'heart rate',
        FitnessMetricType.sleep => 'sleep',
        FitnessMetricType.calories => 'calories',
        FitnessMetricType.waterIntake => 'water',
        FitnessMetricType.distance => 'distance',
        FitnessMetricType.custom => 'metrics',
      };
    }
    return 'manual';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
