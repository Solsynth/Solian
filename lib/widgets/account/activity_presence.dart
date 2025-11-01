import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/activity/activity_rpc.dart';

class ActivityPresenceWidget extends ConsumerWidget {
  final String uname;

  const ActivityPresenceWidget({super.key, required this.uname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(presenceActivitiesProvider(uname));

    return activitiesAsync.when(
      data: (activities) => _buildActivitiesList(activities),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading activities: $error')),
    );
  }

  Widget _buildActivitiesList(List<SnPresenceActivity> activities) {
    if (activities.isEmpty) {
      return const Center(child: Text('No active activities'));
    }

    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(activity.title ?? 'Untitled Activity'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${activity.type}'),
                if (activity.subtitle != null) Text(activity.subtitle!),
                if (activity.caption != null) Text(activity.caption!),
                Text(
                  'Expires: ${activity.leaseExpiresAt.toLocal().toString()}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // TODO: Implement delete functionality
              },
            ),
          ),
        );
      },
    );
  }
}
