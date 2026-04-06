import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final fitnessClientProvider = Provider<FitnessApi>((ref) {
  final client = ref.watch(solarNetworkClientProvider);
  return client.fitness;
});

final workoutsProvider = FutureProvider.autoDispose
    .family<PaginatedResult<SnWorkout>, ({int skip, int take})>((
      ref,
      params,
    ) async {
      final fitness = ref.watch(fitnessClientProvider);
      return fitness.getWorkouts(skip: params.skip, take: params.take);
    });

final workoutDetailProvider = FutureProvider.autoDispose
    .family<SnWorkout, String>((ref, id) async {
      final fitness = ref.watch(fitnessClientProvider);
      return fitness.getWorkout(id);
    });

final workoutGoalsProvider = FutureProvider.autoDispose
    .family<
      PaginatedResult<SnFitnessGoal>,
      ({FitnessGoalStatus? status, int skip, int take})
    >((ref, params) async {
      final fitness = ref.watch(fitnessClientProvider);
      return fitness.getGoals(
        status: params.status,
        skip: params.skip,
        take: params.take,
      );
    });

final goalStatsProvider = FutureProvider.autoDispose<GoalStats>((ref) async {
  final fitness = ref.watch(fitnessClientProvider);
  return fitness.getGoalStats();
});

final goalDetailProvider = FutureProvider.autoDispose
    .family<SnFitnessGoal, String>((ref, id) async {
      final fitness = ref.watch(fitnessClientProvider);
      return fitness.getGoal(id);
    });

final metricsProvider = FutureProvider.autoDispose
    .family<
      PaginatedResult<SnFitnessMetric>,
      ({FitnessMetricType? type, int skip, int take})
    >((ref, params) async {
      final fitness = ref.watch(fitnessClientProvider);
      return fitness.getMetrics(
        type: params.type,
        skip: params.skip,
        take: params.take,
      );
    });

final metricDetailProvider = FutureProvider.autoDispose
    .family<SnFitnessMetric, String>((ref, id) async {
      final fitness = ref.watch(fitnessClientProvider);
      return fitness.getMetric(id);
    });

final exercisesProvider = FutureProvider.autoDispose
    .family<
      PaginatedResult<SnExerciseLibrary>,
      ({ExerciseCategory? category, int skip, int take})
    >((ref, params) async {
      final fitness = ref.watch(fitnessClientProvider);
      return fitness.getExercises(
        category: params.category,
        skip: params.skip,
        take: params.take,
      );
    });

final exerciseDetailProvider = FutureProvider.autoDispose
    .family<SnExerciseLibrary, String>((ref, id) async {
      final fitness = ref.watch(fitnessClientProvider);
      return fitness.getExercise(id);
    });

class WorkoutNotifier extends AsyncNotifier<SnWorkout> {
  @override
  Future<SnWorkout> build() async {
    throw UnimplementedError('Use workoutDetailProvider instead');
  }

  Future<SnWorkout> createWorkout(CreateWorkoutRequest request) async {
    final fitness = ref.read(fitnessClientProvider);
    final workout = await fitness.createWorkout(request);
    ref.invalidate(workoutsProvider);
    return workout;
  }

  Future<SnWorkout> updateWorkout(
    String id,
    UpdateWorkoutRequest request,
  ) async {
    final fitness = ref.read(fitnessClientProvider);
    final workout = await fitness.updateWorkout(id, request);
    ref.invalidate(workoutsProvider);
    ref.invalidate(workoutDetailProvider(id));
    return workout;
  }

  Future<void> deleteWorkout(String id) async {
    final fitness = ref.read(fitnessClientProvider);
    await fitness.deleteWorkout(id);
    ref.invalidate(workoutsProvider);
  }

  Future<int> updateWorkoutsVisibility({
    required List<String> workoutIds,
    required FitnessVisibility visibility,
  }) async {
    final fitness = ref.read(fitnessClientProvider);
    final count = await fitness.updateWorkoutsVisibility(
      workoutIds: workoutIds,
      visibility: visibility,
    );
    ref.invalidate(workoutsProvider);
    for (final id in workoutIds) {
      ref.invalidate(workoutDetailProvider(id));
    }
    return count;
  }

  Future<SnWorkoutExercise> addExercise(
    String workoutId,
    AddExerciseRequest request,
  ) async {
    final fitness = ref.read(fitnessClientProvider);
    final exercise = await fitness.addExercise(workoutId, request);
    ref.invalidate(workoutDetailProvider(workoutId));
    return exercise;
  }

  Future<SnWorkoutExercise> updateExercise(
    String exerciseId,
    UpdateWorkoutExerciseRequest request,
  ) async {
    final fitness = ref.read(fitnessClientProvider);
    return fitness.updateExercise(exerciseId, request);
  }

  Future<void> removeExercise(String exerciseId, String workoutId) async {
    final fitness = ref.read(fitnessClientProvider);
    await fitness.removeExercise(exerciseId);
    ref.invalidate(workoutDetailProvider(workoutId));
  }
}

final workoutNotifierProvider =
    AsyncNotifierProvider<WorkoutNotifier, SnWorkout>(WorkoutNotifier.new);

class GoalNotifier extends AsyncNotifier<SnFitnessGoal> {
  @override
  Future<SnFitnessGoal> build() async {
    throw UnimplementedError('Use goalDetailProvider instead');
  }

