import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
sealed class SnNotableDay with _$SnNotableDay {
  const factory SnNotableDay({
    required DateTime date,
    required String localName,
    required String globalName,
    required String? countryCode,
    required String? localizableKey,
    required List<int> holidays,
  }) = _SnNotableDay;

  factory SnNotableDay.fromJson(Map<String, dynamic> json) =>
      _$SnNotableDayFromJson(json);
}

@freezed
sealed class SnTimelineEvent with _$SnTimelineEvent {
  const factory SnTimelineEvent({
    required String id,
    required String type,
    required String resourceIdentifier,
    required dynamic data,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnTimelineEvent;

  factory SnTimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$SnTimelineEventFromJson(json);
}

@freezed
sealed class SnCheckInResult with _$SnCheckInResult {
  const factory SnCheckInResult({
    required String id,
    required int level,
    required List<SnFortuneTip> tips,
    required String accountId,
    required SnAccount? account,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnCheckInResult;

  factory SnCheckInResult.fromJson(Map<String, dynamic> json) =>
      _$SnCheckInResultFromJson(json);
}

@freezed
sealed class SnFortuneTip with _$SnFortuneTip {
  const factory SnFortuneTip({
    required bool isPositive,
    required String title,
    required String content,
  }) = _SnFortuneTip;

  factory SnFortuneTip.fromJson(Map<String, dynamic> json) =>
      _$SnFortuneTipFromJson(json);
}

@freezed
sealed class SnEventCalendarEntry with _$SnEventCalendarEntry {
  const factory SnEventCalendarEntry({
    required DateTime date,
    required SnCheckInResult? checkInResult,
    required List<SnAccountStatus> statuses,
  }) = _SnEventCalendarEntry;

  factory SnEventCalendarEntry.fromJson(Map<String, dynamic> json) =>
      _$SnEventCalendarEntryFromJson(json);
}

@freezed
sealed class SnPresenceActivity with _$SnPresenceActivity {
  const factory SnPresenceActivity({
    required String id,
    required int type,
    required String? manualId,
    required String? title,
    required String? subtitle,
    required String? caption,
    required String? titleUrl,
    required String? subtitleUrl,
    required String? smallImage,
    required String? largeImage,
    required Map<String, dynamic>? meta,
    required int leaseMinutes,
    required DateTime leaseExpiresAt,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnPresenceActivity;

  factory SnPresenceActivity.fromJson(Map<String, dynamic> json) =>
      _$SnPresenceActivityFromJson(json);
}

@freezed
sealed class SnAccountTimelineItem with _$SnAccountTimelineItem {
  const factory SnAccountTimelineItem({
    required String id,
    required DateTime createdAt,
    required int eventType,
    SnPresenceActivity? activity,
    SnAccountStatus? status,
  }) = _SnAccountTimelineItem;

  factory SnAccountTimelineItem.fromJson(Map<String, dynamic> json) =>
      _$SnAccountTimelineItemFromJson(json);
}
