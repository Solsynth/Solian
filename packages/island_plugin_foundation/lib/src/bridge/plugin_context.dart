import 'dart:convert';

import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:logging/logging.dart';

final _log = Logger('PluginContext');

/// Per-plugin identity handed to every [PluginApi.register] call.
///
/// Carries the plugin's id and granted permissions so API handlers never have
/// to consult a global "active plugin" — that singleton was wrong whenever a
/// handler fired outside the plugin-load window (timers, callbacks, WebSocket
/// dispatch).
class PluginContext {
  final String pluginId;
  final Set<PluginPermission> permissions;

  const PluginContext({
    required this.pluginId,
    required this.permissions,
  });

  bool hasPermission(PluginPermission perm) => permissions.contains(perm);

  /// Normalize a raw message from the JS bridge into a string-keyed map.
  ///
  /// The bridge delivers either a JSON string (from `JSON.stringify`) or an
  /// already-parsed object, so handlers used to each repeat
  /// `args is String ? jsonDecode(args) : args` plus key stringification.
  /// Malformed input is logged and yields `{}` so handlers can no-op safely.
  Map<String, dynamic> decode(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    if (raw is String) {
      try {
        final d = jsonDecode(raw);
        if (d is Map<String, dynamic>) return d;
        if (d is Map) return d.map((k, v) => MapEntry(k.toString(), v));
        _log.warning('Plugin $pluginId message is not a JSON object: $raw');
      } catch (_) {
        _log.warning('Plugin $pluginId message is not valid JSON: $raw');
      }
      return {};
    }
    _log.warning(
      'Plugin $pluginId message has unexpected type: ${raw.runtimeType}',
    );
    return {};
  }
}
