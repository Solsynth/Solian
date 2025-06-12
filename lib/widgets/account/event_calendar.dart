import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';

/// A reusable widget for displaying an event calendar with event details
/// This can be used in various places throughout the app
class EventCalendarWidget extends HookConsumerWidget {
  /// The list of calendar entries to display
  final AsyncValue<List<SnEventCalendarEntry>> events;

  /// Initial date to focus on
  final DateTime? initialDate;

  /// Whether to show the event details below the calendar
  final bool showEventDetails;

  /// Whether to constrain the width of the calendar
  final bool constrainWidth;

  /// Maximum width constraint when constrainWidth is true
  final double maxWidth;

  /// Callback when a day is selected
  final void Function(DateTime)? onDaySelected;

  /// Callback when the focused month changes
  final void Function(int year, int month)? onMonthChanged;

  const EventCalendarWidget({
    super.key,
    required this.events,
    this.initialDate,
    this.showEventDetails = true,
    this.constrainWidth = false,
    this.maxWidth = 480,
    this.onDaySelected,
    this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = useState(initialDate?.month ?? DateTime.now().month);
    final selectedYear = useState(initialDate?.year ?? DateTime.now().year);
    final selectedDay = useState(initialDate ?? DateTime.now());

    final content = Column(
      children: [
        TableCalendar(
          locale: EasyLocalization.of(context)!.locale.toString(),
          firstDay: DateTime.now().add(Duration(days: -3650)),
          lastDay: DateTime.now().add(Duration(days: 3650)),
          focusedDay: DateTime.utc(
            selectedYear.value,
            selectedMonth.value,
            selectedDay.value.day,
          ),
          weekNumbersVisible: false,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) {
            return isSameDay(selectedDay.value, day);
          },
          onDaySelected: (value, _) {
            selectedDay.value = value;
            onDaySelected?.call(value);
          },
          onPageChanged: (focusedDay) {
            selectedMonth.value = focusedDay.month;
            selectedYear.value = focusedDay.year;
            onMonthChanged?.call(focusedDay.year, focusedDay.month);
          },
          eventLoader: (day) {
            return events.value
                    ?.where((e) => isSameDay(e.date, day))
                    .expand((e) => [...e.statuses, e.checkInResult])
                    .where((e) => e != null)
                    .toList() ??
                [];
          },
          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              final text = DateFormat.EEEEE().format(day);
              return Center(child: Text(text));
            },
            markerBuilder: (context, day, events) {
              var checkInResult =
                  events.whereType<SnCheckInResult>().firstOrNull;
              if (checkInResult != null) {
                return Positioned(
                  top: 32,
                  child: Text(
                    'checkInResultT${checkInResult.level}'.tr(),
                    style: TextStyle(
                      fontSize: 9,
                      color:
                          isSameDay(selectedDay.value, day)
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : isSameDay(DateTime.now(), day)
                              ? Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
        if (showEventDetails) ...[
          const Divider(height: 1).padding(top: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Builder(
              builder: (context) {
                final event =
                    events.value
                        ?.where((e) => isSameDay(e.date, selectedDay.value))
                        .firstOrNull;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(DateFormat.EEEE().format(selectedDay.value))
                        .fontSize(16)
                        .bold()
                        .textColor(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                    Text(DateFormat.yMd().format(selectedDay.value))
                        .fontSize(12)
                        .textColor(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                    const Gap(16),
                    if (event?.checkInResult != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'checkInResultLevel${event!.checkInResult!.level}',
                          ).tr().fontSize(16).bold(),
                          for (final tip in event.checkInResult!.tips)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Icon(
                                  Symbols.circle,
                                  size: 12,
                                  fill: 1,
                                ).padding(top: 4, right: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tip.title).bold(),
                                      Text(tip.content),
                                    ],
                                  ),
                                ),
                              ],
                            ).padding(top: 8),
                        ],
                      ),
                    if (event?.checkInResult == null &&
                        (event?.statuses.isEmpty ?? true))
                      Text('eventCalanderEmpty').tr(),
                  ],
                ).padding(vertical: 24, horizontal: 24);
              },
            ),
          ),
        ],
      ],
    );

    if (constrainWidth) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(margin: EdgeInsets.all(16), child: content),
      ).center();
    }

    return content;
  }
}