  Future<SnFitnessGoal> createGoal(CreateGoalRequest request) async {
    final fitness = ref.read(fitnessClientProvider);
    final goal = await fitness.createGoal(request);
    ref.invalidate(workoutGoalsProvider);
    ref.invalidate(goalStatsProvider);
    return goal;
  }

  Future<SnFitnessGoal> updateGoal(String id, UpdateGoalRequest request) async {
    final fitness = ref.read(fitnessClientProvider);
    final goal = await fitness.updateGoal(id, request);
    ref.invalidate(workoutGoalsProvider);
    ref.invalidate(goalDetailProvider(id));
    return goal;
  }

  Future<SnFitnessGoal> updateGoalProgress(
    String id,
    double currentValue,
  ) async {
    final fitness = ref.read(fitnessClientProvider);
    final goal = await fitness.updateProgress(
      id,
      UpdateProgressRequest(currentValue: currentValue),
    );
    ref.invalidate(workoutGoalsProvider);
    ref.invalidate(goalDetailProvider(id));
    return goal;
  }

  Future<SnFitnessGoal> updateGoalStatus(
    String id,
    FitnessGoalStatus status,
  ) async {
    final fitness = ref.read(fitnessClientProvider);
    final goal = await fitness.updateGoalStatus(
      id,
      UpdateGoalStatusRequest(status: status),
    );
    ref.invalidate(workoutGoalsProvider);
    ref.invalidate(goalDetailProvider(id));
    ref.invalidate(goalStatsProvider);
    return goal;
  }

  Future<void> deleteGoal(String id) async {
    final fitness = ref.read(fitnessClientProvider);
    await fitness.deleteGoal(id);
    ref.invalidate(workoutGoalsProvider);
    ref.invalidate(goalStatsProvider);
  }

  Future<int> updateGoalsVisibility({
    required List<String> goalIds,
    required FitnessVisibility visibility,
  }) async {
    final fitness = ref.read(fitnessClientProvider);
    final count = await fitness.updateGoalsVisibility(
      goalIds: goalIds,
      visibility: visibility,
    );
    ref.invalidate(workoutGoalsProvider);
    ref.invalidate(goalStatsProvider);
    for (final id in goalIds) {
      ref.invalidate(goalDetailProvider(id));
    }
    return count;
  }

  Future<SnFitnessGoal> recalculateGoal(String id) async {
    final fitness = ref.read(fitnessClientProvider);
    final goal = await fitness.recalculateGoal(id);
    ref.invalidate(workoutGoalsProvider);
    ref.invalidate(goalDetailProvider(id));
    return goal;
  }
}

final goalNotifierProvider = AsyncNotifierProvider<GoalNotifier, SnFitnessGoal>(
  GoalNotifier.new,
);

class MetricNotifier extends AsyncNotifier<SnFitnessMetric> {
  @override
  Future<SnFitnessMetric> build() async {
    throw UnimplementedError('Use metricDetailProvider instead');
  }

  Future<SnFitnessMetric> createMetric(CreateMetricRequest request) async {
    final fitness = ref.read(fitnessClientProvider);
    final metric = await fitness.createMetric(request);
    ref.invalidate(metricsProvider);
    return metric;
  }

  Future<SnFitnessMetric> updateMetric(
    String id,
    UpdateMetricRequest request,
  ) async {
    final fitness = ref.read(fitnessClientProvider);
    final metric = await fitness.updateMetric(id, request);
    ref.invalidate(metricsProvider);
    ref.invalidate(metricDetailProvider(id));
    return metric;
  }

  Future<void> deleteMetric(String id) async {
    final fitness = ref.read(fitnessClientProvider);
    await fitness.deleteMetric(id);
    ref.invalidate(metricsProvider);
  }

  Future<int> updateMetricsVisibility({
    required List<String> metricIds,
    required FitnessVisibility visibility,
  }) async {
    final fitness = ref.read(fitnessClientProvider);
    final count = await fitness.updateMetricsVisibility(
      metricIds: metricIds,
      visibility: visibility,
    );
    ref.invalidate(metricsProvider);
    for (final id in metricIds) {
      ref.invalidate(metricDetailProvider(id));
    }
    return count;
  }
}

final metricNotifierProvider =
    AsyncNotifierProvider<MetricNotifier, SnFitnessMetric>(MetricNotifier.new);

class ExerciseNotifier extends AsyncNotifier<SnExerciseLibrary> {
  @override
  Future<SnExerciseLibrary> build() async {
    throw UnimplementedError('Use exerciseDetailProvider instead');
  }

  Future<SnExerciseLibrary> createExercise(
    CreateExerciseRequest request,
  ) async {
    final fitness = ref.read(fitnessClientProvider);
    final exercise = await fitness.createExercise(request);
    ref.invalidate(exercisesProvider);
    return exercise;
  }

  Future<SnExerciseLibrary> updateExerciseLibrary(
    String id,
    UpdateExerciseLibraryRequest request,
  ) async {
    final fitness = ref.read(fitnessClientProvider);
    final exercise = await fitness.updateExerciseLibrary(id, request);
    ref.invalidate(exercisesProvider);
    ref.invalidate(exerciseDetailProvider(id));
    return exercise;
  }

  Future<void> deleteExercise(String id) async {
    final fitness = ref.read(fitnessClientProvider);
    await fitness.deleteExercise(id);
    ref.invalidate(exercisesProvider);
  }
}

final exerciseNotifierProvider =
    AsyncNotifierProvider<ExerciseNotifier, SnExerciseLibrary>(
      ExerciseNotifier.new,
    );
