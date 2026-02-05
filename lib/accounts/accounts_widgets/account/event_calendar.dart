import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/accounts/accounts_widgets/account/event_details_widget.dart';
import 'package:island/core/models/activity.dart';
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
              final checkInResult = events
                  .whereType<SnCheckInResult>()
                  .firstOrNull;
              final statuses = events.whereType<SnAccountStatus>().toList();

              final textColor = isSameDay(selectedDay.value, day)
                  ? Colors.white
                  : isSameDay(DateTime.now(), day)
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface;

              final shadow =
                  isSameDay(selectedDay.value, day) ||
                      isSameDay(DateTime.now(), day)
                  ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ]
                  : null;

              if (checkInResult != null) {
                return Positioned(
                  top: 32,
                  child: Row(
                    spacing: 2,
                    children: [
                      Text(
                        'checkInResultT${checkInResult.level}'.tr(),
                        style: TextStyle(
                          fontSize: 9,
                          color: textColor,
                          shadows: shadow,
                        ),
                      ),
                      if (statuses.isNotEmpty) ...[
                        Icon(
                          switch (statuses.first.attitude) {
                            0 => Symbols.sentiment_satisfied,
                            2 => Symbols.sentiment_dissatisfied,
                            _ => Symbols.sentiment_neutral,
                          },
                          size: 12,
                          color: textColor,
                          shadows: shadow,
                        ),
                      ],
                    ],
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
                final event = events.value
                    ?.where((e) => isSameDay(e.date, selectedDay.value))
                    .firstOrNull;
                return EventDetailsWidget(
                  selectedDay: selectedDay.value,
                  event: event,
                );
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
