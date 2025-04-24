import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class SnAccount with _$SnAccount {
  const factory SnAccount({
    required int id,
    required String name,
    required String nick,
    required String language,
    required bool isSuperuser,
    required SnAccountProfile profile,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccount;

  factory SnAccount.fromJson(Map<String, dynamic> json) =>
      _$SnAccountFromJson(json);
}

@freezed
abstract class SnAccountProfile with _$SnAccountProfile {
  const factory SnAccountProfile({
    required int id,
    required String? firstName,
    required String? middleName,
    required String? lastName,
    required String? bio,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccountProfile;

  factory SnAccountProfile.fromJson(Map<String, dynamic> json) =>
      _$SnAccountProfileFromJson(json);
}
