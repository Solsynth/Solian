import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/progression_ws.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/screens/e2ee_keypair_screen.dart';
import 'package:island/core/services/update_service.dart';
import 'package:island/e2ee/mls_engine.dart';
import 'package:island/e2ee/mls_storage.dart';
import 'package:island/e2ee/mls_client.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/network_status_sheet.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:island/shared/widgets/app_onboarding_sheet.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:island/talker.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
              leading: const Icon(Symbols.slideshow),
              trailing: const Icon(Symbols.chevron_right),
              title: const Text('Show onboarding (new user)'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () async {
                final info = await PackageInfo.fromPlatform();
                if (!context.mounted) return;
                await showAppOnboardingSheet(
                  context,
                  version: info.version,
                  isFirstLaunch: true,
                  suggestAuth: true,
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.slideshow),
              trailing: const Icon(Symbols.chevron_right),
              title: const Text('Show onboarding (old user)'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () async {
                final info = await PackageInfo.fromPlatform();
                if (!context.mounted) return;
                await showAppOnboardingSheet(
                  context,
                  version: info.version,
                  isFirstLaunch: false,
                  suggestAuth: false,
                );
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
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.military_tech),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test achievement completed'),
              onTap: () {
                final notifier = ref.read(
                  progressionWebSocketProvider.notifier,
                );
                notifier.testShowCompletion(
                  kind: 'achievement',
                  title: 'First Post',
                  reward: const SnProgressRewardDefinition(
                    experience: 100,
                    sourcePoints: 50,
                  ),
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.assignment),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test quest completed'),
              onTap: () {
                final notifier = ref.read(
                  progressionWebSocketProvider.notifier,
                );
                notifier.testShowCompletion(
                  kind: 'quest',
                  title: 'Daily Check-in',
                  reward: const SnProgressRewardDefinition(experience: 50),
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
              leading: const Icon(Symbols.key),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('E2EE keypairs'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const E2eeKeypairScreen(),
                  ),
                );
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
              leading: const Icon(Symbols.info),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('MLS Diagnostics'),
              onTap: () async {
                try {
                  final mlsClient = ref.read(mlsClientProvider);
                  final deviceId = await mlsClient.getDeviceId();
                  final signerPub = await mlsClient.identityManager
                      .getSignerPublicKey();
                  final kpCount = await mlsClient.identityManager
                      .getKeyPackageUploadCount();
                  final accountId = await mlsClient.identityManager
                      .getCurrentAccountId();

                  final info = StringBuffer();
                  info.writeln('MLS Diagnostics');
                  info.writeln('─' * 30);
                  info.writeln('Device ID: ${deviceId ?? "null"}');
                  info.writeln('Account ID: ${accountId ?? "null"}');
                  final signerPubStr = base64Encode(signerPub);
                  info.writeln(
                    'Signer Public Key: ${signerPubStr.length > 20 ? "${signerPubStr.substring(0, 20)}..." : signerPubStr}',
                  );
                  info.writeln('Local KeyPackages: $kpCount');

                  if (accountId != null) {
                    final serverKps = await mlsClient.identityManager
                        .getDeviceKeyPackages(accountId);
                    info.writeln('Server KeyPackages: ${serverKps.length}');
                    for (final kp in serverKps) {
                      info.writeln(
                        '  Device: ${kp['device_id']}, KP: ${kp['key_package'] != null ? "yes" : "no"}',
                      );
                    }
                  }

                  if (!context.mounted) return;
                  showInfoAlert(info.toString(), 'MLS Diagnostics');
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorAlert(e);
                }
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.security),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Clear MLS storage'),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear MLS Storage?'),
                    content: const Text(
                      'This will delete all MLS group states, credentials, and key packages. '
                      'You will need to re-register your device and re-bootstrap all groups.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final storage = MlsStorage();
                  await storage.clearAll();
                  MlsEngineService.resetInstance();
                  showInfoAlert(
                    'MLS storage cleared. Please restart the app.',
                    'Done',
                  );
                }
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.mail),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Fetch pending E2EE envelopes'),
              onTap: () async {
                try {
                  final mlsClient = ref.read(mlsClientProvider);
                  await mlsClient.fetchAndProcessPendingEnvelopes();
                  if (!context.mounted) return;
                  showSnackBar('Pending envelopes processed');
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorAlert(e);
                }
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.info),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('MLS Diagnostics'),
              onTap: () async {
                try {
                  final mlsClient = ref.read(mlsClientProvider);
                  final deviceId = await mlsClient.getDeviceId();
                  final signerPub = await mlsClient.identityManager
                      .getSignerPublicKey();
                  final kpCount = await mlsClient.identityManager
                      .getKeyPackageUploadCount();

                  final info = StringBuffer();
                  info.writeln('MLS Diagnostics');
                  info.writeln('─' * 30);
                  info.writeln('Device ID: ${deviceId ?? "null"}');
                  final signerPubStr = base64Encode(signerPub);
                  info.writeln(
                    'Signer Public Key: ${signerPubStr.length > 20 ? "${signerPubStr.substring(0, 20)}..." : signerPubStr}',
                  );
                  info.writeln('Local KeyPackages: $kpCount');

                  if (!context.mounted) return;
                  showInfoAlert(info.toString(), 'MLS Diagnostics');
                } catch (e) {
                  if (!context.mounted) return;
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
