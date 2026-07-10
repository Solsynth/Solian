import 'dart:convert';

import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:island_plugin_foundation/src/plugin_manager.dart';
import 'package:logging/logging.dart';

final _log = Logger('EventsApi');

/// Describes a registered event handler from a plugin.
class PluginEventHandler {
  final String pluginId;
  final String eventName;
  final String handlerName;

  const PluginEventHandler({
    required this.pluginId,
    required this.eventName,
    required this.handlerName,
  });
}

/// Exposes event subscription to JavaScript plugins.
///
/// Provides:
/// - `events.subscribe(event_name, handler_name)` — register a handler
/// - `events.list_events()` — list available events
///
/// Host apps can customize [availableEvents] (defaults cover common social app
/// events; hosts may pass their own list).
class EventsApi extends PluginApi {
  EventsApi({List<String>? availableEvents})
    : availableEvents =
          availableEvents ??
          const [
            'post.created',
            'post.updated',
            'post.deleted',
            'message.received',
            'message.updated',
            'message.deleted',
            'chat.typing',
            'app.foreground',
            'app.background',
          ];

  /// Event names advertised by `events.list_events()`.
  final List<String> availableEvents;

  final List<PluginEventHandler> _handlers = [];

  /// All registered event handlers across plugins.
  List<PluginEventHandler> get handlers => List.unmodifiable(_handlers);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.eventsSubscribe};

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    if (!granted.contains(PluginPermission.eventsSubscribe)) return '';
    return '''
var events = {};
events.subscribe = function(eventName, handler) {
  sendMessage("api:events:subscribe", JSON.stringify({event: eventName, handler: handler}));
};
events.list_events = function() {
  return sendMessage("api:events:list_events", "[]");
};
''';
  }

  @override
  void register(JsRuntime runtime) {
    runtime.onMessage('api:events:subscribe', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final eventName = data['event']?.toString();
        final handlerName = data['handler']?.toString();

        if (eventName == null || handlerName == null) return;

        final pluginId = PluginManager.activePluginId ?? 'unknown';

        _handlers.add(
          PluginEventHandler(
            pluginId: pluginId,
            eventName: eventName,
            handlerName: handlerName,
          ),
        );

        _log.info('Plugin $pluginId subscribed to $eventName -> $handlerName');
      } catch (e) {
        _log.warning('Failed to subscribe to event: $e');
      }
    });

    runtime.onMessage('api:events:list_events', (args) {
      return jsonEncode(availableEvents);
    });
  }

  @override
  void onPluginUnload(String pluginId) {
    clearHandlers(pluginId);
  }

  /// Clear handlers for a specific plugin.
  void clearHandlers(String pluginId) {
    _handlers.removeWhere((h) => h.pluginId == pluginId);
  }

  /// Clear all handlers.
  void clearAll() {
    _handlers.clear();
  }

  @override
  void reset() {
    clearAll();
  }
}
