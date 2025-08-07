import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:island/widgets/content/sheet.dart';

/// Data model for a GitHub release we care about
class GithubReleaseInfo {
  final String tagName; // e.g. 3.1.0+118
  final String name; // release title
  final String body; // changelog markdown
  final String htmlUrl; // release page
  final DateTime createdAt;

  const GithubReleaseInfo({
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.createdAt,
  });
}

/// Parses version and build number from "x.y.z+build"
class _ParsedVersion implements Comparable<_ParsedVersion> {
  final int major;
  final int minor;
  final int patch;
  final int build;

  const _ParsedVersion(this.major, this.minor, this.patch, this.build);

  static _ParsedVersion? tryParse(String input) {
    // Expect format like 0.0.0+00 (build after '+'). Allow missing build as 0.
    final partsPlus = input.split('+');
    final core = partsPlus[0].trim();
    final buildStr = partsPlus.length > 1 ? partsPlus[1].trim() : '0';
    final coreParts = core.split('.');
    if (coreParts.length != 3) return null;

    final major = int.tryParse(coreParts[0]) ?? 0;
    final minor = int.tryParse(coreParts[1]) ?? 0;
    final patch = int.tryParse(coreParts[2]) ?? 0;
    final build = int.tryParse(buildStr) ?? 0;

    return _ParsedVersion(major, minor, patch, build);
  }

  @override
  int compareTo(_ParsedVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    return build.compareTo(other.build);
  }

  @override
  String toString() => '$major.$minor.$patch+$build';
}

class UpdateService {
  UpdateService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              headers: {
                // Identify the app to GitHub; avoids some rate-limits and adds clarity
                'Accept': 'application/vnd.github+json',
                'User-Agent': 'solian-update-checker',
              },
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  static const _releasesLatestApi =
      'https://api.github.com/repos/solsynth/solian/releases/latest';

  /// Checks GitHub for the latest release and compares against the current app version.
  /// If update is available, shows a bottom sheet with changelog and an action to open release page.
  Future<void> checkForUpdates(BuildContext context) async {
    try {
      final release = await fetchLatestRelease();
      if (release == null) return;

      final info = await PackageInfo.fromPlatform();
      final localVersionStr = '${info.version}+${info.buildNumber}';

      final latest = _ParsedVersion.tryParse(release.tagName);
      final local = _ParsedVersion.tryParse(localVersionStr);

      if (latest == null || local == null) {
        // If parsing fails, do nothing silently
        return;
      }

      final needsUpdate = latest.compareTo(local) > 0;
      if (!needsUpdate) return;

      if (!context.mounted) return;

      // Delay to ensure UI is ready (if called at startup)
      await Future.delayed(const Duration(milliseconds: 100));

      await showUpdateSheet(context, release);
    } catch (_) {
      // Ignore errors (network, api, etc.)
      return;
    }
  }

  /// Manually show the update sheet with a provided release.
  /// Useful for About page or testing.
  Future<void> showUpdateSheet(
    BuildContext context,
    GithubReleaseInfo release,
  ) async {
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder:
          (ctx) => _UpdateSheet(
            release: release,
            onOpen: () async {
              final uri = Uri.parse(release.htmlUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
    );
  }

  /// Fetch the latest release info from GitHub.
  /// Public so other screens (e.g., About) can manually trigger update checks.
  Future<GithubReleaseInfo?> fetchLatestRelease() async {
    final resp = await _dio.get(_releasesLatestApi);
    if (resp.statusCode != 200) return null;
    final data = resp.data as Map<String, dynamic>;

    final tagName = (data['tag_name'] ?? '').toString();
    final name = (data['name'] ?? tagName).toString();
    final body = (data['body'] ?? '').toString();
    final htmlUrl = (data['html_url'] ?? '').toString();
    final createdAtStr = (data['created_at'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

    if (tagName.isEmpty || htmlUrl.isEmpty) return null;

    return GithubReleaseInfo(
      tagName: tagName,
      name: name,
      body: body,
      htmlUrl: htmlUrl,
      createdAt: createdAt,
    );
  }
}

class _UpdateSheet extends StatelessWidget {
  const _UpdateSheet({required this.release, required this.onOpen});

  final GithubReleaseInfo release;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SheetScaffold(
      titleText: 'Update available',
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
                Text(release.name, style: theme.textTheme.titleMedium).bold(),
                Text(release.tagName).fontSize(12),
              ],
            ).padding(vertical: 16, horizontal: 16),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: SelectableText(
                  release.body.isEmpty
                      ? 'No changelog provided.'
                      : release.body,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open release page'),
                      ),
                    ),
                  ],
                ),
              ],
            ).padding(horizontal: 16),
          ],
        ),
      ),
    );
  }
}
