import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/fitness/screens/goal_create_screen.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final Set<String> _selected = {};
  List<SnFitnessGoal> _currentGoals = [];
  bool _isSelectionMode = false;

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      if (_selected.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAllGoals() {
    setState(() {
      _selected.clear();
      for (final goal in _currentGoals) {
        _selected.add(goal.id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selected.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _updateSelectedVisibility(
    BuildContext context,
    WidgetRef ref,
    FitnessVisibility visibility,
  ) async {
    if (_selected.isEmpty) return;

    try {
      final count = await ref
          .read(goalNotifierProvider.notifier)
          .updateGoalsVisibility(
            goalIds: _selected.toList(),
            visibility: visibility,
          );
      if (context.mounted) {
        showSnackBar('Updated visibility for $count goals');
        _clearSelection();
      }
    } catch (e) {
      showErrorAlert('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(
      workoutGoalsProvider((status: null, skip: 0, take: 50)),
    );

    return AppScaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selected.length} selected')
            : const Text('Goals'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.visibility),
              tooltip: 'Set Visibility',
              onSelected: (value) {
                if (value == 'selectAll') {
                  _selectAllGoals();
                } else if (value == 'private' || value == 'public') {
                  _updateSelectedVisibility(
                    context,
                    ref,
                    value == 'private'
                        ? FitnessVisibility.private
                        : FitnessVisibility.public,
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'selectAll',
                  child: Row(
                    children: [
                      Icon(
                        Icons.select_all,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(width: 12),
                      Text('Select All'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'private',
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(width: 12),
                      Text('Set Private'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'public',
                  child: Row(
                    children: [
                      Icon(
                        Icons.public,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(width: 12),
                      Text('Set Public'),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: 'Select',
              onPressed: _enterSelectionMode,
            ),
          ],
          const Gap(8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            workoutGoalsProvider((status: null, skip: 0, take: 50)),
          );
        },
        child: goalsAsync.when(
          data: (result) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _currentGoals = result.items;
            });
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
                return _GoalCard(
                  goal: goal,
                  isSelectionMode: _isSelectionMode,
                  isSelected: _selected.contains(goal.id),
                  onTap: _isSelectionMode
                      ? () => _toggleSelection(goal.id)
                      : () => context.router.push(GoalDetailRoute(id: goal.id)),
                  onLongPress: () => _toggleSelection(goal.id),
                );
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
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _GoalCard({
    required this.goal,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

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
        onTap: isSelectionMode ? onTap : onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onTap?.call(),
                    ),
                  if (isSelectionMode) const SizedBox(width: 8),
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
