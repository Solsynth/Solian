import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/fitness/workout.dart'
    as workout_models;
import 'package:solar_network_sdk/src/models/fitness/goal.dart' as goal_models;
import 'package:solar_network_sdk/src/models/fitness/metric.dart'
    as metric_models;
import 'package:solar_network_sdk/src/models/fitness/exercise.dart'
    as exercise_models;

class FitnessApi extends BaseApi {
  FitnessApi(super.dio);

  static const String _basePath = '/fitness';

  // ==========================================
  // Workout endpoints
  // ==========================================

  Future<PaginatedResult<workout_models.SnWorkout>> getWorkouts({
    int skip = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/workouts',
      queryParameters: {'skip': skip, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, workout_models.SnWorkout.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  Future<workout_models.SnWorkout> getWorkout(String id) async {
    final response = await get<Map<String, dynamic>>('$_basePath/workouts/$id');
    return workout_models.SnWorkout.fromJson(response.data!);
  }

  Future<workout_models.SnWorkout> createWorkout(
    workout_models.CreateWorkoutRequest request,
  ) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/workouts',
      data: request.toJson(),
    );
    return workout_models.SnWorkout.fromJson(response.data!);
  }

  Future<workout_models.SnWorkout> updateWorkout(
    String id,
    workout_models.UpdateWorkoutRequest request,
  ) async {
    final response = await put<Map<String, dynamic>>(
      '$_basePath/workouts/$id',
      data: request.toJson(),
    );
    return workout_models.SnWorkout.fromJson(response.data!);
  }

  Future<void> deleteWorkout(String id) async {
    await delete('$_basePath/workouts/$id');
  }

  Future<void> createWorkoutsBatch(
    workout_models.CreateWorkoutsBatchRequest request,
  ) async {
    await post<List<dynamic>>(
      '$_basePath/workouts/batch',
      data: request.toJson(),
    );
  }

  Future<workout_models.SnWorkoutExercise> addExercise(
    String workoutId,
    workout_models.AddExerciseRequest request,
  ) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/workouts/$workoutId/exercises',
      data: request.toJson(),
    );
    return workout_models.SnWorkoutExercise.fromJson(response.data!);
  }

  Future<workout_models.SnWorkoutExercise> updateExercise(
    String exerciseId,
    workout_models.UpdateWorkoutExerciseRequest request,
  ) async {
    final response = await put<Map<String, dynamic>>(
      '$_basePath/workouts/exercises/$exerciseId',
      data: request.toJson(),
    );
    return workout_models.SnWorkoutExercise.fromJson(response.data!);
  }

  Future<void> removeExercise(String exerciseId) async {
    await delete('$_basePath/workouts/exercises/$exerciseId');
  }

  // ==========================================
  // Goal endpoints
  // ==========================================

  Future<PaginatedResult<goal_models.SnFitnessGoal>> getGoals({
    goal_models.FitnessGoalStatus? status,
    int skip = 0,
    int take = 20,
  }) async {
    final queryParams = <String, dynamic>{'skip': skip, 'take': take};
    if (status != null) queryParams['status'] = status.index;

    final response = await get<List<dynamic>>(
      '$_basePath/goals',
      queryParameters: queryParams,
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, goal_models.SnFitnessGoal.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  Future<goal_models.GoalStats> getGoalStats() async {
    final response = await get<Map<String, dynamic>>('$_basePath/goals/stats');
    return goal_models.GoalStats.fromJson(response.data!);
  }

  Future<goal_models.SnFitnessGoal> getGoal(String id) async {
    final response = await get<Map<String, dynamic>>('$_basePath/goals/$id');
    return goal_models.SnFitnessGoal.fromJson(response.data!);
  }

  Future<goal_models.SnFitnessGoal> createGoal(
    goal_models.CreateGoalRequest request,
  ) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/goals',
      data: request.toJson(),
    );
    return goal_models.SnFitnessGoal.fromJson(response.data!);
  }

  Future<goal_models.SnFitnessGoal> updateGoal(
    String id,
    goal_models.UpdateGoalRequest request,
  ) async {
    final response = await put<Map<String, dynamic>>(
      '$_basePath/goals/$id',
      data: request.toJson(),
    );
    return goal_models.SnFitnessGoal.fromJson(response.data!);
  }

  Future<goal_models.SnFitnessGoal> updateProgress(
    String id,
    goal_models.UpdateProgressRequest request,
  ) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/goals/$id/progress',
      data: request.toJson(),
    );
    return goal_models.SnFitnessGoal.fromJson(response.data!);
  }

  Future<goal_models.SnFitnessGoal> updateGoalStatus(
    String id,
    goal_models.UpdateGoalStatusRequest request,
  ) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/goals/$id/status',
      data: request.toJson(),
    );
    return goal_models.SnFitnessGoal.fromJson(response.data!);
  }

  Future<void> deleteGoal(String id) async {
    await delete('$_basePath/goals/$id');
  }

  // ==========================================
  // Metric endpoints
  // ==========================================

  Future<PaginatedResult<metric_models.SnFitnessMetric>> getMetrics({
    metric_models.FitnessMetricType? type,
    int skip = 0,
    int take = 20,
  }) async {
    final queryParams = <String, dynamic>{'skip': skip, 'take': take};
    if (type != null) queryParams['type'] = type.index;

    final response = await get<List<dynamic>>(
      '$_basePath/metrics',
      queryParameters: queryParams,
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, metric_models.SnFitnessMetric.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  Future<metric_models.SnFitnessMetric> getMetric(String id) async {
    final response = await get<Map<String, dynamic>>('$_basePath/metrics/$id');
    return metric_models.SnFitnessMetric.fromJson(response.data!);
  }

  Future<metric_models.SnFitnessMetric> createMetric(
    metric_models.CreateMetricRequest request,
  ) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/metrics',
      data: request.toJson(),
    );
    return metric_models.SnFitnessMetric.fromJson(response.data!);
  }

  Future<metric_models.SnFitnessMetric> updateMetric(
    String id,
    metric_models.UpdateMetricRequest request,
  ) async {
    final response = await put<Map<String, dynamic>>(
      '$_basePath/metrics/$id',
      data: request.toJson(),
    );
    return metric_models.SnFitnessMetric.fromJson(response.data!);
  }

  Future<void> deleteMetric(String id) async {
    await delete('$_basePath/metrics/$id');
  }

  Future<void> createMetricsBatch(
    metric_models.CreateMetricsBatchRequest request,
  ) async {
    await post<List<dynamic>>(
      '$_basePath/metrics/batch',
      data: request.toJson(),
    );
  }

  // ==========================================
  // Exercise Library endpoints
  // ==========================================

  Future<PaginatedResult<exercise_models.SnExerciseLibrary>> getExercises({
    exercise_models.ExerciseCategory? category,
    int skip = 0,
    int take = 20,
  }) async {
    final queryParams = <String, dynamic>{'skip': skip, 'take': take};
    if (category != null) queryParams['category'] = category.index;

    final response = await get<List<dynamic>>(
      '$_basePath/exercises',
      queryParameters: queryParams,
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(
      response,
      exercise_models.SnExerciseLibrary.fromJson,
    );
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  Future<exercise_models.SnExerciseLibrary> getExercise(String id) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/exercises/$id',
    );
    return exercise_models.SnExerciseLibrary.fromJson(response.data!);
  }

  Future<exercise_models.SnExerciseLibrary> createExercise(
    exercise_models.CreateExerciseRequest request,
  ) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/exercises',
      data: request.toJson(),
    );
    return exercise_models.SnExerciseLibrary.fromJson(response.data!);
  }

  Future<exercise_models.SnExerciseLibrary> updateExerciseLibrary(
    String id,
    exercise_models.UpdateExerciseLibraryRequest request,
  ) async {
    final response = await put<Map<String, dynamic>>(
      '$_basePath/exercises/$id',
      data: request.toJson(),
    );
    return exercise_models.SnExerciseLibrary.fromJson(response.data!);
  }

  Future<void> deleteExercise(String id) async {
    await delete('$_basePath/exercises/$id');
  }
}
