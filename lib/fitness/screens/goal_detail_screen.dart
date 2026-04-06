import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_nameplate.dart';
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
        appBar: AppBar(title: Text('goal'.tr())),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBar(title: Text('goal'.tr())),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SnFitnessGoal goal,
  ) {
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    final isOwner = currentUserId == goal.accountId;

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
                      Text('recalculateProgress'.tr()),
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
                      Text('pauseGoal'.tr()),
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
                      Text('resumeGoal'.tr()),
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
                      Text('markComplete'.tr()),
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
                      Text('cancelGoal'.tr()),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Symbols.delete,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const Gap(12),
                    Text(
                      'deleteGoal'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
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
                    Text('editGoal'.tr()),
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
            if (!isOwner)
              AccountNameplate(name: goal.accountId, padding: EdgeInsets.zero),
            if (!isOwner) const SizedBox(height: 16),
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
              _buildSection(context, 'description'.tr(), goal.description!),
            ],
            if (goal.notes != null) ...[
              const SizedBox(height: 16),
              _buildSection(context, 'notes'.tr(), goal.notes!),
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
                        'complete'.tr(),
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
                    'autoTrackingEnabled'.tr(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'autoTrackingFrom'.tr(args: [_getBindingLabel(goal)]),
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
                    'repeatingGoal'.tr(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isEndless
                        ? 'repeatingGoalInfo'.tr(
                            args: [
                              current.toString(),
                              _getRepeatTypeName(repeatType),
                              interval.toString(),
                            ],
                          )
                        : 'repeatingGoalInfoCount'.tr(
                            args: [
                              current.toString(),
                              count.toString(),
                              _getRepeatTypeName(repeatType),
                              interval.toString(),
                            ],
                          ),
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
              'details'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'goalType'.tr(),
              value: _getGoalTypeName(goal.goalType),
            ),
            _DetailRow(
              label: 'targetValue'.tr(),
              value: '${goal.targetValue ?? '—'} ${goal.unit ?? ''}',
            ),
            _DetailRow(
              label: 'startDate'.tr(),
              value: _formatDate(goal.startDate),
            ),
            _DetailRow(
              label: 'endDate'.tr(),
              value: goal.endDate != null
                  ? _formatDate(goal.endDate!)
                  : 'noDeadline'.tr(),
            ),
            _DetailRow(
              label: 'visibility'.tr(),
              value: goal.visibility == FitnessVisibility.public
                  ? 'visibilityPublic'.tr()
                  : 'visibilityPrivate'.tr(),
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
          showSnackBar('progressRecalculated'.tr());
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
        case 'delete':
          await ref.read(goalNotifierProvider.notifier).deleteGoal(goal.id);
          if (context.mounted) {
            Navigator.pop(context);
          }
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
      FitnessGoalStatus.active => 'active'.tr(),
      FitnessGoalStatus.completed => 'completed'.tr(),
      FitnessGoalStatus.paused => 'paused'.tr(),
      FitnessGoalStatus.cancelled => 'cancelled'.tr(),
    };
  }

  String _getGoalTypeName(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.weightLoss => 'goalTypeWeightLoss'.tr(),
      FitnessGoalType.weightGain => 'goalTypeWeightGain'.tr(),
      FitnessGoalType.steps => 'goalTypeSteps'.tr(),
      FitnessGoalType.distance => 'goalTypeDistance'.tr(),
      FitnessGoalType.duration => 'goalTypeDuration'.tr(),
      FitnessGoalType.reps => 'goalTypeReps'.tr(),
      FitnessGoalType.strength => 'goalTypeStrength'.tr(),
      FitnessGoalType.cardio => 'goalTypeCardio'.tr(),
      FitnessGoalType.flexibility => 'goalTypeFlexibility'.tr(),
      FitnessGoalType.custom => 'goalTypeCustom'.tr(),
    };
  }

  String _getRepeatTypeName(RepeatType type) {
    return switch (type) {
      RepeatType.daily => 'day'.tr(),
      RepeatType.weekly => 'week'.tr(),
      RepeatType.biweekly => '2Weeks'.tr(),
      RepeatType.monthly => 'month'.tr(),
      RepeatType.quarterly => 'quarter'.tr(),
      RepeatType.yearly => 'year'.tr(),
    };
  }

  String _getBindingLabel(SnFitnessGoal goal) {
    if (goal.boundWorkoutType != null) {
      final type = WorkoutType.values[goal.boundWorkoutType!];
      return switch (type) {
        WorkoutType.strength => 'strengthWorkouts'.tr(),
        WorkoutType.cardio => 'cardioWorkouts'.tr(),
        WorkoutType.hiit => 'hiitWorkouts'.tr(),
        WorkoutType.yoga => 'yogaSessions'.tr(),
        WorkoutType.other => 'fitnessWorkouts'.tr(),
      };
    }
    if (goal.boundMetricType != null) {
      final type = FitnessMetricType.values[goal.boundMetricType!];
      return switch (type) {
        FitnessMetricType.weight => 'weight'.tr(),
        FitnessMetricType.bodyFat => 'bodyFat'.tr(),
        FitnessMetricType.steps => 'steps'.tr(),
        FitnessMetricType.heartRate => 'heartRate'.tr(),
        FitnessMetricType.sleep => 'sleep'.tr(),
        FitnessMetricType.calories => 'calories'.tr(),
        FitnessMetricType.waterIntake => 'water'.tr(),
        FitnessMetricType.distance => 'distance'.tr(),
        FitnessMetricType.custom => 'fitnessMetrics'.tr(),
      };
    }
    return 'manual'.tr();
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
