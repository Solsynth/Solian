import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/plugins/apis/plugin_api.dart';
import 'package:island/plugins/plugin_manager.dart';

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
/// Plugins can intercept and modify data before it reaches the server:
/// - `hooks.before_post_create(handler)` — modify post payload before creation
/// - `hooks.before_message_send(handler)` — modify message content before send
/// - `hooks.before_post_display(handler)` — modify post data before rendering
/// - `hooks.before_message_display(handler)` — modify message before rendering
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
  final List<PluginHookHandler> _handlers = [];

  List<PluginHookHandler> get handlers => List.unmodifiable(_handlers);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.eventsSubscribe};

  @override
  void register(JsRuntime runtime) {
    _activeInstance = this;

    runtime.onMessage('api:hooks:before_post_create', (args) {
      _registerHookFromMessage('before_post_create', args);
    });
    runtime.onMessage('api:hooks:before_message_send', (args) {
      _registerHookFromMessage('before_message_send', args);
    });
    runtime.onMessage('api:hooks:before_post_display', (args) {
      _registerHookFromMessage('before_post_display', args);
    });
    runtime.onMessage('api:hooks:before_message_display', (args) {
      _registerHookFromMessage('before_message_display', args);
    });
  }

  static HooksApi? _activeInstance;

  static void reset() {
    _activeInstance = null;
  }

  void _registerHookFromMessage(String hookName, dynamic args) {
    try {
      final data = args is String ? jsonDecode(args) : args;
      final handlerName = data['handler']?.toString();
      if (handlerName == null) return;

      final pluginId = PluginManager.activePluginId ?? 'unknown';

      _activeInstance?._handlers.add(PluginHookHandler(
        pluginId: pluginId,
        hookName: hookName,
        handlerName: handlerName,
      ));

      _log.info('Plugin $pluginId registered hook: $hookName -> $handlerName');
    } catch (e) {
      _log.warning('Failed to register hook $hookName: $e');
    }
  }

  /// Clear hooks for a specific plugin.
  void clearHooks(String pluginId) {
    _handlers.removeWhere((h) => h.pluginId == pluginId);
  }

  /// Clear all hooks.
  void clearAll() {
    _handlers.clear();
  }
}
