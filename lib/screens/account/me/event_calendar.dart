import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:table_calendar/table_calendar.dart';

part 'event_calendar.g.dart';
part 'event_calendar.freezed.dart';

@freezed
abstract class EventCalendarQuery with _$EventCalendarQuery {
  const factory EventCalendarQuery({
    required String? uname,
    required int year,
    required int month,
  }) = _EventCalendarQuery;
}

@riverpod
Future<List<SnEventCalendarEntry>> accountEventCalendar(
  Ref ref,
  EventCalendarQuery query,
) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/accounts/${query.uname ?? 'me'}/calendar');
  return resp.data
      .map((e) => SnEventCalendarEntry.fromJson(e))
      .cast<SnEventCalendarEntry>()
      .toList();
}

@RoutePage()
class MyselfEventCalendarScreen extends HookConsumerWidget {
  const MyselfEventCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = useState(DateTime.now().month);
    final selectedYear = useState(DateTime.now().year);

    final selectedDay = useState(DateTime.now());

    final events = ref.watch(
      accountEventCalendarProvider(
        EventCalendarQuery(
          uname: 'me',
          year: selectedYear.value,
          month: selectedMonth.value,
        ),
      ),
    );

    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('eventCalander').tr(),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: EasyLocalization.of(context)!.locale.toString(),
            firstDay: DateTime.now().add(Duration(days: -3650)),
            lastDay: DateTime.now().add(Duration(days: 3650)),
            focusedDay: DateTime.utc(
              selectedYear.value,
              selectedMonth.value,
              DateTime.now().day,
            ),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay.value, day);
            },
            onDaySelected: (value, _) {
              selectedDay.value = value;
            },
            onPageChanged: (focusedDay) {
              selectedMonth.value = focusedDay.month;
              selectedYear.value = focusedDay.year;
            },
            eventLoader: (day) {
              return events.value
                      ?.where((e) => isSameDay(e.date, day))
                      .expand((e) => [...e.statuses, e.checkInResult])
                      .where((e) => e != null)
                      .toList() ??
                  [];
            },
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                final text = DateFormat.EEEEE().format(day);
                return Center(child: Text(text));
              },
              markerBuilder: (context, day, events) {
                var checkInResult =
                    events.whereType<SnCheckInResult>().firstOrNull;
                if (checkInResult != null) {
                  return Positioned(
                    top: 32,
                    child: Text(
                      ['大凶', '凶', '中平', '吉', '大吉'][checkInResult.level],
                      style: TextStyle(
                        fontSize: 9,
                        color:
                            isSameDay(selectedDay.value, day)
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const Divider(height: 1).padding(top: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Builder(
              builder: (context) {
                final event =
                    events.value
                        ?.where((e) => isSameDay(e.date, selectedDay.value))
                        .firstOrNull;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(DateFormat.EEEE().format(selectedDay.value))
                        .fontSize(16)
                        .bold()
                        .textColor(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                    Text(DateFormat.yMd().format(selectedDay.value))
                        .fontSize(12)
                        .textColor(
                          Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                    const Gap(16),
                    if (event?.checkInResult != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'checkInResultLevel${event!.checkInResult!.level}',
                          ).tr().fontSize(16).bold(),
                          for (final tip in event.checkInResult!.tips)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tip.title).bold(),
                                      Text(tip.content),
                                    ],
                                  ),
                                ),
                              ],
                            ).padding(top: 8),
                        ],
                      ),
                    if (event?.checkInResult == null &&
                        (event?.statuses.isEmpty ?? true))
                      Text('eventCalanderEmpty').tr(),
                  ],
                ).padding(vertical: 24, horizontal: 24);
              },
            ),
          ),
        ],
      ),
    );
  }
}
