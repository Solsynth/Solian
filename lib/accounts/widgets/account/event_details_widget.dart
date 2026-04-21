import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/activity_utils.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class EventDetailsWidget extends StatelessWidget {
  final DateTime selectedDay;
  final SnEventCalendarEntry? event;
  final void Function(DateTime)? onEditEvent;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date header
        Text(
          DateFormat.EEEE().format(selectedDay),
        ).fontSize(16).bold().textColor(colorScheme.onSecondaryContainer),
        Text(
          DateFormat.yMd().format(selectedDay),
        ).fontSize(12).textColor(colorScheme.onSecondaryContainer),
        const Gap(16),

        // Notable Days (Holidays)
        if (hasNotableDays) ...[
          _buildSectionHeader(
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
          const Gap(8),
        ],

        // User Events
        if (hasUserEvents) ...[
          Row(
            children: [
              _buildSectionHeader(
                context,
                Symbols.event,
                'eventUserEvents'.tr(),
                colorScheme.primary,
              ),
              const Spacer(),
              if (onEditEvent != null)
                IconButton(
                  icon: const Icon(Symbols.add, size: 18),
                  onPressed: () => onEditEvent!(selectedDay),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const Gap(8),
          for (final userEvent in event!.userEvents) ...[
            _buildUserEventCard(context, userEvent),
            const Gap(8),
          ],
          const Gap(8),
        ],

        // Check-in Result
        if (hasCheckIn) ...[
          _buildSectionHeader(
            context,
            Symbols.stars,
            'eventCheckIn'.tr(),
            colorScheme.secondary,
          ),
          const Gap(8),
          _buildCheckInCard(context, event!.checkInResult!),
          const Gap(16),
        ],

        // Statuses
        if (hasStatuses) ...[
          _buildSectionHeader(
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
        if (isEmpty) ...[
          Center(
            child: Column(
              children: [
                Icon(
                  Symbols.calendar_month,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const Gap(8),
                Text(
                  'eventCalendarEmpty'.tr(),
                ).textColor(colorScheme.onSurfaceVariant).opacity(0.7),
                if (onEditEvent != null) ...[
                  const Gap(16),
                  FilledButton.icon(
                    onPressed: () => onEditEvent!(selectedDay),
                    icon: const Icon(Symbols.add),
                    label: Text('calendarEventAdd'.tr()),
                  ),
                ],
              ],
            ),
          ).padding(vertical: 24),
        ],
      ],
    ).padding(vertical: 24, horizontal: 24);
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const Gap(8),
        Text(title).fontSize(14).bold().textColor(color),
      ],
    );
  }

  Widget _buildNotableDayCard(BuildContext context, SnNotableDay day) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.tertiaryContainer.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Symbols.celebration,
                  size: 16,
                  color: colorScheme.onTertiaryContainer,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    day.globalName.isNotEmpty ? day.globalName : day.localName,
                  ).bold().textColor(colorScheme.onTertiaryContainer),
                ),
              ],
            ),
            if (day.localName.isNotEmpty &&
                day.localName != day.globalName) ...[
              const Gap(4),
              Text(day.localName)
                  .fontSize(12)
                  .textColor(colorScheme.onTertiaryContainer.withOpacity(0.8)),
            ],
            if (day.holidays.isNotEmpty) ...[
              const Gap(8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: day.holidays.map((holiday) {
                  return Chip(
                    label: Text(
                      _getHolidayTypeName(holiday),
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                    backgroundColor: colorScheme.tertiary.withOpacity(0.3),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
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

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.primaryContainer.withOpacity(0.5),
      child: InkWell(
        onTap: onEditEvent != null ? () => onEditEvent!(selectedDay) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      userEvent.title,
                    ).bold().textColor(colorScheme.onPrimaryContainer),
                  ),
                  Icon(visibilityIcon, size: 14, color: visibilityColor),
                  if (userEvent.recurrence != null &&
                      userEvent.recurrence!.frequency !=
                          SnRecurrenceFrequency.none) ...[
                    const Gap(4),
                    Icon(
                      Symbols.repeat,
                      size: 14,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
              const Gap(4),
              Row(
                children: [
                  Icon(
                    Symbols.schedule,
                    size: 12,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                  const Gap(4),
                  Text(timeText)
                      .fontSize(12)
                      .textColor(
                        colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                ],
              ),
              if (userEvent.location?.isNotEmpty ?? false) ...[
                const Gap(4),
                Row(
                  children: [
                    Icon(
                      Symbols.location_on,
                      size: 12,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                    const Gap(4),
                    Text(userEvent.location!)
                        .fontSize(12)
                        .textColor(
                          colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                  ],
                ),
              ],
              if (userEvent.description?.isNotEmpty ?? false) ...[
                const Gap(8),
                Text(userEvent.description!)
                    .fontSize(12)
                    .textColor(colorScheme.onPrimaryContainer.withOpacity(0.8)),
              ],
            ],
          ),
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
      color: colorScheme.secondaryContainer.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('checkInResultLevel${checkInResult.level}')
                .tr()
                .fontSize(16)
                .bold()
                .textColor(colorScheme.onSecondaryContainer),
            for (final tip in checkInResult.tips)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Icon(
                    Symbols.circle,
                    size: 12,
                    fill: 1,
                  ).padding(top: 4, right: 4),
                  Icon(
                    tip.isPositive ? Symbols.thumb_up : Symbols.thumb_down,
                    size: 14,
                  ).padding(top: 2.5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(tip.title).bold(), Text(tip.content)],
                    ),
                  ),
                ],
              ).padding(top: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, SnAccountStatus status) {
    return Row(
      spacing: 8,
      children: [
        Icon(switch (status.attitude) {
          0 => Symbols.sentiment_satisfied,
          2 => Symbols.sentiment_dissatisfied,
          _ => Symbols.sentiment_neutral,
        }),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((getActivityTitle(status.label, status.meta) ??
                      getStatusDisplayLabel(context, status))
                  .isNotEmpty)
                Text(
                  getActivityTitle(status.label, status.meta) ??
                      getStatusDisplayLabel(context, status),
                ),
              if (getActivitySubtitle(status.meta) != null)
                Text(
                  getActivitySubtitle(status.meta)!,
                ).fontSize(11).opacity(0.8),
              Text(
                '${status.createdAt.formatSystem()} - ${status.clearedAt?.formatSystem() ?? 'present'.tr()}',
              ).fontSize(11).opacity(0.8),
            ],
          ),
        ),
      ],
    ).padding(vertical: 8);
  }
}
