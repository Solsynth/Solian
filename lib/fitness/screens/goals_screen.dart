import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
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
              return const Center(child: Text('No goals yet'));
            }
            return ListView.builder(
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
        ? (goal.currentValue! / goal.targetValue! * 100).clamp(0, 100)
        : 0.0;

    final statusColor = switch (goal.status) {
      FitnessGoalStatus.active => Colors.green,
      FitnessGoalStatus.completed => Colors.blue,
      FitnessGoalStatus.cancelled => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getGoalIcon(goal.goalType), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (goal.description != null)
                        Text(
                          goal.description!,
                          style: Theme.of(context).textTheme.bodySmall,
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
                    goal.status.name,
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
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${goal.currentValue?.toStringAsFixed(1) ?? '0'} / ${goal.targetValue} ${goal.unit ?? ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Until ${goal.endDate?.toString().split(' ')[0] ?? 'No deadline'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGoalIcon(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.weightLoss => Symbols.monitor_weight,
      FitnessGoalType.muscleGain => Symbols.fitness_center,
      FitnessGoalType.endurance => Symbols.directions_run,
      FitnessGoalType.steps => Symbols.directions_walk,
      FitnessGoalType.custom => Symbols.flag,
    };
  }
}
