import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/bridge/plugin_context.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';

abstract class PluginApi {
  Set<PluginPermission> get requiredPermissions;

  String? jsBindingsFor(Set<PluginPermission> granted) => null;

  void register(PluginContext context, JsRuntime runtime);

  void onPluginUnload(String pluginId) {}

  void reset() {}
}
