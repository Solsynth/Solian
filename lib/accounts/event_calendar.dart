import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'event_calendar.g.dart';

/// Query parameters for fetching event calendar data
class EventCalendarQuery {
  /// Username to fetch calendar for, null means current user ('me')
  final String? uname;

  /// Year to fetch calendar for
  final int year;

  /// Month to fetch calendar for
  final int month;

  /// Whether to include notable days (holidays)
  final bool includeNotableDays;

  /// Whether to use merged calendar view
  final bool useMergedView;

  const EventCalendarQuery({
    required this.uname,
    required this.year,
    required this.month,
    this.includeNotableDays = true,
    this.useMergedView = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventCalendarQuery &&
          runtimeType == other.runtimeType &&
          uname == other.uname &&
          year == other.year &&
          month == other.month &&
          includeNotableDays == other.includeNotableDays &&
          useMergedView == other.useMergedView;

  @override
  int get hashCode =>
      uname.hashCode ^
      year.hashCode ^
      month.hashCode ^
      includeNotableDays.hashCode ^
      useMergedView.hashCode;
}

/// Provider for fetching event calendar data
/// This can be used anywhere in the app where calendar data is needed
@riverpod
Future<List<SnEventCalendarEntry>> eventCalendar(
  Ref ref,
  EventCalendarQuery query,
) async {
  final client = ref.watch(solarNetworkClientProvider);

  if (query.useMergedView) {
    // For merged view, we fetch a single day and wrap it in a list
    // The merged view returns one entry per request with mergedEvents
    final mergedEntry = await client.accounts.getEventCalendar(
      username: query.uname,
      year: query.year,
      month: query.month,
      includeNotableDays: query.includeNotableDays,
    );
    return mergedEntry;
  }

  return await client.accounts.getEventCalendar(
    username: query.uname,
    year: query.year,
    month: query.month,
    includeNotableDays: query.includeNotableDays,
  );
}

/// Provider for fetching merged calendar for a specific month
@riverpod
Future<SnEventCalendarEntry> mergedCalendar(
  Ref ref, {
  required int year,
  required int month,
  String? username,
}) async {
  final client = ref.watch(solarNetworkClientProvider);

  if (username != null) {
    return await client.accounts.getUserMergedCalendar(
      username: username,
      year: year,
      month: month,
    );
  }

  return await client.accounts.getMergedCalendar(year: year, month: month);
}

/// Query parameters for listing calendar events
class CalendarEventListQuery {
  final DateTime? startTime;
  final DateTime? endTime;
  final int offset;
  final int take;

  const CalendarEventListQuery({
    this.startTime,
    this.endTime,
    this.offset = 0,
    this.take = 50,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventListQuery &&
          runtimeType == other.runtimeType &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          offset == other.offset &&
          take == other.take;

  @override
  int get hashCode =>
      startTime.hashCode ^ endTime.hashCode ^ offset.hashCode ^ take.hashCode;
}

/// Provider for listing user's calendar events
@riverpod
Future<PaginatedResult<SnUserCalendarEvent>> calendarEvents(
  Ref ref,
  CalendarEventListQuery query,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.listCalendarEvents(
    startTime: query.startTime,
    endTime: query.endTime,
    offset: query.offset,
    take: query.take,
  );
}

/// Provider for a single calendar event
@riverpod
Future<SnUserCalendarEvent> calendarEvent(Ref ref, String eventId) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getCalendarEvent(eventId);
}

/// Provider for fetching upcoming event countdowns
@riverpod
Future<List<SnEventCountdownItem>> eventCountdowns(
  Ref ref, {
  int take = 5,
  String? username,
}) async {
  final client = ref.watch(solarNetworkClientProvider);

  if (username != null && username != 'me') {
    return await client.accounts.getUserEventCountdowns(username, take: take);
  }

  return await client.accounts.getEventCountdowns(take: take);
}

/// Provider for countdowns within the next week
@riverpod
Future<List<SnEventCountdownItem>> weekCountdowns(
  Ref ref, {
  String? username,
}) async {
  final allCountdowns = await ref.watch(
    eventCountdownsProvider(take: 20, username: username).future,
  );
  return allCountdowns.where((item) => item.daysRemaining <= 7).toList();
}

/// Provider for countdowns within the next month
@riverpod
Future<List<SnEventCountdownItem>> monthCountdowns(
  Ref ref, {
  String? username,
}) async {
  final allCountdowns = await ref.watch(
    eventCountdownsProvider(take: 20, username: username).future,
  );
  return allCountdowns.where((item) => item.daysRemaining <= 30).toList();
}

/// Provider for countdowns within the next year
@riverpod
Future<List<SnEventCountdownItem>> yearCountdowns(
  Ref ref, {
  String? username,
}) async {
  final allCountdowns = await ref.watch(
    eventCountdownsProvider(take: 50, username: username).future,
  );
  return allCountdowns.where((item) => item.daysRemaining <= 365).toList();
}
