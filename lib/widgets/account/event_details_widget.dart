import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/activity.dart';
import 'package:island/services/time.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class EventDetailsWidget extends StatelessWidget {
  final DateTime selectedDay;
  final SnEventCalendarEntry? event;

  const EventDetailsWidget({
    super.key,
    required this.selectedDay,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(DateFormat.EEEE().format(selectedDay))
            .fontSize(16)
            .bold()
            .textColor(Theme.of(context).colorScheme.onSecondaryContainer),
        Text(DateFormat.yMd().format(selectedDay))
            .fontSize(12)
            .textColor(Theme.of(context).colorScheme.onSecondaryContainer),
        const Gap(16),
        if (event?.checkInResult != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'checkInResultLevel${event!.checkInResult!.level}',
              ).tr().fontSize(16).bold(),
              for (final tip in event!.checkInResult!.tips)
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
              if (event!.statuses.isNotEmpty) ...[
                const Gap(16),
                Text('statusLabel').tr().fontSize(16).bold(),
              ],
              for (final status in event!.statuses) ...[
                Row(
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
                          Text(status.label),
                          Text(
                            '${status.createdAt.formatSystem()} - ${status.clearedAt?.formatSystem() ?? 'present'.tr()}',
                          ).fontSize(11).opacity(0.8),
                        ],
                      ),
                    ),
                  ],
                ).padding(vertical: 8),
              ],
            ],
          ),
        if (event?.checkInResult == null && (event?.statuses.isEmpty ?? true))
          Text('eventCalanderEmpty').tr(),
      ],
    ).padding(vertical: 24, horizontal: 24);
  }
}
