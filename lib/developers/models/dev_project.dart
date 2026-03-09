import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/developers/models/developer.dart';

part 'dev_project.freezed.dart';
part 'dev_project.g.dart';

@freezed
sealed class SnDevProject with _$SnDevProject {
  const factory SnDevProject({
    required String id,
    required String slug,
    required String name,
    required String description,
    required SnDeveloper developer,
    required String developerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnDevProject;

  factory SnDevProject.fromJson(Map<String, dynamic> json) =>
      _$SnDevProjectFromJson(json);
}
