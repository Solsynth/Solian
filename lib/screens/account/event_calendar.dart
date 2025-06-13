import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/event_calendar.dart';
import 'package:island/screens/account/profile.dart';
import 'package:island/widgets/account/account_nameplate.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/account/event_calendar.dart';
import 'package:island/widgets/account/fortune_graph.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class EventCalanderScreen extends HookConsumerWidget {
  final String name;
  const EventCalanderScreen({super.key, @PathParam("name") required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current date
    final now = DateTime.now();

    // Create the query for the current month
    final query = useState(
      EventCalendarQuery(uname: name, year: now.year, month: now.month),
    );

    // Watch the event calendar data
    final events = ref.watch(eventCalendarProvider(query.value));
    final user = ref.watch(accountProvider(name));

    // Track the selected day for synchronizing between widgets
    final selectedDay = useState(now);

    void onMonthChanged(int year, int month) {
      query.value = EventCalendarQuery(
        uname: query.value.uname,
        year: year,
        month: month,
      );
    }

    // Function to handle day selection for synchronizing between widgets
    void onDaySelected(DateTime day) {
      selectedDay.value = day;
    }

    return AppScaffold(
      noBackground: false,
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('eventCalander').tr(),
      ),
      body: SingleChildScrollView(
        child:
            MediaQuery.of(context).size.width > 480
                ? ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 480),
                  child: Column(
                    children: [
                      Card(
                        margin: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Use the reusable EventCalendarWidget
                            EventCalendarWidget(
                              events: events,
                              initialDate: now,
                              showEventDetails: true,
                              onMonthChanged: onMonthChanged,
                              onDaySelected: onDaySelected,
                            ),
                          ],
                        ),
                      ),

                      // Add the fortune graph widget
                      const Divider(height: 1),
                      FortuneGraphWidget(
                        events: events,
                        constrainWidth: true,
                        onPointSelected: onDaySelected,
                      ),

                      // Show user profile if viewing someone else's calendar
                      if (name != 'me' && user.hasValue)
                        AccountNameplate(name: name),
                    ],
                  ),
                ).center()
                : Column(
                  children: [
                    // Use the reusable EventCalendarWidget
                    EventCalendarWidget(
                      events: events,
                      initialDate: now,
                      showEventDetails: true,
                      onMonthChanged: onMonthChanged,
                      onDaySelected: onDaySelected,
                    ),

                    // Add the fortune graph widget
                    const Divider(height: 1),
                    FortuneGraphWidget(
                      events: events,
                      onPointSelected: onDaySelected,
                    ).padding(horizontal: 8, vertical: 4),

                    // Show user profile if viewing someone else's calendar
                    if (name != 'me' && user.hasValue)
                      AccountNameplate(name: name),
                    Gap(MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
      ),
    );
  }
}
