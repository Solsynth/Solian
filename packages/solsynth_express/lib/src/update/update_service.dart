import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_update/azhon_app_update.dart';
import 'package:flutter_app_update/result_model.dart';
import 'package:flutter_app_update/update_model.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';

import '../api/models.dart';
import '../api/solsynth_express_api.dart';
import '../ui/update_sheet.dart';

const bool kEnableBuiltInUpdate = true;
const kDefaultDistributionApiBaseUrl = 'https://api.solian.app/dist';
const kDefaultDistributionProductId = '5260a14a-97f3-431c-9c2a-b174a4de7d97';

/// High-level update facade for Flutter applications.
class UpdateService {
  UpdateService({
    SolsynthExpressApi? api,
    Dio? dio,
    String? apiBaseUrl,
    String? productId,
    this.channel = 'stable',
    this.enabled = true,
  }) : _api =
           api ??
           SolsynthExpressApi(
             baseUrl:
                 apiBaseUrl ??
                 const String.fromEnvironment(
                   'DISTRIBUTION_API_BASE_URL',
                   defaultValue: kDefaultDistributionApiBaseUrl,
                 ),
             productId:
                 productId ??
                 const String.fromEnvironment(
                   'DISTRIBUTION_PRODUCT_ID',
                   defaultValue: kDefaultDistributionProductId,
                 ),
             dio: dio,
           );

  final SolsynthExpressApi _api;
  final String channel;
  final bool enabled;

  /// Checks for a newer release and presents [UpdateSheet] when one exists.
  Future<void> checkForUpdates(BuildContext context) async {
    if (!enabled || !kEnableBuiltInUpdate || kIsWeb || !_api.isConfigured) {
      return;
    }
    try {
      final info = await PackageInfo.fromPlatform();
      final target = await _currentTarget();
      if (target == null) return;
      final result = await _api.checkForUpdate(
        currentVersion: info.version,
        platform: target.platform,
        architecture: target.architecture,
        channel: channel,
        clientVersion: info.version,
      );
      if (!result.updateAvailable ||
          result.release == null ||
          !context.mounted) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (context.mounted) await showUpdateSheet(context, result.release!);
    } catch (error, stackTrace) {
      Logger.root.severe(
        '[Solsynth Express] Update check failed',
        error,
        stackTrace,
      );
    }
  }

