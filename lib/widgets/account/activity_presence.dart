import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/activity/activity_rpc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

const kPresenseActivityTypes = [
  'unknown',
  'presenceTypeGaming',
  'presenceTypeMusic',
  'presenceTypeWorkout',
];

class ActivityPresenceWidget extends ConsumerWidget {
  final String uname;

  const ActivityPresenceWidget({super.key, required this.uname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(presenceActivitiesProvider(uname));

    return activitiesAsync.when(
      data:
          (activities) => Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  'activities',
                ).tr().bold().padding(horizontal: 8, vertical: 4),
                if (activities.isEmpty)
                  Row(children: [
                    const Icon(Symbols.inbox),
                    Text('dataEmpty').tr()
                  ],).opacity(0.75),
                ...activities.map(
                  (activity) => Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(
                        (activity.title?.isEmpty ?? true)
                            ? 'Untitled Activity'
                            : activity.title!,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kPresenseActivityTypes[activity.type]).tr(),
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              final duration = DateTime.now().difference(activity.createdAt);
                              final hours = duration.inHours.toString().padLeft(2, '0');
                              final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
                              final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
                              return Text('$hours:$minutes:$seconds').textColor(Colors.green);
                            },
                          ),
                          if (activity.subtitle?.isNotEmpty ?? false)
                            Text(activity.subtitle!),
                          if (activity.caption?.isNotEmpty ?? false)
                            Text(activity.caption!),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ).padding(all: 8),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading activities: $error')),
    );
  }
}
