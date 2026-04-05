import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

enum FitnessGoalType {
  @JsonValue(0)
  weightLoss,
  @JsonValue(1)
  muscleGain,
  @JsonValue(2)
  endurance,
  @JsonValue(3)
  steps,
  @JsonValue(4)
  custom,
}

enum FitnessGoalStatus {
  @JsonValue(0)
  active,
  @JsonValue(1)
  completed,
  @JsonValue(2)
  cancelled,
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
    required DateTime startDate,
    DateTime? endDate,
    required FitnessGoalStatus status,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
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
    required DateTime startDate,
    String? description,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? endDate,
    String? notes,
  }) = _CreateGoalRequest;

  factory CreateGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGoalRequestFromJson(json);
}

@freezed
sealed class UpdateGoalRequest with _$UpdateGoalRequest {
  const factory UpdateGoalRequest({
    required String title,
    required FitnessGoalType goalType,
    required DateTime startDate,
    required FitnessGoalStatus status,
    String? description,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? endDate,
    String? notes,
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