  /// Presents a release without checking the network.
  Future<void> showUpdateSheet(
    BuildContext context,
    DistributionReleaseInfo release,
  ) async {
    if (!context.mounted) return;
    final target = await _currentTarget();
    if (!context.mounted) return;
    final artifact = target == null
        ? null
        : release.artifactFor(target.platform, target.architecture);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => UpdateSheet(
        release: release,
        androidUpdateUrl: target?.platform == 'android'
            ? artifact?.downloadUrl
            : null,
        windowsUpdateUrl: target?.platform == 'windows'
            ? artifact?.downloadUrl
            : null,
        linuxUpdateUrl: target?.platform == 'linux'
            ? artifact?.downloadUrl
            : null,
        onAndroidInstall: artifact == null
            ? null
            : () => installAndroidUpdate(
                artifact.downloadUrl,
                apkName: 'solian-update-${release.tagName}.apk',
              ),
        onWindowsInstall: artifact == null
            ? null
            : () =>
                  performAutomaticWindowsUpdate(context, artifact.downloadUrl),
        onLinuxInstall: artifact == null
            ? null
            : () => performAutomaticLinuxUpdate(context, artifact.downloadUrl),
      ),
    );
  }

  Future<DistributionReleaseInfo?> fetchLatestRelease({
    String? platform,
    String? architecture,
  }) async {
    if (!enabled || !_api.isConfigured) return null;
    return _api.fetchLatestRelease(
      channel: channel,
      platform: platform,
      architecture: architecture,
    );
  }

  Future<List<DistributionChannel>> fetchChannels() {
    if (!_api.isConfigured) return Future.value(const []);
    return _api.listChannels();
  }

  Future<int> cleanupPreviousUpdateArtifacts() async {
    final tempDir = await getTemporaryDirectory();
    var deleted = 0;
    for (final entity in tempDir.listSync(followLinks: false)) {
      final fileName = path.basename(entity.path);
      final removableFile =
          entity is File &&
          ((fileName.startsWith('solian-update-') &&
                  fileName.endsWith('.apk')) ||
              (fileName.startsWith('solian-installer-') &&
                  fileName.endsWith('.zip')) ||
              (fileName.startsWith('solian-linux-') &&
                  (fileName.endsWith('.zip') ||
                      fileName.endsWith('.AppImage'))));
      final removableDirectory =
          entity is Directory &&
          (fileName.startsWith('solian-installer-') ||
              fileName.startsWith('solian-linux-'));
      if (!removableFile && !removableDirectory) continue;
      try {
        await entity.delete(recursive: entity is Directory);
        deleted++;
      } catch (error) {
        Logger.root.warning(
          '[Solsynth Express] Failed to clean $fileName: $error',
        );
      }
    }
    return deleted;
  }

  Future<void> installAndroidUpdate(
    String url, {
    required String apkName,
  }) async {
    if (!Platform.isAndroid) return;
    AzhonAppUpdate.dispose();
    AzhonAppUpdate.listener((ResultModel result) {
      if (result.type == ResultType.done) {
        unawaited(
          Future<void>.delayed(const Duration(seconds: 10), () async {
            await _cleanupFile(result.apk);
          }),
        );
      }
    });
    try {
      await AzhonAppUpdate.update(
        UpdateModel(
          url,
          apkName,
          'launcher_icon',
          'https://apps.apple.com/us/app/solian/id6499032345',
        ),
      );
    } catch (error) {
      AzhonAppUpdate.dispose();
      Logger.root.warning('[Solsynth Express] Android update failed: $error');
      rethrow;
    }
  }

  Future<void> performAutomaticWindowsUpdate(
    BuildContext context,
    String url,
  ) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _InstallProgressDialog(service: this, updateUrl: url, linux: false),
    );
  }

  Future<void> performAutomaticLinuxUpdate(
    BuildContext context,
    String url,
  ) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _InstallProgressDialog(service: this, updateUrl: url, linux: true),
    );
  }

  Future<_UpdateTarget?> _currentTarget() async {
    if (kIsWeb) return null;
    final platform = Platform.isAndroid
        ? 'android'
        : Platform.isWindows
        ? 'windows'
        : Platform.isLinux
        ? 'linux'
        : Platform.isMacOS
        ? 'macos'
        : Platform.isIOS
        ? 'ios'
        : '';
    final architecture = await _currentArchitecture();
    if (platform.isEmpty || architecture.isEmpty) return null;
    return _UpdateTarget(platform, architecture);
  }

  Future<String> _currentArchitecture() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      for (final abi in info.supportedAbis) {
        switch (abi) {
          case 'arm64-v8a':
            return 'arm64';
          case 'armeabi-v7a':
            return 'armeabi-v7a';
          case 'x86_64':
            return 'x86_64';
          case 'x86':
            return 'x86';
        }
      }
    }
    if (Platform.isWindows) {
      final value =
          Platform.environment['PROCESSOR_ARCHITEW6432'] ??
          Platform.environment['PROCESSOR_ARCHITECTURE'];
      if (value != null) {
        return switch (value.toUpperCase()) {
          'AMD64' || 'X86_64' => 'amd64',
          'ARM64' => 'arm64',
          _ => value.toLowerCase(),
        };
      }
    }
    if (Platform.isLinux) return 'amd64';
    if (Platform.isMacOS || Platform.isIOS) return 'arm64';
    return '';
  }

  Future<String?> _download(
    String url,
    String prefix,
    String extension, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(
        tempDir.path,
        '$prefix${DateTime.now().millisecondsSinceEpoch}$extension',
      );
      final response = await Dio().download(
        url,
        filePath,
        onReceiveProgress: onProgress,
      );
      return response.statusCode == 200 ? filePath : null;
    } catch (error, stackTrace) {
      Logger.root.severe(
        '[Solsynth Express] Download failed',
        error,
        stackTrace,
      );
      return null;
    }
  }

  Future<String?> _extractWindows(String zipPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final extractDir = path.join(
        tempDir.path,
        'solian-installer-${DateTime.now().millisecondsSinceEpoch}',
      );
      final archive = ZipDecoder().decodeBytes(
        await File(zipPath).readAsBytes(),
      );
      for (final entry in archive) {
        final filePath = path.join(extractDir, entry.name);
        if (entry.isFile) {
          await Directory(path.dirname(filePath)).create(recursive: true);
          await File(filePath).writeAsBytes(entry.content as List<int>);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }
      return extractDir;
    } catch (error, stackTrace) {
      Logger.root.severe(
        '[Solsynth Express] Windows extraction failed',
        error,
        stackTrace,
      );
      return null;
    }
  }

  Future<bool> _runWindowsInstaller(String extractDir) async {
    try {
      final executable = Directory(extractDir)
          .listSync()
          .whereType<File>()
          .firstWhere((file) => file.path.endsWith('.exe'));
      final results = await Shell().run(executable.path);
      return results.isNotEmpty && results.first.exitCode == 0;
    } catch (error) {
      Logger.root.severe('[Solsynth Express] Windows install failed: $error');
      return false;
    }
  }

  Future<bool> _installLinux(String zipPath) async {
    String? extractDir;
    try {
      final tempDir = await getTemporaryDirectory();
      extractDir = path.join(
        tempDir.path,
        'solian-linux-${DateTime.now().millisecondsSinceEpoch}',
      );
      final archive = ZipDecoder().decodeBytes(
        await File(zipPath).readAsBytes(),
      );
      String? appImage;
      for (final entry in archive) {
        final filePath = path.join(extractDir, entry.name);
        if (entry.isFile) {
          await Directory(path.dirname(filePath)).create(recursive: true);
          await File(filePath).writeAsBytes(entry.content as List<int>);
          if (entry.name.endsWith('.AppImage')) appImage = filePath;
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }
      if (appImage == null) return false;
      await Shell().run('chmod +x "$appImage"');
      final home = Platform.environment['HOME'];
      if (home == null || home.isEmpty) return false;
      final destinationDir = path.join(home, '.local', 'bin');
      await Directory(destinationDir).create(recursive: true);
      await File(appImage).copy(path.join(destinationDir, 'solian.AppImage'));
      return true;
    } catch (error) {
      Logger.root.severe('[Solsynth Express] Linux install failed: $error');
      return false;
    } finally {
      await _cleanupDirectory(extractDir);
    }
  }

  static Future<void> _cleanupFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return;
    try {
      final file = File(filePath);
      if (await file.exists()) await file.delete();
    } catch (error) {
      Logger.root.warning('[Solsynth Express] Failed to delete file: $error');
    }
  }

  static Future<void> _cleanupDirectory(String? dirPath) async {
    if (dirPath == null || dirPath.isEmpty) return;
    try {
      final directory = Directory(dirPath);
      if (await directory.exists()) await directory.delete(recursive: true);
    } catch (error) {
      Logger.root.warning(
        '[Solsynth Express] Failed to delete directory: $error',
      );
    }
  }
}

