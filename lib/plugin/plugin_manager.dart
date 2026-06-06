import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pocketpy/pocketpy.dart';
import 'package:pocketpy/pocketpy_bindings_generated.dart';

import 'package:island/plugin/bridge/py_bridge.dart';
import 'package:island/plugin/models/plugin_manifest.dart';
import 'package:island/plugin/apis/plugin_api.dart';

final _log = Logger('PluginManager');

/// Runtime state of a loaded plugin.
class PluginInstance {
  final PluginManifest manifest;
  final String directoryPath;
  PluginState state;
  Pointer<py_TValue>? module;
  String? lastError;

  PluginInstance({
    required this.manifest,
    required this.directoryPath,
    this.state = PluginState.discovered,
    this.module,
    this.lastError,
  });
}

/// Manages plugin discovery, loading, lifecycle, and sandbox enforcement.
class PluginManager {
  static final PluginManager _instance = PluginManager._();
  factory PluginManager() => _instance;
  PluginManager._();

  final PyBridge _py = PyBridge.instance;
  final Map<String, PluginInstance> _plugins = {};
  final Map<String, PluginApi> _apis = {};
  bool _initialized = false;
  int _inlineCounter = 0;

  /// The plugin ID of the currently loading plugin (set during registration).
  /// Used by API callbacks to identify which plugin is registering.
  String? _activePluginId;

  /// Get the currently active plugin ID (public accessor for API callbacks).
  static String? get activePluginId => _instance._activePluginId;

  /// All loaded plugin instances.
  Map<String, PluginInstance> get plugins => Map.unmodifiable(_plugins);

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

  /// Initialize the plugin manager and load all plugins.
  Future<void> initialize() async {
    if (_initialized) return;

    _py.initialize();

    // Register built-in APIs
    // (External code should call registerApi() before initialize(), or after)

    // Discover and load plugins from all sources
    await _discoverPlugins();

    _initialized = true;
    _log.info('Plugin manager initialized with ${_plugins.length} plugins');
  }

  /// Discover plugins from local filesystem and bundled assets.
  Future<void> _discoverPlugins() async {
    // 1. Load from app plugins directory
    if (!kIsWeb) {
      try {
        final appDir = await getApplicationSupportDirectory();
        final pluginsDir = Directory(path.join(appDir.path, 'plugins'));
        if (await pluginsDir.exists()) {
          await _discoverFromDirectory(pluginsDir);
        }
      } catch (e) {
        _log.warning('Failed to scan app plugins directory: $e');
      }
    }

    // 2. Load bundled init scripts from assets
    try {
      await _loadBundledScripts();
    } catch (e) {
      _log.warning('Failed to load bundled scripts: $e');
    }
  }

  /// Scan a directory for plugin subdirectories containing manifest.json.
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

  /// Load bundled Python scripts from assets/scripts/.
  Future<void> _loadBundledScripts() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      final scripts = allAssets
          .where((a) => a.startsWith('assets/scripts/') && a.endsWith('.py'))
          .toList()
        ..sort();

