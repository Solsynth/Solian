import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/fitness/fitness_data.dart';
import 'package:island/fitness/fitness_service.dart';
import 'package:island/core/services/update_service.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/network_status_sheet.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/config.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:island/talker.dart';

Future<void> _showSetTokenDialog(BuildContext context, WidgetRef ref) async {
  final TextEditingController controller = TextEditingController();
  final prefs = ref.read(sharedPreferencesProvider);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Set access token'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter access token',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Set'),
            onPressed: () async {
              final token = controller.text.trim();
              if (token.isNotEmpty) {
                await setToken(prefs, token);
                ref.invalidate(tokenProvider);
                // Store context in local variable to avoid async gap issue
                final navigatorContext = context;
                if (navigatorContext.mounted) {
                  Navigator.of(navigatorContext).pop();
                }
              }
            },
          ),
        ],
      );
    },
  );
}

class DebugSheet extends HookConsumerWidget {
  const DebugSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      titleText: 'Debug',
      heightFactor: 0.6,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(4),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.update),
              trailing: const Icon(Symbols.chevron_right),
              title: Text('Force update'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () async {
                // Fetch latest release and show the unified sheet
                final svc = UpdateService();
                // Reuse service fetch + compare to decide content
                showLoadingModal(context);
                final release = await svc.fetchLatestRelease();
                if (!context.mounted) return;
                hideLoadingModal(context);
                if (release != null) {
                  await svc.showUpdateSheet(context, release);
                } else {
                  showInfoAlert(
                    'Currently cannot get update from the GitHub.',
                    'Unable to check for updates',
                  );
                }
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.wifi),
              trailing: const Icon(Symbols.chevron_right),
              title: Text('Connection status'),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => NetworkStatusSheet(),
                );
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.bug_report),
              trailing: const Icon(Symbols.chevron_right),
              title: Text('Logs'),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TalkerScreen(talker: talker),
                  ),
                );
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.error),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test error alert'),
              onTap: () {
                showErrorAlert(
                  'This is a test error message for debugging purposes.',
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.info),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test info alert'),
              onTap: () {
                showInfoAlert(
                  'This is a test info message for debugging purposes.',
                  'Test Alert',
                );
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.copy_all),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Copy access token'),
              onTap: () async {
                final tk = ref.watch(tokenProvider);
                Clipboard.setData(ClipboardData(text: tk!.token));
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.edit),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Set access token'),
              onTap: () async {
                await _showSetTokenDialog(context, ref);
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.delete),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Reset database'),
              onTap: () async {
                resetDatabase(ref);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.clear),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Clear cache'),
              onTap: () async {
                DefaultCacheManager().emptyCache();
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.fitness_center),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Load Last 7 Days Workouts'),
              onTap: () async {
                try {
                  final fitnessService = ref.read(fitnessServiceProvider);

                  // Check if platform is supported
                  if (!fitnessService.isPlatformSupported) {
                    showErrorAlert(
                      'Fitness data is only available on iOS and Android devices.',
                    );
                    return;
                  }

                  // Check permissions first
                  final permissionStatus = await fitnessService
                      .getPermissionStatus();
                  if (permissionStatus != FitnessPermissionStatus.granted) {
                    final granted = await fitnessService.requestPermissions();
                    if (!granted) {
                      showErrorAlert(
                        'Permission to access fitness data was denied. Please enable it in your device settings.',
                      );
                      return;
                    }
                  }

                  // Get workouts from the last 7 days
                  final workouts = await fitnessService.getWorkoutsLast7Days();

                  if (workouts.isEmpty) {
                    showInfoAlert(
                      'No workout data found for the last 7 days.',
                      'No Data',
                    );
                    return;
                  }

                  // Format the workout data for display
                  StringBuffer sb = StringBuffer();
                  for (final workout in workouts) {
                    final dateStr =
                        '${workout.startTime.day}/${workout.startTime.month}';
                    final energyStr = workout.energyBurnedString.isNotEmpty
                        ? ' • ${workout.energyBurnedString}'
                        : '';
                    final distanceStr = workout.distanceString.isNotEmpty
                        ? ' • ${workout.distanceString}'
                        : '';
                    final stepsStr = workout.stepsString.isNotEmpty
                        ? ' • ${workout.stepsString} steps'
                        : '';

                    sb.write(
                      '${workout.workoutTypeString} • $dateStr • ${workout.durationString}$energyStr$distanceStr$stepsStr\n',
                    );
                  }

                  showInfoAlert(sb.toString(), 'Workout Data Retrieved');
                } catch (e) {
                  showErrorAlert(e);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
