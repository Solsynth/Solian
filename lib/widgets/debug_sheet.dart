import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/modular/miniapp_loader.dart';
import 'package:island/pods/message.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/plugin_registry.dart';
import 'package:island/services/update_service.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/network_status_sheet.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/miniapp_modal.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/pods/config.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:island/talker.dart';

Future<void> _showSetTokenDialog(BuildContext context, WidgetRef ref) async {
  final TextEditingController controller = TextEditingController();
  final prefs = ref.read(sharedPreferencesProvider);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Set Access Token'),
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
              title: const Text('Test Error Alert'),
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
              title: const Text('Test Info Alert'),
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
            if (!kIsWeb &&
                (Platform.isMacOS || Platform.isWindows || Platform.isLinux))
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.file_upload),
                trailing: const Icon(Symbols.chevron_right),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                title: Text('Load Miniapp from File'),
                onTap: () async {
                  await MiniappLoader.loadMiniappFromSource(context, ref);
                },
              ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.download),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Load Miniapp from URL'),
              onTap: () async {
                await _showLoadFromUrlDialog(context, ref);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.play_circle),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Launch Miniapp'),
              onTap: () async {
                await _showMiniappSelector(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLoadFromUrlDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Load Miniapp from URL'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter .evc file URL',
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
              child: const Text('Load'),
              onPressed: () async {
                final url = controller.text.trim();
                if (url.isNotEmpty) {
                  Navigator.of(context).pop();
                  showLoadingModal(context);
                  await MiniappLoader.loadMiniappFromUrl(context, ref, url);
                  if (context.mounted) {
                    hideLoadingModal(context);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMiniappSelector(BuildContext context, WidgetRef ref) async {
    final registry = ref.read(pluginRegistryProvider);
    final miniapps = registry.miniApps.values.toList();

    if (miniapps.isEmpty) {
      showErrorAlert('No miniapps loaded');
      return;
    }

    final selectedId = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Miniapp'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: miniapps.length,
              itemBuilder: (context, index) {
                final miniapp = miniapps[index];
                return ListTile(
                  title: Text(miniapp.metadata.name),
                  subtitle: Text(miniapp.metadata.description),
                  onTap: () {
                    Navigator.of(context).pop(miniapp.metadata.id);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedId != null && context.mounted) {
      await showMiniappModal(context, ref, selectedId);
    }
  }
}
