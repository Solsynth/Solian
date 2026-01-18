import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:island/modular/interface.dart';
import 'package:island/pods/plugin_registry.dart';
import 'package:island/talker.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/dart_miniapp_display.dart';
import 'package:island/widgets/miniapp_modal.dart';

typedef ProgressCallback = void Function(double progress, String message);

final flutterEvalPlugin = FlutterEvalPlugin();

class MiniappLoader {
  static Future<void> loadMiniappFromSource(
    BuildContext context,
    WidgetRef ref, {
    ProgressCallback? onProgress,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['dart', 'evc'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      final fileName = file.name;

      if (fileName.endsWith('.dart')) {
        await _loadDartSource(context, file, fileName);
      } else if (fileName.endsWith('.evc')) {
        await _loadBytecodeFile(context, ref, file, fileName, onProgress);
      } else {
        showErrorAlert('Unsupported file type. Please use .dart or .evc files');
      }
    } catch (e, stackTrace) {
      talker.error('[MiniappLoader] Failed to load from source', e, stackTrace);
      showErrorAlert('Failed to load miniapp: $e');
    }
  }

  static Future<void> _loadDartSource(
    BuildContext context,
    PlatformFile file,
    String fileName,
  ) async {
    try {
      final sourceCode = file.bytes;

      if (sourceCode == null) {
        showErrorAlert('Unable to read file contents');
        return;
      }

      final package = _generatePackageName(fileName);

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (modalContext) {
          return DartMiniappDisplay(
            package: package,
            sourceCode: String.fromCharCodes(sourceCode),
          );
        },
      );
    } catch (e, stackTrace) {
      talker.error('[MiniappLoader] Failed to load dart source', e, stackTrace);
      showErrorAlert('Failed to load miniapp: $e');
    }
  }

  static Future<void> _loadBytecodeFile(
    BuildContext context,
    WidgetRef ref,
    PlatformFile file,
    String fileName,
    ProgressCallback? onProgress,
  ) async {
    try {
      final bytecode = file.bytes;

      if (bytecode == null) {
        showErrorAlert('Unable to read file contents');
        return;
      }

      if (onProgress != null) {
        onProgress(0.3, 'Saving bytecode...');
      }

      final registryNotifier = ref.read(pluginRegistryProvider.notifier);
      final cacheDirPath = await registryNotifier.getMiniAppCacheDirectory();
      final appId = _generateAppId(fileName);
      final cachePath = '$cacheDirPath/$appId.evc';

      final cacheFile = File(cachePath);
      await cacheFile.writeAsBytes(bytecode);

      if (onProgress != null) {
        onProgress(0.5, 'Loading miniapp...');
      }

      final metadata = MiniAppMetadata(
        id: appId,
        name: appId,
        version: '0.0.1-dev',
        description: 'Loaded from file: $fileName',
        downloadUrl: '',
        localCachePath: cachePath,
        lastUpdated: DateTime.now(),
        isEnabled: true,
      );

      final success = await registryNotifier.loadMiniappFromCache(
        metadata,
        onProgress: onProgress,
      );

      if (success && context.mounted) {
        if (onProgress != null) {
          onProgress(1.0, 'Loaded successfully');
        }
        showInfoAlert('Miniapp loaded successfully from file', 'Load Complete');
        await showMiniappModal(context, ref, appId);
      } else {
        showErrorAlert('Failed to load miniapp');
      }
    } catch (e, stackTrace) {
      talker.error(
        '[MiniappLoader] Failed to load bytecode file',
        e,
        stackTrace,
      );
      showErrorAlert('Failed to load miniapp: $e');
    }
  }

  static Future<void> loadMiniappFromUrl(
    BuildContext context,
    WidgetRef ref,
    String url, {
    ProgressCallback? onProgress,
  }) async {
    try {
      if (onProgress != null) {
        onProgress(0.1, 'Downloading from URL...');
      }

      final registryNotifier = ref.read(pluginRegistryProvider.notifier);
      final success = await registryNotifier.loadMiniappFromUrl(
        url,
        onProgress: onProgress,
      );

      if (success) {
        if (onProgress != null) {
          onProgress(1.0, 'Loaded successfully');
        }
        showInfoAlert('Miniapp loaded successfully from URL', 'Load Complete');

        if (context.mounted) {
          final appId = registryNotifier.generateAppIdFromUrl(url);
          await showMiniappModal(context, ref, appId);
        }
      } else {
        showErrorAlert('Failed to load miniapp');
      }
    } catch (e, stackTrace) {
      talker.error('[MiniappLoader] Failed to load from URL', e, stackTrace);
      showErrorAlert('Failed to load miniapp: $e');
    }
  }

  static String _generateAppId(String fileName) {
    final baseName = fileName
        .replaceAll('.dart', '')
        .replaceAll('.evc', '')
        .replaceAll(RegExp(r'[^\w-]'), '_');
    return 'dev_${baseName}_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String _generatePackageName(String fileName) {
    final baseName = fileName
        .replaceAll('.dart', '')
        .replaceAll(RegExp(r'[^\w-]'), '_');
    return 'dev_${baseName}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
