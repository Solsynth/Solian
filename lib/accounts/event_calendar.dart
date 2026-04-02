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

  const EventCalendarQuery({
    required this.uname,
    required this.year,
    required this.month,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventCalendarQuery &&
          runtimeType == other.runtimeType &&
          uname == other.uname &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => uname.hashCode ^ year.hashCode ^ month.hashCode;
}

/// Provider for fetching event calendar data
/// This can be used anywhere in the app where calendar data is needed
@riverpod
Future<List<SnEventCalendarEntry>> eventCalendar(
  Ref ref,
  EventCalendarQuery query,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getEventCalendar(
    username: query.uname,
    year: query.year,
    month: query.month,
  );
}
