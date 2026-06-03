import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/calendar_event_creation_sheet.dart';
import 'package:island/core/network.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/core/widgets/embeds/embed_list.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class CalendarEventDetailScreen extends ConsumerWidget {
  final String username;
  final String eventId;

  const CalendarEventDetailScreen({
    super.key,
    @PathParam('name') required this.username,
    @PathParam('id') required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(
      calendarEventDetailProvider((username, eventId)),
    );
    final currentUserAsync = ref.watch(userInfoProvider);
    final currentUser = currentUserAsync.whenOrNull(data: (user) => user);

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          final isOwner =
              currentUser != null && event.accountId == currentUser.id;
          final isPublic = event.visibility == 200;
          final canSubscribe =
              currentUser != null && !isOwner && isPublic;

          return _CalendarEventDetailContent(
            event: event,
            isOwner: isOwner,
            canSubscribe: canSubscribe,
            onEdit: () async {
              final result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (context) =>
                    CalendarEventCreationSheet(initialEvent: event),
              );
              if (result == true && context.mounted) {
                ref.invalidate(
                  calendarEventDetailProvider((username, eventId)),
                );
              }
            },
            onDelete: () async {
              final confirmed = await showConfirmAlert(
                'calendarEventDeleteConfirm'.tr(),
                'calendarEventDelete'.tr(),
                icon: Symbols.delete,
                isDanger: true,
              );
              if (confirmed) {
                try {
                  final client = ref.read(solarNetworkClientProvider);
                  await client.accounts.deleteCalendarEvent(eventId);
                  if (context.mounted) {
                    context.router.maybePop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    showErrorAlert(e);
                  }
                }
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.error,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const Gap(16),
              Text('calendarEventUnavailable'.tr()),
              const Gap(8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarEventDetailContent extends HookConsumerWidget {
  final SnUserCalendarEvent event;
  final bool isOwner;
  final bool canSubscribe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CalendarEventDetailContent({
    required this.event,
    this.isOwner = false,
    this.canSubscribe = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasBackground = event.background != null;
    final occurrenceSummary = useMemoized(_buildOccurrenceSummary);
    final selectedOccurrenceKind = useState<_OccurrenceSelection>(
      occurrenceSummary.next != null
          ? _OccurrenceSelection.next
          : occurrenceSummary.first != null
          ? _OccurrenceSelection.first
          : _OccurrenceSelection.last,
    );
    final selectedOccurrence = occurrenceSummary.resolve(
      selectedOccurrenceKind.value,
    );
    final displayStartTime =
        selectedOccurrence?.startTime ?? event.startTime.toLocal();
    final displayEndTime =
        selectedOccurrence?.endTime ?? event.endTime.toLocal();

    final isSubscribedAsync = canSubscribe
        ? ref.watch(isCalendarSubscribedProvider(event.accountId))
        : const AsyncValue<bool>.data(false);
    final isSubscribed = isSubscribedAsync.whenOrNull(data: (v) => v) ?? false;
    final isToggling = useState(false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (canSubscribe)
            isSubscribedAsync.when(
              data: (_) => IconButton(
                icon: isToggling.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: hasBackground
                              ? Colors.white
                              : colorScheme.onSurface,
                        ),
                      )
                    : Icon(
                        isSubscribed
                            ? Symbols.notifications_active
                            : Symbols.notifications,
                        color: hasBackground
                            ? Colors.white
                            : colorScheme.onSurface,
                      ),
                onPressed: isToggling.value
                    ? null
                    : () async {
                        isToggling.value = true;
                        try {
                          final client = ref.read(solarNetworkClientProvider);
                          if (isSubscribed) {
                            await client.accounts
                                .unsubscribeFromCalendar(event.accountId);
                          } else {
                            await client.accounts
                                .subscribeToCalendar(event.accountId);
                          }
                          ref.invalidate(isCalendarSubscribedProvider);
                          ref.invalidate(calendarSubscriptionsProvider);
                        } catch (e) {
                          if (context.mounted) {
                            showErrorAlert(e);
                          }
                        } finally {
                          isToggling.value = false;
                        }
                      },
                tooltip: isSubscribed
                    ? 'calendarEventUnsubscribe'.tr()
                    : 'calendarEventSubscribe'.tr(),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          IconButton(
            icon: Icon(
              Symbols.share,
              color: hasBackground ? Colors.white : colorScheme.onSurface,
            ),
            onPressed: () => shareCalendarEventAsScreenshot(
              context,
              ref,
              event,
              displayStartTime: displayStartTime,
              displayEndTime: displayEndTime,
              selectedOccurrenceIndex: selectedOccurrence?.index,
            ),
            tooltip: 'share'.tr(),
          ),
          if (isOwner) ...[
            IconButton(
              icon: Icon(
                Symbols.edit,
                color: hasBackground ? Colors.white : colorScheme.onSurface,
              ),
              onPressed: onEdit,
              tooltip: 'edit'.tr(),
            ),
            IconButton(
              icon: Icon(
                Symbols.delete,
                color: hasBackground ? Colors.white : colorScheme.onSurface,
              ),
              onPressed: onDelete,
              tooltip: 'delete'.tr(),
            ),
          ],
          const Gap(8),
        ],
      ),
      body: Stack(
        children: [
          // Background image covering entire page
          if (hasBackground)
            Positioned.fill(
              child: CloudFileWidget(
                item: event.background!,
                fit: BoxFit.cover,
                useInternalGate: false,
              ),
            ),
          // Gradient overlay
          if (hasBackground)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          // Fallback background color
          if (!hasBackground)
            Positioned.fill(child: Container(color: colorScheme.surface)),
          // Scrollable content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      // Top spacing for status bar
                      SizedBox(
                        height:
                            MediaQuery.of(context).padding.top + kToolbarHeight,
                      ),
                      // Header with icon and title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Icon
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: hasBackground
                                  ? Colors.white.withOpacity(0.2)
                                  : colorScheme.primaryContainer,
                              child: event.icon != null
                                  ? ClipOval(
                                      child: SizedBox(
                                        width: 72,
                                        height: 72,
                                        child: CloudFileWidget(
                                          item: event.icon!,
                                          fit: BoxFit.cover,
                                          useInternalGate: false,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Symbols.calendar_month,
                                      size: 36,
                                      color: hasBackground
                                          ? Colors.white
                                          : colorScheme.onPrimaryContainer,
                                    ),
                            ),
                            const SizedBox(height: 16),
                            // Title
                            Text(
                              event.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: hasBackground
                                    ? Colors.white
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (event.description != null &&
                                event.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              // Description
                              Text(
                                event.description!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: hasBackground
                                      ? Colors.white.withOpacity(0.9)
                                      : colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Mini Calendar & Properties
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                // Mini Calendar Card
                                _buildTheCalendarPart(
                                  context,
                                  theme,
                                  colorScheme,
                                  displayStartTime,
                                  displayEndTime,
                                ),
                                if (occurrenceSummary.hasAnySelection) ...[
                                  const SizedBox(height: 12),
                                  _buildOccurrenceSegmentedButton(
                                    theme,
                                    colorScheme,
                                    occurrenceSummary,
                                    selectedOccurrenceKind.value,
                                    (value) =>
                                        selectedOccurrenceKind.value = value,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                // Properties Grid
                                _buildPropertiesGrid(
                                  context,
                                  theme,
                                  colorScheme,
                                  selectedOccurrence,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTheCalendarPart(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    DateTime startTime,
    DateTime endTime,
  ) {
    final startDay = startTime;
    final endDay = endTime;
    final isSameDay = DateUtils.isSameDay(startDay, endDay);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.04),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        child: Card(
          key: ValueKey(
            '${startTime.toIso8601String()}|${endTime.toIso8601String()}',
          ),
          elevation: 4,
          color: colorScheme.surfaceContainerHigh,
          child: Column(
            spacing: 16,
            children: [
              Material(
                color: colorScheme.surfaceContainer.withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSameDay)
                      Text(
                        DateFormat.yMMMMd().format(startDay),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (startDay.year == endDay.year &&
                        startDay.month == endDay.month)
                      Text(
                        '${DateFormat.yMMMMd().format(startDay)} – ${DateFormat.d().format(endDay)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Text(
                        '${DateFormat.yMMMd().format(startDay)} – ${DateFormat.yMMMd().format(endDay)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ).padding(horizontal: 12, vertical: 8),
              ),
              _LiveCountdown(
                startTime: startTime,
                endTime: endTime,
                theme: theme,
                colorScheme: colorScheme,
              ),
              if (event.isAllDay)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.today,
                        size: 14,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'eventAllDay'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              if (event.account != null)
                Material(
                  color: colorScheme.surfaceContainer.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ProfilePictureWidget(
                        file: event.account!.profile.picture,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AccountName(account: event.account!),
                          Text(
                            event.account!.profile.bio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).padding(horizontal: 12, vertical: 8),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesGrid(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    _OccurrenceInstance? selectedOccurrence,
  ) {
    final properties = <_PropertyItem>[
      // Time (if not all day)
      if (!event.isAllDay)
        _PropertyItem(
          icon: Symbols.schedule,
          tooltip: 'eventTime'.tr(),
          value: _formatTimeRange(
            selectedOccurrence?.startTime ?? event.startTime.toLocal(),
            selectedOccurrence?.endTime ?? event.endTime.toLocal(),
          ),
        ),
      // Location
      if (event.location != null && event.location!.isNotEmpty)
        _PropertyItem(
          icon: Symbols.location_on,
          tooltip: 'eventLocation'.tr(),
          value: event.location!,
        ),
      // Visibility
      _PropertyItem(
        icon: _getVisibilityIcon(event.visibility),
        tooltip: 'eventVisibility'.tr(),
        value: _getVisibilityText(event.visibility),
      ),
      // Recurrence
      if (event.recurrence != null)
        _PropertyItem(
          icon: Symbols.repeat,
          tooltip: 'eventRecurrence'.tr(),
          value: _getRecurrenceText(event.recurrence!),
        ),
      if (selectedOccurrence != null)
        _PropertyItem(
          icon: Symbols.tag,
          tooltip: 'eventRecurrence'.tr(),
          value: 'occurrenceSelectedTime'.tr(
            args: [
              selectedOccurrence.index.toString(),
              _getOrdinalSuffix(selectedOccurrence.index),
            ],
          ),
        ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: properties.map((prop) {
        return Tooltip(
          message: prop.tooltip,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(prop.icon, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    prop.value,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOccurrenceSegmentedButton(
    ThemeData theme,
    ColorScheme colorScheme,
    _OccurrenceSummary summary,
    _OccurrenceSelection selected,
    ValueChanged<_OccurrenceSelection> onChanged,
  ) {
    return SegmentedButton<_OccurrenceSelection>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: _OccurrenceSelection.first,
          enabled: summary.first != null,
          label: Text('occurrenceFirstTime'.tr()),
        ),
        ButtonSegment(
          value: _OccurrenceSelection.last,
          enabled: summary.last != null,
          label: Text('occurrenceLastTime'.tr()),
        ),
        ButtonSegment(
          value: _OccurrenceSelection.next,
          enabled: summary.next != null,
          label: Text('occurrenceNextTime'.tr()),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHigh;
        }),
      ),
    );
  }

  IconData _getVisibilityIcon(int visibility) {
    return switch (visibility) {
      200 => Symbols.public,
      100 => Symbols.group,
      _ => Symbols.lock,
    };
  }

  String _getVisibilityText(int visibility) {
    return switch (visibility) {
      0 => 'visibilityPrivate'.tr(),
      100 => 'visibilityFriends'.tr(),
      200 => 'visibilityPublic'.tr(),
      _ => 'visibilityPrivate'.tr(),
    };
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    if (DateUtils.isSameDay(start, end)) {
      return '${DateFormat.Hm().format(start)} - ${DateFormat.Hm().format(end)}';
    }
    return '${DateFormat.yMMMd().add_Hm().format(start)} - ${DateFormat.yMMMd().add_Hm().format(end)}';
  }

  String _getRecurrenceText(SnRecurrencePattern recurrence) {
    final frequency = switch (recurrence.frequency) {
      1 => 'recurrenceDaily'.tr(),
      2 => 'recurrenceWeekly'.tr(),
      3 => 'recurrenceMonthly'.tr(),
      4 => 'recurrenceYearly'.tr(),
      _ => 'recurrenceNone'.tr(),
    };

    if (recurrence.interval > 1) {
      return '$frequency (every ${recurrence.interval})';
    }
    return frequency;
  }

  _OccurrenceSummary _buildOccurrenceSummary() {
    final recurrence = event.recurrence;
    if (recurrence == null ||
        recurrence.frequency == SnRecurrenceFrequency.none) {
      return const _OccurrenceSummary();
    }

    final instances = <_OccurrenceInstance>[];
    final originalStart = event.startTime.toLocal();
    final originalEnd = event.endTime.toLocal();
    final duration = originalEnd.difference(originalStart);
    final hardLimit =
        recurrence.occurrences != null && recurrence.occurrences! > 0
        ? recurrence.occurrences!
        : 1000;

    var current = originalStart;
    for (var index = 1; index <= hardLimit; index++) {
      if (recurrence.endDate != null &&
          current.isAfter(recurrence.endDate!.toLocal())) {
        break;
      }
      instances.add(
        _OccurrenceInstance(
          index: index,
          startTime: current,
          endTime: current.add(duration),
        ),
      );
      final next = _nextRecurrenceDate(current, recurrence);
      if (next == null) break;
      current = next;
    }

    final now = DateTime.now();
    final next = instances.cast<_OccurrenceInstance?>().firstWhere(
      (item) => item != null && item.endTime.isAfter(now),
      orElse: () => instances.isNotEmpty ? instances.last : null,
    );
    final last = instances.reversed.cast<_OccurrenceInstance?>().firstWhere(
      (item) => item != null && !item.startTime.isAfter(now),
      orElse: () => instances.isNotEmpty ? instances.first : null,
    );

    return _OccurrenceSummary(
      first: instances.isNotEmpty ? instances.first : null,
      last: last,
      next: next,
    );
  }

  DateTime? _nextRecurrenceDate(
    DateTime current,
    SnRecurrencePattern recurrence,
  ) {
    final interval = recurrence.interval > 0 ? recurrence.interval : 1;

    switch (recurrence.frequency) {
      case SnRecurrenceFrequency.daily:
        return current.add(Duration(days: interval));
      case SnRecurrenceFrequency.weekly:
        return _nextWeeklyRecurrenceDate(current, recurrence, interval);
      case SnRecurrenceFrequency.monthly:
        return _addMonthsClamped(current, interval);
      case SnRecurrenceFrequency.yearly:
        return _addMonthsClamped(current, interval * 12);
      default:
        return null;
    }
  }

  DateTime? _nextWeeklyRecurrenceDate(
    DateTime current,
    SnRecurrencePattern recurrence,
    int interval,
  ) {
    final weekdays = (recurrence.daysOfWeek ?? const <String>[])
        .map(_dayNameToWeekday)
        .whereType<int>()
        .toSet();
    final effectiveWeekdays = weekdays.isNotEmpty
        ? weekdays
        : {event.startTime.toLocal().weekday};

    var candidate = current.add(const Duration(days: 1));
    for (var i = 0; i < 4000; i++) {
      if (candidate.isAfter(event.startTime.toLocal()) &&
          effectiveWeekdays.contains(candidate.weekday) &&
          _weeksSinceAnchor(event.startTime.toLocal(), candidate) % interval ==
              0) {
        return candidate;
      }
      candidate = candidate.add(const Duration(days: 1));
    }
    return null;
  }

  int? _dayNameToWeekday(String day) {
    return switch (day) {
      'Monday' => DateTime.monday,
      'Tuesday' => DateTime.tuesday,
      'Wednesday' => DateTime.wednesday,
      'Thursday' => DateTime.thursday,
      'Friday' => DateTime.friday,
      'Saturday' => DateTime.saturday,
      'Sunday' => DateTime.sunday,
      _ => null,
    };
  }

  int _weeksSinceAnchor(DateTime anchor, DateTime date) {
    final anchorDate = DateTime(anchor.year, anchor.month, anchor.day);
    final dateValue = DateTime(date.year, date.month, date.day);
    final anchorWeekStart = anchorDate.subtract(
      Duration(days: anchorDate.weekday - 1),
    );
    final dateWeekStart = dateValue.subtract(
      Duration(days: dateValue.weekday - 1),
    );
    return dateWeekStart.difference(anchorWeekStart).inDays ~/ 7;
  }

  DateTime _addMonthsClamped(DateTime date, int months) {
    final monthIndex = date.month - 1 + months;
    final year = date.year + (monthIndex ~/ 12);
    final month = (monthIndex % 12) + 1;
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = date.day.clamp(1, lastDayOfMonth).toInt();
    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  String _getOrdinalSuffix(int number) {
    final mod100 = number % 100;
    if (mod100 >= 11 && mod100 <= 13) return 'th';
    return switch (number % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }
}

enum _OccurrenceSelection { first, last, next }

class _OccurrenceSummary {
  final _OccurrenceInstance? first;
  final _OccurrenceInstance? last;
  final _OccurrenceInstance? next;

  const _OccurrenceSummary({this.first, this.last, this.next});

  bool get hasAnySelection => first != null || last != null || next != null;

  _OccurrenceInstance? resolve(_OccurrenceSelection selection) {
    return switch (selection) {
      _OccurrenceSelection.first => first ?? next ?? last,
      _OccurrenceSelection.last => last ?? next ?? first,
      _OccurrenceSelection.next => next ?? first ?? last,
    };
  }
}

class _OccurrenceInstance {
  final int index;
  final DateTime startTime;
  final DateTime endTime;

  const _OccurrenceInstance({
    required this.index,
    required this.startTime,
    required this.endTime,
  });
}

class _LiveCountdown extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _LiveCountdown({
    required this.startTime,
    required this.endTime,
    required this.theme,
    required this.colorScheme,
  });

  @override
  State<_LiveCountdown> createState() => _LiveCountdownState();
}

class _LiveCountdownState extends State<_LiveCountdown> {
  Timer? _timer;
  int _displayMode = 0;

  @override
  void initState() {
    super.initState();
    _scheduleTimer();
  }

  @override
  void didUpdateWidget(_LiveCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startTime != widget.startTime ||
        oldWidget.endTime != widget.endTime) {
      _timer?.cancel();
      _scheduleTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleTimer() {
    final diff = _getDuration();
    final absDiff = diff.abs();

    Duration interval;
    if (absDiff < const Duration(minutes: 1)) {
      interval = const Duration(seconds: 1);
    } else if (absDiff < const Duration(hours: 1)) {
      interval = const Duration(minutes: 1);
    } else {
      interval = const Duration(hours: 1);
    }

    _timer = Timer.periodic(interval, (_) {
      if (mounted) setState(() {});
    });
  }

  Duration _getDuration() {
    final now = DateTime.now();
    if (now.isBefore(widget.startTime)) {
      return widget.startTime.difference(now);
    } else if (now.isBefore(widget.endTime)) {
      return Duration.zero;
    } else {
      return now.difference(widget.endTime);
    }
  }

  bool _isPast() => DateTime.now().isAfter(widget.endTime);
  bool _isOngoing() {
    final now = DateTime.now();
    return !now.isBefore(widget.startTime) && now.isBefore(widget.endTime);
  }

  void _cycleMode() {
    setState(() {
      _displayMode = (_displayMode + 1) % 4;
    });
  }

  String _formatDaysOnly(Duration duration) {
    final abs = duration.abs();
    if (abs < const Duration(seconds: 1)) return 'now';
    return '${abs.inDays}d';
  }

  String _formatDetailed(Duration duration) {
    if (duration == Duration.zero) return 'now';

    final abs = duration.abs();
    final years = abs.inDays ~/ 365;
    final months = (abs.inDays % 365) ~/ 30;
    final weeks = (abs.inDays % 365 % 30) ~/ 7;
    final days = abs.inDays % 365 % 30 % 7;
    final hours = abs.inHours % 24;
    final minutes = abs.inMinutes % 60;
    final seconds = abs.inSeconds % 60;

    final parts = <String>[];
    if (years > 0) parts.add('${years}y');
    if (months > 0) parts.add('${months}mo');
    if (weeks > 0) parts.add('${weeks}w');
    if (days > 0) parts.add('${days}d');
    if (hours > 0 && parts.length < 2) parts.add('${hours}h');
    if (minutes > 0 && parts.length < 2) parts.add('${minutes}m');
    if (parts.isEmpty) parts.add('${seconds}s');

    return parts.take(2).join(' ');
  }

  String _formatCompact(Duration duration) {
    final abs = duration.abs();
    if (abs < const Duration(seconds: 1)) return 'now';
    if (abs < const Duration(minutes: 1)) return '${abs.inSeconds}s';
    if (abs < const Duration(hours: 1)) return '${abs.inMinutes}m';
    if (abs < const Duration(days: 1)) return '${abs.inHours}h';
    if (abs < const Duration(days: 7)) return '${abs.inDays}d';
    if (abs < const Duration(days: 30)) return '${abs.inDays ~/ 7}w';
    if (abs < const Duration(days: 365)) return '${abs.inDays ~/ 30}mo';
    return '${abs.inDays ~/ 365}y';
  }

  String _formatNatural(Duration duration, bool isPast) {
    final abs = duration.abs();
    if (abs < const Duration(seconds: 1)) return 'countdownNow'.tr();
    final suffix = isPast ? 'Past' : 'Future';
    if (abs < const Duration(minutes: 1)) {
      return 'countdownSeconds$suffix'.tr(args: [abs.inSeconds.toString()]);
    }
    if (abs < const Duration(hours: 1)) {
      return 'countdownMinutes$suffix'.tr(args: [abs.inMinutes.toString()]);
    }
    if (abs < const Duration(days: 1)) {
      return 'countdownHours$suffix'.tr(args: [abs.inHours.toString()]);
    }
    if (abs < const Duration(days: 7)) {
      return 'countdownDays$suffix'.tr(args: [abs.inDays.toString()]);
    }
    if (abs < const Duration(days: 30)) {
      return 'countdownWeeks$suffix'.tr(args: [(abs.inDays ~/ 7).toString()]);
    }
    if (abs < const Duration(days: 365)) {
      return 'countdownMonths$suffix'.tr(args: [(abs.inDays ~/ 30).toString()]);
    }
    return 'countdownYears$suffix'.tr(args: [(abs.inDays ~/ 365).toString()]);
  }

  String _getDisplayText() {
    final duration = _getDuration();
    final isPast = _isPast();
    return switch (_displayMode) {
      0 => _formatNatural(duration, isPast),
      1 => _formatDetailed(duration),
      2 => _formatDaysOnly(duration),
      _ => _formatCompact(duration),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isPast = _isPast();
    final isOngoing = _isOngoing();

    return GestureDetector(
      onTap: _cycleMode,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isPast && !isOngoing) Text('countdownFutureStatic'.tr()),
          Text(
            _getDisplayText(),
            style: widget.theme.textTheme.headlineMedium?.copyWith(
              color: isPast
                  ? widget.colorScheme.onSurfaceVariant
                  : isOngoing
                  ? widget.colorScheme.tertiary
                  : widget.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isPast) Text('countdownPastStatic'.tr()),
          if (isOngoing) Text('countdownOngoing'.tr()),
          Text(
            'countdownTapToSwitch'.tr(),
            style: widget.theme.textTheme.labelSmall?.copyWith(
              color: widget.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyItem {
  final IconData icon;
  final String tooltip;
  final String value;

  const _PropertyItem({
    required this.icon,
    required this.tooltip,
    required this.value,
  });
}
