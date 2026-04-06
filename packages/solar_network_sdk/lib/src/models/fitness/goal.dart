import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'workout.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

enum FitnessGoalType {
  @JsonValue(0)
  weightLoss,
  @JsonValue(1)
  weightGain,
  @JsonValue(2)
  steps,
  @JsonValue(3)
  distance,
  @JsonValue(4)
  duration,
  @JsonValue(5)
  reps,
  @JsonValue(6)
  strength,
  @JsonValue(7)
  cardio,
  @JsonValue(8)
  flexibility,
  @JsonValue(9)
  custom,
}

enum FitnessGoalStatus {
  @JsonValue(0)
  active,
  @JsonValue(1)
  completed,
  @JsonValue(2)
  paused,
  @JsonValue(3)
  cancelled,
}

enum RepeatType {
  @JsonValue(0)
  daily,
  @JsonValue(1)
  weekly,
  @JsonValue(2)
  biweekly,
  @JsonValue(3)
  monthly,
  @JsonValue(4)
  quarterly,
  @JsonValue(5)
  yearly,
}

@freezed
sealed class SnFitnessGoal with _$SnFitnessGoal {
  const factory SnFitnessGoal({
    required String id,
    required String accountId,
    required FitnessGoalType goalType,
    required String title,
    String? description,
    double? targetValue,
    double? currentValue,
    String? unit,
    int? boundWorkoutType,
    int? boundMetricType,
    @Default(true) bool autoUpdateProgress,
    @DateTimeConverter() required DateTime startDate,
    @NullableDateTimeConverter() DateTime? endDate,
    required FitnessGoalStatus status,
    String? notes,
    @DateTimeConverter() required DateTime createdAt,
    @DateTimeConverter() required DateTime updatedAt,
    RepeatType? repeatType,
    int? repeatInterval,
    int? repeatCount,
    int? currentRepetition,
    String? parentGoalId,
    @Default(FitnessVisibility.private) FitnessVisibility visibility,
  }) = _SnFitnessGoal;

  factory SnFitnessGoal.fromJson(Map<String, dynamic> json) =>
      _$SnFitnessGoalFromJson(json);
}

@freezed
sealed class GoalStats with _$GoalStats {
  const factory GoalStats({
    required int activeCount,
    required int completedCount,
  }) = _GoalStats;

  factory GoalStats.fromJson(Map<String, dynamic> json) =>
      _$GoalStatsFromJson(json);
}

@freezed
sealed class CreateGoalRequest with _$CreateGoalRequest {
  const factory CreateGoalRequest({
    required String title,
    required FitnessGoalType goalType,
    @DateTimeConverter() required DateTime startDate,
    String? description,
    double? targetValue,
    String? unit,
    int? boundWorkoutType,
    int? boundMetricType,
    @Default(true) bool autoUpdateProgress,
    @NullableDateTimeConverter() DateTime? endDate,
    String? notes,
    RepeatType? repeatType,
    int? repeatInterval,
    int? repeatCount,
    @Default(FitnessVisibility.private) FitnessVisibility visibility,
  }) = _CreateGoalRequest;

  factory CreateGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGoalRequestFromJson(json);
}

@freezed
sealed class UpdateGoalRequest with _$UpdateGoalRequest {
  const factory UpdateGoalRequest({
    required String title,
    required FitnessGoalType goalType,
    @DateTimeConverter() required DateTime startDate,
    required FitnessGoalStatus status,
    String? description,
    double? targetValue,
    double? currentValue,
    String? unit,
    int? boundWorkoutType,
    int? boundMetricType,
    bool? autoUpdateProgress,
    @NullableDateTimeConverter() DateTime? endDate,
    String? notes,
    FitnessVisibility? visibility,
  }) = _UpdateGoalRequest;

  factory UpdateGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGoalRequestFromJson(json);
}

@freezed
sealed class UpdateProgressRequest with _$UpdateProgressRequest {
  const factory UpdateProgressRequest({required double currentValue}) =
      _UpdateProgressRequest;

  factory UpdateProgressRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProgressRequestFromJson(json);
}

@freezed
sealed class UpdateGoalStatusRequest with _$UpdateGoalStatusRequest {
  const factory UpdateGoalStatusRequest({required FitnessGoalStatus status}) =
      _UpdateGoalStatusRequest;

  factory UpdateGoalStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGoalStatusRequestFromJson(json);
}
