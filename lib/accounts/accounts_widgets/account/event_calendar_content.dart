import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account/profile.dart';
import 'package:island/accounts/accounts_widgets/account/account_nameplate.dart';
import 'package:island/accounts/accounts_widgets/account/event_calendar.dart';
import 'package:island/accounts/accounts_widgets/account/fortune_graph.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:styled_widget/styled_widget.dart';

/// A reusable content widget for event calendar that can be used in screens or sheets
/// This widget manages the calendar state and displays the calendar and fortune graph
class EventCalendarContent extends HookConsumerWidget {
  /// Username to fetch calendar for, null means current user ('me')
  final String name;

  /// Whether this is being displayed in a sheet (affects layout)
  final bool isSheet;

  const EventCalendarContent({
    super.key,
    required this.name,
    this.isSheet = false,
  });

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

    if (isSheet) {
      // Sheet layout - simplified, no app bar, scrollable content
      return SingleChildScrollView(
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

            // Add the fortune graph widget
            const Divider(height: 1),
            FortuneGraphWidget(
              events: events,
              onPointSelected: onDaySelected,
            ).padding(horizontal: 8, vertical: 4),

            // Show user profile if viewing someone else's calendar
            if (name != 'me' && user.value != null)
              AccountNameplate(name: name),
            Gap(MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      );
    } else {
      // Screen layout - with responsive design
      return SingleChildScrollView(
        child: MediaQuery.of(context).size.width > 480
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    Card(
                      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
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
                    FortuneGraphWidget(
                      events: events,
                      constrainWidth: true,
                      onPointSelected: onDaySelected,
                    ),

                    // Show user profile if viewing someone else's calendar
                    if (name != 'me' && user.value != null)
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
                  if (name != 'me' && user.value != null)
                    AccountNameplate(name: name),
                  Gap(MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
      );
    }
  }
}
