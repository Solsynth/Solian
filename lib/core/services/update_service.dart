import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_update/azhon_app_update.dart';
import 'package:flutter_app_update/update_model.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';
import 'package:collection/collection.dart'; // Added for firstWhereOrNull
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';

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

  /// Normalize Android build numbers by removing architecture-based offsets
  /// Android adds 1000 for x86, 2000 for ARMv7, 4000 for ARMv8
  int get normalizedBuild {
    // Check if build number has an architecture offset
    // We detect this by checking if the build % 1000 is the base build
    if (build >= 4000) {
      // Likely ARMv8 (arm64-v8a) with +4000 offset
      return build % 4000;
    } else if (build >= 2000) {
      // Likely ARMv7 (armeabi-v7a) with +2000 offset
      return build % 2000;
    } else if (build >= 1000) {
      // Likely x86/x86_64 with +1000 offset
      return build % 1000;
    }
    // No offset, return as-is
    return build;
  }

  @override
  int compareTo(_ParsedVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    // Use normalized build numbers for comparison to handle Android arch offsets
    return normalizedBuild.compareTo(other.normalizedBuild);
  }

  @override
  String toString() => '$major.$minor.$patch+$build';
}

const bool kEnableBuiltInUpdate = true;

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
    if (!kEnableBuiltInUpdate) {
      Logger.root.info(
        '[Update] Built-in update is disabled via kEnableBuiltInUpdate',
      );
      return;
    }
    Logger.root.info('[Update] Checking for updates...');
    try {
      final release = await fetchLatestRelease();
      if (release == null) {
        Logger.root.info(
          '[Update] No latest release found or could not fetch.',
        );
        return;
      }
      Logger.root.info('[Update] Fetched latest release: ${release.tagName}');

      final info = await PackageInfo.fromPlatform();
      final localVersionStr = '${info.version}+${info.buildNumber}';
      Logger.root.info('[Update] Local app version: $localVersionStr');

      final latest = _ParsedVersion.tryParse(release.tagName);
      final local = _ParsedVersion.tryParse(localVersionStr);

      if (latest == null || local == null) {
        Logger.root.info(
          '[Update] Failed to parse versions. Latest: ${release.tagName}, Local: $localVersionStr',
        );
        // If parsing fails, do nothing silently
        return;
      }
      Logger.root.info(
        '[Update] Parsed versions. Latest: $latest, Local: $local',
      );

      final needsUpdate = latest.compareTo(local) > 0;
      if (!needsUpdate) {
        Logger.root.info('[Update] App is up to date. No update needed.');
        return;
      }
      Logger.root.info(
        '[Update] Update available! Latest: $latest, Local: $local',
      );

      if (!context.mounted) {
        Logger.root.info(
          '[Update] Context not mounted, cannot show update sheet.',
        );
        return;
      }

      // Delay to ensure UI is ready (if called at startup)
      await Future.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        await showUpdateSheet(context, release);
        Logger.root.info('[Update] Update sheet shown.');
      }
    } catch (e) {
      Logger.root.severe('[Update] Error checking for updates: $e');
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
        String? windowsUpdateUrl;
        if (Platform.isAndroid) {
          androidUpdateUrl = _getAndroidUpdateUrl(release.assets);
        }
        if (Platform.isWindows) {
          windowsUpdateUrl = _getWindowsUpdateUrl();
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
          windowsUpdateUrl: windowsUpdateUrl,
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
      return 'https://fs.solsynth.dev/d/public/r2/solian/${arm64.name}';
    } else if (armeabi != null) {
      return 'https://fs.solsynth.dev/d/public/r2/solian/${armeabi.name}';
    } else if (x86_64 != null) {
      return 'https://fs.solsynth.dev/d/public/r2/solian/${x86_64.name}';
    }
    return null;
  }

  String _getWindowsUpdateUrl() {
    return 'https://fs.solsynth.dev/d/public/r2/solian/build-output-windows-installer.zip';
  }

  /// Performs automatic Windows update: download, extract, and install
  Future<void> performAutomaticWindowsUpdate(
    BuildContext context,
    String url,
  ) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _WindowsUpdateDialog(
        updateUrl: url,
        onComplete: () {
          // Close the update sheet
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Fetch the latest release info from GitHub.
  /// Public so other screens (e.g., About) can manually trigger update checks.
  Future<GithubReleaseInfo?> fetchLatestRelease() async {
    final apiEndpoint = useProxy
        ? '$_proxyBaseUrl${Uri.encodeComponent(_releasesLatestApi)}'
        : _releasesLatestApi;

    Logger.root.info(
      '[Update] Fetching latest release from GitHub API: $apiEndpoint (Proxy: $useProxy)',
    );
    final resp = await _dio.get(apiEndpoint);
    if (resp.statusCode != 200) {
      Logger.root.severe(
        '[Update] Failed to fetch latest release. Status code: ${resp.statusCode}',
      );
      return null;
    }
    final data = resp.data as Map<String, dynamic>;
    Logger.root.info('[Update] Successfully fetched release data.');

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
      Logger.root.severe(
        '[Update] Missing tag_name or html_url in release data. TagName: "$tagName", HtmlUrl: "$htmlUrl"',
      );
      return null;
    }

    Logger.root.info('[Update] Returning GithubReleaseInfo for tag: $tagName');
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

class _WindowsUpdateDialog extends StatefulWidget {
  const _WindowsUpdateDialog({
    required this.updateUrl,
    required this.onComplete,
  });

  final String updateUrl;
  final VoidCallback onComplete;

  @override
  State<_WindowsUpdateDialog> createState() => _WindowsUpdateDialogState();
}

class _WindowsUpdateDialogState extends State<_WindowsUpdateDialog> {
  final ValueNotifier<double?> progressNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<String> messageNotifier = ValueNotifier<String>(
    'Downloading installer...',
  );

  @override
  void initState() {
    super.initState();
    _startUpdate();
  }

  Future<void> _startUpdate() async {
    try {
      // Step 1: Download
      final zipPath = await _downloadWindowsInstaller(
        widget.updateUrl,
        onProgress: (received, total) {
          if (total == -1) {
            progressNotifier.value = null;
          } else {
            progressNotifier.value = received / total;
          }
        },
      );
      if (zipPath == null) {
        _showError('Failed to download installer');
        return;
      }

      // Step 2: Extract
      messageNotifier.value = 'Extracting installer...';
      progressNotifier.value = null; // Indeterminate for extraction

      final extractDir = await _extractWindowsInstaller(zipPath);
      if (extractDir == null) {
        _showError('Failed to extract installer');
        return;
      }

      // Step 3: Run installer
      messageNotifier.value = 'Running installer...';

      final success = await _runWindowsInstaller(extractDir);
      if (!mounted) return;

      if (success) {
        messageNotifier.value = 'Update Complete';
        progressNotifier.value = 1.0;
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
          widget.onComplete();
        }
      } else {
        _showError('Failed to run installer');
      }

      // Cleanup
      try {
        await File(zipPath).delete();
        await Directory(extractDir).delete(recursive: true);
      } catch (e) {
        Logger.root.severe('[Update] Error cleaning up temporary files: $e');
      }
    } catch (e) {
      _showError('Update failed: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Installing Update'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<double?>(
            valueListenable: progressNotifier,
            builder: (context, progress, child) {
              return LinearProgressIndicator(value: progress);
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<String>(
            valueListenable: messageNotifier,
            builder: (context, message, child) {
              return Text(message);
            },
          ),
        ],
      ),
    );
  }

  /// Downloads the Windows installer ZIP file
  Future<String?> _downloadWindowsInstaller(
    String url, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      Logger.root.info(
        '[Update] Starting Windows installer download from: $url',
      );

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'solian-installer-${DateTime.now().millisecondsSinceEpoch}.zip';
      final filePath = path.join(tempDir.path, fileName);

      final response = await Dio().download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            Logger.root.info(
              '[Update] Download progress: ${(received / total * 100).toStringAsFixed(1)}%',
            );
          }
          onProgress?.call(received, total);
        },
      );

      if (response.statusCode == 200) {
        Logger.root.info(
          '[Update] Windows installer downloaded successfully to: $filePath',
        );
        return filePath;
      } else {
        Logger.root.severe(
          '[Update] Failed to download Windows installer. Status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      Logger.root.severe('[Update] Error downloading Windows installer: $e');
      return null;
    }
  }

  /// Extracts the ZIP file to a temporary directory
  Future<String?> _extractWindowsInstaller(String zipPath) async {
    try {
      Logger.root.info('[Update] Extracting Windows installer from: $zipPath');

      final tempDir = await getTemporaryDirectory();
      final extractDir = path.join(
        tempDir.path,
        'solian-installer-${DateTime.now().millisecondsSinceEpoch}',
      );

      final zipFile = File(zipPath);
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final filePath = path.join(extractDir, filename);
          await Directory(path.dirname(filePath)).create(recursive: true);
          await File(filePath).writeAsBytes(data);
        } else {
          final dirPath = path.join(extractDir, filename);
          await Directory(dirPath).create(recursive: true);
        }
      }

      Logger.root.info(
        '[Update] Windows installer extracted successfully to: $extractDir',
      );
      return extractDir;
    } catch (e) {
      Logger.root.severe('[Update] Error extracting Windows installer: $e');
      return null;
    }
  }

  /// Runs the setup.exe file
  Future<bool> _runWindowsInstaller(String extractDir) async {
    try {
      Logger.root.info('[Update] Running Windows installer from: $extractDir');

      final dir = Directory(extractDir);
      final exeFiles = dir
          .listSync()
          .where((f) => f is File && f.path.endsWith('.exe'))
          .toList();

      if (exeFiles.isEmpty) {
        Logger.root.info('[Update] No .exe file found in extracted directory');
        return false;
      }

      final setupExePath = exeFiles.first.path;
      Logger.root.info('[Update] Found installer executable: $setupExePath');

      final shell = Shell();
      final results = await shell.run(setupExePath);
      final result = results.first;

      if (result.exitCode == 0) {
        Logger.root.info('[Update] Windows installer completed successfully');
        return true;
      } else {
        Logger.root.severe(
          '[Update] Windows installer failed with exit code: ${result.exitCode}',
        );
        Logger.root.severe('[Update] Installer output: ${result.stdout}');
        Logger.root.severe('[Update] Installer errors: ${result.stderr}');
        return false;
      }
    } catch (e) {
      Logger.root.severe('[Update] Error running Windows installer: $e');
      return false;
    }
  }
}

