import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/widgets/account/event_calendar_content.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class EventHubScreen extends HookConsumerWidget {
  final String name;

  const EventHubScreen({super.key, @pathParam required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('eventCalendar'.tr()), centerTitle: true),
      body: isWide ? _WideLayout(name: name) : _NarrowLayout(name: name),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final String name;

  const _WideLayout({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Calendar
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: EventCalendarContent(name: name),
          ),
        ),
        // Right column - Countdown
        Expanded(
          flex: 1,
          child: Material(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainer.withOpacity(0.5),
            child: _CountdownContent(name: name),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final String name;

  const _NarrowLayout({required this.name});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            elevation: 1,
            child: TabBar(
              tabs: [
                Tab(
                  icon: const Icon(Symbols.calendar_month),
                  text: 'eventCalendar'.tr(),
                ),
                Tab(
                  icon: const Icon(Symbols.timer),
                  text: 'eventCountdowns'.tr(),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: isWideScreen(context)
                      ? const EdgeInsets.all(16)
                      : EdgeInsets.zero,
                  child: EventCalendarContent(name: name),
                ),
                _CountdownContent(name: name),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownContent extends HookConsumerWidget {
  final String name;

  const _CountdownContent({required this.name});

  static const _availableTags = [
    null, // All
    'Holiday',
    'Event',
    'Anniversary',
    'Memorial',
    'Festival',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final includeNotableDays = useState(true);
    final selectedTag = useState<String?>(null);
    final query = EventCountdownQuery(
      username: name,
      includeNotableDays: includeNotableDays.value,
      tag: selectedTag.value,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'includeNotableDays'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: includeNotableDays.value,
                      onChanged: (value) {
                        includeNotableDays.value = value;
                      },
                    ),
                  ],
                ),
                const Gap(8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableTags.map((tag) {
                      final isSelected = selectedTag.value == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            tag == null
                                ? 'countdownTagAll'.tr()
                                : 'countdownTag$tag'.tr(),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            selectedTag.value = tag;
                          },
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const _TimeProgressPageView(),
        const Gap(8),
        Expanded(
          child: PaginationList<SnEventCountdownItem>(
            provider: eventCountdownListProvider(query),
            notifier: eventCountdownListProvider(query).notifier,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index, item) {
              return _CountdownCard(item: item, username: name);
            },
          ),
        ),
      ],
    );
  }
}

class _TimeProgressPageView extends HookWidget {
  const _TimeProgressPageView();

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(initialPage: 1);
    final currentPage = useState(1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 104,
          child: PageView(
            controller: pageController,
            onPageChanged: (page) => currentPage.value = page,
            children: [
              _TimeProgressCard(
                type: _TimeProgressType.week,
                title: 'timeProgressWeek'.tr(),
                icon: Symbols.calendar_view_week,
              ),
              _TimeProgressCard(
                type: _TimeProgressType.month,
                title: 'timeProgressMonth'.tr(),
                icon: Symbols.calendar_view_month,
              ),
              _TimeProgressCard(
                type: _TimeProgressType.year,
                title: 'timeProgressYear'.tr(),
                icon: Symbols.calendar_today,
              ),
            ],
          ),
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentPage.value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            );
          }),
        ),
      ],
    );
  }
}

enum _TimeProgressType { week, month, year }

class _TimeProgressCard extends HookWidget {
  final _TimeProgressType type;
  final String title;
  final IconData icon;

