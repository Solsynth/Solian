import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/activity_utils.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class EventDetailsWidget extends StatelessWidget {
  final DateTime selectedDay;
  final SnEventCalendarEntry? event;
  final void Function(DateTime, {SnUserCalendarEvent? event})? onEditEvent;

  const EventDetailsWidget({
    super.key,
    required this.selectedDay,
    this.event,
    this.onEditEvent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasCheckIn = event?.checkInResult != null;
    final hasStatuses = event?.statuses.isNotEmpty ?? false;
    final hasUserEvents = event?.userEvents.isNotEmpty ?? false;
    final hasNotableDays = event?.notableDays.isNotEmpty ?? false;
    final isEmpty =
        !hasCheckIn && !hasStatuses && !hasUserEvents && !hasNotableDays;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          _buildDateHeader(context),
          const Gap(16),

          // Notable Days (Holidays)
          if (hasNotableDays) ...[
            _buildSectionTitle(
              context,
              Symbols.celebration,
              'eventNotableDays'.tr(),
              colorScheme.tertiary,
            ),
            const Gap(8),
            for (final day in event!.notableDays) ...[
              _buildNotableDayCard(context, day),
              const Gap(8),
            ],
          ],

          // User Events
          if (hasUserEvents || onEditEvent != null) ...[
            Row(
              children: [
                _buildSectionTitle(
                  context,
                  Symbols.event,
                  'eventUserEvents'.tr(),
                  colorScheme.primary,
                ),
                const Spacer(),
                if (onEditEvent != null)
                  IconButton.filledTonal(
                    icon: const Icon(Symbols.add, size: 18),
                    onPressed: () => onEditEvent!(selectedDay),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const Gap(8),
            for (final userEvent in event?.userEvents ?? []) ...[
              _buildUserEventCard(context, userEvent),
              const Gap(8),
            ],
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
            _buildCheckInCard(context, event!.checkInResult!),
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
            for (final status in event!.statuses) ...[
              _buildStatusCard(context, status),
              const Gap(8),
            ],
          ],

          // Empty state
          if (isEmpty) ...[_buildEmptyState(context)],
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${selectedDay.day}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Gap(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.EEEE().format(selectedDay),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              DateFormat.yMMMMd().format(selectedDay),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: color, fill: 1),
        const Gap(8),
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotableDayCard(BuildContext context, SnNotableDay day) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use localizable key for display name if available
    final displayName = day.localizableKey != null && day.localizableKey!.isNotEmpty
        ? day.localizableKey!.tr()
        : (day.globalName.isNotEmpty ? day.globalName : day.localName);

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.tertiaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Symbols.celebration,
                  size: 18,
                  color: colorScheme.onTertiaryContainer,
                  fill: 1,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (day.localName.isNotEmpty && day.localName != displayName) ...[
              const Gap(4),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  day.localName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer.withOpacity(0.8),
                  ),
                ),
              ),
            ],
            if (day.holidays.isNotEmpty) ...[
              const Gap(12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: day.holidays.map((holiday) {
                  return Chip(
                    label: Text(
                      _getHolidayTypeName(holiday),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                    backgroundColor: colorScheme.tertiary.withOpacity(0.3),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getHolidayTypeName(int holidayType) {
    switch (holidayType) {
      case 0:
        return 'holidayPublic'.tr();
      case 1:
        return 'holidayBank'.tr();
      case 2:
        return 'holidaySchool'.tr();
      case 3:
        return 'holidayAuthorities'.tr();
      case 4:
        return 'holidayOptional'.tr();
      case 5:
        return 'holidayObservance'.tr();
      default:
        return 'holidayOther'.tr();
    }
  }

  Widget _buildUserEventCard(
    BuildContext context,
    SnUserCalendarEvent userEvent,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final startTime = userEvent.startTime.toLocal();
    final endTime = userEvent.endTime.toLocal();
    final isAllDay = userEvent.isAllDay;

    String timeText;
    if (isAllDay) {
      timeText = 'eventAllDay'.tr();
    } else {
      timeText =
          '${DateFormat.Hm().format(startTime)} - ${DateFormat.Hm().format(endTime)}';
    }

    IconData visibilityIcon;
    Color visibilityColor;
    switch (userEvent.visibility) {
      case SnEventVisibility.public:
        visibilityIcon = Symbols.public;
        visibilityColor = colorScheme.primary;
      case SnEventVisibility.friends:
        visibilityIcon = Symbols.group;
        visibilityColor = colorScheme.secondary;
      default:
        visibilityIcon = Symbols.lock;
        visibilityColor = colorScheme.outline;
    }

    final hasBackground = userEvent.background != null;
    final hasIcon = userEvent.icon != null;

    return Card(
      margin: EdgeInsets.zero,
      color: hasBackground ? null : colorScheme.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEditEvent != null
            ? () => onEditEvent!(selectedDay, event: userEvent)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Background image
            if (hasBackground)
              SizedBox(
                height: 80,
                child: CloudFileWidget(
                  item: userEvent.background!,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon
                      if (hasIcon) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CloudFileWidget(
                              item: userEvent.icon!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Gap(8),
                      ],
                      Expanded(
                        child: Text(
                          userEvent.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: hasBackground
                                ? null
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(visibilityIcon, size: 16, color: visibilityColor),
                      if (userEvent.recurrence != null &&
                          userEvent.recurrence!.frequency !=
                              SnRecurrenceFrequency.none) ...[
                        const Gap(4),
                        Icon(
                          Symbols.repeat,
                          size: 16,
                          color: (hasBackground
                                  ? colorScheme.onSurface
                                  : colorScheme.onPrimaryContainer)
                              .withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Icon(
                        Symbols.schedule,
                        size: 14,
                        color: (hasBackground
                                ? colorScheme.onSurface
                                : colorScheme.onPrimaryContainer)
                            .withOpacity(0.7),
                      ),
                      const Gap(8),
                      Text(
                        timeText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: (hasBackground
                                  ? colorScheme.onSurface
                                  : colorScheme.onPrimaryContainer)
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  if (userEvent.location?.isNotEmpty ?? false) ...[
                    const Gap(4),
                    Row(
                      children: [
                        Icon(
                          Symbols.location_on,
                          size: 14,
                          color: (hasBackground
                                  ? colorScheme.onSurface
                                  : colorScheme.onPrimaryContainer)
                              .withOpacity(0.7),
                        ),
                        const Gap(8),
                        Text(
                          userEvent.location!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: (hasBackground
                                    ? colorScheme.onSurface
                                    : colorScheme.onPrimaryContainer)
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (userEvent.description?.isNotEmpty ?? false) ...[
                    const Gap(8),
                    Text(
                      userEvent.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: (hasBackground
                                ? colorScheme.onSurface
                                : colorScheme.onPrimaryContainer)
                            .withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCard(
    BuildContext context,
    SnCheckInResult checkInResult,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.secondaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Symbols.stars,
                  size: 18,
                  color: colorScheme.onSecondaryContainer,
                  fill: 1,
                ),
                const Gap(8),
                Text(
                  'checkInResultLevel${checkInResult.level}'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Gap(12),
            for (final tip in checkInResult.tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.onSecondaryContainer.withOpacity(
                          0.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      tip.isPositive ? Symbols.thumb_up : Symbols.thumb_down,
                      size: 16,
                      color: colorScheme.onSecondaryContainer.withOpacity(0.7),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          Text(
                            tip.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
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
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, SnAccountStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title =
        getActivityTitle(status.label, status.meta) ??
        getStatusDisplayLabel(context, status);
    final subtitle = getActivitySubtitle(status.meta);

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(switch (status.attitude) {
                  0 => Symbols.sentiment_satisfied,
                  2 => Symbols.sentiment_dissatisfied,
                  _ => Symbols.sentiment_neutral,
                }, color: colorScheme.onPrimaryContainer),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    '${status.createdAt.formatSystem()} - ${status.clearedAt?.formatSystem() ?? 'present'.tr()}',
                    style: theme.textTheme.labelSmall?.copyWith(
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        children: [
          const Gap(16),
          Icon(
            Symbols.calendar_month,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const Gap(12),
          Text(
            'eventCalendarEmpty'.tr(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          if (onEditEvent != null) ...[
            const Gap(16),
            FilledButton.tonalIcon(
              onPressed: () => onEditEvent!(selectedDay),
              icon: const Icon(Symbols.add),
              label: Text('calendarEventAdd'.tr()),
            ),
          ],
          const Gap(16),
        ],
      ),
    );
  }
}