class _UpdateTarget {
  const _UpdateTarget(this.platform, this.architecture);
  final String platform;
  final String architecture;
}

class _InstallProgressDialog extends StatefulWidget {
  const _InstallProgressDialog({
    required this.service,
    required this.updateUrl,
    required this.linux,
  });

  final UpdateService service;
  final String updateUrl;
  final bool linux;

  @override
  State<_InstallProgressDialog> createState() => _InstallProgressDialogState();
}

class _InstallProgressDialogState extends State<_InstallProgressDialog> {
  double? progress;
  String message = 'Downloading installer...';
  bool finished = false;

  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  Future<void> _run() async {
    String? downloaded;
    String? extracted;
    try {
      downloaded = await widget.service._download(
        widget.updateUrl,
        widget.linux ? 'solian-linux-' : 'solian-installer-',
        widget.linux ? '.zip' : '.zip',
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() => progress = total <= 0 ? null : received / total);
        },
      );
      if (downloaded == null) throw StateError('Download failed');
      if (!mounted) return;
      setState(() {
        message = widget.linux
            ? 'Installing AppImage...'
            : 'Extracting installer...';
        progress = null;
      });
      final success = widget.linux
          ? await widget.service._installLinux(downloaded)
          : await (() async {
              extracted = await widget.service._extractWindows(downloaded!);
              return extracted != null &&
                  await widget.service._runWindowsInstaller(extracted!);
            })();
      if (!mounted) return;
      if (!success) throw StateError('Installation failed');
      setState(() {
        message = 'Update Complete';
        progress = 1;
        finished = true;
      });
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Update Failed'),
          content: Text('$error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      await UpdateService._cleanupFile(downloaded);
      await UpdateService._cleanupDirectory(extracted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Installing Update'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
