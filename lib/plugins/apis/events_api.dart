import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/plugins/apis/plugin_api.dart';
import 'package:island/plugins/plugin_manager.dart';

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
/// - `events.subscribe(event_name, handler_name)` - register a handler
/// - `events.list()` - list available events
class EventsApi extends PluginApi {
  final List<PluginEventHandler> _handlers = [];

  /// All registered event handlers across plugins.
  List<PluginEventHandler> get handlers => List.unmodifiable(_handlers);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.eventsSubscribe};

  @override
  void register(JsRuntime runtime) {
    _activeInstance = this;

    runtime.onMessage('api:events:subscribe', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final eventName = data['event']?.toString();
        final handlerName = data['handler']?.toString();

        if (eventName == null || handlerName == null) return;

        final pluginId = PluginManager.activePluginId ?? 'unknown';

        _activeInstance?._handlers.add(PluginEventHandler(
          pluginId: pluginId,
          eventName: eventName,
          handlerName: handlerName,
        ));

        _log.info('Plugin $pluginId subscribed to $eventName -> $handlerName');
      } catch (e) {
        _log.warning('Failed to subscribe to event: $e');
      }
    });

    runtime.onMessage('api:events:list_events', (args) {
      return jsonEncode([
        'post.created',
        'post.updated',
        'post.deleted',
        'message.received',
        'message.updated',
        'message.deleted',
        'chat.typing',
        'app.foreground',
        'app.background',
      ]);
    });
  }

  static EventsApi? _activeInstance;

  static void reset() {
    _activeInstance = null;
  }

  /// Clear handlers for a specific plugin.
  void clearHandlers(String pluginId) {
    _handlers.removeWhere((h) => h.pluginId == pluginId);
  }

  /// Clear all handlers.
  void clearAll() {
    _handlers.clear();
  }
}
