import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/screens/event_hub_schedule.dart';
import 'package:island/accounts/widgets/account/calendar_event_creation_sheet.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:table_calendar/table_calendar.dart';

@RoutePage()
class EventHubScreen extends HookConsumerWidget {
  final String name;

  const EventHubScreen({super.key, @pathParam required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateUtils.dateOnly(DateTime.now());
    final mode = useState(EventHubViewMode.month);
    final selectedDate = useState(now);
    final focusedMonth = useState(DateTime(now.year, now.month));
    final isWide = isWideScreen(context);
    final query = EventCalendarQuery(
      uname: name,
      year: focusedMonth.value.year,
      month: focusedMonth.value.month,
    );
    final events = ref.watch(eventCalendarProvider(query));

    Future<void> openEditor({SnUserCalendarEvent? event, DateTime? date}) async {
      final changed = await showCalendarEventSheet(
        context,
        initialEvent: event,
        initialDate: date ?? selectedDate.value,
      );
      if (changed == true) {
        ref.invalidate(eventCalendarProvider(query));
      }
    }

    void jumpToToday() {
      final today = DateUtils.dateOnly(DateTime.now());
      selectedDate.value = today;
      focusedMonth.value = DateTime(today.year, today.month);
    }

    void shiftMonth(int delta) {
      focusedMonth.value = DateTime(
        focusedMonth.value.year,
        focusedMonth.value.month + delta,
      );
      if (!_sameMonth(selectedDate.value, focusedMonth.value)) {
        selectedDate.value = focusedMonth.value;
      }
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(DateFormat.yMMMM().format(focusedMonth.value)),
        centerTitle: true,
        actions: [
          TextButton(onPressed: jumpToToday, child: const Text('Today')),
          if (name == 'me')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => openEditor(date: selectedDate.value),
            ),
        ],
      ),
      body: events.when(
        data: (entries) {
          final dayEvents = eventHubEventsForDay(entries, selectedDate.value);
          final agendaSections = buildEventHubAgendaSections(
            entries,
            fromDate: selectedDate.value,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => shiftMonth(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              DateFormat.yMMMM().format(focusedMonth.value),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => shiftMonth(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const Gap(12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<EventHubViewMode>(
                        segments: const [
                          ButtonSegment(
                            value: EventHubViewMode.month,
                            label: Text('Month'),
                          ),
                          ButtonSegment(
                            value: EventHubViewMode.agenda,
                            label: Text('Agenda'),
                          ),
                          ButtonSegment(
                            value: EventHubViewMode.day,
                            label: Text('Day'),
                          ),
                        ],
                        selected: {mode.value},
                        onSelectionChanged: (selection) {
                          mode.value = selection.first;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: switch (mode.value) {
                    EventHubViewMode.month => _MonthView(
                      username: name,
                      entries: entries,
                      selectedDate: selectedDate.value,
                      focusedMonth: focusedMonth.value,
                      isWide: isWide,
                      onSelectDate: (value) => selectedDate.value = value,
                      onMonthChanged: (value) {
                        focusedMonth.value = DateTime(value.year, value.month);
                      },
                      onEditEvent: name == 'me'
                          ? (event) => openEditor(event: event)
                          : null,
                    ),
                    EventHubViewMode.agenda => _AgendaView(
                      username: name,
                      sections: agendaSections,
                      selectedDate: selectedDate.value,
                      onSelectDate: (value) {
                        selectedDate.value = value;
                        focusedMonth.value = DateTime(value.year, value.month);
                      },
                      onEditEvent: name == 'me'
                          ? (event) => openEditor(event: event)
                          : null,
                    ),
                    EventHubViewMode.day => _DayView(
                      username: name,
                      date: selectedDate.value,
                      events: dayEvents,
                      onEditEvent: name == 'me'
                          ? (event) => openEditor(event: event)
                          : null,
                    ),
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_busy_outlined, size: 32),
                const Gap(12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  final String username;
  final List<SnEventCalendarEntry> entries;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final bool isWide;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<SnUserCalendarEvent>? onEditEvent;

  const _MonthView({
    required this.username,
    required this.entries,
    required this.selectedDate,
    required this.focusedMonth,
    required this.isWide,
    required this.onSelectDate,
    required this.onMonthChanged,
    this.onEditEvent,
  });

  @override
  Widget build(BuildContext context) {
    final dayEvents = eventHubEventsForDay(entries, selectedDate);
    final calendar = Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar<SnEventCalendarEntry>(
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          focusedDay: focusedMonth,
          calendarFormat: CalendarFormat.month,
          headerVisible: false,
          availableGestures: AvailableGestures.horizontalSwipe,
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          onDaySelected: (selected, focused) {
            onSelectDate(DateUtils.dateOnly(selected));
            onMonthChanged(DateUtils.dateOnly(focused));
          },
          onPageChanged: (focused) => onMonthChanged(DateUtils.dateOnly(focused)),
          eventLoader: (day) {
            for (final entry in entries) {
              if (isSameDay(entry.date, day)) return [entry];
            }
            return const [];
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) =>
                _MonthCell(day: day, selectedDate: selectedDate, entries: entries),
            todayBuilder: (context, day, focusedDay) =>
                _MonthCell(day: day, selectedDate: selectedDate, entries: entries),
            selectedBuilder: (context, day, focusedDay) =>
                _MonthCell(day: day, selectedDate: selectedDate, entries: entries),
            outsideBuilder: (context, day, focusedDay) => Opacity(
              opacity: 0.45,
              child: _MonthCell(
                day: day,
                selectedDate: selectedDate,
                entries: entries,
              ),
            ),
            dowBuilder: (context, day) => Center(
              child: Text(
                DateFormat.E().format(day),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ),
      ),
    );

    final agenda = _SelectedDayAgenda(
      username: username,
      selectedDate: selectedDate,
      events: dayEvents,
      onEditEvent: onEditEvent,
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: calendar),
          const Gap(16),
          Expanded(flex: 2, child: agenda),
        ],
      );
    }

    return ListView(
      children: [calendar, const Gap(12), agenda],
    );
  }
}

class _MonthCell extends StatelessWidget {
  final DateTime day;
  final DateTime selectedDate;
  final List<SnEventCalendarEntry> entries;

  const _MonthCell({
    required this.day,
    required this.selectedDate,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entry = _entryForDay(entries, day);
    final isSelected = isSameDay(day, selectedDate);
    final isToday = isSameDay(day, DateTime.now());
    final eventCount = entry?.userEvents.length ?? 0;
    final notableCount = entry?.notableDays.length ?? 0;

    final background = isSelected
        ? colorScheme.primaryContainer
        : isToday
        ? colorScheme.surfaceContainerHighest
        : Colors.transparent;
    final foreground = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${day.day}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              if (eventCount > 0)
                ...List.generate(
                  eventCount.clamp(0, 3),
                  (_) => Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (notableCount > 0)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectedDayAgenda extends StatelessWidget {
  final String username;
  final DateTime selectedDate;
  final List<SnUserCalendarEvent> events;
  final ValueChanged<SnUserCalendarEvent>? onEditEvent;

  const _SelectedDayAgenda({
    required this.username,
    required this.selectedDate,
    required this.events,
    this.onEditEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMMEEEEd().format(selectedDate),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(12),
            if (events.isEmpty)
              Text(
                'No events',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...events.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _EventTile(
                    username: username,
                    event: event,
                    onEditEvent: onEditEvent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AgendaView extends StatelessWidget {
  final String username;
  final List<EventHubDaySection> sections;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<SnUserCalendarEvent>? onEditEvent;

  const _AgendaView({
    required this.username,
    required this.sections,
    required this.selectedDate,
    required this.onSelectDate,
    this.onEditEvent,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(child: Text('No upcoming events'));
    }

    return ListView.separated(
      itemCount: sections.length,
      separatorBuilder: (_, _) => const Gap(12),
      itemBuilder: (context, index) {
        final section = sections[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => onSelectDate(section.date),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      DateFormat.yMMMMEEEEd().format(section.date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isSameDay(section.date, selectedDate)
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                ...section.events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _EventTile(
                      username: username,
                      event: event,
                      onEditEvent: onEditEvent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DayView extends StatelessWidget {
  final String username;
  final DateTime date;
  final List<SnUserCalendarEvent> events;
  final ValueChanged<SnUserCalendarEvent>? onEditEvent;

  const _DayView({
    required this.username,
    required this.date,
    required this.events,
    this.onEditEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            DateFormat.yMMMMEEEEd().format(date),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(12),
          if (events.isEmpty)
            const Text('No events')
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text(
                        event.isAllDay
                            ? 'All day'
                            : DateFormat.Hm().format(event.startTime.toLocal()),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: _EventTile(
                        username: username,
                        event: event,
                        onEditEvent: onEditEvent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final String username;
  final SnUserCalendarEvent event;
  final ValueChanged<SnUserCalendarEvent>? onEditEvent;

  const _EventTile({
    required this.username,
    required this.event,
    this.onEditEvent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          try {
            context.router.push(
              CalendarEventDetailRoute(username: username, eventId: event.id),
            );
          } catch (_) {}
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Gap(4),
                    Text(
                      _formatEventTime(event),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if ((event.location ?? '').isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        event.location!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (onEditEvent != null)
                IconButton(
                  onPressed: () => onEditEvent!(event),
                  icon: const Icon(Icons.edit_outlined),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

SnEventCalendarEntry? _entryForDay(List<SnEventCalendarEntry> entries, DateTime day) {
  for (final entry in entries) {
    if (isSameDay(entry.date, day)) return entry;
  }
  return null;
}

bool _sameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

String _formatEventTime(SnUserCalendarEvent event) {
  if (event.isAllDay) return 'All day';
  final start = DateFormat.Hm().format(event.startTime.toLocal());
  final end = DateFormat.Hm().format(event.endTime.toLocal());
  return '$start – $end';
}
