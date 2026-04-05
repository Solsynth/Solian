// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnFitnessGoal _$SnFitnessGoalFromJson(Map<String, dynamic> json) =>
    _SnFitnessGoal(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      goalType: $enumDecode(_$FitnessGoalTypeEnumMap, json['goal_type']),
      title: json['title'] as String,
      description: json['description'] as String?,
      targetValue: (json['target_value'] as num?)?.toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      status: $enumDecode(_$FitnessGoalStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'status': _$FitnessGoalStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$FitnessGoalTypeEnumMap = {
  FitnessGoalType.weightLoss: 0,
  FitnessGoalType.muscleGain: 1,
  FitnessGoalType.endurance: 2,
  FitnessGoalType.steps: 3,
  FitnessGoalType.custom: 4,
};

const _$FitnessGoalStatusEnumMap = {
  FitnessGoalStatus.active: 0,
  FitnessGoalStatus.completed: 1,
  FitnessGoalStatus.cancelled: 2,
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
      startDate: DateTime.parse(json['start_date'] as String),
      description: json['description'] as String?,
      targetValue: (json['target_value'] as num?)?.toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateGoalRequestToJson(_CreateGoalRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'goal_type': _$FitnessGoalTypeEnumMap[instance.goalType]!,
      'start_date': instance.startDate.toIso8601String(),
      'description': instance.description,
      'target_value': instance.targetValue,
      'current_value': instance.currentValue,
      'unit': instance.unit,
      'end_date': instance.endDate?.toIso8601String(),
      'notes': instance.notes,
    };

_UpdateGoalRequest _$UpdateGoalRequestFromJson(Map<String, dynamic> json) =>
    _UpdateGoalRequest(
      title: json['title'] as String,
      goalType: $enumDecode(_$FitnessGoalTypeEnumMap, json['goal_type']),
      startDate: DateTime.parse(json['start_date'] as String),
      status: $enumDecode(_$FitnessGoalStatusEnumMap, json['status']),
      description: json['description'] as String?,
      targetValue: (json['target_value'] as num?)?.toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$UpdateGoalRequestToJson(_UpdateGoalRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'goal_type': _$FitnessGoalTypeEnumMap[instance.goalType]!,
      'start_date': instance.startDate.toIso8601String(),
      'status': _$FitnessGoalStatusEnumMap[instance.status]!,
      'description': instance.description,
      'target_value': instance.targetValue,
      'current_value': instance.currentValue,
      'unit': instance.unit,
      'end_date': instance.endDate?.toIso8601String(),
      'notes': instance.notes,
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
