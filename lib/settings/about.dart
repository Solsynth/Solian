import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/udid.dart' as udid;
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Solian',
    packageName: 'dev.solsynth.solian',
    version: '1.0.0',
    buildNumber: '1',
  );
  BaseDeviceInfo? _deviceInfo;
  String? _deviceUdid;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _initDeviceInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'aboutScreenFailedToLoadPackageInfo'.tr(
            args: [e.toString()],
          );
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      _deviceInfo = await deviceInfoPlugin.deviceInfo;
      _deviceUdid = await udid.getUdid();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'aboutScreenFailedToLoadDeviceInfo'.tr(
            args: [e.toString()],
          );
        });
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('about'.tr()), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      // App Icon and Name
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        child: Image.asset(
                          'assets/icons/icon.png',
                          width: 56,
                          height: 56,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _packageInfo.appName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'aboutScreenVersionInfo'.tr(
                          args: [
                            _packageInfo.version,
                            _packageInfo.buildNumber,
                          ],
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // App Info Card
                      _buildSection(
                        context,
                        title: 'aboutScreenAppInfoSectionTitle'.tr(),
                        children: [
                          _buildInfoItem(
                            context,
                            icon: Symbols.info,
                            label: 'aboutScreenPackageNameLabel'.tr(),
                            value: _packageInfo.packageName,
                          ),
                          _buildInfoItem(
                            context,
                            icon: Symbols.update,
                            label: 'aboutScreenVersionLabel'.tr(),
                            value: _packageInfo.version,
                          ),
                          _buildInfoItem(
                            context,
                            icon: Symbols.build,
                            label: 'aboutScreenBuildNumberLabel'.tr(),
                            value: _packageInfo.buildNumber,
                          ),
                        ],
                      ),

                      if (_deviceInfo != null) const SizedBox(height: 16),

                      if (_deviceInfo != null)
                        _buildSection(
                          context,
                          title: 'Device Information',
                          children: [
                            FutureBuilder<String>(
                              future: udid.getDeviceName(),
                              builder: (context, snapshot) {
                                final value = snapshot.hasData
                                    ? snapshot.data!
                                    : 'unknown'.tr();
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
                              value: _deviceUdid ?? 'N/A',
                              copyable: true,
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Links Card
                      _buildSection(
                        context,
                        title: 'aboutScreenLinksSectionTitle'.tr(),
                        children: [
                          _buildListTile(
                            context,
                            icon: Symbols.privacy_tip,
                            title: 'aboutScreenPrivacyPolicyTitle'.tr(),
                            onTap: () => _launchURL(
                              'https://solsynth.dev/terms/privacy-policy',
                            ),
                          ),
                          _buildListTile(
                            context,
                            icon: Symbols.description,
                            title: 'aboutScreenTermsOfServiceTitle'.tr(),
                            onTap: () => _launchURL(
                              'https://solsynth.dev/terms/user-agreement',
                            ),
                          ),
                          _buildListTile(
                            context,
                            icon: Symbols.code,
                            title: 'aboutScreenOpenSourceLicensesTitle'.tr(),
                            onTap: () {
                              showLicensePage(
                                context: context,
                                applicationName: _packageInfo.appName,
                                applicationVersion:
                                    'Version ${_packageInfo.version}',
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Developer Info
                      _buildSection(
                        context,
                        title: 'aboutScreenDeveloperSectionTitle'.tr(),
                        children: [
                          _buildListTile(
                            context,
                            icon: Symbols.email,
                            title: 'aboutScreenContactUsTitle'.tr(),
                            subtitle: 'lily@solsynth.dev',
                            onTap: () => _launchURL('mailto:lily@solsynth.dev'),
                          ),
                          _buildListTile(
                            context,
                            icon: Symbols.copyright,
                            title: 'aboutScreenLicenseTitle'.tr(),
                            subtitle: 'aboutScreenLicenseContent'.tr(),
                            onTap: () => _launchURL(
                              'https://github.com/Solsynth/Solian/blob/v3/LICENSE.txt',
                            ),
                          ),
                          if (kIsWeb || !(Platform.isMacOS || Platform.isIOS))
                            _buildListTile(
                              context,
                              icon: Symbols.favorite,
                              title: 'donate'.tr(),
                              subtitle: 'donateDescription'.tr(),
                              onTap: () {
                                launchUrlString(
                                  'https://afdian.com/@littlesheep',
                                );
                              },
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Copyright
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'aboutScreenCopyright'.tr(
                                args: [DateTime.now().year.toString()],
                              ),
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const Gap(1),
                            Text(
                              'aboutScreenMadeWith'.tr(),
                              textAlign: TextAlign.center,
                            ).fontSize(10).opacity(0.8),
                          ],
                        ),
                      ),

                      Gap(MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).hintColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildListTile(
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
          leading: Icon(icon).padding(top: multipleLines ? 8 : 0),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          isThreeLine: multipleLines,
          trailing: const Icon(
            Symbols.chevron_right,
          ).padding(top: multipleLines ? 8 : 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          minLeadingWidth: 24,
        ),
      ],
    );
  }
}
