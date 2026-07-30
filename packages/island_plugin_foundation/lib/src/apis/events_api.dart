import 'dart:convert';

import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/bridge/plugin_context.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:logging/logging.dart';

final _log = Logger('EventsApi');

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

  final List<String> availableEvents;
  final List<PluginEventHandler> _handlers = [];

  List<PluginEventHandler> get handlers => List.unmodifiable(_handlers);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.eventsSubscribe};

  @override
  void register(PluginContext context, JsRuntime runtime) {
    runtime.exec('''
var events = {};
events.subscribe = function(eventName, handler) {
  sendMessage("api:events:subscribe", JSON.stringify({event: eventName, handler: handler}));
};
events.list_events = function() {
  return sendMessage("api:events:list_events", "[]");
};
''');
    runtime.onMessage('api:events:subscribe', (raw) {
      try {
        final data = context.router.decode(raw);
        final eventName = data['event']?.toString();
        final handlerName = data['handler']?.toString();
        if (eventName == null || handlerName == null) return;

        _handlers.add(PluginEventHandler(
          pluginId: context.pluginId,
          eventName: eventName,
          handlerName: handlerName,
        ));
        _log.info('Plugin ${context.pluginId} subscribed to $eventName -> $handlerName');
      } catch (e) {
        _log.warning('Failed to subscribe to event: $e');
      }
    });

    runtime.onMessage('api:events:list_events', (raw) {
      return jsonEncode(availableEvents);
    });
  }

  @override
  void onPluginUnload(String pluginId) {
    _handlers.removeWhere((h) => h.pluginId == pluginId);
  }

  @override
  void reset() {
    _handlers.clear();
  }
}
