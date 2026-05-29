import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'account.freezed.dart';
part 'account.g.dart';

abstract interface class IDisplayableAccount {
  String get id;
  String get name;
  String get nick;
  SnCloudFileReference? get profilePicture;
  SnCloudFileReference? get profileBackground;
  SnVerificationMark? get profileVerification;
}

extension IDisplayableAccountDisplayName on IDisplayableAccount {
  String get displayName =>
      nick.isNotEmpty ? nick : (name.isNotEmpty ? '@$name' : 'Unknown');
}

abstract final class SnAccountStatusType {
  static const int defaultType = 0;
  static const int busy = 1;
  static const int doNotDisturb = 2;
  static const int invisible = 3;
}

Object? _readStatusType(Map<dynamic, dynamic> json, String key) {
  if (json.containsKey(key)) return json[key];
  if (json['is_invisible'] == true) {
    return SnAccountStatusType.invisible;
  }
  if (json['is_not_disturb'] == true) {
    return SnAccountStatusType.doNotDisturb;
  }
  return SnAccountStatusType.defaultType;
}

int _statusTypeFromJson(Object? value) =>
    (value as num?)?.toInt() ?? SnAccountStatusType.defaultType;

@freezed
sealed class SnAccount with _$SnAccount implements IDisplayableAccount {
  const SnAccount._();

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
    @Default([]) List<SnContactMethod> contacts,
    required DateTime? activatedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccount;

  factory SnAccount.fromJson(Map<String, dynamic> json) =>
      _$SnAccountFromJson(json);

  @override
  SnCloudFileReference? get profilePicture => profile.picture;

  @override
  SnCloudFileReference? get profileBackground => profile.background;

  @override
  SnVerificationMark? get profileVerification => profile.verification;
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
sealed class UsernameColor with _$UsernameColor {
  const factory UsernameColor({
    @Default('plain') String type,
    String? value,
    String? direction,
    List<String>? colors,
  }) = _UsernameColor;

  factory UsernameColor.fromJson(Map<String, dynamic> json) =>
      _$UsernameColorFromJson(json);
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
    required SnCloudFileReference? picture,
    required SnCloudFileReference? background,
    required SnVerificationMark? verification,
    UsernameColor? usernameColor,
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
    @Default(false) bool isIdle,
    DateTime? idleSince,
    required bool isCustomized,
    @JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson)
    @Default(SnAccountStatusType.defaultType)
    int type,
    @Default("") String label,
    String? symbol,
    required Map<String, dynamic>? meta,
    required DateTime? clearedAt,
    String? appIdentifier,
    @Default(false) bool isAutomated,
    required String accountId,
    SnAccount? account,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccountStatus;

  factory SnAccountStatus.fromJson(Map<String, dynamic> json) =>
      _$SnAccountStatusFromJson(json);
}

extension SnAccountStatusCompat on SnAccountStatus {
  bool get isInvisible => type == SnAccountStatusType.invisible;
  bool get isNotDisturb => type == SnAccountStatusType.doNotDisturb;
  bool get isBusy => type == SnAccountStatusType.busy;
  bool get isIdleOrOnline => isOnline && isIdle;
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
    required bool isPublic,
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
    required String id,
    required String topic,
    required String title,
    @Default('') String subtitle,
    @JsonKey(name: 'content') required String body,
    @Default({}) Map<String, dynamic> meta,
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
sealed class SnAccountProfileRef with _$SnAccountProfileRef {
  const factory SnAccountProfileRef({
    required String id,
    @Default('') String firstName,
    @Default('') String middleName,
    @Default('') String lastName,
    @Default('') String bio,
    SnCloudFileReference? picture,
    SnCloudFileReference? background,
    SnVerificationMark? verification,
    UsernameColor? usernameColor,
  }) = _SnAccountProfileRef;

