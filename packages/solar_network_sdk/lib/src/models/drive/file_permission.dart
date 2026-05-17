import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_permission.freezed.dart';
part 'file_permission.g.dart';

@freezed
sealed class SnFilePermissionStatus with _$SnFilePermissionStatus {
  const factory SnFilePermissionStatus({
    required bool readable,
    required bool writable,
    required bool manageable,
    required String visibility,
    @JsonKey(name: 'inherited_from') String? inheritedFrom,
  }) = _SnFilePermissionStatus;

  factory SnFilePermissionStatus.fromJson(Map<String, dynamic> json) =>
      _$SnFilePermissionStatusFromJson(json);
}

@freezed
sealed class SnFilePermission with _$SnFilePermission {
  const factory SnFilePermission({
    String? id,
    @JsonKey(name: 'file_id') required String fileId,
    @JsonKey(name: 'subject_type') required String subjectType,
    @JsonKey(name: 'subject_id') required String subjectId,
    required String permission,
    required DateTime? createdAt,
    required DateTime? updatedAt,
    required DateTime? deletedAt,
  }) = _SnFilePermission;

  factory SnFilePermission.fromJson(Map<String, dynamic> json) =>
      _$SnFilePermissionFromJson(json);
}
