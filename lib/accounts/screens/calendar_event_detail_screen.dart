import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/calendar_event_creation_sheet.dart';
import 'package:island/core/network.dart';
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
          return _CalendarEventDetailContent(
            event: event,
            isOwner: isOwner,
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

class _CalendarEventDetailContent extends StatelessWidget {
  final SnUserCalendarEvent event;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CalendarEventDetailContent({
    required this.event,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasBackground = event.background != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
            const Gap(8),
          ],
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
                                ),
                                const SizedBox(height: 16),
                                // Properties Grid
                                _buildPropertiesGrid(
                                  context,
                                  theme,
                                  colorScheme,
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
  ) {
    final startDay = event.startTime.toLocal();
    final endDay = event.endTime.toLocal();
    final isSameDay = DateUtils.isSameDay(startDay, endDay);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
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
              startTime: event.startTime,
              endTime: event.endTime,
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
                    ProfilePictureWidget(file: event.account!.profile.picture),
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
    );
  }

  Widget _buildPropertiesGrid(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final properties = <_PropertyItem>[
      // Time (if not all day)
      if (!event.isAllDay)
        _PropertyItem(
          icon: Symbols.schedule,
          tooltip: 'eventTime'.tr(),
          value: _formatTimeRange(
            event.startTime.toLocal(),
            event.endTime.toLocal(),
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
