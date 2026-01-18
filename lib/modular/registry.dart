import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:island/modular/interface.dart';
import 'package:island/talker.dart';

typedef ProgressCallback = void Function(double progress, String message);

dynamic flutterEvalPlugin;

class Runtime {
  final ByteData bytecode;

  Runtime(this.bytecode);

  void addPlugin(dynamic plugin) {}

  dynamic executeLib(String package, String function) {
    return null;
  }

  void dispose() {}
}

class PluginRegistry {
  final Map<String, RawPlugin> _rawPlugins = {};
  final Map<String, MiniApp> _miniApps = {};

  Map<String, RawPlugin> get rawPlugins => Map.unmodifiable(_rawPlugins);
  Map<String, MiniApp> get miniApps => Map.unmodifiable(_miniApps);

  void registerRawPlugin(RawPlugin plugin) {
    _rawPlugins[plugin.metadata.id] = plugin;
    talker.info(
      '[PluginRegistry] Registered raw plugin: ${plugin.metadata.id}',
    );
  }

  void unregisterRawPlugin(String id) {
    _rawPlugins.remove(id);
    talker.info('[PluginRegistry] Unregistered raw plugin: $id');
  }

  RawPlugin? getRawPlugin(String id) {
    return _rawPlugins[id];
  }

  Future<PluginLoadResult> loadMiniApp(
    MiniAppMetadata metadata, {
    ProgressCallback? onProgress,
  }) async {
    if (_miniApps.containsKey(metadata.id)) {
      return PluginLoadResult.alreadyLoaded;
    }

    try {
      talker.info('[PluginRegistry] Loading mini-app: ${metadata.id}');

      if (metadata.localCachePath == null) {
        talker.warning(
          '[PluginRegistry] Mini-app has no cache path: ${metadata.id}',
        );
        return PluginLoadResult.failed;
      }

      final file = File(metadata.localCachePath!);
      if (!await file.exists()) {
        talker.warning(
          '[PluginRegistry] Mini-app cache file not found: ${metadata.localCachePath}',
        );
        return PluginLoadResult.failed;
      }

      final bytecode = await file.readAsBytes();

      if (onProgress != null) {
        onProgress(0.5, 'Initializing runtime...');
      }

      final runtime = Runtime(ByteData.sublistView(bytecode));
      runtime.addPlugin(flutterEvalPlugin);

      if (onProgress != null) {
        onProgress(0.8, 'Building entry widget...');
      }

      final entryFunction = runtime.executeLib(
        'package:mini_app/main.dart',
        'buildEntry',
      );

      if (entryFunction == null) {
        talker.error(
          '[PluginRegistry] Failed to get entry function for mini-app: ${metadata.id}',
        );
        return PluginLoadResult.failed;
      }

      final miniApp = EvaluatedMiniApp(
        appMetadata: metadata,
        entryFunction: entryFunction,
        runtime: runtime,
      );

      _miniApps[metadata.id] = miniApp;

      if (onProgress != null) {
        onProgress(1.0, 'Loaded successfully');
      }

      talker.info(
        '[PluginRegistry] Successfully loaded mini-app: ${metadata.id}',
      );
      return PluginLoadResult.success;
    } catch (e, stackTrace) {
      talker.error(
        '[PluginRegistry] Failed to load mini-app: ${metadata.id}',
        e,
        stackTrace,
      );
      return PluginLoadResult.failed;
    }
  }

  void unloadMiniApp(String id) {
    final miniApp = _miniApps[id];
    if (miniApp != null) {
      if (miniApp is EvaluatedMiniApp) {
        miniApp.runtime.dispose();
      }
      _miniApps.remove(id);
      talker.info('[PluginRegistry] Unloaded mini-app: $id');
    }
  }

  MiniApp? getMiniApp(String id) {
    return _miniApps[id];
  }

  Future<String> getMiniAppCacheDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDocDir.path}/mini_apps');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  String getMiniAppCachePath(String id) {
    return '$id.evc';
  }

  Future<void> clearMiniAppCache() async {
    final cacheDirPath = await getMiniAppCacheDirectory();
    final cacheDir = Directory(cacheDirPath);
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create(recursive: true);
      talker.info('[PluginRegistry] Cleared mini-app cache');
    }
  }

  void dispose() {
    for (final miniApp in _miniApps.values) {
      if (miniApp is EvaluatedMiniApp) {
        miniApp.runtime.dispose();
      }
    }
    _miniApps.clear();
    _rawPlugins.clear();
    talker.info('[PluginRegistry] Disposed');
  }
}

class EvaluatedMiniApp extends MiniApp {
  final MiniAppMetadata appMetadata;
  final dynamic entryFunction;
  final Runtime runtime;

  EvaluatedMiniApp({
    required this.appMetadata,
    required this.entryFunction,
    required this.runtime,
  });

  @override
  PluginMetadata get metadata => appMetadata as PluginMetadata;

  @override
  Widget buildEntry() {
    try {
      final result = entryFunction();
      if (result is Widget) {
        return result;
      }
      talker.warning(
        '[MiniApp] Entry function did not return a Widget: $result',
      );
      return const SizedBox.shrink();
    } catch (e, stackTrace) {
      talker.error('[MiniApp] Failed to build entry widget', e, stackTrace);
      return const SizedBox.shrink();
    }
  }
}
