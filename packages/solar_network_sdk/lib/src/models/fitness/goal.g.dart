// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnFitnessGoal _$SnFitnessGoalFromJson(
  Map<String, dynamic> json,
) => _SnFitnessGoal(
  id: json['id'] as String,
  accountId: json['account_id'] as String,
  goalType: $enumDecode(_$FitnessGoalTypeEnumMap, json['goal_type']),
  title: json['title'] as String,
  description: json['description'] as String?,
  targetValue: (json['target_value'] as num?)?.toDouble(),
  currentValue: (json['current_value'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
  boundWorkoutType: (json['bound_workout_type'] as num?)?.toInt(),
  boundMetricType: (json['bound_metric_type'] as num?)?.toInt(),
  autoUpdateProgress: json['auto_update_progress'] as bool? ?? true,
  startDate: const DateTimeConverter().fromJson(json['start_date'] as String),
  endDate: const NullableDateTimeConverter().fromJson(
    json['end_date'] as String?,
  ),
  status: $enumDecode(_$FitnessGoalStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  createdAt: const DateTimeConverter().fromJson(json['created_at'] as String),
  updatedAt: const DateTimeConverter().fromJson(json['updated_at'] as String),
  repeatType: $enumDecodeNullable(_$RepeatTypeEnumMap, json['repeat_type']),
  repeatInterval: (json['repeat_interval'] as num?)?.toInt(),
  repeatCount: (json['repeat_count'] as num?)?.toInt(),
  currentRepetition: (json['current_repetition'] as num?)?.toInt(),
  parentGoalId: json['parent_goal_id'] as String?,
  visibility:
      $enumDecodeNullable(_$FitnessVisibilityEnumMap, json['visibility']) ??
      FitnessVisibility.private,
);

Map<String, dynamic> _$SnFitnessGoalToJson(_SnFitnessGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'goal_type': _$FitnessGoalTypeEnumMap[instance.goalType]!,
      'title': instance.title,
      'description': instance.description,
      'target_value': instance.targetValue,
      'current_value': instance.currentValue,
      'unit': instance.unit,
      'bound_workout_type': instance.boundWorkoutType,
      'bound_metric_type': instance.boundMetricType,
      'auto_update_progress': instance.autoUpdateProgress,
      'start_date': const DateTimeConverter().toJson(instance.startDate),
      'end_date': const NullableDateTimeConverter().toJson(instance.endDate),
      'status': _$FitnessGoalStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'created_at': const DateTimeConverter().toJson(instance.createdAt),
      'updated_at': const DateTimeConverter().toJson(instance.updatedAt),
      'repeat_type': _$RepeatTypeEnumMap[instance.repeatType],
      'repeat_interval': instance.repeatInterval,
      'repeat_count': instance.repeatCount,
      'current_repetition': instance.currentRepetition,
      'parent_goal_id': instance.parentGoalId,
      'visibility': _$FitnessVisibilityEnumMap[instance.visibility]!,
    };

const _$FitnessGoalTypeEnumMap = {
  FitnessGoalType.weightLoss: 0,
  FitnessGoalType.weightGain: 1,
  FitnessGoalType.steps: 2,
  FitnessGoalType.distance: 3,
  FitnessGoalType.duration: 4,
  FitnessGoalType.reps: 5,
  FitnessGoalType.strength: 6,
  FitnessGoalType.cardio: 7,
  FitnessGoalType.flexibility: 8,
  FitnessGoalType.custom: 9,
};

const _$FitnessGoalStatusEnumMap = {
  FitnessGoalStatus.active: 0,
  FitnessGoalStatus.completed: 1,
  FitnessGoalStatus.paused: 2,
  FitnessGoalStatus.cancelled: 3,
};

const _$RepeatTypeEnumMap = {
  RepeatType.daily: 0,
  RepeatType.weekly: 1,
  RepeatType.biweekly: 2,
  RepeatType.monthly: 3,
  RepeatType.quarterly: 4,
  RepeatType.yearly: 5,
};

const _$FitnessVisibilityEnumMap = {
  FitnessVisibility.private: 0,
  FitnessVisibility.public: 1,
};

_GoalStats _$GoalStatsFromJson(Map<String, dynamic> json) => _GoalStats(
  activeCount: (json['active_count'] as num).toInt(),
  completedCount: (json['completed_count'] as num).toInt(),
);

Map<String, dynamic> _$GoalStatsToJson(_GoalStats instance) =>
    <String, dynamic>{
      'active_count': instance.activeCount,
      'completed_count': instance.completedCount,
    };

_CreateGoalRequest _$CreateGoalRequestFromJson(Map<String, dynamic> json) =>
    _CreateGoalRequest(
      title: json['title'] as String,
      goalType: $enumDecode(_$FitnessGoalTypeEnumMap, json['goal_type']),
      startDate: const DateTimeConverter().fromJson(
        json['start_date'] as String,
      ),
      description: json['description'] as String?,
      targetValue: (json['target_value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      boundWorkoutType: (json['bound_workout_type'] as num?)?.toInt(),
      boundMetricType: (json['bound_metric_type'] as num?)?.toInt(),
      autoUpdateProgress: json['auto_update_progress'] as bool? ?? true,
      endDate: const NullableDateTimeConverter().fromJson(
        json['end_date'] as String?,
      ),
      notes: json['notes'] as String?,
      repeatType: $enumDecodeNullable(_$RepeatTypeEnumMap, json['repeat_type']),
      repeatInterval: (json['repeat_interval'] as num?)?.toInt(),
      repeatCount: (json['repeat_count'] as num?)?.toInt(),
      visibility:
          $enumDecodeNullable(_$FitnessVisibilityEnumMap, json['visibility']) ??
          FitnessVisibility.private,
    );

Map<String, dynamic> _$CreateGoalRequestToJson(_CreateGoalRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'goal_type': _$FitnessGoalTypeEnumMap[instance.goalType]!,
      'start_date': const DateTimeConverter().toJson(instance.startDate),
      'description': instance.description,
      'target_value': instance.targetValue,
      'unit': instance.unit,
      'bound_workout_type': instance.boundWorkoutType,
      'bound_metric_type': instance.boundMetricType,
      'auto_update_progress': instance.autoUpdateProgress,
      'end_date': const NullableDateTimeConverter().toJson(instance.endDate),
      'notes': instance.notes,
      'repeat_type': _$RepeatTypeEnumMap[instance.repeatType],
      'repeat_interval': instance.repeatInterval,
      'repeat_count': instance.repeatCount,
      'visibility': _$FitnessVisibilityEnumMap[instance.visibility]!,
    };

_UpdateGoalRequest _$UpdateGoalRequestFromJson(Map<String, dynamic> json) =>
    _UpdateGoalRequest(
      title: json['title'] as String,
      goalType: $enumDecode(_$FitnessGoalTypeEnumMap, json['goal_type']),
      startDate: const DateTimeConverter().fromJson(
        json['start_date'] as String,
      ),
      status: $enumDecode(_$FitnessGoalStatusEnumMap, json['status']),
      description: json['description'] as String?,
      targetValue: (json['target_value'] as num?)?.toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      boundWorkoutType: (json['bound_workout_type'] as num?)?.toInt(),
      boundMetricType: (json['bound_metric_type'] as num?)?.toInt(),
      autoUpdateProgress: json['auto_update_progress'] as bool?,
      endDate: const NullableDateTimeConverter().fromJson(
        json['end_date'] as String?,
      ),
      notes: json['notes'] as String?,
      visibility: $enumDecodeNullable(
        _$FitnessVisibilityEnumMap,
        json['visibility'],
      ),
    );

Map<String, dynamic> _$UpdateGoalRequestToJson(_UpdateGoalRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'goal_type': _$FitnessGoalTypeEnumMap[instance.goalType]!,
      'start_date': const DateTimeConverter().toJson(instance.startDate),
      'status': _$FitnessGoalStatusEnumMap[instance.status]!,
      'description': instance.description,
      'target_value': instance.targetValue,
      'current_value': instance.currentValue,
      'unit': instance.unit,
      'bound_workout_type': instance.boundWorkoutType,
      'bound_metric_type': instance.boundMetricType,
      'auto_update_progress': instance.autoUpdateProgress,
      'end_date': const NullableDateTimeConverter().toJson(instance.endDate),
      'notes': instance.notes,
      'visibility': _$FitnessVisibilityEnumMap[instance.visibility],
    };

_UpdateProgressRequest _$UpdateProgressRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateProgressRequest(
  currentValue: (json['current_value'] as num).toDouble(),
);

Map<String, dynamic> _$UpdateProgressRequestToJson(
  _UpdateProgressRequest instance,
) => <String, dynamic>{'current_value': instance.currentValue};

_UpdateGoalStatusRequest _$UpdateGoalStatusRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateGoalStatusRequest(
  status: $enumDecode(_$FitnessGoalStatusEnumMap, json['status']),
);

Map<String, dynamic> _$UpdateGoalStatusRequestToJson(
  _UpdateGoalStatusRequest instance,
) => <String, dynamic>{'status': _$FitnessGoalStatusEnumMap[instance.status]!};
