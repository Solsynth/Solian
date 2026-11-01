/// The user's Solar Network calendar, as tools.
///
/// Reads a month's events and the notable days coming up, and adds an event.
/// It runs on demand: the companion is asked what is on the calendar now and
/// then, not constantly, and its definitions are worth little on a run that
/// never mentions a date.
///
/// ## Two endpoints that are not what they look like
///
/// `calendar/merged` is the month view the app's own calendar screen reads, and
/// it answers with one object holding the month's events rather than a day
/// keyed by date. Its `merged_events` carry a `type` that the service writes as
/// the enum's number, which is why nothing here parses that field as a word.
///
/// Notable days are a **global, anonymous list** — there is no per-account
/// "next notable day" endpoint anywhere, and the client used to ask one that
/// does not exist. A client that got a 404 back turned it into `null` and
/// answered "no notable day" forever, which is the kind of wrong answer that is
/// worse than an error. The tool computes the next one from the list instead,
/// and says whose calendar that list is.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

/// How much of an event's note the model is given.
const int _noteChars = 300;

/// The region the notable-day list is read for.
///
/// The endpoint defaults to `CN` and the seeded days are Chinese; the request
/// names it rather than relying on a default that could change under us.
const String _region = 'CN';

/// The `CalendarEventType` the service numbers its merged events with.
///
/// The wire carries the number, so the reader is told what it means.
const Map<int, String> _kindByType = {
  0: 'user_event',
  1: 'check_in',
  2: 'status',
  3: 'notable_day',
};

class AgendaPlugin extends SnPlugin {
  const AgendaPlugin();

  @override
  String get id => 'agenda';

  @override
  String get label => 'thoughtsSkillAgendaLabel'.tr();

  @override
  String get description => 'thoughtsSkillAgendaDescription'.tr();

  @override
  String get summary => 'Read the calendar and add events';

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'read_agenda',
        description:
            'What is on the user\'s Solar Network calendar for a month: their '
            'own events, and the notable days that fall in it. Defaults to the '
            'current month and year.',
        parameters: {
          'type': 'object',
          'properties': {
            'year': {
              'type': 'integer',
              'description': 'The year to read, e.g. 2026.',
            },
            'month': {
              'type': 'integer',
              'description': 'The month to read, 1-12.',
            },
          },
        },
        execute: (arguments) => solarToolResult(() async {
          final month = _month(arguments);
          if (month == null) {
            return {'error': 'The "month" argument must be 1-12.'};
          }
          final year = _year(arguments);
          if (year == null) {
            return {'error': 'The "year" argument must be a positive year.'};
          }
          final body = await solarGet(
            dio,
            '/stargate/accounts/me/calendar/merged',
            query: {'year': year, 'month': month},
          );
          // The events list is kept even when empty: "nothing on that month"
          // is what the caller asked, and an omitted key reads as unknown.
          return {'year': year, 'month': month, 'events': _events(body)};
        }),
      ),
      SnLocalTool(
        name: 'next_notable_day',
        description:
            'The next notable day (holiday or observance) coming up in the '
            'user\'s region, and how many days away it is. Reads the global '
            'list for $_region; the user may observe different days than the '
            'list holds.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final now = DateTime.now().toUtc();
          final body = await solarGet(
            dio,
            '/stargate/notable-days',
            // The list is per year and mixes recurring entries; a year of
            // headroom is what covers "the next one" across a year boundary.
            query: {'region': _region, 'year': now.year, 'take': 50},
          );
          final upcoming = _upcomingNotableDays(body, now);
          return {'notable_day': upcoming.isEmpty ? null : upcoming.first};
        }),
      ),
      SnLocalTool(
        name: 'create_event',
        description:
            'Adds an event to the user\'s Solar Network calendar. It is their '
            'real calendar, so the event shows up on their other devices. Give '
            'the times as ISO-8601 timestamps.',
        parameters: {
          'type': 'object',
          'properties': {
            'title': {'type': 'string', 'description': 'What the event is.'},
            'start': {
              'type': 'string',
              'description': 'Start, ISO-8601, e.g. 2026-10-01T09:00:00Z.',
            },
            'end': {'type': 'string', 'description': 'End, ISO-8601.'},
            'description': {
              'type': 'string',
              'description': 'Optional note about the event.',
            },
            'all_day': {
              'type': 'boolean',
              'description': 'True for an event with no particular time.',
            },
          },
          'required': ['title', 'start', 'end'],
        },
        execute: (arguments) => solarToolResult(() async {
          final title = solarText(arguments, 'title');
          if (title == null) return solarMissing('title');
          final start = solarText(arguments, 'start');
          final end = solarText(arguments, 'end');
          if (start == null) return solarMissing('start');
          if (end == null) return solarMissing('end');
          // Parsed before the request rather than by the server: a timestamp
          // the model wrote as prose is a turn it can fix, not a failed call.
          final startTime = DateTime.tryParse(start);
          final endTime = DateTime.tryParse(end);
          if (startTime == null || endTime == null) {
            return {
              'error':
                  'The times must be ISO-8601 timestamps, e.g. '
                  '2026-10-01T09:00:00Z.',
            };
          }
          if (endTime.isBefore(startTime)) {
            return {'error': 'The event ends before it starts.'};
          }
          final created = await solarPost(
            dio,
            '/stargate/accounts/me/calendar/events',
            body: {
              'title': title,
              'start_time': startTime.toUtc().toIso8601String(),
              'end_time': endTime.toUtc().toIso8601String(),
              'is_all_day': arguments['all_day'] == true,
              'description': solarText(arguments, 'description'),
            },
          );
          return _event(created);
        }),
      ),
    ];
  }

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'The user\'s Solar Network calendar tools are loaded: local_read_agenda, '
    'local_next_notable_day and local_create_event. The calendar is their real '
    'one, so an event added here is visible on their other devices.',
    'Quote the dates the user gave rather than guessing a year, and give the '
    'times as ISO-8601. Notable days come from a global list for $_region, so '
    'present them as what the list holds rather than as what the user '
    'necessarily observes.',
  ];
}

