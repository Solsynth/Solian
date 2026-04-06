import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/fitness/screens/workout_record_screen.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  final Set<String> _selected = {};
  List<SnWorkout> _currentWorkouts = [];
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

  void _selectAllWorkouts() {
    setState(() {
      _selected.clear();
      for (final workout in _currentWorkouts) {
        _selected.add(workout.id);
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
          .read(workoutNotifierProvider.notifier)
          .updateWorkoutsVisibility(
            workoutIds: _selected.toList(),
            visibility: visibility,
          );
      if (context.mounted) {
        showSnackBar('Updated visibility for $count workouts');
        _clearSelection();
      }
    } catch (e) {
      showErrorAlert('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutsProvider((skip: 0, take: 50)));

    return AppScaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selected.length} selected')
            : const Text('Workouts'),
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
                  _selectAllWorkouts();
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
          ref.invalidate(workoutsProvider((skip: 0, take: 50)));
        },
        child: workoutsAsync.when(
          data: (result) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _currentWorkouts = result.items;
            });
            if (result.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No workouts yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showRecordWorkoutSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Record Workout'),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: result.items.length,
              itemBuilder: (context, index) {
                final workout = result.items[index];
                return _WorkoutCard(
                  workout: workout,
                  isSelectionMode: _isSelectionMode,
                  isSelected: _selected.contains(workout.id),
                  onTap: _isSelectionMode
                      ? () => _toggleSelection(workout.id)
                      : null,
                  onLongPress: () => _toggleSelection(workout.id),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordWorkoutSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Record Workout'),
      ),
    );
  }

  void _showRecordWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const WorkoutRecordScreen(),
    );
  }
}

class _WorkoutCard extends ConsumerWidget {
  final SnWorkout workout;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _WorkoutCard({
    required this.workout,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = workout.endTime != null
        ? workout.endTime!.difference(workout.startTime)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (isSelectionMode)
                Checkbox(value: isSelected, onChanged: (_) => onTap?.call()),
              if (isSelectionMode) const SizedBox(width: 8),
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
                    if (workout.caloriesBurned != null || duration != null)
                      const SizedBox(height: 4),
                    if (workout.caloriesBurned != null || duration != null)
                      Row(
                        children: [
                          if (duration != null) ...[
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(duration),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${workout.caloriesBurned} kcal',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Symbols.delete,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => _showDeleteDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(workoutNotifierProvider.notifier)
                    .deleteWorkout(workout.id);
              } catch (e) {
                showErrorAlert('Error: $e');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
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
