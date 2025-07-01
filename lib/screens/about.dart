import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Island',
    packageName: 'com.example.island',
    version: '1.0.0',
    buildNumber: '1',
  );
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
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
          _errorMessage = 'Failed to load package info: $e';
          _isLoading = false;
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

    return Scaffold(
      appBar: AppBar(title: const Text('About'), elevation: 0),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
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
                      'Version ${_packageInfo.version} (${_packageInfo.buildNumber})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // App Info Card
                    _buildSection(
                      context,
                      title: 'App Information',
                      children: [
                        _buildInfoItem(
                          context,
                          icon: Icons.info_outline,
                          label: 'Package Name',
                          value: _packageInfo.packageName,
                        ),
                        _buildInfoItem(
                          context,
                          icon: Icons.update,
                          label: 'Version',
                          value: _packageInfo.version,
                        ),
                        _buildInfoItem(
                          context,
                          icon: Icons.build,
                          label: 'Build Number',
                          value: _packageInfo.buildNumber,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Links Card
                    _buildSection(
                      context,
                      title: 'Links',
                      children: [
                        _buildListTile(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap:
                              () => _launchURL(
                                'https://solsynth.dev/terms/privacy-policy',
                              ),
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          onTap:
                              () => _launchURL(
                                'https://example.com/terms/basic-law',
                              ),
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.code,
                          title: 'Open Source Licenses',
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
                      title: 'Developer',
                      children: [
                        _buildListTile(
                          context,
                          icon: Icons.email_outlined,
                          title: 'Contact Us',
                          subtitle: 'lily@solsynth.dev',
                          onTap: () => _launchURL('mailto:lily@solsynth.dev'),
                        ),
                        _buildListTile(
                          context,
                          icon: Icons.copyright,
                          title: 'License',
                          subtitle:
                              'Copyright reserved © ${DateTime.now().year} Solsynth\nGNU Affero General Public License v3.0',
                          onTap:
                              () => _launchURL(
                                'https://github.com/Solsynth/Solian/blob/v3/LICENSE.txt',
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Copyright
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '© ${DateTime.now().year} ${_packageInfo.appName}. All rights reserved.',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
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
                ),
              ],
            ),
          ),
          if (value.startsWith('http') || value.contains('@'))
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Copy to clipboard',
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
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          minLeadingWidth: 24,
        ),
      ],
    );
  }
}