/// The month to read, defaulting to now, or null when the model gave nonsense.
int? _month(Map<String, dynamic> arguments) {
  final asked = solarNumber(arguments, 'month')?.toInt();
  if (asked == null) return DateTime.now().month;
  return asked >= 1 && asked <= 12 ? asked : null;
}

/// The year to read, defaulting to now.
int? _year(Map<String, dynamic> arguments) {
  final asked = solarNumber(arguments, 'year')?.toInt();
  if (asked == null) return DateTime.now().year;
  return asked > 0 ? asked : null;
}

/// The month's events, from whichever list the response actually carries.
///
/// `merged_events` is the union the service builds — the user's own events
/// beside check-ins, statuses and notable days — and `user_events` is the
/// narrower list. Reading the union first means an answer that includes the
/// events the calendar screen shows.
List<Map<String, dynamic>> _events(Object? body) {
  final merged = solarList(body, 'merged_events');
  final source = merged.isNotEmpty ? merged : solarList(body, 'user_events');
  return [for (final event in source) _event(event)];
}

/// One event projected to what a reader needs.
Map<String, dynamic> _event(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'kind': _kindByType[solarInt(json, 'type')],
  'title': solarString(json, 'title'),
  'start': solarTimeField(json, 'start_time'),
  'end': solarTimeField(json, 'end_time'),
  'all_day': solarField(json, 'is_all_day') == true ? true : null,
  'location': solarClip(solarString(json, 'location'), limit: _noteChars),
  'description': solarClip(solarString(json, 'description'), limit: _noteChars),
});

/// The notable days at or after [now], soonest first.
///
/// A recurring entry carries the anchor date it recurs from rather than this
/// year's occurrence, so its month and day are projected onto the year being
/// read — otherwise a holiday would sort by the year it was seeded in.
List<Map<String, dynamic>> _upcomingNotableDays(Object? body, DateTime now) {
  final days = <Map<String, dynamic>>[];
  for (final entry in solarList(body, 'notable_days').isEmpty
      ? solarPage(body)
      : solarList(body, 'notable_days')) {
    final start = _occurrence(entry, now);
    if (start == null || start.isBefore(now.subtract(const Duration(days: 1)))) {
      continue;
    }
    days.add(
      solarCompact({
        'date': solarTime(start),
        'name':
            solarString(entry, 'local_name') ?? solarString(entry, 'name'),
        'english_name': solarString(entry, 'name'),
        'description': solarClip(
          solarString(entry, 'description'),
          limit: _noteChars,
        ),
        // Days away is the part a reader acts on, and it saves the model from
        // doing date arithmetic it is bad at.
        'days_away': start.difference(now).inDays,
      }),
    );
  }
  days.sort((a, b) => '${a['date']}'.compareTo('${b['date']}'));
  return days;
}

/// When a notable day next occurs at or after [now].
DateTime? _occurrence(Object? entry, DateTime now) {
  final start = solarTime(solarField(entry, 'start_date'));
  if (start == null) return null;
  final parsed = DateTime.tryParse(start);
  if (parsed == null) return null;
  if (solarField(entry, 'is_recurring') != true) {
    return parsed.isBefore(now) ? null : parsed;
  }
  // A recurring day is anchored to a reference year: keep its month and day,
  // and move them to the current one, or the next when they have passed.
  var occurrence = DateTime.utc(
    now.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
  );
  if (occurrence.isBefore(now)) {
    occurrence = DateTime.utc(
      now.year + 1,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
    );
  }
  return occurrence;
}
