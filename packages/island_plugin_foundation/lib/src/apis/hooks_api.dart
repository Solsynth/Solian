import 'dart:convert';

import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:island_plugin_foundation/src/plugin_manager.dart';
import 'package:logging/logging.dart';

final _log = Logger('HooksApi');

/// A registered hook handler from a plugin.
class PluginHookHandler {
  final String pluginId;
  final String hookName;
  final String handlerName;

  const PluginHookHandler({
    required this.pluginId,
    required this.hookName,
    required this.handlerName,
  });
}

/// Exposes content-transforming hooks to JavaScript plugins.
///
/// Default hook names cover common social-app intercept points. Hosts can pass
/// a custom [hookNames] list; each becomes `hooks.<name>(handler)`.
///
/// Handler signature in JavaScript:
/// ```javascript
/// function myHandler(data) {
///     data.content = data.content.toUpperCase();
///     return data;
/// }
/// ```
///
/// Return `null` from a handler to cancel the operation entirely.
class HooksApi extends PluginApi {
  HooksApi({List<String>? hookNames})
    : hookNames =
          hookNames ??
          const [
            'before_post_create',
            'before_message_send',
            'before_post_display',
            'before_message_display',
          ];

  /// Hook channel names exposed to plugins.
  final List<String> hookNames;

  final List<PluginHookHandler> _handlers = [];

  List<PluginHookHandler> get handlers => List.unmodifiable(_handlers);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.eventsSubscribe};

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    if (!granted.contains(PluginPermission.eventsSubscribe)) return '';
    final buf = StringBuffer('var hooks = {};\n');
    for (final name in hookNames) {
      buf.writeln('hooks.$name = function(handler) {');
      buf.writeln(
        '  sendMessage("api:hooks:$name", JSON.stringify({handler: handler.name || handler.toString()}));',
      );
      buf.writeln('};');
    }
    return buf.toString();
  }

  @override
  void register(JsRuntime runtime) {
    for (final name in hookNames) {
      runtime.onMessage('api:hooks:$name', (args) {
        _registerHookFromMessage(name, args);
      });
    }
  }

  void _registerHookFromMessage(String hookName, dynamic args) {
    try {
      final data = args is String ? jsonDecode(args) : args;
      final handlerName = data['handler']?.toString();
      if (handlerName == null) return;

      final pluginId = PluginManager.activePluginId ?? 'unknown';

      _handlers.add(
        PluginHookHandler(
          pluginId: pluginId,
          hookName: hookName,
          handlerName: handlerName,
        ),
      );

      _log.info('Plugin $pluginId registered hook: $hookName -> $handlerName');
    } catch (e) {
      _log.warning('Failed to register hook $hookName: $e');
    }
  }

  @override
  void onPluginUnload(String pluginId) {
    clearHooks(pluginId);
  }

  /// Clear hooks for a specific plugin.
  void clearHooks(String pluginId) {
    _handlers.removeWhere((h) => h.pluginId == pluginId);
  }

  /// Clear all hooks.
  void clearAll() {
    _handlers.clear();
  }

  @override
  void reset() {
    clearAll();
  }
}
