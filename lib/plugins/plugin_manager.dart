import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/plugins/apis/plugin_api.dart';
import 'package:island/plugins/apis/hooks_api.dart';
import 'package:island/plugins/apis/commands_api.dart';
import 'package:island/plugins/apis/events_api.dart';
import 'package:island/plugins/background_runner.dart';

final _log = Logger('PluginManager');

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
class PluginManager {
  static final PluginManager _instance = PluginManager._();
  factory PluginManager() => _instance;
  PluginManager._();

  final JsBridge _bridge = JsBridge.instance;
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

  /// Load bundled JavaScript scripts from assets/scripts/.
  Future<void> _loadBundledScripts() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      final scripts = allAssets
          .where((a) => a.startsWith('assets/scripts/') && a.endsWith('.js'))
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
      // Create a dedicated JS runtime for this plugin
      final runtimeName = 'plugin:$pluginId';
      instance.runtime = _bridge.createRuntime(runtimeName);

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
      _activePluginId = pluginId;
      final result = instance.runtime!.execWithOutput(
        source,
        filename: entryPath,
      );
      _activePluginId = null;

      if (!result.success) {
        instance.state = PluginState.error;
        instance.lastError = result.error ?? 'Unknown error';
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

    // Dispose the JS runtime
    instance.runtime?.dispose();
    instance.runtime = null;
    instance.state = PluginState.discovered;
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

  /// Re-discover plugins from all sources and load them.
  /// Returns the number of newly discovered plugins.
  Future<int> reload() async {
    final before = Set<String>.of(_plugins.keys);
    _initialized = false;
    await initialize();
    await loadAll();
    final added = _plugins.keys.where((id) => !before.contains(id)).length;
    _log.info('Reloaded plugins: ${_plugins.length} total, $added new');
    return added;
  }

  /// Install a plugin from an arbitrary local folder path.
  /// Validates that the folder contains a manifest.json.
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

  /// Install a plugin from an inline JavaScript source string.
  /// Creates a temporary plugin with a generated ID.
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

    // Create runtime and register APIs
    final runtimeName = 'plugin:$pluginId';
    instance.runtime = _bridge.createRuntime(runtimeName);
    _registerPluginApis(instance);

    // Execute inline source
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

    return instance;
  }

  /// Register API bridges into a plugin's runtime based on its permissions.
  void _registerPluginApis(PluginInstance instance) {
    final runtime = instance.runtime;
    if (runtime == null) return;
    final perms = instance.manifest.permissions.toSet();

    // Set the active plugin ID so API callbacks can identify the plugin
    _activePluginId = instance.manifest.id;

    for (final entry in _apis.entries) {
      final api = entry.value;

      // Check if this API requires any permission
      if (api.requiredPermissions.isEmpty ||
          api.requiredPermissions.any(perms.contains)) {
        api.register(runtime);
      }
    }

    // Create namespace objects so JS code can call e.g. commands.register_command()
    _createApiNamespaces(instance);

    // Register the plugin's own metadata
    _registerPluginMetadata(instance);

    _activePluginId = null;
  }

