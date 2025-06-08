import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
sealed class SnAccount with _$SnAccount {
  const factory SnAccount({
    required String id,
    required String name,
    required String nick,
    required String language,
    required bool isSuperuser,
    required SnAccountProfile profile,
    @Default([]) List<SnAccountBadge> badges,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccount;

  factory SnAccount.fromJson(Map<String, dynamic> json) =>
      _$SnAccountFromJson(json);
}

@freezed
sealed class SnAccountProfile with _$SnAccountProfile {
  const factory SnAccountProfile({
    required String id,
    required String? firstName,
    required String? middleName,
    required String? lastName,
    @Default('') String bio,
    required int experience,
    required int level,
    required double levelingProgress,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccountProfile;

  factory SnAccountProfile.fromJson(Map<String, dynamic> json) =>
      _$SnAccountProfileFromJson(json);
}

@freezed
sealed class SnAccountStatus with _$SnAccountStatus {
  const factory SnAccountStatus({
    required String id,
    required int attitude,
    required bool isOnline,
    required bool isInvisible,
    required bool isNotDisturb,
    required bool isCustomized,
    @Default("") String label,
    required DateTime? clearedAt,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccountStatus;

  factory SnAccountStatus.fromJson(Map<String, dynamic> json) =>
      _$SnAccountStatusFromJson(json);
}

@freezed
sealed class SnAccountBadge with _$SnAccountBadge {
  const factory SnAccountBadge({
    required String id,
    required String type,
    required String? label,
    required String? caption,
    required Map<String, dynamic> meta,
    required DateTime? expiredAt,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccountBadge;

  factory SnAccountBadge.fromJson(Map<String, dynamic> json) =>
      _$SnAccountBadgeFromJson(json);
}

@freezed
sealed class SnContactMethod with _$SnContactMethod {
  const factory SnContactMethod({
    required String id,
    required int type,
    required DateTime? verifiedAt,
    required bool isPrimary,
    required String content,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnContactMethod;

  factory SnContactMethod.fromJson(Map<String, dynamic> json) =>
      _$SnContactMethodFromJson(json);
}

@freezed
sealed class SnNotification with _$SnNotification {
  const factory SnNotification({
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String id,
    required String topic,
    required String title,
    @Default('') String subtitle,
    required String content,
    @Default({}) Map<String, dynamic> meta,
    required int priority,
    required DateTime? viewedAt,
    required String accountId,
  }) = _SnNotification;

  factory SnNotification.fromJson(Map<String, dynamic> json) =>
      _$SnNotificationFromJson(json);
}
