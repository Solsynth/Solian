import 'package:flutter/foundation.dart';
import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:island_plugin_foundation/src/plugin_manager.dart';

/// Central, listenable façade over [PluginManager] for host UI and state.
///
/// Use this as the single entry point from Flutter widgets / Riverpod:
///
/// ```dart
/// final controller = PluginController.instance;
/// controller.addListener(() => setState(() {}));
/// await controller.initialize();
/// controller.registerApi('hooks', HooksApi());
/// ```
///
/// Domain-specific APIs (dashboard, Solar Network, notify, …) stay in the host
/// app and are registered here — the foundation never imports them.
class PluginController extends ChangeNotifier {
  static PluginController? _instance;

  /// Shared process-wide controller (wraps the shared [PluginManager]).
  static PluginController get instance =>
      _instance ??= PluginController._(PluginManager());

  /// Create a controller bound to an existing [PluginManager].
  ///
  /// Prefer [instance] unless testing with a custom manager.
  factory PluginController([PluginManager? manager]) {
    if (manager == null || identical(manager, PluginManager())) {
      return instance;
    }
    return PluginController._(manager);
  }

  PluginController._(this.manager) {
    manager.addListener(_onManagerChanged);
  }

  /// Underlying lifecycle manager.
  final PluginManager manager;

  void _onManagerChanged() => notifyListeners();

  // ── Read-only state ──────────────────────────────────────────────────────

  /// Snapshot of all known plugins.
  Map<String, PluginInstance> get plugins => manager.plugins;

  /// Plugins as a list (convenient for UI).
  List<PluginInstance> get pluginList => manager.plugins.values.toList();

  /// Active plugins only.
  List<PluginInstance> get activePlugins => pluginList
      .where((p) => p.state == PluginState.active)
      .toList(growable: false);

  bool get isInitialized => manager.isInitialized;

  /// Currently loading plugin ID (for API registration callbacks).
  String? get activePluginId => PluginManager.activePluginId;

  // ── API registry ─────────────────────────────────────────────────────────

  /// Register a host or foundation API under [namespace].
  void registerApi(String namespace, PluginApi api) {
    manager.registerApi(namespace, api);
  }

  /// Lookup a registered API by concrete type.
  T? getApi<T extends PluginApi>() => manager.getApi<T>();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> initialize() => manager.initialize();

  Future<bool> loadPlugin(String pluginId) => manager.loadPlugin(pluginId);

  void unloadPlugin(String pluginId) => manager.unloadPlugin(pluginId);

  void disablePlugin(String pluginId) => manager.disablePlugin(pluginId);

  Future<void> enablePlugin(String pluginId) => manager.enablePlugin(pluginId);

  Future<void> loadAll() => manager.loadAll();

  Future<void> loadAllAtStartup() => manager.loadAllAtStartup();

  Future<int> reload() => manager.reload();

  Future<bool> installFromFolder(String folderPath) =>
      manager.installFromFolder(folderPath);

  Future<bool> installPlugin(String sourceDirPath) =>
      manager.installPlugin(sourceDirPath);

  Future<void> uninstallPlugin(String pluginId) =>
      manager.uninstallPlugin(pluginId);

  PluginInstance installInlinePlugin({
    required String name,
    required String source,
    String? id,
    List<PluginPermission> permissions = const [],
  }) {
    return manager.installInlinePlugin(
      name: name,
      source: source,
      id: id,
      permissions: permissions,
    );
  }

  String? resolvePluginAsset(String pluginId, String relativePath) =>
      manager.resolvePluginAsset(pluginId, relativePath);

  void fireEvent(String eventName, [Map<String, dynamic>? data]) =>
      manager.fireEvent(eventName, data);

  /// Tear down plugins and APIs. Detaches this controller from the manager.
  @override
  void dispose() {
    manager.removeListener(_onManagerChanged);
    manager.dispose();
    if (identical(_instance, this)) {
      _instance = null;
    }
    super.dispose();
  }

  /// Reset the shared singleton (for hot restart / tests).
  static void resetInstance() {
    final current = _instance;
    if (current != null) {
      current.manager.removeListener(current._onManagerChanged);
      _instance = null;
    }
  }
}
