import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/account.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
sealed class SnNotableDay with _$SnNotableDay {
  const factory SnNotableDay({
    required DateTime date,
    required String localName,
    required String globalName,
    required String countryCode,
    required List<int> holidays,
  }) = _SnNotableDay;

  factory SnNotableDay.fromJson(Map<String, dynamic> json) =>
      _$SnNotableDayFromJson(json);
}

@freezed
sealed class SnActivity with _$SnActivity {
  const factory SnActivity({
    required String id,
    required String type,
    required String resourceIdentifier,
    required dynamic data,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnActivity;

  factory SnActivity.fromJson(Map<String, dynamic> json) =>
      _$SnActivityFromJson(json);
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
