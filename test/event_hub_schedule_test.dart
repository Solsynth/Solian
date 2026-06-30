import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/screens/event_hub_schedule.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  group('eventHubEventsForDay', () {
    test('returns all-day events before timed events for the selected day', () {
      final day = DateTime(2026, 7, 4);
      final timed = _event(
        id: 'timed',
        title: 'Lunch',
        startTime: day.add(const Duration(hours: 12)),
        endTime: day.add(const Duration(hours: 13)),
      );
      final allDay = _event(
        id: 'all-day',
        title: 'Holiday',
        startTime: day,
        endTime: day.add(const Duration(hours: 23, minutes: 59)),
        isAllDay: true,
      );
      final entries = [
        SnEventCalendarEntry(date: day, userEvents: [timed, allDay]),
      ];

      final result = eventHubEventsForDay(entries, day);

      expect(result.map((event) => event.id), ['all-day', 'timed']);
    });
  });

  group('buildEventHubAgendaSections', () {
    test('drops empty dates and keeps sections in chronological order', () {
      final july4 = DateTime(2026, 7, 4);
      final july6 = DateTime(2026, 7, 6);
      final entries = [
        SnEventCalendarEntry(
          date: july6,
          userEvents: [
            _event(
              id: 'late',
              title: 'Late event',
              startTime: july6.add(const Duration(hours: 9)),
              endTime: july6.add(const Duration(hours: 10)),
            ),
          ],
        ),
        SnEventCalendarEntry(date: july4, userEvents: const []),
      ];

      final result = buildEventHubAgendaSections(entries, fromDate: july4);

      expect(result.length, 1);
      expect(result.single.date, july6);
      expect(result.single.events.single.id, 'late');
    });
  });
}

SnUserCalendarEvent _event({
  required String id,
  required String title,
  required DateTime startTime,
  required DateTime endTime,
  bool isAllDay = false,
}) {
  final now = DateTime(2026, 6, 30, 12);
  return SnUserCalendarEvent(
    id: id,
    title: title,
    startTime: startTime,
    endTime: endTime,
    isAllDay: isAllDay,
    accountId: 'account-1',
    createdAt: now,
    updatedAt: now,
  );
}
