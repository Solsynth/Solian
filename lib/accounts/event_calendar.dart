import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'event_calendar.g.dart';

/// Search result item that can be either a user event or a notable day
class CalendarSearchResult {
  final String type; // 'UserEvent' or 'NotableDay'
  final DateTime startTime;
  final DateTime endTime;
  final SnUserCalendarEvent? userEvent;
  final SnNotableDayDetail? notableDay;

  const CalendarSearchResult({
    required this.type,
    required this.startTime,
    required this.endTime,
    this.userEvent,
    this.notableDay,
  });

  factory CalendarSearchResult.fromJson(Map<String, dynamic> json) {
    // API returns type as int: 0=UserEvent, 1=NotableDay
    final typeValue = json['type'];
    final isUserEvent = typeValue is int
        ? typeValue == 0
        : (typeValue as String) == 'UserEvent';

    if (isUserEvent) {
      return CalendarSearchResult(
        type: 'UserEvent',
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: DateTime.parse(json['end_time'] as String),
        userEvent: json['user_event'] != null
            ? SnUserCalendarEvent.fromJson(
                json['user_event'] as Map<String, dynamic>,
              )
            : null,
      );
    } else {
      return CalendarSearchResult(
        type: 'NotableDay',
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: DateTime.parse(json['end_time'] as String),
        notableDay: json['notable_day'] != null
            ? SnNotableDayDetail.fromJson(
                json['notable_day'] as Map<String, dynamic>,
              )
            : null,
      );
    }
  }
}

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

/// Provider for fetching the current user's used calendar tags
@riverpod
Future<List<String>> usedCalendarTags(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getUsedCalendarTags();
}

/// Query parameters for calendar search
class CalendarSearchQuery {
  final String? query;
  final String? accountId;
  final List<String> tags;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? notableDayTag;
  final int offset;
  final int take;
  final bool isSearchActive;
  final int debounceKey;

  const CalendarSearchQuery({
    this.query,
    this.accountId,
    this.tags = const [],
    this.startTime,
    this.endTime,
    this.notableDayTag,
    this.offset = 0,
    this.take = 50,
    this.isSearchActive = false,
    this.debounceKey = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarSearchQuery &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          accountId == other.accountId &&
          _listEquals(tags, other.tags) &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          notableDayTag == other.notableDayTag &&
          offset == other.offset &&
          take == other.take &&
          isSearchActive == other.isSearchActive &&
          debounceKey == other.debounceKey;

  @override
  int get hashCode =>
      query.hashCode ^
      accountId.hashCode ^
      tags.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      notableDayTag.hashCode ^
      offset.hashCode ^
      take.hashCode ^
      isSearchActive.hashCode ^
      debounceKey.hashCode;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Provider for searching calendar events + notable days
@riverpod
Future<List<CalendarSearchResult>> calendarSearch(
  Ref ref,
  CalendarSearchQuery query,
) async {
  // Return empty if search is not active (avoids unnecessary API calls)
  if (!query.isSearchActive) {
    return const [];
  }

  final client = ref.watch(solarNetworkClientProvider);
  final results = await client.accounts.searchCalendarEvents(
    query: query.query,
    accountId: query.accountId,
    tags: query.tags.isEmpty ? null : query.tags,
    startTime: query.startTime,
    endTime: query.endTime,
    notableDayTag: query.notableDayTag,
    offset: query.offset,
    take: query.take,
  );
  return results
      .map((json) => CalendarSearchResult.fromJson(json))
      .toList();
}
