import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';
import 'package:solar_network_sdk/src/models/drive/file.dart';

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
    SnCheckInFortuneReport? fortuneReport,
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
sealed class SnCheckInFortuneReport with _$SnCheckInFortuneReport {
  const factory SnCheckInFortuneReport({
    required int version,
    required String poem,
    required String summary,
    required String? summaryDetail,
    required String wish,
    required String love,
    required String study,
    required String career,
    required String health,
    required String lostItem,
    required String luckyColor,
    required String luckyDirection,
    required String luckyTime,
    required String luckyItem,
    required String luckyAction,
    required String avoidAction,
    required String ritual,
  }) = _SnCheckInFortuneReport;

  factory SnCheckInFortuneReport.fromJson(Map<String, dynamic> json) =>
      _$SnCheckInFortuneReportFromJson(json);
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

/// Event visibility levels (int values matching backend enum)
/// Private = 0, Friends = 100, Public = 200
class SnEventVisibility {
  static const int private = 0;
  static const int friends = 100;
  static const int public = 200;
}

/// Recurrence frequency (int values matching backend enum)
/// None = 0, Daily = 1, Weekly = 2, Monthly = 3, Yearly = 4
class SnRecurrenceFrequency {
  static const int none = 0;
  static const int daily = 1;
  static const int weekly = 2;
  static const int monthly = 3;
  static const int yearly = 4;
}

/// Merged calendar event types
class SnMergedEventType {
  static const String userEvent = 'UserEvent';
  static const String checkIn = 'CheckIn';
  static const String status = 'Status';
  static const String notableDay = 'NotableDay';
}

@freezed
sealed class SnRecurrencePattern with _$SnRecurrencePattern {
  const factory SnRecurrencePattern({
    required int frequency,
    @Default(1) int interval,
    DateTime? endDate,
    int? occurrences,
    List<String>? daysOfWeek,
    int? dayOfMonth,
    int? monthOfYear,
  }) = _SnRecurrencePattern;

  factory SnRecurrencePattern.fromJson(Map<String, dynamic> json) =>
      _$SnRecurrencePatternFromJson(json);
}

@freezed
sealed class SnUserCalendarEvent with _$SnUserCalendarEvent {
  const factory SnUserCalendarEvent({
    required String id,
    required String title,
    String? description,
    String? location,
    required DateTime startTime,
    required DateTime endTime,
    @Default(false) bool isAllDay,
    @Default(SnEventVisibility.private) int visibility,
    SnRecurrencePattern? recurrence,
    Map<String, dynamic>? meta,
    SnCloudFileReference? icon,
    SnCloudFileReference? background,
    required String accountId,
    SnAccount? account,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnUserCalendarEvent;

  factory SnUserCalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$SnUserCalendarEventFromJson(json);
}

@freezed
sealed class SnMergedCalendarEvent with _$SnMergedCalendarEvent {
  const factory SnMergedCalendarEvent({
    String? id,
    required String type,
    required String title,
    String? description,
    String? location,
    required DateTime startTime,
    required DateTime endTime,
    @Default(false) bool isAllDay,
    Map<String, dynamic>? meta,
  }) = _SnMergedCalendarEvent;

  factory SnMergedCalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$SnMergedCalendarEventFromJson(json);
}

@freezed
sealed class SnEventCalendarEntry with _$SnEventCalendarEntry {
  const factory SnEventCalendarEntry({
    required DateTime date,
    SnCheckInResult? checkInResult,
    @Default([]) List<SnAccountStatus> statuses,
    @Default([]) List<SnUserCalendarEvent> userEvents,
    @Default([]) List<SnNotableDay> notableDays,
    List<SnMergedCalendarEvent>? mergedEvents,
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
    SnAccount? account,
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

/// Event countdown item types (int values matching backend enum)
/// UserEvent = 0, CheckIn = 1, Status = 2, NotableDay = 3
class SnEventCountdownType {
  static const int userEvent = 0;
  static const int checkIn = 1;
  static const int status = 2;
  static const int notableDay = 3;
}

@freezed
sealed class SnEventCountdownItem with _$SnEventCountdownItem {
  const factory SnEventCountdownItem({
    String? eventId,
    required int eventType,
    required String title,
    String? description,
    String? location,
    required DateTime startTime,
    required DateTime endTime,
    @Default(false) bool isAllDay,
    required int daysRemaining,
    required int hoursRemaining,
    required bool isOngoing,
    Map<String, dynamic>? meta,
    String? accountId,
  }) = _SnEventCountdownItem;

  factory SnEventCountdownItem.fromJson(Map<String, dynamic> json) =>
      _$SnEventCountdownItemFromJson(json);
}
