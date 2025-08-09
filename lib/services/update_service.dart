import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_update/azhon_app_update.dart';
import 'package:flutter_app_update/update_model.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:collection/collection.dart'; // Added for firstWhereOrNull
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:island/widgets/content/sheet.dart';

/// Data model for a GitHub release we care about
class GithubReleaseInfo {
  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final DateTime createdAt;
  final List<GithubReleaseAsset> assets;

  const GithubReleaseInfo({
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.createdAt,
    this.assets = const [],
  });
}

/// Data model for a GitHub release asset
class GithubReleaseAsset {
  final String name;
  final String browserDownloadUrl;

  const GithubReleaseAsset({
    required this.name,
    required this.browserDownloadUrl,
  });

  factory GithubReleaseAsset.fromJson(Map<String, dynamic> json) {
    return GithubReleaseAsset(
      name: json['name'] as String,
      browserDownloadUrl: json['browser_download_url'] as String,
    );
  }
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
  UpdateService({Dio? dio, this.useProxy = false})
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
  final bool useProxy;

  static const _proxyBaseUrl = 'https://ghfast.top/';

  static const _releasesLatestApi =
      'https://api.github.com/repos/solsynth/solian/releases/latest';

  /// Checks GitHub for the latest release and compares against the current app version.
  /// If update is available, shows a bottom sheet with changelog and an action to open release page.
  Future<void> checkForUpdates(BuildContext context) async {
    log('[Update] Checking for updates...');
    try {
      final release = await fetchLatestRelease();
      if (release == null) {
        log('[Update] No latest release found or could not fetch.');
        return;
      }
      log('[Update] Fetched latest release: ${release.tagName}');

      final info = await PackageInfo.fromPlatform();
      final localVersionStr = '${info.version}+${info.buildNumber}';
      log('[Update] Local app version: $localVersionStr');

      final latest = _ParsedVersion.tryParse(release.tagName);
      final local = _ParsedVersion.tryParse(localVersionStr);

      if (latest == null || local == null) {
        log(
          '[Update] Failed to parse versions. Latest: ${release.tagName}, Local: $localVersionStr',
        );
        // If parsing fails, do nothing silently
        return;
      }
      log('[Update] Parsed versions. Latest: $latest, Local: $local');

      final needsUpdate = latest.compareTo(local) > 0;
      if (!needsUpdate) {
        log('[Update] App is up to date. No update needed.');
        return;
      }
      log('[Update] Update available! Latest: $latest, Local: $local');

      if (!context.mounted) {
        log('[Update] Context not mounted, cannot show update sheet.');
        return;
      }

      // Delay to ensure UI is ready (if called at startup)
      await Future.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        await showUpdateSheet(context, release);
        log('[Update] Update sheet shown.');
      }
    } catch (e) {
      log('[Update] Error checking for updates: $e');
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
      builder: (ctx) {
        String? androidUpdateUrl;
        if (Platform.isAndroid) {
          androidUpdateUrl = _getAndroidUpdateUrl(release.assets);
        }
        return _UpdateSheet(
          release: release,
          onOpen: () async {
            final uri = Uri.parse(release.htmlUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          androidUpdateUrl: androidUpdateUrl,
          useProxy: useProxy, // Pass the useProxy flag
        );
      },
    );
  }

  String? _getAndroidUpdateUrl(List<GithubReleaseAsset> assets) {
    final arm64 = assets.firstWhereOrNull(
      (asset) => asset.name == 'app-arm64-v8a-release.apk',
    );
    final armeabi = assets.firstWhereOrNull(
      (asset) => asset.name == 'app-armeabi-v7a-release.apk',
    );
    final x86_64 = assets.firstWhereOrNull(
      (asset) => asset.name == 'app-x86_64-release.apk',
    );

    // Prioritize arm64, then armeabi, then x86_64
    if (arm64 != null) {
      return arm64.browserDownloadUrl;
    } else if (armeabi != null) {
      return armeabi.browserDownloadUrl;
    } else if (x86_64 != null) {
      return x86_64.browserDownloadUrl;
    }
    return null;
  }

  /// Fetch the latest release info from GitHub.
  /// Public so other screens (e.g., About) can manually trigger update checks.
  Future<GithubReleaseInfo?> fetchLatestRelease() async {
    final apiEndpoint =
        useProxy
            ? '$_proxyBaseUrl${Uri.encodeComponent(_releasesLatestApi)}'
            : _releasesLatestApi;

    log(
      '[Update] Fetching latest release from GitHub API: $apiEndpoint (Proxy: $useProxy)',
    );
    final resp = await _dio.get(apiEndpoint);
    if (resp.statusCode != 200) {
      log(
        '[Update] Failed to fetch latest release. Status code: ${resp.statusCode}',
      );
      return null;
    }
    final data = resp.data as Map<String, dynamic>;
    log('[Update] Successfully fetched release data.');

    final tagName = (data['tag_name'] ?? '').toString();
    final name = (data['name'] ?? tagName).toString();
    final body = (data['body'] ?? '').toString();
    final htmlUrl = (data['html_url'] ?? '').toString();
    final createdAtStr = (data['created_at'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
    final assetsData =
        (data['assets'] as List<dynamic>?)
            ?.map((e) => GithubReleaseAsset.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    if (tagName.isEmpty || htmlUrl.isEmpty) {
      log(
        '[Update] Missing tag_name or html_url in release data. TagName: "$tagName", HtmlUrl: "$htmlUrl"',
      );
      return null;
    }

    log('[Update] Returning GithubReleaseInfo for tag: $tagName');
    return GithubReleaseInfo(
      tagName: tagName,
      name: name,
      body: body,
      htmlUrl: htmlUrl,
      createdAt: createdAt,
      assets: assetsData,
    );
  }
}

class _UpdateSheet extends StatefulWidget {
  const _UpdateSheet({
    required this.release,
    required this.onOpen,
    this.androidUpdateUrl,
    this.useProxy = false,
  });

  final String? androidUpdateUrl;
  final bool useProxy;
  final GithubReleaseInfo release;
  final VoidCallback onOpen;

  @override
  State<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<_UpdateSheet> {
  late bool _useProxy;

  @override
  void initState() {
    super.initState();
    _useProxy = widget.useProxy;
  }

  Future<void> _installUpdate(String url) async {
    final downloadUrl =
        _useProxy ? 'https://ghfast.top/${Uri.encodeComponent(url)}' : url;

    UpdateModel model = UpdateModel(
      downloadUrl,
      "solian-update-${widget.release.tagName}.apk",
      "launcher_icon",
      'https://apps.apple.com/us/app/solian/id6499032345',
    );
    AzhonAppUpdate.update(model);
  }

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
                Text(
                  widget.release.name,
                  style: theme.textTheme.titleMedium,
                ).bold(),
                Text(widget.release.tagName).fontSize(12),
              ],
            ).padding(vertical: 16, horizontal: 16),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: MarkdownTextContent(
                  content:
                      widget.release.body.isEmpty
                          ? 'No changelog provided.'
                          : widget.release.body,
                ),
              ),
            ),
            if (!kIsWeb && Platform.isAndroid)
              SwitchListTile(
                title: const Text('Use GitHub Proxy for Download'),
                value: _useProxy,
                onChanged: (value) {
                  setState(() {
                    _useProxy = value;
                  });
                },
              ).padding(horizontal: 8),
            Column(
              children: [
                Row(
                  spacing: 8,
                  children: [
                    if (!kIsWeb &&
                        Platform.isAndroid &&
                        widget.androidUpdateUrl != null)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            log(widget.androidUpdateUrl!);
                            _installUpdate(widget.androidUpdateUrl!);
                          },
                          icon: const Icon(Symbols.update),
                          label: const Text('Install update'),
                        ),
                      ),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: widget.onOpen,
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