  /// Create JavaScript namespace objects for each registered API.
  /// After this, plugin code can use `commands.register_command(...)` etc.
  void _createApiNamespaces(PluginInstance instance) {
    final runtime = instance.runtime;
    if (runtime == null) return;

    // Build JS code that creates namespace objects with wrapper functions.
    // sendMessage channels are the bridge; this creates ergonomic JS wrappers.
    final buf = StringBuffer();

    buf.writeln('var hooks = {};');
    buf.writeln('hooks.before_post_create = function(handler) {');
    buf.writeln('  sendMessage("api:hooks:before_post_create", JSON.stringify({handler: handler.name || handler.toString()}));');
    buf.writeln('};');
    buf.writeln('hooks.before_message_send = function(handler) {');
    buf.writeln('  sendMessage("api:hooks:before_message_send", JSON.stringify({handler: handler.name || handler.toString()}));');
    buf.writeln('};');
    buf.writeln('hooks.before_post_display = function(handler) {');
    buf.writeln('  sendMessage("api:hooks:before_post_display", JSON.stringify({handler: handler.name || handler.toString()}));');
    buf.writeln('};');
    buf.writeln('hooks.before_message_display = function(handler) {');
    buf.writeln('  sendMessage("api:hooks:before_message_display", JSON.stringify({handler: handler.name || handler.toString()}));');
    buf.writeln('};');

    buf.writeln('var commands = {};');
    buf.writeln('commands.register_command = function(name, description, handler, icon) {');
    buf.writeln('  sendMessage("api:commands:register_command", JSON.stringify({name: name, description: description, handler: handler, icon: icon || null}));');
    buf.writeln('};');

    buf.writeln('var events = {};');
    buf.writeln('events.subscribe = function(eventName, handler) {');
    buf.writeln('  sendMessage("api:events:subscribe", JSON.stringify({event: eventName, handler: handler}));');
    buf.writeln('};');
    buf.writeln('events.list_events = function() {');
    buf.writeln('  return sendMessage("api:events:list_events", "[]");');
    buf.writeln('};');

    buf.writeln('function notify(title, body) {');
    buf.writeln('  sendMessage("api:notify", JSON.stringify({title: title, body: body}));');
    buf.writeln('}');

    buf.writeln('var ui = {};');
    buf.writeln('ui.card = function(title, body, actions) {');
    buf.writeln('  var result = sendMessage("api:ui:card", JSON.stringify({title: title, body: body, actions: actions || []}));');
    buf.writeln('  return result;');
    buf.writeln('};');
    buf.writeln('ui.list_items = function(items) {');
    buf.writeln('  return sendMessage("api:ui:list_items", JSON.stringify({items: items}));');
    buf.writeln('};');
    buf.writeln('ui.button = function(label, callback) {');
    buf.writeln('  return sendMessage("api:ui:button", JSON.stringify({label: label, callback: callback || null}));');
    buf.writeln('};');
    buf.writeln('ui.text = function(content) {');
    buf.writeln('  return sendMessage("api:ui:text", JSON.stringify({content: content}));');
    buf.writeln('};');
    buf.writeln('ui.section = function(title, children) {');
    buf.writeln('  return sendMessage("api:ui:section", JSON.stringify({title: title, children: children || []}));');
    buf.writeln('};');
    buf.writeln('ui.divider = function() {');
    buf.writeln('  return sendMessage("api:ui:divider", "{}");');
    buf.writeln('};');

    buf.writeln('var tasks = {};');
    buf.writeln('tasks.schedule = function(intervalSeconds, handler) {');
    buf.writeln('  sendMessage("api:tasks:schedule", JSON.stringify({interval: intervalSeconds, handler: handler}));');
    buf.writeln('};');

    final code = buf.toString();
    final ok = runtime.exec(code, filename: '<api_namespaces>');
    if (!ok) {
      _log.warning('Failed to create API namespaces');
    }
  }

  /// Register plugin metadata as read-only globals in the runtime.
  void _registerPluginMetadata(PluginInstance instance) {
    final runtime = instance.runtime;
    if (runtime == null) return;

    runtime.setGlobal('__plugin_id__', instance.manifest.id);
  }

  /// Call a named hook function in a plugin's runtime, if it exists.
  void _callPluginHook(PluginInstance instance, String hookName) {
    final runtime = instance.runtime;
    if (runtime == null) return;

    // Use bracket notation so names with dots (e.g. "on_message.received") work.
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
      if (!instance.manifest.permissions.contains(PluginPermission.eventsSubscribe)) {
        continue;
      }

      // Fire lifecycle hook (e.g. on_message.received)
      _callPluginHook(instance, 'on_$eventName');

      if (data != null) {
        // Call handle_<event> with data argument — use bracket notation for dotted names
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

  /// Escape a string for use as a JavaScript string literal.
  String _jsStringLiteral(String s) {
    return "'${s.replaceAll("\\", "\\\\").replaceAll("'", "\\'").replaceAll("\n", "\\n").replaceAll("\r", "\\r")}'";
  }

  /// Dispose all plugins and clean up resources.
  void dispose() {
    for (final id in _plugins.keys.toList()) {
      unloadPlugin(id);
    }
    _plugins.clear();
    _apis.clear();
    _initialized = false;
    _inlineCounter = 0;
    _activePluginId = null;

    // Clear static state on API classes
    HooksApi.reset();
    CommandsApi.reset();
    EventsApi.reset();
    BackgroundTaskApi.reset();

    // Dispose all JS runtimes
    _bridge.disposeAll();

    _log.info('PluginManager disposed');
  }
}
