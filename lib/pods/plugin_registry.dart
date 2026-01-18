import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/modular/interface.dart';
import 'package:island/modular/registry.dart';
import 'package:island/pods/config.dart';
import 'package:island/talker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plugin_registry.freezed.dart';
part 'plugin_registry.g.dart';

const kMiniAppsRegistryKey = 'mini_apps_registry';
const kMiniAppsLastSyncKey = 'mini_apps_last_sync';
const kRawPluginsRegistryKey = 'raw_plugins_registry';

@freezed
sealed class MiniAppSyncResult with _$MiniAppSyncResult {
  const factory MiniAppSyncResult({
    required bool success,
    List<String>? added,
    List<String>? updated,
    List<String>? removed,
    String? error,
  }) = _MiniAppSyncResult;
}

@Riverpod(keepAlive: true)
class PluginRegistryNotifier extends _$PluginRegistryNotifier {
  late final PluginRegistry _registry;
  late final Dio _dio;

  @override
  PluginRegistry build() {
    _registry = PluginRegistry();
    _dio = Dio();

    ref.onDispose(() {
      _registry.dispose();
    });

    _loadFromPrefs();

    return _registry;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final registryJson = prefs.getString(kMiniAppsRegistryKey);
      if (registryJson != null) {
        final List<dynamic> decoded = jsonDecode(registryJson);
        for (final item in decoded) {
          final metadata = MiniAppMetadata.fromJson(
            item as Map<String, dynamic>,
          );
          if (metadata.isEnabled && metadata.localCachePath != null) {
            await _registry.loadMiniApp(metadata);
          }
        }
      }
      talker.info('[PluginRegistry] Loaded registry from preferences');
    } catch (e, stackTrace) {
      talker.error(
        '[PluginRegistry] Failed to load from preferences',
        e,
        stackTrace,
      );
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final miniAppsData = _registry.miniApps.values
          .map((app) => (app as EvaluatedMiniApp).appMetadata.toJson())
          .toList();
      await prefs.setString(kMiniAppsRegistryKey, jsonEncode(miniAppsData));
      talker.info('[PluginRegistry] Saved registry to preferences');
    } catch (e, stackTrace) {
      talker.error(
        '[PluginRegistry] Failed to save to preferences',
        e,
        stackTrace,
      );
    }
  }

  void registerRawPlugin(RawPlugin plugin) {
    _registry.registerRawPlugin(plugin);
  }

  void unregisterRawPlugin(String id) {
    _registry.unregisterRawPlugin(id);
  }

  Future<MiniAppSyncResult> syncMiniAppsFromServer(String apiEndpoint) async {
    try {
      talker.info(
        '[PluginRegistry] Syncing mini-apps from server: $apiEndpoint',
      );

      final response = await _dio.get(apiEndpoint);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch mini-apps: ${response.statusCode}');
      }

      final List<dynamic> data = response.data['mini_apps'] ?? [];
      final serverApps = data
          .map(
            (item) => MiniAppServerInfo.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      final currentApps = _registry.miniApps;
      final added = <String>[];
      final updated = <String>[];

      for (final serverApp in serverApps) {
        final existingApp = currentApps[serverApp.id];
        if (existingApp == null) {
          added.add(serverApp.id);
          talker.info('[PluginRegistry] Found new mini-app: ${serverApp.name}');
        } else {
          final currentMetadata = (existingApp as EvaluatedMiniApp).appMetadata;
          if (currentMetadata.version != serverApp.version) {
            updated.add(serverApp.id);
            talker.info(
              '[PluginRegistry] Found update for mini-app: ${serverApp.name}',
            );
          }
        }
      }

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(
        kMiniAppsLastSyncKey,
        DateTime.now().toIso8601String(),
      );

      final syncResult = MiniAppSyncResult(
        success: true,
        added: added,
        updated: updated,
      );

      await _saveToPrefs();
      return syncResult;
    } catch (e, stackTrace) {
      talker.error('[PluginRegistry] Failed to sync mini-apps', e, stackTrace);
      return MiniAppSyncResult(success: false, error: e.toString());
    }
  }

  Future<bool> downloadMiniApp(
    String id,
    String downloadUrl, {
    ProgressCallback? onProgress,
  }) async {
    try {
      talker.info(
        '[PluginRegistry] Downloading mini-app: $id from $downloadUrl',
      );

      final cacheDirPath = await _registry.getMiniAppCacheDirectory();
      final cachePath = '$cacheDirPath/${_registry.getMiniAppCachePath(id)}';

      await _dio.download(
        downloadUrl,
        cachePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(
              progress,
              'Downloading... ${((progress * 100).toStringAsFixed(0))}%',
            );
          }
        },
      );

      talker.info('[PluginRegistry] Downloaded mini-app: $id to $cachePath');

      final metadata = MiniAppMetadata(
        id: id,
        name: id,
        version: '1.0.0',
        description: 'Downloaded mini-app',
        downloadUrl: downloadUrl,
        localCachePath: cachePath,
        lastUpdated: DateTime.now(),
        isEnabled: true,
      );

      final result = await _registry.loadMiniApp(
        metadata,
        onProgress: onProgress,
      );

      if (result == PluginLoadResult.success) {
        await _saveToPrefs();
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      talker.error(
        '[PluginRegistry] Failed to download mini-app: $id',
        e,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> updateMiniApp(String id, {ProgressCallback? onProgress}) async {
    try {
      final miniApp = _registry.getMiniApp(id);
      if (miniApp == null) {
        talker.warning('[PluginRegistry] Mini-app not found for update: $id');
        return false;
      }

      final appMetadata = (miniApp as EvaluatedMiniApp).appMetadata;

      _registry.unloadMiniApp(id);

      if (onProgress != null) {
        onProgress(0.0, 'Downloading update...');
      }

      final success = await downloadMiniApp(
        id,
        appMetadata.downloadUrl,
        onProgress: onProgress,
      );

      if (success) {
        talker.info('[PluginRegistry] Successfully updated mini-app: $id');
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      talker.error(
        '[PluginRegistry] Failed to update mini-app: $id',
        e,
        stackTrace,
      );
      return false;
    }
  }

  Future<void> enableMiniApp(String id, bool enabled) async {
    final miniApp = _registry.getMiniApp(id);
    if (miniApp != null) {
      final appMetadata = (miniApp as EvaluatedMiniApp).appMetadata;
      if (enabled && appMetadata.isEnabled == false) {
        await _registry.loadMiniApp(appMetadata.copyWith(isEnabled: true));
      } else if (!enabled && appMetadata.isEnabled == true) {
        _registry.unloadMiniApp(id);
        final updatedMetadata = appMetadata.copyWith(isEnabled: false);
        final evaluatedMiniApp = miniApp as EvaluatedMiniApp;
        final updatedMiniApp = EvaluatedMiniApp(
          appMetadata: updatedMetadata,
          entryFunction: evaluatedMiniApp.entryFunction,
          runtime: evaluatedMiniApp.runtime,
        );
        _registry.miniApps[id] = updatedMiniApp;
      }
      await _saveToPrefs();
    }
  }

  Future<void> deleteMiniApp(String id, {bool deleteCache = true}) async {
    try {
      _registry.unloadMiniApp(id);

      if (deleteCache) {
        final cacheDirPath = await _registry.getMiniAppCacheDirectory();
        final cachePath = '$cacheDirPath/${_registry.getMiniAppCachePath(id)}';
        final file = File(cachePath);
        if (await file.exists()) {
          await file.delete();
          talker.info('[PluginRegistry] Deleted cache for mini-app: $id');
        }
      }

      await _saveToPrefs();
    } catch (e, stackTrace) {
      talker.error(
        '[PluginRegistry] Failed to delete mini-app: $id',
        e,
        stackTrace,
      );
    }
  }

  Future<void> clearMiniAppCache() async {
    await _registry.clearMiniAppCache();
  }

  List<MiniApp> getAvailableMiniApps() {
    return _registry.miniApps.values.toList();
  }

  Map<String, RawPlugin> getAvailableRawPlugins() {
    return _registry.rawPlugins;
  }

  Future<MiniApp?> getMiniApp(String id) async {
    return _registry.getMiniApp(id);
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final lastSyncStr = prefs.getString(kMiniAppsLastSyncKey);
    if (lastSyncStr != null) {
      return DateTime.tryParse(lastSyncStr);
    }
    return null;
  }

  Future<String> getMiniAppCacheDirectory() async {
    return _registry.getMiniAppCacheDirectory();
  }

  Future<bool> loadMiniappFromCache(
    MiniAppMetadata metadata, {
    ProgressCallback? onProgress,
  }) async {
    try {
      final result = await _registry.loadMiniApp(
        metadata,
        onProgress: onProgress,
      );

      if (result == PluginLoadResult.success) {
        await _saveToPrefs();
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      talker.error(
        '[PluginRegistry] Failed to load miniapp from cache',
        e,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> loadMiniappFromUrl(
    String url, {
    ProgressCallback? onProgress,
  }) async {
    try {
      final appId = generateAppIdFromUrl(url);
      final cacheDirPath = await _registry.getMiniAppCacheDirectory();
      final cachePath = '$cacheDirPath/${_registry.getMiniAppCachePath(appId)}';

      await _dio.download(
        url,
        cachePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(
              progress,
              'Downloading... ${((progress * 100).toStringAsFixed(0))}%',
            );
          }
        },
      );

      talker.info('[PluginRegistry] Downloaded mini-app: $appId to $cachePath');

      final metadata = MiniAppMetadata(
        id: appId,
        name: appId,
        version: '1.0.0',
        description: 'Loaded from URL',
        downloadUrl: url,
        localCachePath: cachePath,
        lastUpdated: DateTime.now(),
        isEnabled: true,
      );

      final result = await _registry.loadMiniApp(
        metadata,
        onProgress: onProgress,
      );

      if (result == PluginLoadResult.success) {
        await _saveToPrefs();
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      talker.error(
        '[PluginRegistry] Failed to load miniapp from URL',
        e,
        stackTrace,
      );
      return false;
    }
  }

  String generateAppIdFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return 'dev_miniapp_${DateTime.now().millisecondsSinceEpoch}';
    }
    final path = uri.pathSegments.lastWhere(
      (s) => s.isNotEmpty,
      orElse: () => 'miniapp',
    );
    final baseName = path
        .replaceAll('.evc', '')
        .replaceAll(RegExp(r'[^\w-]'), '_');
    return 'dev_$baseName';
  }
}

final miniAppsProvider = Provider.autoDispose((ref) {
  final registry = ref.watch(pluginRegistryProvider);
  return registry.miniApps.values.toList();
});

final rawPluginsProvider = Provider.autoDispose((ref) {
  final registry = ref.watch(pluginRegistryProvider);
  return registry.rawPlugins;
});

typedef ProgressCallback = void Function(double progress, String message);