  const _TimeProgressCard({
    required this.type,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final currentTime = useState(DateTime.now());
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        currentTime.value = DateTime.now();
      });
      return timer.cancel;
    }, []);

    final progress = _calculateProgress(currentTime.value);
    final totalBlocks = _getTotalBlocks();
    final currentBlock = _getCurrentBlock(currentTime.value);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const Gap(8),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const Gap(12),
          if (type == _TimeProgressType.week)
            _buildWeekBlocks(colorScheme, currentBlock)
          else
            SizedBox(
              height: 24,
              child: Row(
                children: List.generate(totalBlocks, (index) {
                  final blockState = _getBlockState(index, currentBlock);
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _getBlockColor(blockState, colorScheme),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeekBlocks(ColorScheme colorScheme, int currentBlock) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SizedBox(
      height: 20,
      child: Row(
        children: List.generate(7, (index) {
          final blockState = _getBlockState(index, currentBlock);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _getBlockColor(blockState, colorScheme),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  weekdays[index],
                  style: TextStyle(
                    fontSize: 8,
                    color: blockState == _BlockState.today
                        ? colorScheme.primary
                        : (blockState == _BlockState.past
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant),
                    fontWeight: blockState == _BlockState.today
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  double _calculateProgress(DateTime now) {
    switch (type) {
      case _TimeProgressType.week:
        final dayOfWeek = now.weekday;
        final hourProgress = now.hour / 24;
        return ((dayOfWeek - 1 + hourProgress) / 7).clamp(0.0, 1.0);
      case _TimeProgressType.month:
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final dayProgress = now.day / daysInMonth;
        return dayProgress.clamp(0.0, 1.0);
      case _TimeProgressType.year:
        final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
        final isLeapYear =
            (now.year % 4 == 0 && now.year % 100 != 0) || (now.year % 400 == 0);
        final totalDays = isLeapYear ? 366 : 365;
        return (dayOfYear / totalDays).clamp(0.0, 1.0);
    }
  }

  int _getTotalBlocks() {
    switch (type) {
      case _TimeProgressType.week:
        return 7;
      case _TimeProgressType.month:
        return 30;
      case _TimeProgressType.year:
        return 12;
    }
  }

  int _getCurrentBlock(DateTime now) {
    switch (type) {
      case _TimeProgressType.week:
        return now.weekday - 1;
      case _TimeProgressType.month:
        return now.day - 1;
      case _TimeProgressType.year:
        return now.month - 1;
    }
  }

  _BlockState _getBlockState(int blockIndex, int currentBlock) {
    if (blockIndex < currentBlock) return _BlockState.past;
    if (blockIndex == currentBlock) return _BlockState.today;
    return _BlockState.future;
  }

  Color _getBlockColor(_BlockState state, ColorScheme colorScheme) {
    switch (state) {
      case _BlockState.past:
        return colorScheme.primary;
      case _BlockState.today:
        return colorScheme.primaryContainer;
      case _BlockState.future:
        return colorScheme.surfaceContainerHigh;
    }
  }
}

enum _BlockState { past, today, future }

class _CountdownCard extends StatelessWidget {
  final SnEventCountdownItem item;
  final String username;

  const _CountdownCard({required this.item, required this.username});

  bool get _isPast => item.startTime.isBefore(DateTime.now());

  Duration get _durationSince => DateTime.now().difference(item.startTime);

  String _formatDuration(BuildContext context, Duration duration) {
    if (duration.inDays > 365) {
      final years = duration.inDays ~/ 365;
      return '{}y'.tr(args: [years.toString()]);
    }
    if (duration.inDays > 30) {
      final months = duration.inDays ~/ 30;
      return '{}mo'.tr(args: [months.toString()]);
    }
    if (duration.inDays > 0) {
      return '{}d'.tr(args: [duration.inDays.toString()]);
    }
    if (duration.inHours > 0) {
      return '{}h'.tr(args: [duration.inHours.toString()]);
    }
    return '{}m'.tr(args: [duration.inMinutes.toString()]);
  }

  double _calculateYearProgress() {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final elapsedDuration = now.difference(yearStart).inMilliseconds;
    final eventDuration = item.startTime.difference(yearStart).inMilliseconds;

    if (eventDuration <= 0) return 1.0;
    return (elapsedDuration / eventDuration).clamp(0.0, 1.0);
  }

  Widget _buildPastDuration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final durationText = _formatDuration(context, _durationSince);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'countdownPast'.tr(args: [durationText]),
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isUserEvent = item.eventType == SnEventCountdownType.userEvent;
    final icon = isUserEvent ? Symbols.event : Symbols.celebration;
    final iconColor = isUserEvent ? colorScheme.primary : colorScheme.tertiary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isUserEvent && item.eventId != null
            ? () {
                context.router.push(
                  CalendarEventDetailRoute(
                    username: username,
                    eventId: item.eventId!,
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isUserEvent
                      ? colorScheme.primaryContainer
                      : colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Gap(6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _calculateYearProgress(),
                      minHeight: 4,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isUserEvent
                            ? colorScheme.primary
                            : colorScheme.tertiary,
                      ),
                    ),
                  ),
                  const Gap(6),
                  Row(
                    children: [
                      Icon(
                        Symbols.calendar_today,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const Gap(4),
                      Text(
                        DateFormat.MMMd().format(item.startTime.toLocal()),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (item.location != null) ...[
                        const Gap(8),
                        Icon(
                          Symbols.location_on,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const Gap(4),
                        Flexible(
                          child: Text(
                            item.location!,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Gap(12),
            if (item.isOngoing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.play_circle,
                      color: colorScheme.primary,
                      size: 14,
                    ),
                    const Gap(4),
                    Text(
                      'countdownOngoing'.tr(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else if (_isPast)
              _buildPastDuration(context)
            else
              SizedBox(
                width: 110,
                child: SlideCountdown(
                  decoration: const BoxDecoration(),
                  style: textTheme.titleSmall!.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  separatorStyle: textTheme.titleSmall!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  padding: EdgeInsets.zero,
                  duration: item.startTime.difference(DateTime.now()),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
