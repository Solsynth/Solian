import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/calendar_event_creation_sheet.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/embeds/embed_list.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
    final eventAsync = ref.watch(calendarEventDetailProvider((username, eventId)));
    final currentUserAsync = ref.watch(userInfoProvider);
    final currentUser = currentUserAsync.whenOrNull(data: (user) => user);

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          final isOwner = currentUser != null && event.accountId == currentUser.id;
          return _CalendarEventDetailContent(
            event: event,
            isOwner: isOwner,
            onEdit: () async {
              final result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (context) => CalendarEventCreationSheet(
                  initialEvent: event,
                ),
              );
              if (result == true && context.mounted) {
                ref.invalidate(calendarEventDetailProvider((username, eventId)));
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
    final now = DateTime.now();
    final isPast = event.startTime.isBefore(now);
    final daysDiff = event.startTime.difference(now).inDays;
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
            Positioned.fill(
              child: Container(color: colorScheme.surface),
            ),
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
                        height: MediaQuery.of(context).padding.top + kToolbarHeight,
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
                            const SizedBox(height: 8),
                            // Countdown badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: hasBackground
                                    ? Colors.white.withOpacity(0.2)
                                    : (isPast
                                        ? colorScheme.surfaceContainerHighest
                                        : colorScheme.primaryContainer),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isPast
                              ? 'countdownPast'.tr(
                                  args: ['${daysDiff.abs()} days'],
                                )
                              : 'countdownFuture'.tr(
                                  args: ['$daysDiff days'],
                                ),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: hasBackground
                                ? Colors.white
                                : (isPast
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onPrimaryContainer),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                          _buildMiniCalendar(context, theme, colorScheme),
                          const SizedBox(height: 16),
                          // Properties Grid
                          _buildPropertiesGrid(context, theme, colorScheme),
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

  Widget _buildMiniCalendar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final startDay = event.startTime.toLocal();
    final endDay = event.endTime.toLocal();
    final isSameDay = startDay.year == endDay.year &&
        startDay.month == endDay.month &&
        startDay.day == endDay.day;
    final now = DateTime.now();
    final isPast = startDay.isBefore(now);

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start date
                _buildDateBox(
                  context,
                  startDay,
                  isPast ? colorScheme.surfaceContainerHighest : colorScheme.primaryContainer,
                  isPast ? colorScheme.onSurfaceVariant : colorScheme.onPrimaryContainer,
                ),
                if (!isSameDay) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Symbols.arrow_forward,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  // End date
                  _buildDateBox(
                    context,
                    endDay,
                    colorScheme.primaryContainer,
                    colorScheme.onPrimaryContainer,
                  ),
                ],
              ],
            ),
            if (event.isAllDay) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(
    BuildContext context,
    DateTime date,
    Color bgColor,
    Color fgColor,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            DateFormat.E().format(date),
            style: theme.textTheme.labelSmall?.copyWith(
              color: fgColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat.MMM().format(date),
            style: theme.textTheme.labelSmall?.copyWith(
              color: fgColor.withOpacity(0.7),
            ),
          ),
          if (!event.isAllDay)
            Text(
              DateFormat.Hm().format(date),
              style: theme.textTheme.labelSmall?.copyWith(
                color: fgColor.withOpacity(0.7),
              ),
            ),
        ],
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
          value: '${DateFormat.Hm().format(event.startTime.toLocal())} - '
              '${DateFormat.Hm().format(event.endTime.toLocal())}',
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

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Properties chips
            if (properties.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: properties.map((prop) {
                  return Tooltip(
                    message: prop.tooltip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            prop.icon,
                            size: 16,
                            color: colorScheme.primary,
                          ),
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
              ),
            // Description
            if (event.description != null &&
                event.description!.isNotEmpty) ...[
              if (properties.isNotEmpty) const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Symbols.description,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
