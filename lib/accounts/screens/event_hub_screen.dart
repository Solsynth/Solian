import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/screens/event_hub_schedule.dart';
import 'package:island/accounts/widgets/account/calendar_event_creation_sheet.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
    final includeNotableDays = useState(true);
    final isWide = isWideScreen(context);

    final query = EventCalendarQuery(
      uname: name,
      year: focusedMonth.value.year,
      month: focusedMonth.value.month,
      includeNotableDays: includeNotableDays.value,
    );
    final events = ref.watch(eventCalendarProvider(query));

    Future<void> openEditor({
      SnUserCalendarEvent? event,
      DateTime? date,
    }) async {
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

    void shiftPeriod(int delta) {
      switch (mode.value) {
        case EventHubViewMode.day:
          final next = selectedDate.value.add(Duration(days: delta));
          selectedDate.value = next;
          focusedMonth.value = DateTime(next.year, next.month);
          break;
        case EventHubViewMode.week:
          final next = selectedDate.value.add(Duration(days: 7 * delta));
          selectedDate.value = next;
          focusedMonth.value = DateTime(next.year, next.month);
          break;
        case EventHubViewMode.month:
          final next = DateTime(
            focusedMonth.value.year,
            focusedMonth.value.month + delta,
          );
          focusedMonth.value = next;
          if (!_sameMonth(selectedDate.value, next)) {
            selectedDate.value = DateTime(next.year, next.month, 1);
          }
          break;
      }
    }

    final showFiltersSidebar = useState(false);
    final sidebarNotifier = useMemoized(() => ValueNotifier(false));
    final showInspectorSidebar = useState(true);
    final inspectorNotifier = useMemoized(() => ValueNotifier(true));

    useEffect(() {
      sidebarNotifier.value = showFiltersSidebar.value;
      return null;
    }, [showFiltersSidebar.value]);

    useEffect(() {
      inspectorNotifier.value = showInspectorSidebar.value;
      return null;
    }, [showInspectorSidebar.value]);

    void openFilters() {
      if (isWide) {
        showFiltersSidebar.value = !showFiltersSidebar.value;
      } else {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => SheetScaffold(
            showHeader: false,
            child: _CalendarFiltersSheet(
              selectedDate: selectedDate.value,
              focusedMonth: focusedMonth.value,
              includeNotableDays: includeNotableDays.value,
              fullDateFormat: _formatFullDate(selectedDate.value),
              onSelectDate: (value) {
                selectedDate.value = value;
                focusedMonth.value = DateTime(value.year, value.month);
                Navigator.pop(context);
              },
              onMonthChanged: (value) {
                focusedMonth.value = DateTime(value.year, value.month);
              },
              onToggleNotableDays: (value) {
                includeNotableDays.value = value;
              },
              onJumpToToday: jumpToToday,
            ),
          ),
        );
      }
    }

    final colorScheme = Theme.of(context).colorScheme;

    final calendarBody = events.when(
      data: (entries) {
        final dayEvents = eventHubEventsForDay(entries, selectedDate.value);
        final weekDays = _buildWeekDays(selectedDate.value);
        final weekSections = weekDays
            .map(
              (day) => EventHubDaySection(
                date: day,
                events: eventHubEventsForDay(entries, day),
              ),
            )
            .where((section) => section.events.isNotEmpty)
            .toList();

        final viewContent = switch (mode.value) {
          EventHubViewMode.month => _MonthCalendarView(
            username: name,
            entries: entries,
            focusedMonth: focusedMonth.value,
            selectedDate: selectedDate.value,
            isWide: isWide,
            onSelectDate: (value) {
              selectedDate.value = value;
              focusedMonth.value = DateTime(value.year, value.month);
            },
            onEditEvent: name == 'me'
                ? (event) => openEditor(event: event)
                : null,
            onAddEvent: name == 'me'
                ? () => openEditor(date: selectedDate.value)
                : null,
            onSwipeUp: () => shiftPeriod(1),
            onSwipeDown: () => shiftPeriod(-1),
          ),
          EventHubViewMode.week => _WeekView(
            username: name,
            sections: weekSections,
            selectedDate: selectedDate.value,
            weekDays: weekDays,
            onSelectDate: (value) {
              selectedDate.value = value;
              focusedMonth.value = DateTime(value.year, value.month);
            },
            onEditEvent: name == 'me'
                ? (event) => openEditor(event: event)
                : null,
            onSwipeLeft: () => shiftPeriod(1),
            onSwipeRight: () => shiftPeriod(-1),
          ),
          EventHubViewMode.day => _DayView(
            username: name,
            date: selectedDate.value,
            events: dayEvents,
            onEditEvent: name == 'me'
                ? (event) => openEditor(event: event)
                : null,
          ),
        };

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: Offset(0, 0),
              end: Offset(0, 0),
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offset.animate(animation),
                child: child,
              ),
            );
          },
          child: Padding(padding: const EdgeInsets.all(8), child: viewContent),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );

    final filterSidebarContent = _CalendarFiltersSidebar(
      selectedDate: selectedDate.value,
      focusedMonth: focusedMonth.value,
      includeNotableDays: includeNotableDays.value,
      fullDateFormat: _formatFullDate(selectedDate.value),
      currentMode: mode.value,
      onModeChanged: (value) => mode.value = value,
      onSelectDate: (value) {
        selectedDate.value = value;
        focusedMonth.value = DateTime(value.year, value.month);
      },
      onMonthChanged: (value) {
        focusedMonth.value = DateTime(value.year, value.month);
      },
      onToggleNotableDays: (value) {
        includeNotableDays.value = value;
      },
      onJumpToToday: jumpToToday,
    );

    final inspectorSidebarContent = events.when(
      data: (entries) {
        final selectedEntry = _entryForDay(entries, selectedDate.value);
        final selectedEvents = eventHubEventsForDay(
          entries,
          selectedDate.value,
        );
        return _DayAgenda(
          username: name,
          selectedDate: selectedDate.value,
          events: selectedEvents,
          onEditEvent: name == 'me'
              ? (event) => openEditor(event: event)
              : null,
          onAddEvent: name == 'me'
              ? () => openEditor(date: selectedDate.value)
              : null,
          compact: true,
          entry: selectedEntry,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );

    final wrappedBody = isWide
        ? ResponsiveSidebar(
            showSidebar: sidebarNotifier,
            sidebarContent: filterSidebarContent,
            sidebarWidth: 320,
            isLeft: true,
            mainContent: ResponsiveSidebar(
              showSidebar: inspectorNotifier,
              sidebarContent: inspectorSidebarContent,
              sidebarWidth: 320,
              isLeft: false,
              mainContent: calendarBody,
            ),
          )
        : calendarBody;

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        surfaceTintColor: colorScheme.surfaceTint,
        scrolledUnderElevation: 3,
        centerTitle: true,
        leading: const AutoLeadingButton(),
        automaticallyImplyLeading: false,
        title: Text('eventCalendar'.tr()),
        actions: [
          IconButton(
            onPressed: openFilters,
            icon: Icon(
              Symbols.tune,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: 'Filters',
          ),
          if (isWide) ...[
            IconButton(
              onPressed: () =>
                  showInspectorSidebar.value = !showInspectorSidebar.value,
              icon: Icon(
                Symbols.calendar_today,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              tooltip: 'Events',
            ),
          ],
          const Gap(8),
        ],
      ),
      body: wrappedBody,
    );
  }
}