      for (final assetPath in scripts) {
        final content = await rootBundle.loadString(assetPath);
        _py.exec(content, filename: assetPath);
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
      // Create a dedicated module for this plugin
      final moduleName = 'plugin_${pluginId.replaceAll('.', '_')}';
      instance.module = _py.newModule(moduleName);

      // Register sandboxed APIs based on permissions
      _registerPluginApis(instance);

      // Execute the plugin entry point
      final entryPath = path.join(instance.directoryPath, instance.manifest.entry);
      final entryFile = File(entryPath);
      if (!await entryFile.exists()) {
        instance.state = PluginState.error;
        instance.lastError = 'Entry file not found: ${instance.manifest.entry}';
        _log.warning('Plugin entry not found: $entryPath');
        return false;
      }

      final source = await entryFile.readAsString();
      final ok = _py.exec(source, filename: entryPath, module: instance.module);

      if (!ok) {
        instance.state = PluginState.error;
        instance.lastError = _py.formatException() ?? 'Unknown error';
        _log.warning('Plugin failed to load: $pluginId - ${instance.lastError}');
        return false;
      }

      // Call on_load() if defined
      _callPluginHook(instance, 'on_load');

      instance.state = PluginState.active;
      _log.info('Plugin activated: $pluginId');
      return true;
    } catch (e) {
      instance.state = PluginState.error;
      instance.lastError = e.toString();
      _log.severe('Failed to load plugin $pluginId: $e');
      return false;
    }
  }

  /// Unload a plugin.
  void unloadPlugin(String pluginId) {
    final instance = _plugins[pluginId];
    if (instance == null) return;

    try {
      _callPluginHook(instance, 'on_unload');
    } catch (_) {}

    instance.state = PluginState.discovered;
    instance.module = null;
    instance.lastError = null;
    _log.info('Plugin unloaded: $pluginId');
  }

  /// Disable a plugin (prevents loading until re-enabled).
  void disablePlugin(String pluginId) {
    final instance = _plugins[pluginId];
    if (instance == null) return;

    unloadPlugin(pluginId);
    instance.state = PluginState.disabled;
  }

  /// Enable a previously disabled plugin.
  void enablePlugin(String pluginId) {
    final instance = _plugins[pluginId];
    if (instance == null) return;
    if (instance.state != PluginState.disabled) return;

    instance.state = PluginState.discovered;
  }

  /// Load all discovered plugins.
  Future<void> loadAll() async {
    for (final id in _plugins.keys.toList()) {
      await loadPlugin(id);
    }
  }

  /// Install a plugin from a directory (copies to plugins dir).
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

      // Check if already installed
      if (_plugins.containsKey(manifest.id)) {
        _log.info('Plugin already installed: ${manifest.id}');
        return false;
      }

      // Copy to plugins directory
      final appDir = await getApplicationSupportDirectory();
      final destDir = Directory(
        path.join(appDir.path, 'plugins', manifest.id),
      );

      if (await destDir.exists()) {
        await destDir.delete(recursive: true);
      }
      await destDir.create(recursive: true);

      await for (final entity in sourceDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: sourceDirPath);
          final destFile = File(path.join(destDir.path, relativePath));
          await destFile.parent.create(recursive: true);
          await entity.copy(destFile.path);
        }
      }

      // Register the plugin
      _plugins[manifest.id] = PluginInstance(
        manifest: manifest,
        directoryPath: destDir.path,
        state: PluginState.discovered,
      );

      _log.info('Installed plugin: ${manifest.id}');
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
    _log.info('Uninstalled plugin: $pluginId');
  }

  /// Install a plugin from an inline Python source string.
  /// Creates a temporary plugin with a generated ID.
  PluginInstance installInlinePlugin({
    required String name,
    required String source,
    String? id,
    List<PluginPermission> permissions = const [],
  }) {
    final baseId = id ?? 'inline.${name.toLowerCase().replaceAll(' ', '_')}';
    // Use a counter suffix to avoid module name collisions on re-run
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

    // Create module and register APIs
    final moduleName = 'plugin_${pluginId.replaceAll('.', '_')}';
    instance.module = _py.newModule(moduleName);
    _registerPluginApis(instance);

    // Execute inline source
    final ok = _py.exec(source, filename: '<inline:$pluginId>', module: instance.module);
    if (ok) {
      _callPluginHook(instance, 'on_load');
      instance.state = PluginState.active;
      _log.info('Inline plugin activated: $pluginId');
    } else {
      instance.state = PluginState.error;
      instance.lastError = _py.formatException() ?? 'Unknown error';
      _log.warning('Inline plugin failed: $pluginId - ${instance.lastError}');
    }

    return instance;
  }

  /// Register API bridges into a plugin's module based on its permissions.
  void _registerPluginApis(PluginInstance instance) {
    if (instance.module == null) return;
    final perms = instance.manifest.permissions.toSet();

    // Set the active plugin ID so API callbacks can identify the plugin
    _activePluginId = instance.manifest.id;

    for (final entry in _apis.entries) {
      final api = entry.value;

      // Check if this API requires any permission
      if (api.requiredPermissions.isEmpty ||
          api.requiredPermissions.any(perms.contains)) {
        api.register(instance.module!, _py);
      }
    }

    // Create namespace objects so Python code can call e.g. commands.register_command()
    _createApiNamespaces(instance);

    // Always register the plugin's own metadata
    _registerPluginMetadata(instance);

    _activePluginId = null;
  }

  /// Create Python namespace objects for each registered API.
  /// After this, plugin code can use `commands.register_command(...)` etc.
  void _createApiNamespaces(PluginInstance instance) {
    if (instance.module == null) return;

    // Known function mappings: namespace -> [function_names]
    // These match what each API's register() method binds to the module.
    // Only APIs with sub-functions need namespace objects.
    // APIs that bind top-level functions (like `notify`) are skipped.
    final apiFunctions = <String, List<String>>{
      'hooks': [
        'before_post_create',
        'before_message_send',
        'before_post_display',
        'before_message_display',
      ],
      'events': ['subscribe', 'list_events'],
      'commands': ['register_command'],
      'ui': ['card', 'list_items', 'button', 'text', 'section', 'divider'],
    };

    final namespaces = apiFunctions.keys
        .where((ns) => _apis.containsKey(ns))
        .toList();
    if (namespaces.isEmpty) return;

    final buf = StringBuffer();
    buf.writeln('class _NS:');
    buf.writeln('  pass');

    for (final ns in namespaces) {
      buf.writeln('$ns = _NS()');
    }

    for (final ns in namespaces) {
      for (final fn in apiFunctions[ns]!) {
        buf.writeln('try: $ns.$fn = $fn');
        buf.writeln('except: pass');
      }
    }

    final code = buf.toString();
    _py.exec(code, filename: '<api_namespaces>', module: instance.module);
  }

  /// Register plugin metadata as read-only globals in the module.
  void _registerPluginMetadata(PluginInstance instance) {
    if (instance.module == null) return;

    // Set __plugin_id__ in the plugin's module (not __main__)
    final idOut = _py.pushTmp();
    _py.newStr(idOut, instance.manifest.id);
    final nameId = _py.name('__plugin_id__');
    pocket.py_setdict(instance.module!, nameId, idOut);
    _py.pop();
  }

  /// Call a named hook function in a plugin's module, if it exists.
  void _callPluginHook(PluginInstance instance, String hookName) {
    if (instance.module == null) return;

    // Look for the function in the plugin's module, not __main__
    final nameId = _py.name(hookName);
    final funcRef = pocket.py_getdict(instance.module!, nameId);
    if (funcRef == nullptr) return;

    // Check if it's callable
    final type = pocket.py_typeof(funcRef);
    if (type != py_PredefinedType.tp_function &&
        type != py_PredefinedType.tp_nativefunc) {
      return;
    }

    // Call it
    final ok = pocket.py_call(funcRef, 0, nullptr);
    if (!ok) {
      _log.warning(
        'Plugin ${instance.manifest.id} hook $hookName failed: '
        '${_py.formatException() ?? "unknown error"}',
      );
    }
  }

  /// Fire an event to all active plugins that have events permission.
  void fireEvent(String eventName, [Map<String, dynamic>? data]) {
    for (final instance in _plugins.values) {
      if (instance.state != PluginState.active) continue;
      if (!instance.manifest.permissions.contains(PluginPermission.eventsSubscribe)) {
        continue;
      }

      _callPluginHook(instance, 'on_$eventName');
      if (data != null) {
        // Call with data argument
        final handlerName = 'handle_$eventName';
        final funcRef = _py.getGlobal(handlerName);
        if (funcRef != null) {
          final dataOut = _py.pushTmp();
          _py.fromDart(dataOut, data);
          pocket.py_call(funcRef, 1, dataOut);
          _py.pop();
        }
      }
    }
  }

  /// Dispose all plugins and clean up resources.
  void dispose() {
    for (final id in _plugins.keys.toList()) {
      unloadPlugin(id);
    }
    _plugins.clear();
    _apis.clear();
    _initialized = false;
  }
}