class _UpdateSheet extends StatefulWidget {
  const _UpdateSheet({
    required this.release,
    required this.onOpen,
    this.androidUpdateUrl,
    this.windowsUpdateUrl,
    this.useProxy = false,
  });

  final String? androidUpdateUrl;
  final String? windowsUpdateUrl;
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
    String downloadUrl = url;
    if (_useProxy) {
      final fileName = url.split('/').last;
      downloadUrl = 'https://fs.solsynth.dev/d/rainyun02/solian/$fileName';
    }

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
                  content: widget.release.body.isEmpty
                      ? 'noChangelogProvided'.tr()
                      : widget.release.body,
                ),
              ),
            ),
            if (!kIsWeb && Platform.isAndroid)
              SwitchListTile(
                title: Text('useSecondarySourceForDownload'.tr()),
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
                            Logger.root.info(widget.androidUpdateUrl!);
                            _installUpdate(widget.androidUpdateUrl!);
                          },
                          icon: const Icon(Symbols.update),
                          label: Text('installUpdate'.tr()),
                        ),
                      ),
                    if (!kIsWeb &&
                        Platform.isWindows &&
                        widget.windowsUpdateUrl != null)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // Access the UpdateService instance to call the automatic update method
                            final updateService = UpdateService(
                              useProxy: widget.useProxy,
                            );
                            updateService.performAutomaticWindowsUpdate(
                              context,
                              widget.windowsUpdateUrl!,
                            );
                          },
                          icon: const Icon(Symbols.update),
                          label: Text('installUpdate'.tr()),
                        ),
                      ),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: widget.onOpen,
                        icon: const Icon(Icons.open_in_new),
                        label: Text('openReleasePage'.tr()),
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