class _MonthCalendarView extends StatelessWidget {
  final String username;
  final List<SnEventCalendarEntry> entries;
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final bool isWide;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<SnUserCalendarEvent>? onEditEvent;
  final VoidCallback? onAddEvent;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;

  const _MonthCalendarView({
    required this.username,
    required this.entries,
    required this.focusedMonth,
    required this.selectedDate,
    required this.isWide,
    required this.onSelectDate,
    this.onEditEvent,
    this.onAddEvent,
    this.onSwipeUp,
    this.onSwipeDown,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthDays = _buildMonthCells(focusedMonth);
    final monthGrid = LayoutBuilder(
      builder: (context, constraints) {
        const headerHeight = 0.0;
        const weekRowHeight = 28.0;
        final gridHeight = constraints.maxHeight - headerHeight - weekRowHeight;
        final weeksCount = (monthDays.length / 7).ceil();
        final cellHeight = gridHeight / weeksCount;
        final cellWidth = constraints.maxWidth / 7;
        final aspectRatio = cellWidth / cellHeight;

        return Column(
          children: [
            SizedBox(
              height: weekRowHeight,
              child: Row(
                children: List.generate(7, (index) {
                  const names = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        names[index],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: monthDays.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: aspectRatio,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  final day = monthDays[index];
                  final entry = _entryForDay(entries, day);
                  return _CalendarDayCell(
                    day: day,
                    focusedMonth: focusedMonth,
                    selectedDate: selectedDate,
                    entry: entry,
                    onTap: () => onSelectDate(day),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    final agendaEntry = isWide ? null : _entryForDay(entries, selectedDate);

    Widget content;
    if (!isWide) {
      final selectedEvents = eventHubEventsForDay(entries, selectedDate);
      final hasContent = selectedEvents.isNotEmpty || agendaEntry != null;

      if (!hasContent) {
        content = monthGrid;
      } else {
        content = Stack(
          children: [
            Positioned.fill(child: monthGrid),
            Positioned.fill(
              child: DraggableScrollableSheet(
                initialChildSize: 0.25,
                minChildSize: 0.12,
                maxChildSize: 0.85,
                snap: true,
                snapSizes: const [0.12, 0.25, 0.5, 0.85],
                builder: (context, scrollController) {
                  return Material(
                    color: colorScheme.surfaceContainer,
                    elevation: 8,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 4),
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: _DayAgenda(
                            username: username,
                            selectedDate: selectedDate,
                            events: selectedEvents,
                            onEditEvent: onEditEvent,
                            onAddEvent: onAddEvent,
                            compact: true,
                            entry: agendaEntry,
                            scrollController: scrollController,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    } else {
      content = monthGrid;
    }

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -200) {
          onSwipeUp?.call();
        } else if (details.primaryVelocity! > 200) {
          onSwipeDown?.call();
        }
      },
      child: content,
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final SnEventCalendarEntry? entry;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.day,
    required this.focusedMonth,
    required this.selectedDate,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = DateUtils.isSameDay(day, selectedDate);
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final isOutside = !_sameMonth(day, focusedMonth);
    final userEvents = entry?.userEvents ?? const <SnUserCalendarEvent>[];
    final notableDays = entry?.notableDays ?? const <SnNotableDay>[];
    final checkIn = entry?.checkInResult;
    final statuses = entry?.statuses ?? const <SnAccountStatus>[];

    final textColor = isSelected
        ? colorScheme.onPrimary
        : isOutside
        ? colorScheme.onSurfaceVariant.withOpacity(0.4)
        : isToday
        ? colorScheme.primary
        : colorScheme.onSurface;

    final tertiaryColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.tertiary;

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isToday
                  ? colorScheme.primary
                  : isSelected
                  ? colorScheme.primary.withOpacity(0.5)
                  : colorScheme.outlineVariant,
              width: isToday ? 2 : 1,
            ),
            color: isSelected
                ? colorScheme.primaryContainer.withOpacity(0.35)
                : isToday
                ? colorScheme.primaryContainer.withOpacity(0.15)
                : Colors.transparent,
          ),
          padding: const EdgeInsets.fromLTRB(5, 4, 5, 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day number
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: isToday || isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              // Check-in result level
              if (checkIn != null)
                Text(
                  'checkInResultT${checkIn.level}'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              // Status sentiment icon
              if (statuses.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    switch (statuses.first.attitude) {
                      0 => Symbols.sentiment_satisfied,
                      2 => Symbols.sentiment_dissatisfied,
                      _ => Symbols.sentiment_neutral,
                    },
                    size: 16,
                    color: textColor,
                  ),
                ),
              // Event icon + title
              if (userEvents.isNotEmpty)
                Expanded(
                  child: _CalendarEventRow(
                    event: userEvents.first,
                    colorScheme: colorScheme,
                  ),
                ),
              // Notable day
              if (notableDays.isNotEmpty && userEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    notableDays.first.localName.isNotEmpty
                        ? notableDays.first.localName
                        : notableDays.first.globalName,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: tertiaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarEventRow extends StatelessWidget {
  final SnUserCalendarEvent event;
  final ColorScheme colorScheme;

  const _CalendarEventRow({required this.event, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Row(
        children: [
          if (event.icon != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CloudFileWidget(item: event.icon!, fit: BoxFit.cover),
              ),
            )
          else
            Icon(Symbols.event, size: 14, color: colorScheme.primary),
          const Gap(3),
          Expanded(
            child: Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayAgenda extends StatelessWidget {
  final String username;
  final DateTime selectedDate;
  final List<SnUserCalendarEvent> events;
  final ValueChanged<SnUserCalendarEvent>? onEditEvent;
  final VoidCallback? onAddEvent;
  final bool compact;
  final SnEventCalendarEntry? entry;
  final ScrollController? scrollController;

  const _DayAgenda({
    required this.username,
    required this.selectedDate,
    required this.events,
    this.onEditEvent,
    this.onAddEvent,
    this.compact = false,
    this.entry,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final checkIn = entry?.checkInResult;
    final statuses = entry?.statuses ?? const <SnAccountStatus>[];
    final notableDays = entry?.notableDays ?? const <SnNotableDay>[];
    final hasCheckIn = checkIn != null;
    final hasStatuses = statuses.isNotEmpty;
    final hasNotableDays = notableDays.isNotEmpty;
    final hasEvents = events.isNotEmpty;
    final isEmpty =
        !hasCheckIn && !hasStatuses && !hasNotableDays && !hasEvents;

    final content = ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 20,
        16,
        compact ? 16 : 20,
        16,
      ),
      children: [
        // Date header
        _buildDateHeader(context),
        const Gap(12),

        // Notable Days
        if (hasNotableDays) ...[
          _buildSectionTitle(
            context,
            Symbols.celebration,
            'eventNotableDays'.tr(),
            colorScheme.tertiary,
          ),
          const Gap(8),
          for (final day in notableDays) ...[
            _buildNotableDayMini(context, day),
            const Gap(6),
          ],
          const Gap(8),
        ],

        // User Events
        if (hasEvents) ...[
          _buildSectionTitle(
            context,
            Symbols.event,
            'eventUserEvents'.tr(),
            colorScheme.primary,
          ),
          const Gap(8),
          for (final event in events)
            _EventTile(
              username: username,
              event: event,
              onEditEvent: onEditEvent,
            ),
          const Gap(8),
        ],

        // Check-in Result
        if (hasCheckIn) ...[
          _buildSectionTitle(
            context,
            Symbols.stars,
            'eventCheckIn'.tr(),
            colorScheme.secondary,
          ),
          const Gap(8),
          _buildCheckInMini(context, checkIn),
          const Gap(8),
        ],

        // Statuses
        if (hasStatuses) ...[
          _buildSectionTitle(
            context,
            Symbols.mood,
            'eventStatuses'.tr(),
            colorScheme.primary,
          ),
          const Gap(8),
          for (final status in statuses) ...[
            _buildStatusMini(context, status),
            const Gap(6),
          ],
          const Gap(4),
        ],

        // Empty state
        if (isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No events',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );

    if (compact) return content;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: content,
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${selectedDate.day}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.EEEE().format(selectedDate),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                DateFormat.yMMMMd().format(selectedDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (onAddEvent != null)
          IconButton.filledTonal(
            onPressed: onAddEvent,
            icon: const Icon(Symbols.add, size: 20),
            tooltip: 'calendarEventAdd'.tr(),
            style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color, fill: 1),
        const Gap(6),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotableDayMini(BuildContext context, SnNotableDay day) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = day.localName.isNotEmpty
        ? day.localName
        : day.globalName;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.tertiaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Icon(
              Symbols.celebration,
              size: 16,
              color: colorScheme.onTertiaryContainer,
              fill: 1,
            ),
            const Gap(8),
            Expanded(
              child: Text(
                displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInMini(BuildContext context, SnCheckInResult checkIn) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.secondaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Symbols.stars,
                  size: 16,
                  color: colorScheme.onSecondaryContainer,
                  fill: 1,
                ),
                const Gap(6),
                Text(
                  'checkInResultLevel${checkIn.level}'.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (checkIn.tips.isNotEmpty) ...[
              const Gap(8),
              for (final tip in checkIn.tips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        tip.isPositive ? Symbols.thumb_up : Symbols.thumb_down,
                        size: 14,
                        color: colorScheme.onSecondaryContainer.withOpacity(
                          0.7,
                        ),
                      ),
                      const Gap(6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.title,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                            ),
                            Text(
                              tip.content,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSecondaryContainer
                                        .withOpacity(0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMini(BuildContext context, SnAccountStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  switch (status.attitude) {
                    0 => Symbols.sentiment_satisfied,
                    2 => Symbols.sentiment_dissatisfied,
                    _ => Symbols.sentiment_neutral,
                  },
                  size: 18,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status.label.isNotEmpty)
                    Text(
                      status.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Text(
                    status.isOnline ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  final String username;
  final List<EventHubDaySection> sections;
  final List<DateTime> weekDays;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<SnUserCalendarEvent>? onEditEvent;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const _WeekView({
    required this.username,
    required this.sections,
    required this.weekDays,
    required this.selectedDate,
    required this.onSelectDate,
    this.onEditEvent,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -200) {
          onSwipeLeft?.call();
        } else if (details.primaryVelocity! > 200) {
          onSwipeRight?.call();
        }
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Week of ${DateFormat.yMMMMd().format(weekDays.first)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const Gap(16),
          Row(
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: [
                          Text(
                            DateFormat.E().format(day),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const Gap(8),
                          FilledButton.tonal(
                            onPressed: () => onSelectDate(day),
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(40, 40),
                              shape: const CircleBorder(),
                              backgroundColor:
                                  DateUtils.isSameDay(day, selectedDate)
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              foregroundColor:
                                  DateUtils.isSameDay(day, selectedDate)
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const Gap(16),
          if (sections.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No events this week',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatFullDate(section.date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Gap(8),
                    ...section.events.map(
                      (event) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        color: colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
            ),
        ],
      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Text(
            _formatFullDate(date),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const Gap(18),
        if (events.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No events',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...events.map(
            (event) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        event.isAllDay
                            ? 'All day'
                            : DateFormat.Hm().format(event.startTime.toLocal()),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
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
    final hasBackground = event.background != null;
    final hasIcon = event.icon != null;

    return Card(
      elevation: 0,
      color: hasBackground ? null : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          try {
            context.router.push(
              CalendarEventDetailRoute(username: username, eventId: event.id),
            );
          } catch (_) {}
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasBackground)
              SizedBox(
                height: 80,
                child: CloudFileWidget(
                  item: event.background!,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasIcon)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CloudFileWidget(
                          item: event.icon!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Symbols.event,
                        size: 18,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: hasBackground
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            Icon(
                              Symbols.schedule,
                              size: 13,
                              color: hasBackground
                                  ? colorScheme.onSurface.withOpacity(0.7)
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const Gap(4),
                            Text(
                              _formatEventTime(event),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: hasBackground
                                        ? colorScheme.onSurface.withOpacity(0.7)
                                        : colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        if ((event.location ?? '').isNotEmpty) ...[
                          const Gap(4),
                          Row(
                            children: [
                              Icon(
                                Symbols.location_on,
                                size: 13,
                                color: hasBackground
                                    ? colorScheme.onSurface.withOpacity(0.7)
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const Gap(4),
                              Expanded(
                                child: Text(
                                  event.location!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: hasBackground
                                            ? colorScheme.onSurface.withOpacity(
                                                0.7,
                                              )
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onEditEvent != null)
                    IconButton(
                      onPressed: () => onEditEvent!(event),
                      icon: Icon(Symbols.edit, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onMonthChanged;

  const _MonthPicker({
    required this.selectedDate,
    required this.focusedMonth,
    required this.onSelectDate,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthDays = _buildMonthCells(focusedMonth);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: () => onMonthChanged(
                DateTime(focusedMonth.year, focusedMonth.month - 1),
              ),
              icon: const Icon(Symbols.chevron_left),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            Expanded(
              child: Center(
                child: Text(
                  _formatMonthYear(focusedMonth),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => onMonthChanged(
                DateTime(focusedMonth.year, focusedMonth.month + 1),
              ),
              icon: const Icon(Symbols.chevron_right),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
        const Gap(8),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: monthDays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final day = monthDays[index];
            final selected = DateUtils.isSameDay(day, selectedDate);
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelectDate(day),
              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? colorScheme.primary : Colors.transparent,
                  ),
                  child: Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? colorScheme.onPrimary
                          : _sameMonth(day, focusedMonth)
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant.withOpacity(0.45),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CalendarFilterGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CalendarFilterGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        ...children,
      ],
    );
  }
}

class _CalendarFiltersSheet extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final bool includeNotableDays;
  final String fullDateFormat;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<bool> onToggleNotableDays;
  final VoidCallback onJumpToToday;

  const _CalendarFiltersSheet({
    required this.selectedDate,
    required this.focusedMonth,
    required this.includeNotableDays,
    required this.fullDateFormat,
    required this.onSelectDate,
    required this.onMonthChanged,
    required this.onToggleNotableDays,
    required this.onJumpToToday,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _MonthPicker(
          selectedDate: selectedDate,
          focusedMonth: focusedMonth,
          onSelectDate: onSelectDate,
          onMonthChanged: onMonthChanged,
        ),
        const Gap(16),
        SwitchListTile(
          value: includeNotableDays,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Include notable days'),
          subtitle: const Text('Show holidays and public notable dates'),
          onChanged: onToggleNotableDays,
        ),
        const Divider(height: 32),
        _CalendarFilterGroup(
          title: 'Selected date',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(fullDateFormat),
              subtitle: const Text(
                'Day, week, and year views follow this date',
              ),
              trailing: TextButton(
                onPressed: onJumpToToday,
                child: const Text('Today'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CalendarFiltersSidebar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final bool includeNotableDays;
  final String fullDateFormat;
  final EventHubViewMode currentMode;
  final ValueChanged<EventHubViewMode> onModeChanged;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<bool> onToggleNotableDays;
  final VoidCallback onJumpToToday;

  const _CalendarFiltersSidebar({
    required this.selectedDate,
    required this.focusedMonth,
    required this.includeNotableDays,
    required this.fullDateFormat,
    required this.currentMode,
    required this.onModeChanged,
    required this.onSelectDate,
    required this.onMonthChanged,
    required this.onToggleNotableDays,
    required this.onJumpToToday,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        SegmentedButton<EventHubViewMode>(
          segments: const [
            ButtonSegment(value: EventHubViewMode.day, label: Text('Day')),
            ButtonSegment(value: EventHubViewMode.week, label: Text('Week')),
            ButtonSegment(value: EventHubViewMode.month, label: Text('Month')),
          ],
          selected: {currentMode},
          emptySelectionAllowed: false,
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            onModeChanged(selection.first);
          },
        ),
        const Gap(16),
        _MonthPicker(
          selectedDate: selectedDate,
          focusedMonth: focusedMonth,
          onSelectDate: onSelectDate,
          onMonthChanged: onMonthChanged,
        ),
        const Gap(16),
        SwitchListTile(
          value: includeNotableDays,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Include notable days'),
          subtitle: const Text('Show holidays and public notable dates'),
          onChanged: onToggleNotableDays,
        ),
        const Divider(height: 32),
        _CalendarFilterGroup(
          title: 'Selected date',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(fullDateFormat),
              subtitle: const Text(
                'Day, week, and year views follow this date',
              ),
              trailing: TextButton(
                onPressed: onJumpToToday,
                child: const Text('Today'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

SnEventCalendarEntry? _entryForDay(
  List<SnEventCalendarEntry> entries,
  DateTime day,
) {
  for (final entry in entries) {
    if (DateUtils.isSameDay(entry.date, day)) return entry;
  }
  return null;
}

List<DateTime> _buildWeekDays(DateTime selectedDate) {
  final start = DateUtils.dateOnly(
    selectedDate.subtract(Duration(days: selectedDate.weekday - 1)),
  );
  return List.generate(7, (index) => start.add(Duration(days: index)));
}

List<DateTime> _buildMonthCells(DateTime focusedMonth) {
  final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
  final start = firstOfMonth.subtract(Duration(days: firstOfMonth.weekday - 1));
  return List.generate(
    42,
    (index) => DateUtils.dateOnly(start.add(Duration(days: index))),
  );
}

bool _sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

String _formatEventTime(SnUserCalendarEvent event) {
  if (event.isAllDay) return 'All day';
  final start = DateFormat.Hm().format(event.startTime.toLocal());
  final end = DateFormat.Hm().format(event.endTime.toLocal());
  return '$start – $end';
}

String _formatMonthYear(DateTime value) => DateFormat.yMMMM().format(value);

String _formatFullDate(DateTime value) => DateFormat.yMMMMEEEEd().format(value);
