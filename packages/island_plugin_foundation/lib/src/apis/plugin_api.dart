import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';

/// Base class for API bridges that expose Dart functionality to JavaScript plugins.
///
/// Host apps register [PluginApi] implementations with [PluginManager] / [PluginController].
/// Each API is gated by [requiredPermissions] and may contribute JS namespace bindings
/// via [jsBindingsFor] so the foundation stays free of host-specific APIs.
abstract class PluginApi {
  /// Permissions required for this API to be available.
  ///
  /// Empty means always available (handlers still decide what they expose).
  /// Non-empty means the plugin must hold **any** of these permissions for the
  /// API to be registered and for its JS bindings to be injected.
  Set<PluginPermission> get requiredPermissions;

  /// Register this API's message handlers into the given plugin runtime.
  void register(JsRuntime runtime);

  /// JavaScript source injected into a plugin when it is granted access to this API.
  ///
  /// Override to provide ergonomic wrappers around `sendMessage(...)` channels.
  /// Return an empty string when nothing should be injected.
  ///
  /// [granted] is the full set of permissions from the plugin manifest so APIs
  /// that span multiple permissions (e.g. internet vs. host API) can inject
  /// only the relevant bindings.
  String jsBindingsFor(Set<PluginPermission> granted) => '';

  /// Called when a plugin is unloaded so the API can drop per-plugin state.
  void onPluginUnload(String pluginId) {}

  /// Reset any static or cached state held by this API (e.g. on full dispose).
  void reset() {}
}
