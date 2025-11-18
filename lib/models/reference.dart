import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';

part 'reference.freezed.dart';
part 'reference.g.dart';

@freezed
sealed class Reference with _$Reference {
  const factory Reference({
    required String id,
    @JsonKey(name: 'file_id') required String fileId,
    SnCloudFile? file,
    required String usage,
    @JsonKey(name: 'resource_id') required String resourceId,
    @JsonKey(name: 'expired_at') DateTime? expiredAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Reference;

  factory Reference.fromJson(Map<String, dynamic> json) =>
      _$ReferenceFromJson(json);
}
