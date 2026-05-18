import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/udid.dart' as udid;
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutContent extends HookConsumerWidget {
  final bool showHeader;

  const AboutContent({super.key, this.showHeader = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final packageInfo = useState<PackageInfo?>(null);
    final deviceInfo = useState<BaseDeviceInfo?>(null);
    final deviceUdid = useState<String?>(null);
    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);

    useEffect(() {
      Future<void> load() async {
        try {
          final info = await PackageInfo.fromPlatform();
          packageInfo.value = info;
        } catch (e) {
          errorMessage.value = 'aboutScreenFailedToLoadPackageInfo'.tr(
            args: [e.toString()],
          );
        }

        try {
          final deviceInfoPlugin = DeviceInfoPlugin();
          deviceInfo.value = await deviceInfoPlugin.deviceInfo;
          deviceUdid.value = await udid.getUdid();
        } catch (e) {
          errorMessage.value = 'aboutScreenFailedToLoadDeviceInfo'.tr(
            args: [e.toString()],
          );
        }

        isLoading.value = false;
      }

      load();
      return null;
    }, []);

    Future<void> launchURL(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }

    if (isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.value != null && packageInfo.value == null) {
      return Center(child: Text(errorMessage.value!));
    }

    final info = packageInfo.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHeader)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset('assets/icons/icon.webp'),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          info.appName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'aboutScreenVersionInfo'.tr(
                            args: [info.version, info.buildNumber],
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                )
              else
                const SizedBox(height: 4),
              if (showHeader) const SizedBox(height: 16),
              _buildSection(
                context,
                title: 'aboutScreenAppInfoSectionTitle'.tr(),
                children: [
                  _buildInfoItem(
                    context,
                    icon: Symbols.info,
                    label: 'aboutScreenPackageNameLabel'.tr(),
                    value: info.packageName,
                  ),
                  _buildInfoItem(
                    context,
                    icon: Symbols.update,
                    label: 'aboutScreenVersionLabel'.tr(),
                    value: info.version,
                  ),
                  _buildInfoItem(
                    context,
                    icon: Symbols.build,
                    label: 'aboutScreenBuildNumberLabel'.tr(),
                    value: info.buildNumber,
                  ),
                ],
              ),
              if (deviceInfo.value != null) ...[
                const SizedBox(height: 12),
                _buildSection(
                  context,
                  title: 'aboutScreenDeviceSectionTitle'.tr(),
                  children: [
                    FutureBuilder<String>(
                      future: udid.getDeviceName(),
                      builder: (context, snapshot) {
                        final value = snapshot.hasData ? snapshot.data! : 'unknown'.tr();
                        return _buildInfoItem(
                          context,
                          icon: Symbols.label,
                          label: 'aboutDeviceName'.tr(),
                          value: value,
                        );
                      },
                    ),
                    _buildInfoItem(
                      context,
                      icon: Symbols.fingerprint,
                      label: 'aboutDeviceIdentifier'.tr(),
                      value: deviceUdid.value ?? 'N/A',
                      copyable: true,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              _buildSection(
                context,
                title: 'aboutScreenLinksSectionTitle'.tr(),
                children: [
                  _buildListTile(
                    context,
                    icon: Symbols.privacy_tip,
                    title: 'aboutScreenPrivacyPolicyTitle'.tr(),
                    onTap: () => launchURL('https://solsynth.dev/terms/privacy-policy'),
                  ),
                  _buildListTile(
                    context,
                    icon: Symbols.description,
                    title: 'aboutScreenTermsOfServiceTitle'.tr(),
                    onTap: () => launchURL('https://solsynth.dev/terms/user-agreement'),
                  ),
                  _buildListTile(
                    context,
                    icon: Symbols.code,
                    title: 'aboutScreenOpenSourceLicensesTitle'.tr(),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: info.appName,
                        applicationVersion: 'Version ${info.version}',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSection(
                context,
                title: 'aboutScreenDeveloperSectionTitle'.tr(),
                children: [
                  _buildListTile(
                    context,
                    icon: Symbols.email,
                    title: 'aboutScreenContactUsTitle'.tr(),
                    subtitle: 'lily@solsynth.dev',
                    onTap: () => launchURL('mailto:lily@solsynth.dev'),
                  ),
                  _buildListTile(
                    context,
                    icon: Symbols.copyright,
                    title: 'aboutScreenLicenseTitle'.tr(),
                    subtitle: 'aboutScreenLicenseContent'.tr(),
                    onTap: () => launchURL('https://github.com/Solsynth/Solian/blob/v3/LICENSE.txt'),
                  ),
                  if (kIsWeb || !(Platform.isMacOS || Platform.isIOS))
                    _buildListTile(
                      context,
                      icon: Symbols.favorite,
                      title: 'donate'.tr(),
                      subtitle: 'donateDescription'.tr(),
                      onTap: () {
                        launchUrl(Uri.parse('https://afdian.com/@littlesheep'));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'aboutScreenCopyright'.tr(
                  args: [DateTime.now().year.toString()],
                ),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const Gap(2),
              Text(
                'aboutScreenMadeWith'.tr(),
                textAlign: TextAlign.center,
              ).fontSize(10).opacity(0.8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: theme.textTheme.bodyMedium,
                  maxLines: copyable ? 1 : null,
                ),
              ],
            ),
          ),
          if (value.startsWith('http') || value.contains('@') || copyable)
            IconButton(
              icon: const Icon(Symbols.content_copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                showSnackBar('copiedToClipboard'.tr());
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'copyToClipboardTooltip'.tr(),
            ),
        ],
      ),
    );
  }

  static Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final multipleLines = subtitle?.contains('\n') ?? false;
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 20).padding(top: multipleLines ? 8 : 0),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          isThreeLine: multipleLines,
          trailing: const Icon(Symbols.chevron_right).padding(top: multipleLines ? 8 : 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          minLeadingWidth: 24,
        ),
      ],
    );
  }
}
