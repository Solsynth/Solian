import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
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

/// Query parameters for event countdowns
class EventCountdownQuery {
  final String? username;
  final bool includeNotableDays;
  final String? tag;

  const EventCountdownQuery({
    this.username,
    this.includeNotableDays = true,
    this.tag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventCountdownQuery &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          includeNotableDays == other.includeNotableDays &&
          tag == other.tag;

  @override
  int get hashCode => username.hashCode ^ includeNotableDays.hashCode ^ tag.hashCode;
}

/// Provider for paginated event countdowns
final eventCountdownListProvider = AsyncNotifierProvider.autoDispose.family(
  EventCountdownListNotifier.new,
);

class EventCountdownListNotifier
    extends AsyncNotifier<PaginationState<SnEventCountdownItem>>
    with AsyncPaginationController<SnEventCountdownItem> {
  static const int pageSize = 20;

  final EventCountdownQuery query;
  EventCountdownListNotifier(this.query);

  @override
  FutureOr<PaginationState<SnEventCountdownItem>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnEventCountdownItem>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    PaginatedResult<SnEventCountdownItem> result;
    if (query.username != null && query.username != 'me') {
      result = await client.accounts.getUserEventCountdowns(
        query.username!,
        take: pageSize,
        offset: fetchedCount,
        includeNotableDays: query.includeNotableDays,
        tag: query.tag,
      );
    } else {
      result = await client.accounts.getEventCountdowns(
        take: pageSize,
        offset: fetchedCount,
        includeNotableDays: query.includeNotableDays,
        tag: query.tag,
      );
    }

    totalCount = result.totalCount;

    return result.items;
  }
}

/// Provider for the list of account IDs the current user has subscribed to
@riverpod
Future<List<String>> calendarSubscriptions(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.listCalendarSubscriptions();
}

/// Checks if the current user is subscribed to a specific account's calendar
@riverpod
Future<bool> isCalendarSubscribed(Ref ref, String accountId) async {
  final subscriptions = await ref.watch(calendarSubscriptionsProvider.future);
  return subscriptions.contains(accountId);
}