  factory SnAccountProfileRef.fromJson(Map<String, dynamic> json) =>
      _$SnAccountProfileRefFromJson(json);
}

@freezed
sealed class SnAccountReference
    with _$SnAccountReference
    implements IDisplayableAccount {
  const SnAccountReference._();

  const factory SnAccountReference({
    required String id,
    required String name,
    required String nick,
    SnAccountProfileRef? profile,
    @Default([]) List<SnAccountBadge> badges,
    String? automatedId,
  }) = _SnAccountReference;

  factory SnAccountReference.fromJson(Map<String, dynamic> json) =>
      _$SnAccountReferenceFromJson(json);

  @override
  SnCloudFileReference? get profilePicture => profile?.picture;

  @override
  SnCloudFileReference? get profileBackground => profile?.background;

  @override
  SnVerificationMark? get profileVerification => profile?.verification;
}

extension SnAccountReferenceDisplay on SnAccountReference {
  String get displayName =>
      nick.isNotEmpty ? nick : (name.isNotEmpty ? '@$name' : 'Unknown');
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
sealed class SnAuthDeviceWithSession with _$SnAuthDeviceWithSession {
  const factory SnAuthDeviceWithSession({
    required String id,
    required String deviceId,
    required String deviceName,
    required String? deviceLabel,
    required String accountId,
    required int platform,
    required List<SnAuthSession> sessions,
    @Default(false) bool isCurrent,
  }) = _SnAuthDeviceWithSessione;

  factory SnAuthDeviceWithSession.fromJson(Map<String, dynamic> json) =>
      _$SnAuthDeviceWithSessionFromJson(json);
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

@freezed
sealed class SnFriendOverviewItem with _$SnFriendOverviewItem {
  const factory SnFriendOverviewItem({
    required SnAccount account,
    required SnAccountStatus status,
    required List<SnPresenceActivity> activities,
  }) = _SnFriendOverviewItem;

  factory SnFriendOverviewItem.fromJson(Map<String, dynamic> json) =>
      _$SnFriendOverviewItemFromJson(json);
}

enum SnNotificationPreferenceLevel {
  normal(0),
  silent(1),
  reject(2);

  final int value;
  const SnNotificationPreferenceLevel(this.value);

  static SnNotificationPreferenceLevel fromValue(int value) {
    return SnNotificationPreferenceLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SnNotificationPreferenceLevel.normal,
    );
  }
}

@freezed
sealed class SnNotificationPreference with _$SnNotificationPreference {
  const factory SnNotificationPreference({
    required String id,
    required String accountId,
    required String topic,
    required SnNotificationPreferenceLevel preference,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnNotificationPreference;

  factory SnNotificationPreference.fromJson(Map<String, dynamic> json) =>
      _$SnNotificationPreferenceFromJson(json);
}

@freezed
sealed class SnNotificationTopic with _$SnNotificationTopic {
  const factory SnNotificationTopic({
    required String topic,
    required String description,
    @Default(false) bool isCustom,
  }) = _SnNotificationTopic;

  factory SnNotificationTopic.fromJson(Map<String, dynamic> json) =>
      _$SnNotificationTopicFromJson(json);
}

@JsonEnum(valueField: 'value')
enum SnNotificationPushSubscriptionProvider {
  apple(0),
  fcm(1),
  sop(2);

  final int value;
  const SnNotificationPushSubscriptionProvider(this.value);

  static SnNotificationPushSubscriptionProvider fromValue(int value) {
    return SnNotificationPushSubscriptionProvider.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SnNotificationPushSubscriptionProvider.fcm,
    );
  }
}

@freezed
sealed class SnNotificationPushSubscription
    with _$SnNotificationPushSubscription {
  const factory SnNotificationPushSubscription({
    required String id,
    required String accountId,
    required String deviceId,
    required String deviceToken,
    String? deviceName,
    required SnNotificationPushSubscriptionProvider provider,
    required bool isActivated,
    DateTime? lastUsedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SnNotificationPushSubscription;

  factory SnNotificationPushSubscription.fromJson(Map<String, dynamic> json) =>
      _$SnNotificationPushSubscriptionFromJson(json);
}
