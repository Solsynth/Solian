import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/fitness/screens/workout_record_screen.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutsProvider((skip: 0, take: 50)));

    return AppScaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workoutsProvider((skip: 0, take: 50)));
        },
        child: workoutsAsync.when(
          data: (result) {
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
                return _WorkoutCard(workout: workout);
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

class _WorkoutCard extends StatelessWidget {
  final SnWorkout workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final duration = workout.endTime != null
        ? workout.endTime!.difference(workout.startTime)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
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
                        if (duration != null && workout.caloriesBurned != null)
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
          ],
        ),
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
