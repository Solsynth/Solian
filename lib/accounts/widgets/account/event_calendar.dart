import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/event_details_widget.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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

  /// Callback when the user wants to add a new event
  final void Function(DateTime)? onAddEvent;

  /// Whether to show the add event button (only shown when onAddEvent is provided)
  final bool canAddEvents;

  const EventCalendarWidget({
    super.key,
    required this.events,
    this.initialDate,
    this.showEventDetails = true,
    this.constrainWidth = false,
    this.maxWidth = 480,
    this.onDaySelected,
    this.onMonthChanged,
    this.onAddEvent,
    this.canAddEvents = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = useState(initialDate?.month ?? DateTime.now().month);
    final selectedYear = useState(initialDate?.year ?? DateTime.now().year);
    final selectedDay = useState(initialDate ?? DateTime.now());

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            final entry = events.value?.firstWhere(
              (e) => isSameDay(e.date, day),
              orElse: () => SnEventCalendarEntry(date: day),
            );
            if (entry == null) return [];

            return [
              ...entry.statuses,
              if (entry.checkInResult != null) entry.checkInResult!,
              ...entry.userEvents,
              ...entry.notableDays,
            ];
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: colorScheme.onPrimaryContainer),
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(color: colorScheme.onPrimary),
            markerSize: 0,
            cellMargin: const EdgeInsets.all(4),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            leftChevronIcon: Icon(
              Symbols.chevron_left,
              color: colorScheme.onSurfaceVariant,
            ),
            rightChevronIcon: Icon(
              Symbols.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.labelMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: theme.textTheme.labelMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              final text = DateFormat.EEEEE().format(day);
              return Center(
                child: Text(
                  text,
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
            markerBuilder: (context, day, dayEvents) {
              final checkInResult = dayEvents
                  .whereType<SnCheckInResult>()
                  .firstOrNull;
              final statuses = dayEvents.whereType<SnAccountStatus>().toList();
              final userEvents = dayEvents
                  .whereType<SnUserCalendarEvent>()
                  .toList();
              final notableDays = dayEvents.whereType<SnNotableDay>().toList();

              final isSelected = isSameDay(selectedDay.value, day);
              final isToday = isSameDay(DateTime.now(), day);

              final textColor = isSelected
                  ? colorScheme.onPrimary
                  : isToday
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface;

              final markers = <Widget>[];

              // Check-in result marker
              if (checkInResult != null) {
                markers.add(
                  Text(
                    'checkInResultT${checkInResult.level}'.tr(),
                    style: theme.textTheme.labelSmall!.copyWith(
                      fontSize: 10,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              // Status marker
              if (statuses.isNotEmpty) {
                markers.add(
                  Icon(
                    switch (statuses.first.attitude) {
                      0 => Symbols.sentiment_satisfied,
                      2 => Symbols.sentiment_dissatisfied,
                      _ => Symbols.sentiment_neutral,
                    },
                    size: 14,
                    color: textColor,
                  ),
                );
              }

              // User events marker
              if (userEvents.isNotEmpty) {
                markers.add(
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }

              // Notable days marker
              if (notableDays.isNotEmpty) {
                markers.add(
                  Icon(
                    Symbols.celebration,
                    size: 14,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.tertiary,
                  ),
                );
              }

              if (markers.isEmpty) return null;

              return Positioned(
                bottom: 2,
                child: Row(
                  spacing: 4,
                  mainAxisSize: MainAxisSize.min,
                  children: markers,
                ),
              );
            },
          ),
        ),
        if (showEventDetails) ...[
          const Divider(height: 1).padding(top: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Builder(
              builder: (context) {
                final event = events.value?.firstWhere(
                  (e) => isSameDay(e.date, selectedDay.value),
                  orElse: () => SnEventCalendarEntry(date: selectedDay.value),
                );
                return EventDetailsWidget(
                  selectedDay: selectedDay.value,
                  event: event,
                  onEditEvent: canAddEvents ? onAddEvent : null,
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
