import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';

/// Base class for API bridges that expose Dart functionality to JavaScript plugins.
///
/// Each API registers message handlers into a plugin's runtime, gated by permissions.
abstract class PluginApi {
  /// Permissions required for this API to be available.
  /// Empty means always available.
  Set<PluginPermission> get requiredPermissions;

  /// Register this API's message handlers into the given plugin runtime.
  void register(JsRuntime runtime);
}
