import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/fitness/screens/goal_create_screen.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class GoalDetailScreen extends ConsumerWidget {
  final String id;

  const GoalDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(id));

    return goalAsync.when(
      data: (goal) => _buildContent(context, ref, goal),
      loading: () => AppScaffold(
        appBar: AppBar(title: const Text('Goal')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBar(title: const Text('Goal')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SnFitnessGoal goal,
  ) {
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

    return AppScaffold(
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, ref, goal, value),
            itemBuilder: (context) => [
              if (goal.autoUpdateProgress)
                PopupMenuItem(
                  value: 'recalculate',
                  child: Row(
                    children: [
                      Icon(
                        Symbols.refresh,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const Gap(12),
                      const Text('Recalculate Progress'),
                    ],
                  ),
                ),
              if (goal.status == FitnessGoalStatus.active)
                PopupMenuItem(
                  value: 'pause',
                  child: Row(
                    children: [
                      Icon(
                        Symbols.pause_circle,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const Gap(12),
                      const Text('Pause Goal'),
                    ],
                  ),
                ),
              if (goal.status == FitnessGoalStatus.paused)
                PopupMenuItem(
                  value: 'resume',
                  child: Row(
                    children: [
                      Icon(
                        Symbols.play_circle,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const Gap(12),
                      const Text('Resume Goal'),
                    ],
                  ),
                ),
              if (goal.status != FitnessGoalStatus.completed)
                PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(
                        Symbols.check_circle,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const Gap(12),
                      const Text('Mark Complete'),
                    ],
                  ),
                ),
              if (goal.status != FitnessGoalStatus.cancelled)
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(
                        Symbols.cancel,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const Gap(12),
                      const Text('Cancel Goal'),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Symbols.edit,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const Gap(12),
                    const Text('Edit Goal'),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressCard(context, goal, progress, statusColor),
            const SizedBox(height: 16),
            if (goal.autoUpdateProgress) _buildAutoUpdateCard(context, goal),
            if (goal.repeatType != null) ...[
              const SizedBox(height: 16),
              _buildRepeatCard(context, goal),
            ],
            const SizedBox(height: 16),
            _buildDetailsCard(context, goal),
            if (goal.description != null) ...[
              const SizedBox(height: 16),
              _buildSection(context, 'Description', goal.description!),
            ],
            if (goal.notes != null) ...[
              const SizedBox(height: 16),
              _buildSection(context, 'Notes', goal.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    SnFitnessGoal goal,
    double progress,
    Color statusColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 10,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Complete',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (goal.targetValue != null)
              Text(
                '${goal.currentValue?.toStringAsFixed(0) ?? '0'} / ${goal.targetValue!.toStringAsFixed(0)} ${goal.unit ?? ''}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getStatusName(goal.status),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoUpdateCard(BuildContext context, SnFitnessGoal goal) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.sync,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-Tracking Enabled',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Progress updates from ${_getBindingLabel(goal)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatCard(BuildContext context, SnFitnessGoal goal) {
    final repeatType = goal.repeatType!;
    final interval = goal.repeatInterval ?? 1;
    final count = goal.repeatCount;
    final current = goal.currentRepetition ?? 1;
    final isEndless = count == null;

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.repeat,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repeating Goal',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isEndless
                        ? '$current ${_getRepeatTypeName(repeatType)} (every $interval) - Endless'
                        : '$current of $count ${_getRepeatTypeName(repeatType)}s (every $interval)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, SnFitnessGoal goal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Type', value: _getGoalTypeName(goal.goalType)),
            _DetailRow(
              label: 'Target',
              value: '${goal.targetValue ?? '—'} ${goal.unit ?? ''}',
            ),
            _DetailRow(label: 'Start Date', value: _formatDate(goal.startDate)),
            _DetailRow(
              label: 'End Date',
              value: goal.endDate != null
                  ? _formatDate(goal.endDate!)
                  : 'No deadline',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(content),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    SnFitnessGoal goal,
    String action,
  ) async {
    try {
      switch (action) {
        case 'recalculate':
          await ref
              .read(goalNotifierProvider.notifier)
              .recalculateGoal(goal.id);
          showSnackBar('Progress recalculated');
          break;
        case 'pause':
          await ref
              .read(goalNotifierProvider.notifier)
              .updateGoalStatus(goal.id, FitnessGoalStatus.paused);
          break;
        case 'resume':
          await ref
              .read(goalNotifierProvider.notifier)
              .updateGoalStatus(goal.id, FitnessGoalStatus.active);
          break;
        case 'complete':
          await ref
              .read(goalNotifierProvider.notifier)
              .updateGoalStatus(goal.id, FitnessGoalStatus.completed);
          break;
        case 'cancel':
          await ref
              .read(goalNotifierProvider.notifier)
              .updateGoalStatus(goal.id, FitnessGoalStatus.cancelled);
          break;
        case 'edit':
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => GoalCreateScreen(goal: goal),
          );
          break;
      }
    } catch (e) {
      showErrorAlert('Error: $e');
    }
  }

  String _getStatusName(FitnessGoalStatus status) {
    return switch (status) {
      FitnessGoalStatus.active => 'Active',
      FitnessGoalStatus.completed => 'Completed',
      FitnessGoalStatus.paused => 'Paused',
      FitnessGoalStatus.cancelled => 'Cancelled',
    };
  }

  String _getGoalTypeName(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.weightLoss => 'Weight Loss',
      FitnessGoalType.weightGain => 'Weight Gain',
      FitnessGoalType.steps => 'Steps',
      FitnessGoalType.distance => 'Distance',
      FitnessGoalType.duration => 'Duration',
      FitnessGoalType.reps => 'Reps',
      FitnessGoalType.strength => 'Strength',
      FitnessGoalType.cardio => 'Cardio',
      FitnessGoalType.flexibility => 'Flexibility',
      FitnessGoalType.custom => 'Custom',
    };
  }

  String _getRepeatTypeName(RepeatType type) {
    return switch (type) {
      RepeatType.daily => 'Day',
      RepeatType.weekly => 'Week',
      RepeatType.biweekly => '2 Weeks',
      RepeatType.monthly => 'Month',
      RepeatType.quarterly => 'Quarter',
      RepeatType.yearly => 'Year',
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
