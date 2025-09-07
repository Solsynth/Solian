import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/auth.dart';
import 'package:island/models/file.dart';
import 'package:island/models/wallet.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
sealed class SnAccount with _$SnAccount {
  const factory SnAccount({
    required String id,
    required String name,
    required String nick,
    required String language,
    @Default("") String region,
    required bool isSuperuser,
    required String? automatedId,
    required SnAccountProfile profile,
    required SnWalletSubscriptionRef? perkSubscription,
    @Default([]) List<SnAccountBadge> badges,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccount;

  factory SnAccount.fromJson(Map<String, dynamic> json) =>
      _$SnAccountFromJson(json);
}

@freezed
sealed class ProfileLink with _$ProfileLink {
  const factory ProfileLink({required String name, required String url}) =
      _ProfileLink;

  factory ProfileLink.fromJson(Map<String, dynamic> json) =>
      _$ProfileLinkFromJson(json);
}

class ProfileLinkConverter
    implements JsonConverter<List<ProfileLink>, dynamic> {
  const ProfileLinkConverter();

  @override
  List<ProfileLink> fromJson(dynamic json) {
    return json is List<dynamic>
        ? json.map((e) => ProfileLink.fromJson(e)).cast<ProfileLink>().toList()
        : <ProfileLink>[];
  }

  @override
  List<dynamic> toJson(List<ProfileLink> object) {
    return object.map((e) => e.toJson()).toList();
  }
}

@freezed
sealed class SnAccountProfile with _$SnAccountProfile {
  const factory SnAccountProfile({
    required String id,
    @Default('') String firstName,
    @Default('') String middleName,
    @Default('') String lastName,
    @Default('') String bio,
    @Default('') String gender,
    @Default('') String pronouns,
    @Default('') String location,
    @Default('') String timeZone,
    DateTime? birthday,
    @ProfileLinkConverter() @Default([]) List<ProfileLink> links,
    DateTime? lastSeenAt,
    SnAccountBadge? activeBadge,
    required int experience,
    required int level,
    @Default(100) double socialCredits,
    @Default(0) int socialCreditsLevel,
    required double levelingProgress,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required SnVerificationMark? verification,
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
    required DateTime? activatedAt,
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

@freezed
sealed class SnVerificationMark with _$SnVerificationMark {
  const factory SnVerificationMark({
    required int type,
    required String? title,
    required String? description,
    required String? verifiedBy,
  }) = _SnVerificationMark;

  factory SnVerificationMark.fromJson(Map<String, dynamic> json) =>
      _$SnVerificationMarkFromJson(json);
}

@freezed
sealed class SnAuthDevice with _$SnAuthDevice {
  const factory SnAuthDevice({
    required String id,
    required String deviceId,
    required String deviceName,
    required String? deviceLabel,
    required String accountId,
    required int platform,
    @Default(false) bool isCurrent,
  }) = _SnAuthDevice;

  factory SnAuthDevice.fromJson(Map<String, dynamic> json) =>
      _$SnAuthDeviceFromJson(json);
}

@freezed
sealed class SnAuthDeviceWithChallenge with _$SnAuthDeviceWithChallenge {
  const factory SnAuthDeviceWithChallenge({
    required String id,
    required String deviceId,
    required String deviceName,
    required String? deviceLabel,
    required String accountId,
    required int platform,
    required List<SnAuthChallenge> challenges,
    @Default(false) bool isCurrent,
  }) = _SnAuthDeviceWithChallengee;

  factory SnAuthDeviceWithChallenge.fromJson(Map<String, dynamic> json) =>
      _$SnAuthDeviceWithChallengeFromJson(json);
}

@freezed
sealed class SnExperienceRecord with _$SnExperienceRecord {
  const factory SnExperienceRecord({
    required String id,
    required int delta,
    required String reasonType,
    required String reason,
    @Default(1.0) double? bonusMultiplier,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnExperienceRecord;

  factory SnExperienceRecord.fromJson(Map<String, dynamic> json) =>
      _$SnExperienceRecordFromJson(json);
}

@freezed
sealed class SnSocialCreditRecord with _$SnSocialCreditRecord {
  const factory SnSocialCreditRecord({
    required String id,
    required double delta,
    required String reasonType,
    required String reason,
    required DateTime? expiredAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnSocialCreditRecord;

  factory SnSocialCreditRecord.fromJson(Map<String, dynamic> json) =>
      _$SnSocialCreditRecordFromJson(json);
}
