import 'package:solar_network_sdk/solar_network_sdk.dart';

enum EventHubViewMode { day, week, month }

class EventHubDaySection {
  final DateTime date;
  final List<SnUserCalendarEvent> events;

  const EventHubDaySection({required this.date, required this.events});
}

List<SnUserCalendarEvent> eventHubEventsForDay(
  List<SnEventCalendarEntry> entries,
  DateTime day,
) {
  for (final entry in entries) {
    if (_sameDay(entry.date, day)) {
      final events = [...entry.userEvents];
      events.sort((a, b) {
        if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
        return a.startTime.compareTo(b.startTime);
      });
      return events;
    }
  }

  return const [];
}

List<EventHubDaySection> buildEventHubAgendaSections(
  List<SnEventCalendarEntry> entries, {
  required DateTime fromDate,
}) {
  final start = DateTime(fromDate.year, fromDate.month, fromDate.day);
  final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

  return sorted
      .where((entry) => !entry.date.isBefore(start))
      .map(
        (entry) => EventHubDaySection(
          date: entry.date,
          events: eventHubEventsForDay(sorted, entry.date),
        ),
      )
      .where((section) => section.events.isNotEmpty)
      .toList();
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
