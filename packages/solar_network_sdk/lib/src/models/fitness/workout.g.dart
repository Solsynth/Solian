// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnWorkout _$SnWorkoutFromJson(Map<String, dynamic> json) => _SnWorkout(
  id: json['id'] as String,
  accountId: json['account_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  type: $enumDecode(_$WorkoutTypeEnumMap, json['type']),
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: json['end_time'] == null
      ? null
      : DateTime.parse(json['end_time'] as String),
  duration: json['duration'] as String?,
  caloriesBurned: (json['calories_burned'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => SnWorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SnWorkoutToJson(_SnWorkout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'name': instance.name,
      'description': instance.description,
      'type': _$WorkoutTypeEnumMap[instance.type]!,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'duration': instance.duration,
      'calories_burned': instance.caloriesBurned,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };

const _$WorkoutTypeEnumMap = {
  WorkoutType.strength: 0,
  WorkoutType.cardio: 1,
  WorkoutType.hiit: 2,
  WorkoutType.yoga: 3,
  WorkoutType.other: 4,
};

_SnWorkoutExercise _$SnWorkoutExerciseFromJson(Map<String, dynamic> json) =>
    _SnWorkoutExercise(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      exerciseName: json['exercise_name'] as String,
      sets: (json['sets'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      duration: json['duration'] as String?,
      notes: json['notes'] as String?,
      orderIndex: (json['order_index'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SnWorkoutExerciseToJson(_SnWorkoutExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workout_id': instance.workoutId,
      'exercise_name': instance.exerciseName,
      'sets': instance.sets,
      'reps': instance.reps,
      'weight': instance.weight,
      'duration': instance.duration,
      'notes': instance.notes,
      'order_index': instance.orderIndex,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_CreateWorkoutRequest _$CreateWorkoutRequestFromJson(
  Map<String, dynamic> json,
) => _CreateWorkoutRequest(
  name: json['name'] as String,
  type: $enumDecode(_$WorkoutTypeEnumMap, json['type']),
  startTime: const DateTimeConverter().fromJson(json['start_time'] as String),
  endTime: const NullableDateTimeConverter().fromJson(
    json['end_time'] as String?,
  ),
  description: json['description'] as String?,
  externalId: json['external_id'] as String?,
  caloriesBurned: (json['calories_burned'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CreateWorkoutRequestToJson(
  _CreateWorkoutRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': _$WorkoutTypeEnumMap[instance.type]!,
  'start_time': const DateTimeConverter().toJson(instance.startTime),
  'end_time': const NullableDateTimeConverter().toJson(instance.endTime),
  'description': instance.description,
  'external_id': instance.externalId,
  'calories_burned': instance.caloriesBurned,
  'notes': instance.notes,
};

_UpdateWorkoutRequest _$UpdateWorkoutRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateWorkoutRequest(
  name: json['name'] as String,
  type: $enumDecode(_$WorkoutTypeEnumMap, json['type']),
  startTime: const DateTimeConverter().fromJson(json['start_time'] as String),
  description: json['description'] as String?,
  duration: json['duration'] as String?,
  caloriesBurned: (json['calories_burned'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$UpdateWorkoutRequestToJson(
  _UpdateWorkoutRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': _$WorkoutTypeEnumMap[instance.type]!,
  'start_time': const DateTimeConverter().toJson(instance.startTime),
  'description': instance.description,
  'duration': instance.duration,
  'calories_burned': instance.caloriesBurned,
  'notes': instance.notes,
};

_AddExerciseRequest _$AddExerciseRequestFromJson(Map<String, dynamic> json) =>
    _AddExerciseRequest(
      exerciseName: json['exercise_name'] as String,
      sets: (json['sets'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      orderIndex: (json['order_index'] as num).toInt(),
    );

Map<String, dynamic> _$AddExerciseRequestToJson(_AddExerciseRequest instance) =>
    <String, dynamic>{
      'exercise_name': instance.exerciseName,
      'sets': instance.sets,
      'reps': instance.reps,
      'weight': instance.weight,
      'notes': instance.notes,
      'order_index': instance.orderIndex,
    };

_UpdateWorkoutExerciseRequest _$UpdateWorkoutExerciseRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateWorkoutExerciseRequest(
  exerciseName: json['exercise_name'] as String,
  sets: (json['sets'] as num?)?.toInt(),
  reps: (json['reps'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  orderIndex: (json['order_index'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$UpdateWorkoutExerciseRequestToJson(
  _UpdateWorkoutExerciseRequest instance,
) => <String, dynamic>{
  'exercise_name': instance.exerciseName,
  'sets': instance.sets,
  'reps': instance.reps,
  'weight': instance.weight,
  'order_index': instance.orderIndex,
  'notes': instance.notes,
};

_CreateWorkoutsBatchRequest _$CreateWorkoutsBatchRequestFromJson(
  Map<String, dynamic> json,
) => _CreateWorkoutsBatchRequest(
  workouts: (json['workouts'] as List<dynamic>)
      .map((e) => CreateWorkoutRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CreateWorkoutsBatchRequestToJson(
  _CreateWorkoutsBatchRequest instance,
) => <String, dynamic>{
  'workouts': instance.workouts.map((e) => e.toJson()).toList(),
};
