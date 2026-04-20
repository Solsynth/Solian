import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final composeFitnessWorkoutsProvider = FutureProvider.autoDispose
    .family<List<_FitnessWorkoutItem>, String>((ref, accountId) async {
      final client = ref.watch(solarNetworkClientProvider);
      final fitness = client.fitness;

      final workouts = await fitness.getWorkouts(skip: 0, take: 50);
      return workouts.items
          .where((w) => w.visibility == FitnessVisibility.public)
          .map(
            (w) => _FitnessWorkoutItem(
              id: w.id,
              name: w.name,
              startTime: w.startTime,
              endTime: w.endTime,
              type: w.type,
              caloriesBurned: w.caloriesBurned?.toDouble(),
              distance: w.distance,
              distanceUnit: w.distanceUnit,
              averageHeartRate: w.averageHeartRate?.toDouble(),
              averageSpeed: w.averageSpeed,
              elevationGain: w.elevationGain,
              meta: w.meta,
            ),
          )
          .toList();
    });

final composeFitnessMetricsProvider = FutureProvider.autoDispose
    .family<List<_FitnessMetricItem>, String>((ref, accountId) async {
      final client = ref.watch(solarNetworkClientProvider);
      final fitness = client.fitness;

      final metrics = await fitness.getMetrics(skip: 0, take: 50);
      return metrics.items
          .where((m) => m.visibility == FitnessVisibility.public)
          .map(
            (m) => _FitnessMetricItem(
              id: m.id,
              metricType: m.metricType,
              value: m.value,
              unit: m.unit,
              recordedAt: m.recordedAt,
              notes: m.notes,
            ),
          )
          .toList();
    });

final composeFitnessGoalsProvider = FutureProvider.autoDispose
    .family<List<_FitnessGoalItem>, String>((ref, accountId) async {
      final client = ref.watch(solarNetworkClientProvider);
      final fitness = client.fitness;

      final goals = await fitness.getGoals(skip: 0, take: 50);
      return goals.items
          .where((g) => g.visibility == FitnessVisibility.public)
          .map(
            (g) => _FitnessGoalItem(
              id: g.id,
              title: g.title,
              goalType: g.goalType,
              currentValue: g.currentValue,
              targetValue: g.targetValue,
              unit: g.unit,
              startDate: g.startDate,
              endDate: g.endDate,
              description: g.description,
            ),
          )
          .toList();
    });

class _FitnessWorkoutItem {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final WorkoutType type;
  final double? caloriesBurned;
  final double? distance;
  final String? distanceUnit;
  final double? averageHeartRate;
  final double? averageSpeed;
  final double? elevationGain;
  final Map<String, dynamic>? meta;

  _FitnessWorkoutItem({
    required this.id,
    required this.name,
    required this.startTime,
    this.endTime,
    required this.type,
    this.caloriesBurned,
    this.distance,
    this.distanceUnit,
    this.averageHeartRate,
    this.averageSpeed,
    this.elevationGain,
    this.meta,
  });

  String get reference => 'workout:$id';

  Duration? get duration =>
      endTime?.difference(startTime);
}

class _FitnessMetricItem {
  final String id;
  final FitnessMetricType metricType;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String? notes;

  _FitnessMetricItem({
    required this.id,
    required this.metricType,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.notes,
  });

  String get reference => 'metric:$id';
}

class _FitnessGoalItem {
  final String id;
  final String title;
  final FitnessGoalType goalType;
  final double? currentValue;
  final double? targetValue;
  final String? unit;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  _FitnessGoalItem({
    required this.id,
    required this.title,
    required this.goalType,
    this.currentValue,
    this.targetValue,
    this.unit,
    required this.startDate,
    this.endDate,
    this.description,
  });

  String get reference => 'goal:$id';

  double get progressPercent {
    if (targetValue != null && currentValue != null && targetValue! > 0) {
      return (currentValue! / targetValue! * 100).clamp(0.0, 100.0);
    }
    return 0.0;
  }
}

class ComposeFitnessSheet extends ConsumerWidget {
  final void Function(String reference) onSelected;

