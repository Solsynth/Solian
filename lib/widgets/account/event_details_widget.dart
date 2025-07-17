import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/activity.dart';
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
        if (event?.checkInResult == null && (event?.statuses.isEmpty ?? true))
          Text('eventCalanderEmpty').tr(),
      ],
    ).padding(vertical: 24, horizontal: 24);
  }
}
