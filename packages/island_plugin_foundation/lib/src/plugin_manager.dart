import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('PluginManager');

const _kPluginStartupPendingKey = 'plugins_startup_pending_loads';
const _kPluginStartupDisabledKey = 'plugins_startup_disabled';

/// Runtime state of a loaded plugin.
class PluginInstance {
  final PluginManifest manifest;
  final String directoryPath;
  PluginState state;
  JsRuntime? runtime;
  String? lastError;

  PluginInstance({
    required this.manifest,
    required this.directoryPath,
    this.state = PluginState.discovered,
    this.runtime,
    this.lastError,
  });
}

/// Manages plugin discovery, loading, lifecycle, and sandbox enforcement.
///
/// Host apps register domain-specific [PluginApi]s (dashboard, network, notify,
/// …) via [registerApi]. Prefer [PluginController] for UI-facing state.
class PluginManager {
  static final PluginManager _instance = PluginManager._();
  factory PluginManager() => _instance;
  PluginManager._();

  final JsBridge _bridge = JsBridge.instance;
  final Map<String, PluginInstance> _plugins = {};
  final Map<String, PluginApi> _apis = {};
  final List<void Function()> _listeners = [];
  bool _initialized = false;
  int _inlineCounter = 0;

  /// Optional asset prefix for bundled scripts (default: `assets/scripts/`).
  String bundledScriptsPrefix = 'assets/scripts/';

  /// Optional subdirectory name under the app support dir (default: `plugins`).
  String pluginsDirectoryName = 'plugins';

  /// The plugin ID of the currently loading plugin (set during registration).
  String? _activePluginId;

  /// Get the currently active plugin ID (public accessor for API callbacks).
  static String? get activePluginId => _instance._activePluginId;

  /// All loaded plugin instances.
  Map<String, PluginInstance> get plugins => Map.unmodifiable(_plugins);

  /// Whether [initialize] has completed.
  bool get isInitialized => _initialized;

  /// Registered API namespaces.
  Map<String, PluginApi> get apis => Map.unmodifiable(_apis);

  /// Subscribe to plugin state changes (load/unload/enable/disable/install).
  void addListener(void Function() listener) => _listeners.add(listener);

