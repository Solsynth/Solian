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
  final events = <SnUserCalendarEvent>[];
  final seen = <String>{};

  for (final entry in entries) {
    for (final event in entry.userEvents) {
      if (_dateOnly(day).isBefore(_dateOnly(event.startTime)) ||
          _dateOnly(day).isAfter(_dateOnly(event.endTime))) {
        continue;
      }
      if (seen.add(event.id)) events.add(event);
    }
  }

  events.sort((a, b) {
    if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
    return a.startTime.compareTo(b.startTime);
  });
  return events;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

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
