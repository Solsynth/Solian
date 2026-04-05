import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

enum WorkoutType {
  @JsonValue(0)
  strength,
  @JsonValue(1)
  cardio,
  @JsonValue(2)
  hiit,
  @JsonValue(3)
  yoga,
  @JsonValue(4)
  other,
}

@freezed
sealed class SnWorkout with _$SnWorkout {
  const factory SnWorkout({
    required String id,
    required String accountId,
    required String name,
    String? description,
    required WorkoutType type,
    required DateTime startTime,
    DateTime? endTime,
    String? duration,
    int? caloriesBurned,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<SnWorkoutExercise> exercises,
  }) = _SnWorkout;

  factory SnWorkout.fromJson(Map<String, dynamic> json) =>
      _$SnWorkoutFromJson(json);
}

@freezed
sealed class SnWorkoutExercise with _$SnWorkoutExercise {
  const factory SnWorkoutExercise({
    required String id,
    required String workoutId,
    required String exerciseName,
    int? sets,
    int? reps,
    double? weight,
    String? duration,
    String? notes,
    required int orderIndex,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SnWorkoutExercise;

  factory SnWorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$SnWorkoutExerciseFromJson(json);
}

@freezed
sealed class CreateWorkoutRequest with _$CreateWorkoutRequest {
  const factory CreateWorkoutRequest({
    required String name,
    required WorkoutType type,
    @DateTimeConverter() required DateTime startTime,
    @NullableDateTimeConverter() DateTime? endTime,
    String? description,
    String? externalId,
    int? caloriesBurned,
    String? notes,
  }) = _CreateWorkoutRequest;

  factory CreateWorkoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkoutRequestFromJson(json);
}

@freezed
sealed class UpdateWorkoutRequest with _$UpdateWorkoutRequest {
  const factory UpdateWorkoutRequest({
    required String name,
    required WorkoutType type,
    @DateTimeConverter() required DateTime startTime,
    String? description,
    String? duration,
    int? caloriesBurned,
    String? notes,
  }) = _UpdateWorkoutRequest;

  factory UpdateWorkoutRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateWorkoutRequestFromJson(json);
}

@freezed
sealed class AddExerciseRequest with _$AddExerciseRequest {
  const factory AddExerciseRequest({
    required String exerciseName,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
    required int orderIndex,
  }) = _AddExerciseRequest;

  factory AddExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$AddExerciseRequestFromJson(json);
}

@freezed
sealed class UpdateWorkoutExerciseRequest with _$UpdateWorkoutExerciseRequest {
  const factory UpdateWorkoutExerciseRequest({
    required String exerciseName,
    int? sets,
    int? reps,
    double? weight,
    int? orderIndex,
    String? notes,
  }) = _UpdateWorkoutExerciseRequest;

  factory UpdateWorkoutExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateWorkoutExerciseRequestFromJson(json);
}

@freezed
sealed class CreateWorkoutsBatchRequest with _$CreateWorkoutsBatchRequest {
  const factory CreateWorkoutsBatchRequest({
    required List<CreateWorkoutRequest> workouts,
  }) = _CreateWorkoutsBatchRequest;

  factory CreateWorkoutsBatchRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkoutsBatchRequestFromJson(json);
}
