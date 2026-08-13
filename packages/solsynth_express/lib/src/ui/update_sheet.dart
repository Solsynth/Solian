import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/models.dart';

/// Bottom sheet for a published Solsynth Express release.
///
/// Install operations are callbacks so the presentation layer stays reusable
/// across host applications and can provide its own update implementation.
class UpdateSheet extends StatelessWidget {
  const UpdateSheet({
    super.key,
    required this.release,
    this.androidUpdateUrl,
    this.windowsUpdateUrl,
    this.linuxUpdateUrl,
    this.onAndroidInstall,
    this.onWindowsInstall,
    this.onLinuxInstall,
  });

  final DistributionReleaseInfo release;
  final String? androidUpdateUrl;
  final String? windowsUpdateUrl;
  final String? linuxUpdateUrl;
  final Future<void> Function()? onAndroidInstall;
  final Future<void> Function()? onWindowsInstall;
  final Future<void> Function()? onLinuxInstall;

  @override
  Widget build(BuildContext context) {
    final canInstallAndroid =
        !kIsWeb &&
        Platform.isAndroid &&
        androidUpdateUrl?.isNotEmpty == true &&
        onAndroidInstall != null;
    final canInstallWindows =
        !kIsWeb &&
        Platform.isWindows &&
        windowsUpdateUrl?.isNotEmpty == true &&
        onWindowsInstall != null;
    final canInstallLinux =
        !kIsWeb &&
        Platform.isLinux &&
        linuxUpdateUrl?.isNotEmpty == true &&
        onLinuxInstall != null;

    return SheetScaffold(
      titleText: 'updateAvailable'.tr(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  release.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ).bold(),
                Text(release.tagName).fontSize(12),
              ],
            ).padding(vertical: 16, horizontal: 16),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SolarMarkdownContent(
                  content: release.body.isEmpty
                      ? 'noChangelogProvided'.tr()
                      : release.body,
                ),
              ),
            ),
            Row(
              spacing: 8,
              children: [
                if (canInstallAndroid)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onAndroidInstall,
                      icon: const Icon(Symbols.update),
                      label: Text('installUpdate'.tr()),
                    ),
                  ),
                if (canInstallWindows)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onWindowsInstall,
                      icon: const Icon(Symbols.update),
                      label: Text('installUpdate'.tr()),
                    ),
                  ),
                if (canInstallLinux)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onLinuxInstall,
                      icon: const Icon(Symbols.update),
                      label: Text('installUpdate'.tr()),
                    ),
                  ),
                if (release.htmlUrl != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openReleasePage(release.htmlUrl!),
                      icon: const Icon(Icons.open_in_new),
                      label: Text('openReleasePage'.tr()),
                    ),
                  ),
              ],
            ).padding(horizontal: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _openReleasePage(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Logger.root.warning('[Solsynth Express] Cannot open release URL: $url');
    }
  }
}
