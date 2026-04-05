import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              return const Center(child: Text('No workouts yet'));
            }
            return ListView.builder(
              itemCount: result.items.length,
              itemBuilder: (context, index) {
                final workout = result.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_getWorkoutIcon(workout.type)),
                    ),
                    title: Text(workout.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatDate(workout.startTime)),
                        if (workout.caloriesBurned != null)
                          Text('${workout.caloriesBurned} calories'),
                      ],
                    ),
                    isThreeLine: workout.caloriesBurned != null,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create workout route
        },
        child: const Icon(Icons.add),
      ),
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
