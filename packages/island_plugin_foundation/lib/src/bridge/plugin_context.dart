import 'package:island_plugin_foundation/src/bridge/message_router.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';

class PluginContext {
  final String pluginId;
  final Set<PluginPermission> permissions;
  final MessageRouter router;

  const PluginContext({
    required this.pluginId,
    required this.permissions,
    required this.router,
  });

  bool hasPermission(PluginPermission perm) => permissions.contains(perm);
}