  const ComposeFitnessSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: SheetScaffold(
        heightFactor: 0.75,
        titleText: 'fitnessEmbed'.tr(),
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'fitnessEmbedWorkouts'.tr()),
                Tab(text: 'fitnessEmbedMetrics'.tr()),
                Tab(text: 'fitnessEmbedGoals'.tr()),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _WorkoutsTab(onSelected: onSelected),
                  _MetricsTab(onSelected: onSelected),
                  _GoalsTab(onSelected: onSelected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutsTab extends ConsumerWidget {
  final void Function(String reference) onSelected;

  const _WorkoutsTab({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(composeFitnessWorkoutsProvider('current'));

    return workoutsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text('noPublicWorkouts'.tr()));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final workout = items[index];
            return _WorkoutListItem(
              workout: workout,
              onTap: () {
                onSelected(workout.reference);
                Navigator.pop(context);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('errorGeneric'.tr(args: [e.toString()]))),
    );
  }
}

class _WorkoutListItem extends StatelessWidget {
  final _FitnessWorkoutItem workout;
  final VoidCallback onTap;

  const _WorkoutListItem({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final duration = workout.duration;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  _getWorkoutIcon(workout.type),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(workout.startTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (workout.caloriesBurned != null ||
                        duration != null ||
                        (workout.meta != null &&
                            workout.meta!['steps'] != null)) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (duration != null) ...[
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(duration),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                          if (duration != null &&
                              workout.caloriesBurned != null)
                            const SizedBox(width: 12),
                          if (workout.caloriesBurned != null) ...[
                            Icon(
                              Icons.local_fire_department_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${workout.caloriesBurned} ${'calories'.tr()}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (workout.distance != null ||
                        workout.averageHeartRate != null ||
                        workout.averageSpeed != null ||
                        workout.elevationGain != null ||
                        (workout.meta != null &&
                            workout.meta!['steps'] != null)) ...[
                      const SizedBox(height: 8),
                      _buildMetaChips(context),
                    ],
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChips(BuildContext context) {
    final chips = <Widget>[];

    if (workout.distance != null) {
      chips.add(
        _buildChip(
          context,
          Icons.straighten,
          '${workout.distance} ${workout.distanceUnit ?? 'km'}',
        ),
      );
    }

    if (workout.meta != null && workout.meta!['steps'] != null) {
      chips.add(
        _buildChip(context, Icons.directions_walk, '${workout.meta!['steps']}'),
      );
    }

    if (workout.averageHeartRate != null) {
      chips.add(
        _buildChip(
          context,
          Icons.monitor_heart,
          '~${workout.averageHeartRate} bpm',
        ),
      );
    }

    if (workout.averageSpeed != null) {
      chips.add(
        _buildChip(context, Icons.speed, '${workout.averageSpeed} km/h'),
      );
    }

    if (workout.elevationGain != null) {
      chips.add(
        _buildChip(context, Icons.terrain, '+${workout.elevationGain}m'),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 6, runSpacing: 6, children: chips);
  }

  Widget _buildChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWorkoutIcon(WorkoutType type) {
    return switch (type) {
      WorkoutType.strength => Icons.fitness_center,
      WorkoutType.cardio => Icons.directions_run,
      WorkoutType.hiit => Icons.flash_on,
      WorkoutType.yoga => Icons.self_improvement,
      WorkoutType.other => Icons.sports,
    };
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _MetricsTab extends ConsumerWidget {
  final void Function(String reference) onSelected;

  const _MetricsTab({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(composeFitnessMetricsProvider('current'));

    return metricsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text('noPublicMetrics'.tr()));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final metric = items[index];
            return _MetricListItem(
              metric: metric,
              onTap: () {
                onSelected(metric.reference);
                Navigator.pop(context);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('errorGeneric'.tr(args: [e.toString()]))),
    );
  }
}

class _MetricListItem extends StatelessWidget {
  final _FitnessMetricItem metric;
  final VoidCallback onTap;

  const _MetricListItem({required this.metric, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  _getMetricIcon(metric.metricType),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMetricTypeName(metric.metricType),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.monitor_weight_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${metric.value} ${metric.unit}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(metric.recordedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (metric.notes != null && metric.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                metric.notes!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMetricIcon(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => Icons.monitor_weight,
      FitnessMetricType.bodyFat => Icons.percent,
      FitnessMetricType.steps => Icons.directions_walk,
      FitnessMetricType.heartRate => Icons.monitor_heart,
      FitnessMetricType.sleep => Icons.bedtime,
      FitnessMetricType.calories => Icons.local_fire_department,
      FitnessMetricType.waterIntake => Icons.water_drop,
      FitnessMetricType.distance => Icons.straighten,
      FitnessMetricType.custom => Icons.show_chart,
    };
  }

  String _getMetricTypeName(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => 'metricTypeWeight'.tr(),
      FitnessMetricType.bodyFat => 'metricTypeBodyFat'.tr(),
      FitnessMetricType.steps => 'metricTypeSteps'.tr(),
      FitnessMetricType.heartRate => 'metricTypeHeartRate'.tr(),
      FitnessMetricType.sleep => 'metricTypeSleep'.tr(),
      FitnessMetricType.calories => 'metricTypeCalories'.tr(),
      FitnessMetricType.waterIntake => 'metricTypeWaterIntake'.tr(),
      FitnessMetricType.distance => 'metricTypeDistance'.tr(),
      FitnessMetricType.custom => 'metricTypeCustom'.tr(),
    };
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

class _GoalsTab extends ConsumerWidget {
  final void Function(String reference) onSelected;

  const _GoalsTab({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(composeFitnessGoalsProvider('current'));

    return goalsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text('noPublicGoals'.tr()));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final goal = items[index];
            return _GoalListItem(
              goal: goal,
              onTap: () {
                onSelected(goal.reference);
                Navigator.pop(context);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('errorGeneric'.tr(args: [e.toString()]))),
    );
  }
}

class _GoalListItem extends StatelessWidget {
  final _FitnessGoalItem goal;
  final VoidCallback onTap;

  const _GoalListItem({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercent / 100;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      _getGoalIcon(goal.goalType),
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getGoalTypeName(goal.goalType),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (goal.targetValue != null)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                          ),
                          Text(
                            '${goal.progressPercent.toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (goal.targetValue != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.currentValue?.toStringAsFixed(0) ?? 0} ${goal.unit ?? ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${goal.targetValue!.toStringAsFixed(0)} ${goal.unit ?? ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (goal.endDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${'ends'.tr()}: ${_formatDate(goal.endDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGoalIcon(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.weightLoss => Icons.trending_down,
      FitnessGoalType.weightGain => Icons.trending_up,
      FitnessGoalType.steps => Icons.directions_walk,
      FitnessGoalType.distance => Icons.straighten,
      FitnessGoalType.duration => Icons.timer,
      FitnessGoalType.reps => Icons.fitness_center,
      FitnessGoalType.strength => Icons.fitness_center,
      FitnessGoalType.cardio => Icons.directions_run,
      FitnessGoalType.flexibility => Icons.self_improvement,
      FitnessGoalType.custom => Icons.flag,
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
