// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnExerciseLibrary _$SnExerciseLibraryFromJson(Map<String, dynamic> json) =>
    _SnExerciseLibrary(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$ExerciseCategoryEnumMap, json['category']),
      muscleGroups: (json['muscle_groups'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      difficulty: $enumDecode(_$ExerciseDifficultyEnumMap, json['difficulty']),
      equipment: (json['equipment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isPublic: json['is_public'] as bool,
      accountId: json['account_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SnExerciseLibraryToJson(_SnExerciseLibrary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': _$ExerciseCategoryEnumMap[instance.category]!,
      'muscle_groups': instance.muscleGroups,
      'difficulty': _$ExerciseDifficultyEnumMap[instance.difficulty]!,
      'equipment': instance.equipment,
      'is_public': instance.isPublic,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$ExerciseCategoryEnumMap = {
  ExerciseCategory.chest: 0,
  ExerciseCategory.back: 1,
  ExerciseCategory.legs: 2,
  ExerciseCategory.arms: 3,
  ExerciseCategory.shoulders: 4,
  ExerciseCategory.core: 5,
  ExerciseCategory.cardio: 6,
  ExerciseCategory.other: 7,
};

const _$ExerciseDifficultyEnumMap = {
  ExerciseDifficulty.beginner: 0,
  ExerciseDifficulty.intermediate: 1,
  ExerciseDifficulty.advanced: 2,
};

_CreateExerciseRequest _$CreateExerciseRequestFromJson(
  Map<String, dynamic> json,
) => _CreateExerciseRequest(
  name: json['name'] as String,
  category: $enumDecode(_$ExerciseCategoryEnumMap, json['category']),
  difficulty: $enumDecode(_$ExerciseDifficultyEnumMap, json['difficulty']),
  description: json['description'] as String?,
  muscleGroups: (json['muscle_groups'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  equipment: (json['equipment'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isPublic: json['is_public'] as bool? ?? true,
);

Map<String, dynamic> _$CreateExerciseRequestToJson(
  _CreateExerciseRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'category': _$ExerciseCategoryEnumMap[instance.category]!,
  'difficulty': _$ExerciseDifficultyEnumMap[instance.difficulty]!,
  'description': instance.description,
  'muscle_groups': instance.muscleGroups,
  'equipment': instance.equipment,
  'is_public': instance.isPublic,
};

_UpdateExerciseLibraryRequest _$UpdateExerciseLibraryRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateExerciseLibraryRequest(
  name: json['name'] as String,
  category: $enumDecode(_$ExerciseCategoryEnumMap, json['category']),
  difficulty: $enumDecode(_$ExerciseDifficultyEnumMap, json['difficulty']),
  description: json['description'] as String?,
  muscleGroups: (json['muscle_groups'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  equipment: (json['equipment'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isPublic: json['is_public'] as bool,
);

Map<String, dynamic> _$UpdateExerciseLibraryRequestToJson(
  _UpdateExerciseLibraryRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'category': _$ExerciseCategoryEnumMap[instance.category]!,
  'difficulty': _$ExerciseDifficultyEnumMap[instance.difficulty]!,
  'description': instance.description,
  'muscle_groups': instance.muscleGroups,
  'equipment': instance.equipment,
  'is_public': instance.isPublic,
};