  /// Remove a previously added listener.
  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      try {
        listener();
      } catch (e) {
        _log.warning('PluginManager listener failed: $e');
      }
    }
  }

  /// Register an API bridge that plugins can access based on permissions.
  void registerApi(String namespace, PluginApi api) {
    _apis[namespace] = api;
    _log.info('Registered API: $namespace');
  }

  /// Get a registered API by type. Returns null if not found.
  T? getApi<T extends PluginApi>() {
    for (final api in _apis.values) {
      if (api is T) return api;
    }
    return null;
  }

  /// Resolve a plugin-owned relative asset without allowing directory escape.
  String? resolvePluginAsset(String pluginId, String relativePath) {
    final instance = _plugins[pluginId];
    if (instance == null || instance.directoryPath.isEmpty) return null;
    try {
      final root = Directory(instance.directoryPath).resolveSymbolicLinksSync();
      final file = File(path.join(root, relativePath));
      if (!file.existsSync()) return null;
      final candidate = file.resolveSymbolicLinksSync();
      final normalizedRoot = root.endsWith(path.separator)
          ? root
          : '$root${path.separator}';
      if (!candidate.startsWith(normalizedRoot)) return null;
      return candidate;
    } catch (_) {
      return null;
    }
  }

  /// Initialize the plugin manager and discover plugins (does not load them).
  Future<void> initialize() async {
    if (_initialized) return;

    await _discoverPlugins();
    await _restoreStartupSafeguards();

    _initialized = true;
    _log.info('Plugin manager initialized with ${_plugins.length} plugins');
    _notifyListeners();
  }

  Future<void> _discoverPlugins() async {
    if (!kIsWeb) {
      try {
        final appDir = await getApplicationSupportDirectory();
        final pluginsDir = Directory(
          path.join(appDir.path, pluginsDirectoryName),
        );
        if (await pluginsDir.exists()) {
          await _discoverFromDirectory(pluginsDir);
        }
      } catch (e) {
        _log.warning('Failed to scan app plugins directory: $e');
      }
    }

    try {
      await _loadBundledScripts();
    } catch (e) {
      _log.warning('Failed to load bundled scripts: $e');
    }
  }

  Future<void> _discoverFromDirectory(Directory dir) async {
    await for (final entity in dir.list()) {
      if (entity is! Directory) continue;
      final manifestFile = File(path.join(entity.path, 'manifest.json'));
      if (!await manifestFile.exists()) continue;

      try {
        final json = jsonDecode(await manifestFile.readAsString());
        final manifest = PluginManifest.fromJson(json as Map<String, dynamic>);
        _plugins[manifest.id] = PluginInstance(
          manifest: manifest,
          directoryPath: entity.path,
          state: PluginState.discovered,
        );
        _log.info('Discovered plugin: ${manifest.id} (${manifest.name})');
      } catch (e) {
        _log.warning('Failed to parse manifest at ${entity.path}: $e');
      }
    }
  }

  Future<void> _restoreStartupSafeguards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending =
          prefs.getStringList(_kPluginStartupPendingKey) ?? const [];
      final disabled =
          prefs.getStringList(_kPluginStartupDisabledKey) ?? const [];
      final quarantined = {...pending, ...disabled};

      for (final pluginId in quarantined) {
        final instance = _plugins[pluginId];
        if (instance == null) continue;
        instance.state = PluginState.disabled;
        instance.lastError = pending.contains(pluginId)
            ? 'Disabled after its previous startup load was interrupted.'
            : 'Disabled by the plugin startup safeguard.';
      }

      if (pending.isNotEmpty) {
        await prefs.setStringList(
          _kPluginStartupDisabledKey,
          quarantined.toList(),
        );
        await prefs.remove(_kPluginStartupPendingKey);
        _log.warning(
          'Skipped ${pending.length} plugin(s) after interrupted startup load',
        );
      }
    } catch (e) {
      _log.warning('Failed to restore plugin startup safeguards: $e');
    }
  }

  Future<void> _markPluginLoadPending(String pluginId) async {
    final prefs = await SharedPreferences.getInstance();
    final pending =
        prefs.getStringList(_kPluginStartupPendingKey) ?? <String>[];
    if (!pending.contains(pluginId)) {
      pending.add(pluginId);
      await prefs.setStringList(_kPluginStartupPendingKey, pending);
    }
  }

  Future<void> _clearPluginLoadPending(String pluginId) async {
    final prefs = await SharedPreferences.getInstance();
    final pending =
        prefs.getStringList(_kPluginStartupPendingKey) ?? <String>[];
    if (pending.remove(pluginId)) {
      await prefs.setStringList(_kPluginStartupPendingKey, pending);
    }
  }

  Future<void> _quarantinePlugin(PluginInstance instance, String error) async {
    unloadPlugin(instance.manifest.id);
    instance.state = PluginState.disabled;
    instance.lastError = 'Disabled after a failed load: $error';
    _log.severe('Quarantined plugin ${instance.manifest.id}: $error');

    try {
      final prefs = await SharedPreferences.getInstance();
      final pending =
          prefs.getStringList(_kPluginStartupPendingKey) ?? <String>[];
      pending.remove(instance.manifest.id);
      await prefs.setStringList(_kPluginStartupPendingKey, pending);

      final disabled =
          prefs.getStringList(_kPluginStartupDisabledKey) ?? <String>[];
      if (!disabled.contains(instance.manifest.id)) {
        disabled.add(instance.manifest.id);
        await prefs.setStringList(_kPluginStartupDisabledKey, disabled);
      }
    } catch (e) {
      _log.warning('Failed to persist plugin quarantine: $e');
    }
    _notifyListeners();
  }

  Future<void> _removeStartupDisabled(String pluginId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final disabled =
          prefs.getStringList(_kPluginStartupDisabledKey) ?? <String>[];
      if (disabled.remove(pluginId)) {
        await prefs.setStringList(_kPluginStartupDisabledKey, disabled);
      }
      await _clearPluginLoadPending(pluginId);
    } catch (e) {
      _log.warning('Failed to re-enable plugin $pluginId: $e');
    }
  }

  /// Load bundled JavaScript scripts from [bundledScriptsPrefix].
  Future<void> _loadBundledScripts() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      final scripts =
          allAssets
              .where(
                (a) => a.startsWith(bundledScriptsPrefix) && a.endsWith('.js'),
              )
              .toList()
            ..sort();

      for (final assetPath in scripts) {
        final content = await rootBundle.loadString(assetPath);
        final runtimeName = 'bundled:${assetPath.split('/').last}';
        final runtime = _bridge.createRuntime(runtimeName);
        runtime.exec(content, filename: assetPath);
        _log.info('Executed bundled script: $assetPath');
      }
    } catch (e) {
      _log.warning('Failed to load bundled scripts: $e');
    }
  }

  /// Load and activate a specific plugin by ID.
  Future<bool> loadPlugin(String pluginId) async {
    final instance = _plugins[pluginId];
    if (instance == null) {
      _log.warning('Plugin not found: $pluginId');
      return false;
    }

    if (instance.state == PluginState.active) return true;
    if (instance.state == PluginState.disabled) {
      _log.info('Plugin is disabled: $pluginId');
      return false;
    }

    try {
      await _markPluginLoadPending(pluginId);

      final runtimeName = 'plugin:$pluginId';
      instance.runtime = _bridge.createRuntime(runtimeName);

      _registerPluginApis(instance);

      final entryPath = path.join(
        instance.directoryPath,
        instance.manifest.entry,
      );
      final entryFile = File(entryPath);
      if (!await entryFile.exists()) {
        await _quarantinePlugin(
          instance,
          'Entry file not found: ${instance.manifest.entry}',
        );
        return false;
      }

      final source = await entryFile.readAsString();
      _activePluginId = pluginId;
      final result = instance.runtime!.execWithOutput(
        source,
        filename: entryPath,
      );
      _activePluginId = null;

      if (!result.success) {
        await _quarantinePlugin(instance, result.error ?? 'Unknown error');
        return false;
      }

      _callPluginHook(instance, 'on_load');

      instance.state = PluginState.active;
      await _clearPluginLoadPending(pluginId);
      _log.info('Plugin activated: $pluginId');
      _notifyListeners();
      return true;
    } catch (e) {
      await _quarantinePlugin(instance, e.toString());
      return false;
    } finally {
      _activePluginId = null;
    }
  }

  /// Unload a plugin.
  void unloadPlugin(String pluginId) {
    final instance = _plugins[pluginId];
    if (instance == null) return;

    try {
      _callPluginHook(instance, 'on_unload');
    } catch (_) {}

    for (final api in _apis.values) {
      api.onPluginUnload(pluginId);
    }

    _bridge.disposeRuntime('plugin:$pluginId');
    instance.runtime = null;
    instance.state = PluginState.discovered;
    instance.lastError = null;
    _log.info('Plugin unloaded: $pluginId');
    _notifyListeners();
  }

  /// Disable a plugin (prevents loading until re-enabled).
  void disablePlugin(String pluginId) {
    final instance = _plugins[pluginId];
    if (instance == null) return;

    unloadPlugin(pluginId);
    instance.state = PluginState.disabled;
    _notifyListeners();
  }

  /// Re-enable a plugin that was disabled manually or by the startup safeguard.
  Future<void> enablePlugin(String pluginId) async {
    final instance = _plugins[pluginId];
    if (instance == null) return;
    if (instance.state != PluginState.disabled) return;

    instance.state = PluginState.discovered;
    instance.lastError = null;
    await _removeStartupDisabled(pluginId);
    _notifyListeners();
  }

  /// Load all discovered plugins.
  Future<void> loadAll() async {
    for (final id in _plugins.keys.toList()) {
      await loadPlugin(id);
    }
  }

  /// Load plugins during the startup splash with crash recovery enabled.
  Future<void> loadAllAtStartup() async {
    await initialize();
    await loadAll();
  }

  /// Re-discover plugins from all sources and load them.
  /// Returns the number of newly discovered plugins.
  Future<int> reload() async {
    for (final id in _plugins.keys.toList()) {
      unloadPlugin(id);
    }
    _plugins.clear();
    _initialized = false;

    await initialize();
    await loadAll();
    _log.info('Reloaded plugins: ${_plugins.length} total');
    _notifyListeners();
    return _plugins.length;
  }

  /// Absolute path of the on-disk plugins directory
  /// (`{appSupport}/plugins`). Creates it if missing.
  Future<String> resolvePluginsDirectoryPath() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(path.join(appDir.path, pluginsDirectoryName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// Install a plugin from an arbitrary local folder path.
  ///
  /// Always **copies** the folder into [resolvePluginsDirectoryPath] under the
  /// plugin id so the source can be removed afterward.
  Future<bool> installFromFolder(String folderPath) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) {
      _log.warning('Folder does not exist: $folderPath');
      return false;
    }
    final manifestFile = File(path.join(folderPath, 'manifest.json'));
    if (!await manifestFile.exists()) {
      _log.warning('No manifest.json in $folderPath');
      return false;
    }
    return installPlugin(folderPath);
  }

  /// Install a plugin from a directory (copies into the app plugins dir).
  Future<bool> installPlugin(String sourceDirPath) async {
    if (kIsWeb) return false;

    try {
      final sourceDir = Directory(sourceDirPath);
      final manifestFile = File(path.join(sourceDirPath, 'manifest.json'));
      if (!await manifestFile.exists()) {
        _log.warning('No manifest.json found in $sourceDirPath');
        return false;
      }

      final json = jsonDecode(await manifestFile.readAsString());
      final manifest = PluginManifest.fromJson(json as Map<String, dynamic>);

      final appDir = await getApplicationSupportDirectory();
      final destDir = Directory(
        path.join(appDir.path, pluginsDirectoryName, manifest.id),
      );

      // Normalize paths so we can detect "already installed here".
      String normalize(String p) =>
          path.normalize(Directory(p).absolute.path);

      final sourceAbs = normalize(sourceDirPath);
      final destAbs = normalize(destDir.path);
      final alreadyInPlace = sourceAbs == destAbs;

      if (_plugins.containsKey(manifest.id) || await destDir.exists()) {
        if (!alreadyInPlace) {
          _log.info('Plugin already installed, replacing: ${manifest.id}');
          await uninstallPlugin(manifest.id);
        } else {
          // Same folder — just unload so we can re-register without deleting.
          unloadPlugin(manifest.id);
          _plugins.remove(manifest.id);
        }
      }

      if (!alreadyInPlace) {
        if (await destDir.exists()) {
          await destDir.delete(recursive: true);
        }
        await destDir.create(recursive: true);

        await for (final entity in sourceDir.list(recursive: true)) {
          if (entity is File) {
            final relativePath =
                path.relative(entity.path, from: sourceDirPath);
            final destFile = File(path.join(destDir.path, relativePath));
            await destFile.parent.create(recursive: true);
            await entity.copy(destFile.path);
          }
        }
      }

      _plugins[manifest.id] = PluginInstance(
        manifest: manifest,
        directoryPath: destDir.path,
        state: PluginState.discovered,
      );

      _log.info(
        alreadyInPlace
            ? 'Registered plugin already in place: ${manifest.id}'
            : 'Installed plugin (copied): ${manifest.id} → ${destDir.path}',
      );
      _notifyListeners();
      return true;
    } catch (e) {
      _log.severe('Failed to install plugin: $e');
      return false;
    }
  }

  /// Uninstall a plugin (removes from disk).
  Future<void> uninstallPlugin(String pluginId) async {
    unloadPlugin(pluginId);

    final instance = _plugins[pluginId];
    if (instance == null) return;

    try {
      final dir = Directory(instance.directoryPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      _log.warning('Failed to delete plugin directory: $e');
    }

    _plugins.remove(pluginId);
    await _removeStartupDisabled(pluginId);
    _log.info('Uninstalled plugin: $pluginId');
    _notifyListeners();
  }

  /// Install a plugin from an inline JavaScript source string.
  PluginInstance installInlinePlugin({
    required String name,
    required String source,
    String? id,
    List<PluginPermission> permissions = const [],
  }) {
    final baseId = id ?? 'inline.${name.toLowerCase().replaceAll(' ', '_')}';
    _inlineCounter++;
    final pluginId = '$baseId.$_inlineCounter';

    final instance = PluginInstance(
      manifest: PluginManifest(
        id: pluginId,
        name: name,
        permissions: permissions,
      ),
      directoryPath: '',
      state: PluginState.discovered,
    );
    _plugins[pluginId] = instance;

    final runtimeName = 'plugin:$pluginId';
    instance.runtime = _bridge.createRuntime(runtimeName);
    _registerPluginApis(instance);

    _activePluginId = pluginId;
    final result = instance.runtime!.execWithOutput(
      source,
      filename: '<inline:$pluginId>',
    );
    _activePluginId = null;

    if (result.success) {
      _callPluginHook(instance, 'on_load');
      instance.state = PluginState.active;
      _log.info('Inline plugin activated: $pluginId');
    } else {
      instance.state = PluginState.error;
      instance.lastError = result.error ?? 'Unknown error';
      _log.severe('Inline plugin failed: $pluginId - ${instance.lastError}');
    }

    _notifyListeners();
    return instance;
  }

  /// Register API bridges into a plugin's runtime based on its permissions.
  void _registerPluginApis(PluginInstance instance) {
    final runtime = instance.runtime;
    if (runtime == null) return;
    final perms = instance.manifest.permissions.toSet();

    _activePluginId = instance.manifest.id;

    for (final entry in _apis.entries) {
      final api = entry.value;

      if (api.requiredPermissions.isEmpty ||
          api.requiredPermissions.any(perms.contains)) {
        api.register(runtime);
      }
    }

    _createApiNamespaces(instance, perms);
    _registerPluginMetadata(instance);

    _activePluginId = null;
  }

  /// Create JavaScript namespace objects from each registered API's bindings.
  void _createApiNamespaces(
    PluginInstance instance,
    Set<PluginPermission> perms,
  ) {
    final runtime = instance.runtime;
    if (runtime == null) return;

    final buf = StringBuffer();
    for (final api in _apis.values) {
      if (api.requiredPermissions.isEmpty ||
          api.requiredPermissions.any(perms.contains)) {
        buf.write(api.jsBindingsFor(perms));
      }
    }

    final code = buf.toString();
    if (code.isEmpty) return;

    final ok = runtime.exec(code, filename: '<api_namespaces>');
    if (!ok) {
      _log.warning('Failed to create API namespaces');
    }
  }

  void _registerPluginMetadata(PluginInstance instance) {
    final runtime = instance.runtime;
    if (runtime == null) return;

    runtime.setGlobal('__plugin_id__', instance.manifest.id);
  }

  void _callPluginHook(PluginInstance instance, String hookName) {
    final runtime = instance.runtime;
    if (runtime == null) return;

    final escaped = _jsStringLiteral(hookName);
    runtime.exec(
      'if (typeof globalThis[$escaped] === "function") { globalThis[$escaped](); }',
      filename: '<hook:$hookName>',
    );
  }

  /// Fire an event to all active plugins that have events permission.
  void fireEvent(String eventName, [Map<String, dynamic>? data]) {
    for (final instance in _plugins.values) {
      if (instance.state != PluginState.active) continue;
      if (!instance.manifest.permissions.contains(
        PluginPermission.eventsSubscribe,
      )) {
        continue;
      }

      _callPluginHook(instance, 'on_$eventName');

      if (data != null) {
        final handlerName = 'handle_$eventName';
        final runtime = instance.runtime;
        if (runtime != null) {
          final dataJson = jsonEncode(data);
          final escaped = _jsStringLiteral(handlerName);
          runtime.exec(
            'if (typeof globalThis[$escaped] === "function") { globalThis[$escaped](JSON.parse(${_jsStringLiteral(dataJson)})); }',
            filename: '<event:$eventName>',
          );
        }
      }
    }
  }

  String _jsStringLiteral(String s) {
    return "'${s.replaceAll("\\", "\\\\").replaceAll("'", "\\'").replaceAll("\n", "\\n").replaceAll("\r", "\\r")}'";
  }

  /// Dispose all plugins and clean up resources.
  void dispose() {
    for (final id in _plugins.keys.toList()) {
      unloadPlugin(id);
    }
    _plugins.clear();
    for (final api in _apis.values) {
      api.reset();
    }
    _apis.clear();
    _initialized = false;
    _inlineCounter = 0;
    _activePluginId = null;

    _bridge.disposeAll();

    _log.info('PluginManager disposed');
    _notifyListeners();
  }
}
