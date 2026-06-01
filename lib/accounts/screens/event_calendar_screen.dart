import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/event_calendar_content.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

@RoutePage()
class EventCalendarScreen extends HookConsumerWidget {
  final String name;

  const EventCalendarScreen({super.key, @pathParam required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text('eventCalendar').tr(),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: EventCalendarContent(name: name),
        ),
      ),
    );
  }
}
