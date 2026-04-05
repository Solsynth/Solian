import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

enum ExerciseCategory {
  @JsonValue(0)
  chest,
  @JsonValue(1)
  back,
  @JsonValue(2)
  legs,
  @JsonValue(3)
  arms,
  @JsonValue(4)
  shoulders,
  @JsonValue(5)
  core,
  @JsonValue(6)
  cardio,
  @JsonValue(7)
  other,
}

enum ExerciseDifficulty {
  @JsonValue(0)
  beginner,
  @JsonValue(1)
  intermediate,
  @JsonValue(2)
  advanced,
}

@freezed
sealed class SnExerciseLibrary with _$SnExerciseLibrary {
  const factory SnExerciseLibrary({
    required String id,
    required String name,
    String? description,
    required ExerciseCategory category,
    List<String>? muscleGroups,
    required ExerciseDifficulty difficulty,
    List<String>? equipment,
    required bool isPublic,
    String? accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SnExerciseLibrary;

  factory SnExerciseLibrary.fromJson(Map<String, dynamic> json) =>
      _$SnExerciseLibraryFromJson(json);
}

@freezed
sealed class CreateExerciseRequest with _$CreateExerciseRequest {
  const factory CreateExerciseRequest({
    required String name,
    required ExerciseCategory category,
    required ExerciseDifficulty difficulty,
    String? description,
    List<String>? muscleGroups,
    List<String>? equipment,
    @Default(true) bool isPublic,
  }) = _CreateExerciseRequest;

  factory CreateExerciseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateExerciseRequestFromJson(json);
}

@freezed
sealed class UpdateExerciseLibraryRequest with _$UpdateExerciseLibraryRequest {
  const factory UpdateExerciseLibraryRequest({
    required String name,
    required ExerciseCategory category,
    required ExerciseDifficulty difficulty,
    String? description,
    List<String>? muscleGroups,
    List<String>? equipment,
    required bool isPublic,
  }) = _UpdateExerciseLibraryRequest;

  factory UpdateExerciseLibraryRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateExerciseLibraryRequestFromJson(json);
}
