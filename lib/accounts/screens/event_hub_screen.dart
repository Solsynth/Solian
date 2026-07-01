import 'dart:async';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/accounts/screens/event_hub_schedule.dart';
import 'package:island/accounts/widgets/account/calendar_event_creation_sheet.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

/// Notable day tag filter options (int-based enum matching backend)
enum NotableDayTagFilter {
  holiday(0),
  event(1),
  anniversary(2),
  memorial(3),
  festival(4);

  final int value;
  const NotableDayTagFilter(this.value);
}

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

    // --- Search & filter states (debounced like discovery search) ---
    final searchQuery = useState<String>('');
    final debouncedSearchQuery = useState<String>('');
    final selectedTags = useState<Set<String>>({});
    final selectedNotableDayTag = useState<NotableDayTagFilter?>(null);
    final isSearchActive = useState(false);
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final debounceTimer = useRef<Timer?>(null);
    const debounceDelay = Duration(milliseconds: 450);

    // Debounce search query using useEffect (like discovery/search.dart)
    useEffect(() {
      if (searchQuery.value.isEmpty) {
        debounceTimer.value?.cancel();
        debouncedSearchQuery.value = '';
        return null;
      }
      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(debounceDelay, () {
        debouncedSearchQuery.value = searchQuery.value;
      });
      return () => debounceTimer.value?.cancel();
    }, [searchQuery.value]);

    final query = EventCalendarQuery(
      uname: name,
      year: focusedMonth.value.year,
      month: focusedMonth.value.month,
      includeNotableDays: includeNotableDays.value,
    );
    final events = ref.watch(eventCalendarProvider(query));

    // Keep previous data while loading a new month/query
    final previousEntries = useRef<List<SnEventCalendarEntry>?>(null);
    useEffect(() {
      if (events.hasValue) {
        previousEntries.value = events.asData?.value;
      }
      return null;
    }, [events.hasValue, events.asData?.value]);

    // Use previous data while loading new month
    final hasAnyData = events.hasValue || previousEntries.value != null;

    // Fetch user's used tags for tag filter suggestions
    final usedTagsAsync = ref.watch(usedCalendarTagsProvider);

    // Determine if we should show search results
    final hasActiveFilters =
        debouncedSearchQuery.value.isNotEmpty ||
        selectedTags.value.isNotEmpty ||
        selectedNotableDayTag.value != null;
    final searchTags = selectedTags.value.toList()..sort();

    // Always watch the search provider (hooks must be called unconditionally)
    final searchResultsAsync = ref.watch(
      calendarSearchProvider(
        CalendarSearchQuery(
          query: debouncedSearchQuery.value.trim().isNotEmpty
              ? debouncedSearchQuery.value.trim()
              : null,
          tags: searchTags,
          startTime: DateTime.utc(
            focusedMonth.value.year,
            focusedMonth.value.month,
            1,
          ),
          endTime: DateTime.utc(
            focusedMonth.value.year,
            focusedMonth.value.month + 1,
            1,
          ),
          notableDayTag: selectedNotableDayTag.value?.value,
          isSearchActive: isSearchActive.value && hasActiveFilters,
        ),
      ),
    );

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
        ref.invalidate(usedCalendarTagsProvider);
      }
    }

    void openNotableDayDetail(String occurrenceKey) {
      // Navigate to notable day detail screen or show dialog
      showDialog<void>(
        context: context,
        builder: (context) =>
            _NotableDayDetailDialog(occurrenceKey: occurrenceKey),
      );
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

    // Cleanup debounce timer on dispose
    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

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
              // New: tag filter params
              initialSelectedTags: selectedTags.value,
              initialSelectedNotableDayTag: selectedNotableDayTag.value,
              usedTags: usedTagsAsync.value ?? [],
              onToggleTag: (tag) {
                final newTags = Set<String>.from(selectedTags.value);
                if (newTags.contains(tag)) {
                  newTags.remove(tag);
                } else {
                  newTags.add(tag);
                }
                selectedTags.value = newTags;
              },
              onNotableDayTagChanged: (tag) {
                selectedNotableDayTag.value = tag;
              },
              onClearFilters: () {
                selectedTags.value = {};
                selectedNotableDayTag.value = null;
                debounceTimer.value?.cancel();
                searchQuery.value = '';
                debouncedSearchQuery.value = '';
              },
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

    // Resolve entries: use current data or fallback to previous entries
    final currentEntries =
        events.value ?? previousEntries.value ?? const <SnEventCalendarEntry>[];
    final isRefreshing = events.isLoading;

    final calendarBody = isSearchActive.value && hasActiveFilters
        ? const SizedBox.shrink() // replaced by search results
        : Builder(
            builder: (context) {
              final dayEvents = eventHubEventsForDay(
                currentEntries,
                selectedDate.value,
              );
              final weekDays = _buildWeekDays(selectedDate.value);
              final weekSections = weekDays
                  .map(
                    (day) => EventHubDaySection(
                      date: day,
                      events: eventHubEventsForDay(currentEntries, day),
                    ),
                  )
                  .where((section) => section.events.isNotEmpty)
                  .toList();

              final viewContent = switch (mode.value) {
                EventHubViewMode.month => _MonthCalendarView(
                  username: name,
                  entries: currentEntries,
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

              // Build the calendar view content (always, so it can be cached while loading)
              final calendarContent = Container(
                key: ValueKey(
                  '${mode.value}_${focusedMonth.value.year}_${focusedMonth.value.month}',
                ),
                padding: switch (mode.value) {
                  EventHubViewMode.month => EdgeInsets.zero,
                  _ => const EdgeInsets.symmetric(horizontal: 12),
                },
                child: viewContent,
              );

              return AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isRefreshing ? 0.5 : 1.0,
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 350),
                  reverse: false,
                  transitionBuilder:
                      (
                        Widget child,
                        Animation<double> primaryAnimation,
                        Animation<double> secondaryAnimation,
                      ) {
                        return SharedAxisTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child,
                        );
                      },
                  child: calendarContent,
                ),
              );
            },
          );

    // Sync indicator overlay (animated slide-in/out like sync_indicator.dart)
    // Always rendered in Stack — internal animation handles show/hide
    final syncIndicator = Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: hasAnyData
          ? _CalendarSyncIndicator(isLoading: isRefreshing)
          : const SizedBox.shrink(),
    );

    final filterSidebarContent = _CalendarFiltersSidebar(
      selectedDate: selectedDate.value,
      focusedMonth: focusedMonth.value,
      includeNotableDays: includeNotableDays.value,
      fullDateFormat: _formatFullDate(selectedDate.value),
      currentMode: mode.value,
      // New: tag filter params
      selectedTags: selectedTags.value,
      selectedNotableDayTag: selectedNotableDayTag.value,
      usedTags: usedTagsAsync.value ?? [],
      onToggleTag: (tag) {
        final newTags = Set<String>.from(selectedTags.value);
        if (newTags.contains(tag)) {
          newTags.remove(tag);
        } else {
          newTags.add(tag);
        }
        selectedTags.value = newTags;
      },
      onNotableDayTagChanged: (tag) {
        selectedNotableDayTag.value = tag;
      },
      onClearFilters: () {
        selectedTags.value = {};
        selectedNotableDayTag.value = null;
      },
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

    // Build search results widget
    final searchResultsWidget = searchResultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.search_off,
                    size: 48,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const Gap(16),
                  Text(
                    'noSearchResults'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'eventHubNoResultsHint'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return _SearchResultsList(
          results: results,
          username: name,
          onEditEvent: name == 'me'
              ? (event) => openEditor(event: event)
              : null,
          onOpenNotableDay: openNotableDayDetail,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.error, size: 48, color: colorScheme.error),
              const Gap(16),
              Text(
                'eventHubSearchFailed'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap content body with sync indicator overlay
    final mainContent = (isSearchActive.value && hasActiveFilters)
        ? searchResultsWidget
        : calendarBody;
    final contentBody = hasAnyData
        ? Stack(children: [mainContent, syncIndicator])
        : mainContent;

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
              mainContent: contentBody,
            ),
          )
        : contentBody;

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        surfaceTintColor: colorScheme.surfaceTint,
        scrolledUnderElevation: 3,
        centerTitle: true,
        leading: const AutoLeadingButton(),
        automaticallyImplyLeading: false,
        title: isSearchActive.value
            ? SearchBar(
                controller: searchController,
                focusNode: searchFocusNode,
                constraints: const BoxConstraints(maxWidth: 400, minHeight: 32),
                hintText: 'searchEvents'.tr(),
                hintStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
                textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
                onTapOutside: (_) => searchFocusNode.unfocus(),
                trailing: [
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        debounceTimer.value?.cancel();
                        searchController.clear();
                        searchQuery.value = '';
                        debouncedSearchQuery.value = '';
                        selectedTags.value = {};
                        selectedNotableDayTag.value = null;
                      },
                      icon: Icon(
                        Symbols.close,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
                onChanged: (value) {
                  searchQuery.value = value;
                },
                onSubmitted: (value) {
                  debounceTimer.value?.cancel();
                  searchQuery.value = value;
                  debouncedSearchQuery.value = value;
                  searchFocusNode.unfocus();
                },
                leading: Icon(
                  Symbols.search,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
              )
            : Text('eventCalendar'.tr()),
        actions: [
          // Search toggle
          IconButton(
            onPressed: () {
              if (isSearchActive.value) {
                debounceTimer.value?.cancel();
                searchController.clear();
                searchQuery.value = '';
                debouncedSearchQuery.value = '';
                selectedTags.value = {};
                selectedNotableDayTag.value = null;
                isSearchActive.value = false;
              } else {
                isSearchActive.value = true;
                Future.microtask(() => searchFocusNode.requestFocus());
              }
            },
            icon: Icon(
              isSearchActive.value ? Symbols.search_off : Symbols.search,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: isSearchActive.value
                ? 'eventHubSearchClose'.tr()
                : 'searchEvents'.tr(),
          ),
          // Filters
          IconButton(
            onPressed: openFilters,
            icon: Icon(
              Symbols.tune,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: 'eventHubFilters'.tr(),
          ),
          if (isWide) ...[
            IconButton(
              onPressed: () =>
                  showInspectorSidebar.value = !showInspectorSidebar.value,
              icon: Icon(
                Symbols.calendar_today,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              tooltip: 'eventHubEvents'.tr(),
            ),
          ],
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: (isSearchActive.value && hasActiveFilters)
                ? searchResultsWidget
                : wrappedBody,
          ),
        ],
      ),
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
                  final names = [
                    'eventHubWeekdayMon'.tr(),
                    'eventHubWeekdayTue'.tr(),
                    'eventHubWeekdayWed'.tr(),
                    'eventHubWeekdayThu'.tr(),
                    'eventHubWeekdayFri'.tr(),
                    'eventHubWeekdaySat'.tr(),
                    'eventHubWeekdaySun'.tr(),
                  ];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        names[index],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ).padding(horizontal: 16),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: monthDays.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: aspectRatio,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                ),
                itemBuilder: (context, index) {
                  final day = monthDays[index];
                  final entry = _entryForDay(entries, day);
                  final dayEvents = eventHubEventsForDay(entries, day);
                  return _CalendarDayCell(
                    day: day,
                    focusedMonth: focusedMonth,
                    selectedDate: selectedDate,
                    entry: entry,
                    gridIndex: index,
                    onTap: () => onSelectDate(day),
                    userEventsOverride: dayEvents,
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
        content = _buildMonthWithHeader(context, monthGrid);
      } else {
        content = LayoutBuilder(
          builder: (context, constraints) {
            final sheetMaxHeight = constraints.maxHeight * 0.85;
            return DraggableOverlaySheet(
              body: _buildMonthWithHeader(context, monthGrid),
              minHeight: 120,
              initialHeight: constraints.maxHeight * 0.25,
              maxHeight: sheetMaxHeight,
              snapHeights: [
                120,
                constraints.maxHeight * 0.25,
                constraints.maxHeight * 0.5,
                sheetMaxHeight,
              ],
              useBottomSafeAreaWhenExpanded: true,
              useBottomSafeAreaWhenCollapsed: false,
              backgroundColor: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: _DayAgenda(
                username: username,
                selectedDate: selectedDate,
                events: selectedEvents,
                onEditEvent: onEditEvent,
                onAddEvent: onAddEvent,
                compact: true,
                entry: agendaEntry,
              ),
            );
          },
        );
      }
    } else {
      content = _buildMonthWithHeader(context, monthGrid);
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

  /// Wraps the month grid with a title header and divider below weekday labels
  Widget _buildMonthWithHeader(BuildContext context, Widget monthGrid) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Month title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatMonthYear(focusedMonth),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Month grid (includes title + weekday headers + divider)
        Expanded(child: monthGrid),
        const Gap(8),
      ],
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final SnEventCalendarEntry? entry;
  final int gridIndex;
  final VoidCallback onTap;
  final List<SnUserCalendarEvent>? userEventsOverride;

  const _CalendarDayCell({
    required this.day,
    required this.focusedMonth,
    required this.selectedDate,
    required this.entry,
    required this.gridIndex,
    required this.onTap,
    this.userEventsOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = DateUtils.isSameDay(day, selectedDate);
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final isOutside = !_sameMonth(day, focusedMonth);
    final userEvents =
        userEventsOverride ??
        entry?.userEvents ??
        const <SnUserCalendarEvent>[];
    final notableDays = entry?.notableDays ?? const <SnNotableDay>[];
    final checkIn = entry?.checkInResult;
    final statuses = entry?.statuses ?? const <SnAccountStatus>[];

    // Shared grid lines: each cell draws right and bottom edges
    // so adjacent cells share a single line, no doubling
    final column = gridIndex % 7;
    final row = gridIndex ~/ 7;
    const totalRows = 6;
    final isLastColumn = column == 6;
    final isLastRow = row == totalRows - 1;
    final gridLine = Border(
      right: isLastColumn
          ? BorderSide.none
          : BorderSide(color: colorScheme.outlineVariant, width: 1),
      bottom: isLastRow
          ? BorderSide.none
          : BorderSide(color: colorScheme.outlineVariant, width: 1),
    );

    final textColor = isSelected
        ? colorScheme.onPrimaryContainer
        : isOutside
        ? colorScheme.onSurfaceVariant.withOpacity(0.4)
        : isToday
        ? colorScheme.primary
        : colorScheme.onSurface;

    final tertiaryColor = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.tertiary;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withOpacity(0.35)
              : isToday
              ? colorScheme.primaryContainer.withOpacity(0.15)
              : Colors.transparent,
          border: isToday && !isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : gridLine,
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
                child: statuses.first.icon != null
                    ? ClipOval(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CloudFileWidget(
                            item: statuses.first.icon!,
                            fit: BoxFit.cover,
                            useInternalGate: false,
                          ),
                        ),
                      )
                    : Icon(
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

  const _DayAgenda({
    required this.username,
    required this.selectedDate,
    required this.events,
    this.onEditEvent,
    this.onAddEvent,
    this.compact = false,
    this.entry,
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
                'eventHubNoEvents'.tr(),
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
    final hasBackground = status.background != null;
    final hasIcon = status.icon != null;
    final textShadow = hasBackground
        ? const [
            Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
          ]
        : null;
    final title = status.label.isNotEmpty
        ? status.label
        : getStatusDisplayLabel(context, status);

    final card = Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (hasBackground)
              Positioned.fill(
                child: CloudImageWidget(
                  file: status.background,
                  aspectRatio: 16 / 9,
                  noBlurhash: true,
                ),
              ),
            if (hasBackground)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.45),
                      ],
                    ),
                  ),
                ),
              ),
            Align(
              alignment: hasBackground
                  ? Alignment.bottomLeft
                  : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    hasIcon
                        ? ProfilePictureWidget(
                            file: status.icon,
                            radius: hasBackground ? 24 : 20,
                            borderRadius: hasBackground ? 14 : 12,
                            fallbackIcon: switch (status.attitude) {
                              0 => Symbols.sentiment_satisfied,
                              2 => Symbols.sentiment_dissatisfied,
                              _ => Symbols.sentiment_neutral,
                            },
                          )
                        : Container(
                            width: hasBackground ? 48 : 40,
                            height: hasBackground ? 48 : 40,
                            decoration: BoxDecoration(
                              color: hasBackground
                                  ? Colors.white24
                                  : colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                hasBackground ? 14 : 12,
                              ),
                            ),
                            child: Icon(
                              switch (status.attitude) {
                                0 => Symbols.sentiment_satisfied,
                                2 => Symbols.sentiment_dissatisfied,
                                _ => Symbols.sentiment_neutral,
                              },
                              size: hasBackground ? 22 : 18,
                              color: hasBackground
                                  ? Colors.white
                                  : colorScheme.onPrimaryContainer,
                            ),
                          ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: hasBackground ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: hasBackground ? Colors.white : null,
                                  fontWeight: FontWeight.w600,
                                  shadows: textShadow,
                                ),
                          ),
                          if ((status.symbol ?? '').isNotEmpty)
                            Text(
                              status.symbol!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: hasBackground
                                        ? Colors.white.withOpacity(0.92)
                                        : colorScheme.onSurfaceVariant,
                                    shadows: textShadow,
                                  ),
                            ),
                          Text(
                            status.isOnline ? 'online'.tr() : 'offline'.tr(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: hasBackground
                                      ? Colors.white.withOpacity(0.82)
                                      : colorScheme.onSurfaceVariant,
                                  shadows: textShadow,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (hasBackground) {
      return AspectRatio(aspectRatio: 16 / 9, child: card);
    }

    return card;
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
              'eventHubWeekNumber'.tr(
                args: [_weekOfMonth(selectedDate).toString()],
              ),
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
                  'eventHubNoEventsWeek'.tr(),
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
                'eventHubNoEvents'.tr(),
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
                            ? 'eventHubAllDay'.tr()
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasBackground = event.background != null;
    final hasIcon = event.icon != null;
    final textColor = hasBackground
        ? colorScheme.onSurface
        : colorScheme.onSurface;
    final subTextColor = hasBackground
        ? colorScheme.onSurface.withOpacity(0.7)
        : colorScheme.onSurfaceVariant;

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
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            Icon(
                              Symbols.schedule,
                              size: 13,
                              color: subTextColor,
                            ),
                            const Gap(4),
                            Text(
                              _formatEventTime(event),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: subTextColor,
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
                                color: subTextColor,
                              ),
                              const Gap(4),
                              Expanded(
                                child: Text(
                                  event.location!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: subTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Owner account info (for friend/subscription events)
                        if (event.account != null &&
                            event.accountId != 'me' &&
                            username != event.account?.name) ...[
                          const Gap(4),
                          Row(
                            children: [
                              Icon(
                                Symbols.person,
                                size: 13,
                                color: subTextColor,
                              ),
                              const Gap(4),
                              Expanded(
                                child: Text(
                                  event.account?.nick ??
                                      event.account?.name ??
                                      '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: subTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Tags
                        if (event.tags.isNotEmpty) ...[
                          const Gap(6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: event.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
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

class _CalendarFiltersSheet extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final bool includeNotableDays;
  final String fullDateFormat;
  final Set<String> initialSelectedTags;
  final NotableDayTagFilter? initialSelectedNotableDayTag;
  final List<String> usedTags;
  final ValueChanged<String> onToggleTag;
  final ValueChanged<NotableDayTagFilter?> onNotableDayTagChanged;
  final VoidCallback onClearFilters;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<bool> onToggleNotableDays;
  final VoidCallback onJumpToToday;

  const _CalendarFiltersSheet({
    required this.selectedDate,
    required this.focusedMonth,
    required this.includeNotableDays,
    required this.fullDateFormat,
    required this.initialSelectedTags,
    required this.initialSelectedNotableDayTag,
    required this.usedTags,
    required this.onToggleTag,
    required this.onNotableDayTagChanged,
    required this.onClearFilters,
    required this.onSelectDate,
    required this.onMonthChanged,
    required this.onToggleNotableDays,
    required this.onJumpToToday,
  });

  @override
  State<_CalendarFiltersSheet> createState() => _CalendarFiltersSheetState();
}

class _CalendarFiltersSheetState extends State<_CalendarFiltersSheet> {
  late Set<String> _selectedTags;
  late NotableDayTagFilter? _selectedNotableDayTag;

  @override
  void initState() {
    super.initState();
    _selectedTags = Set<String>.from(widget.initialSelectedTags);
    _selectedNotableDayTag = widget.initialSelectedNotableDayTag;
  }

  @override
  Widget build(BuildContext context) {
    final usedTags = widget.usedTags;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _MonthPicker(
          selectedDate: widget.selectedDate,
          focusedMonth: widget.focusedMonth,
          onSelectDate: widget.onSelectDate,
          onMonthChanged: widget.onMonthChanged,
        ),
        const Gap(16),
        SwitchListTile(
          value: widget.includeNotableDays,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text('eventHubIncludeNotableDays'.tr()),
          subtitle: Text('eventHubIncludeNotableDaysDesc'.tr()),
          onChanged: widget.onToggleNotableDays,
        ),
        const Gap(16),
        // Tag filters section
        if (usedTags.isNotEmpty || _selectedTags.isNotEmpty) ...[
          _CalendarFilterGroup(
            title: 'eventHubFilterByTags'.tr(),
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: usedTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        if (_selectedTags.contains(tag)) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      });
                      widget.onToggleTag(tag);
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ),
          const Gap(16),
        ],
        // Notable day tag filter
        _CalendarFilterGroup(
          title: 'Notable day type',
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: NotableDayTagFilter.values.map((tag) {
                final isSelected = _selectedNotableDayTag == tag;
                return FilterChip(
                  label: Text(_notableDayTagLabel(tag)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedNotableDayTag = selected ? tag : null;
                    });
                    widget.onNotableDayTagChanged(selected ? tag : null);
                  },
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
        // Clear filters button
        if (_selectedTags.isNotEmpty || _selectedNotableDayTag != null) ...[
          const Gap(12),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedTags = {};
                _selectedNotableDayTag = null;
              });
              widget.onClearFilters();
            },
            icon: const Icon(Symbols.clear_all, size: 16),
            label: Text('eventHubClearFilters'.tr()),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
        const Gap(16),
        _CalendarFilterGroup(
          title: 'eventHubSelectedDate'.tr(),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(widget.fullDateFormat),
              subtitle: Text('eventHubSelectedDateHint'.tr()),
              trailing: TextButton(
                onPressed: widget.onJumpToToday,
                child: Text('eventHubToday'.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _notableDayTagLabel(NotableDayTagFilter tag) {
    return switch (tag) {
      NotableDayTagFilter.holiday => 'eventHubNotableHoliday'.tr(),
      NotableDayTagFilter.event => 'eventHubNotableEvent'.tr(),
      NotableDayTagFilter.anniversary => 'eventHubNotableAnniversary'.tr(),
      NotableDayTagFilter.memorial => 'eventHubNotableMemorial'.tr(),
      NotableDayTagFilter.festival => 'eventHubNotableFestival'.tr(),
    };
  }
}

class _CalendarFiltersSidebar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final bool includeNotableDays;
  final String fullDateFormat;
  final EventHubViewMode currentMode;
  final Set<String> selectedTags;
  final NotableDayTagFilter? selectedNotableDayTag;
  final List<String> usedTags;
  final ValueChanged<String> onToggleTag;
  final ValueChanged<NotableDayTagFilter?> onNotableDayTagChanged;
  final VoidCallback onClearFilters;
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
    required this.selectedTags,
    required this.selectedNotableDayTag,
    required this.usedTags,
    required this.onToggleTag,
    required this.onNotableDayTagChanged,
    required this.onClearFilters,
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
          segments: [
            ButtonSegment(
              value: EventHubViewMode.day,
              label: Text('eventHubViewDay'.tr()),
            ),
            ButtonSegment(
              value: EventHubViewMode.week,
              label: Text('eventHubViewWeek'.tr()),
            ),
            ButtonSegment(
              value: EventHubViewMode.month,
              label: Text('eventHubViewMonth'.tr()),
            ),
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
          title: Text('eventHubIncludeNotableDays'.tr()),
          subtitle: Text('eventHubIncludeNotableDaysDesc'.tr()),
          onChanged: onToggleNotableDays,
        ),
        const Gap(16),
        // Tag filters section
        if (usedTags.isNotEmpty || selectedTags.isNotEmpty) ...[
          _CalendarFilterGroup(
            title: 'eventHubFilterByTags'.tr(),
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: usedTags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) => onToggleTag(tag),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ),
          const Gap(16),
        ],
        // Notable day tag filter
        _CalendarFilterGroup(
          title: 'eventHubNotableDayType'.tr(),
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: NotableDayTagFilter.values.map((tag) {
                final isSelected = selectedNotableDayTag == tag;
                return FilterChip(
                  label: Text(_notableDayTagLabel(tag)),
                  selected: isSelected,
                  onSelected: (selected) {
                    onNotableDayTagChanged(selected ? tag : null);
                  },
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
        // Clear filters button
        if (selectedTags.isNotEmpty || selectedNotableDayTag != null) ...[
          const Gap(12),
          TextButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(Symbols.clear_all, size: 16),
            label: Text('eventHubClearFilters'.tr()),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
        const Gap(16),
        _CalendarFilterGroup(
          title: 'eventHubSelectedDate'.tr(),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(fullDateFormat),
              subtitle: Text('eventHubSelectedDateHint'.tr()),
              trailing: TextButton(
                onPressed: onJumpToToday,
                child: Text('eventHubToday'.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _notableDayTagLabel(NotableDayTagFilter tag) {
    return switch (tag) {
      NotableDayTagFilter.holiday => 'eventHubNotableHoliday'.tr(),
      NotableDayTagFilter.event => 'eventHubNotableEvent'.tr(),
      NotableDayTagFilter.anniversary => 'eventHubNotableAnniversary'.tr(),
      NotableDayTagFilter.memorial => 'eventHubNotableMemorial'.tr(),
      NotableDayTagFilter.festival => 'eventHubNotableFestival'.tr(),
    };
  }
}

/// Search results list widget - styled like week view with date sections
class _SearchResultsList extends StatelessWidget {
  final List<CalendarSearchResult> results;
  final String username;
  final ValueChanged<SnUserCalendarEvent>? onEditEvent;
  final ValueChanged<String>? onOpenNotableDay;

  const _SearchResultsList({
    required this.results,
    required this.username,
    this.onEditEvent,
    this.onOpenNotableDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Group results by date
    final sections = _buildSections();

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: sections.length + 1, // +1 for header
      itemBuilder: (context, index) {
        // Header item
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'eventHubSearchResults'.tr(args: [results.length.toString()]),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          );
        }
        final section = sections[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header (like week view)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  _formatFullDate(section.date),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Items for this date
              ...section.items.map((item) {
                Widget child;

                if (item.userEvent != null) {
                  child = Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _EventTile(
                      username: username,
                      event: item.userEvent!,
                      onEditEvent: onEditEvent,
                    ),
                  );
                } else if (item.notableDay != null) {
                  child = _NotableDayResultCard(
                    notableDay: item.notableDay!,
                    onTap: onOpenNotableDay,
                  );
                } else {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: child,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  List<_SearchSection> _buildSections() {
    final Map<DateTime, List<CalendarSearchResult>> grouped = {};

    for (final result in results) {
      final date = DateUtils.dateOnly(result.startTime);
      grouped.putIfAbsent(date, () => []).add(result);
    }

    final sortedDates = grouped.keys.toList()..sort();

    return sortedDates.map((date) {
      final items = grouped[date]!;
      // Sort items within a day: all-day first, then by start time
      items.sort((a, b) {
        if (a.userEvent != null && b.userEvent != null) {
          if (a.userEvent!.isAllDay != b.userEvent!.isAllDay) {
            return a.userEvent!.isAllDay ? -1 : 1;
          }
          return a.startTime.compareTo(b.startTime);
        }
        return a.startTime.compareTo(b.startTime);
      });
      return _SearchSection(date: date, items: items);
    }).toList();
  }
}

class _SearchSection {
  final DateTime date;
  final List<CalendarSearchResult> items;

  const _SearchSection({required this.date, required this.items});
}

/// Notable day result card in search results
class _NotableDayResultCard extends StatelessWidget {
  final SnNotableDayDetail notableDay;
  final ValueChanged<String>? onTap;

  const _NotableDayResultCard({required this.notableDay, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayName = notableDay.localName.isNotEmpty
        ? notableDay.localName
        : notableDay.globalName;

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.tertiaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: notableDay.occurrenceKey != null
            ? () => onTap?.call(notableDay.occurrenceKey!)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Symbols.celebration,
                size: 20,
                color: colorScheme.onTertiaryContainer,
                fill: 1,
              ),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat.yMMMd().format(notableDay.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onTertiaryContainer.withOpacity(0.7),
                      ),
                    ),
                    if (notableDay.tags != null &&
                        notableDay.tags!.isNotEmpty) ...[
                      const Gap(4),
                      Wrap(
                        spacing: 4,
                        children: notableDay.tags!.map((tag) {
                          return Chip(
                            label: Text(
                              tag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                              ),
                            ),
                            backgroundColor: colorScheme.tertiary.withOpacity(
                              0.3,
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                size: 18,
                color: colorScheme.onTertiaryContainer.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notable day detail dialog
class _NotableDayDetailDialog extends HookConsumerWidget {
  final String occurrenceKey;

  const _NotableDayDetailDialog({required this.occurrenceKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch notable day detail
    final detailAsync = useMemoized(
      () => _fetchNotableDayDetail(ref, occurrenceKey),
      [occurrenceKey],
    );
    final detailFuture = useFuture(detailAsync);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (detailFuture.hasData) ...[
                _buildDetailContent(context, detailFuture.data!),
              ] else if (detailFuture.hasError)
                _buildErrorContent(context, detailFuture.error!)
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              const Gap(16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('close'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localName = data['local_name'] as String? ?? '';
    final globalName = data['global_name'] as String? ?? '';
    final description = data['description'] as String?;
    final dateStr = data['date'] as String?;
    final holidays =
        (data['holidays'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final tags =
        (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];

    DateTime? date;
    if (dateStr != null) {
      date = DateTime.tryParse(dateStr);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.celebration,
              size: 24,
              color: colorScheme.tertiary,
              fill: 1,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                localName.isNotEmpty ? localName : globalName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (date != null) ...[
          const Gap(8),
          Text(
            DateFormat.yMMMMEEEEd().format(date),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (description != null && description.isNotEmpty) ...[
          const Gap(12),
          Text(description, style: theme.textTheme.bodyMedium),
        ],
        if (tags.isNotEmpty) ...[
          const Gap(12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
        if (holidays.isNotEmpty) ...[
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: holidays.map((h) {
              return Chip(
                label: Text(h),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: colorScheme.primaryContainer,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, Object error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Symbols.error, size: 48, color: colorScheme.error),
        const Gap(16),
        Text(
          'eventHubFailedToLoadNotableDay'.tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          error.toString(),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _fetchNotableDayDetail(
    WidgetRef ref,
    String key,
  ) async {
    final client = ref.read(solarNetworkClientProvider);
    return await client.accounts.getNotableDayDetail(key);
  }
}

/// Animated linear progress bar that slides in/out under the AppBar.
class _CalendarSyncIndicator extends HookConsumerWidget {
  final bool isLoading;

  const _CalendarSyncIndicator({required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFirstBuild = useRef(true);
    final wasLoading = useRef(false);

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // Track previous loading state to detect transitions
    useEffect(() {
      if (isFirstBuild.value) {
        isFirstBuild.value = false;
        wasLoading.value = isLoading;
        return null;
      }
      if (isLoading != wasLoading.value) {
        wasLoading.value = isLoading;
        if (isLoading) {
          controller.forward(from: 0);
        } else {
          controller.reverse(from: 1);
        }
      }
      return null;
    }, [isLoading]);

    // Initial animation on first load
    useEffect(() {
      if (isLoading && isFirstBuild.value) {
        controller.forward(from: 0);
      }
      return null;
    }, []);

    const barHeight = 4.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeInOutCubic.transform(controller.value);
        if (t <= 0) return const SizedBox.shrink();
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: t,
            child: Transform.translate(
              offset: Offset(0, (t - 1) * barHeight),
              child: child,
            ),
          ),
        );
      },
      child: LinearProgressIndicator(
        minHeight: barHeight,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
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

int _weekOfMonth(DateTime date) {
  final firstDayWeekday = DateTime(date.year, date.month, 1).weekday;
  return ((date.day + firstDayWeekday - 2) ~/ 7) + 1;
}

String _formatEventTime(SnUserCalendarEvent event) {
  if (event.isAllDay) return 'eventHubAllDay'.tr();
  final start = DateFormat.Hm().format(event.startTime.toLocal());
  final end = DateFormat.Hm().format(event.endTime.toLocal());
  return '$start – $end';
}

String _formatMonthYear(DateTime value) => DateFormat.yMMMM().format(value);

String _formatFullDate(DateTime value) => DateFormat.yMMMMEEEEd().format(value);
