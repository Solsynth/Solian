import 'dart:ffi';
import 'package:pocketpy/pocketpy.dart';
import 'package:pocketpy/pocketpy_bindings_generated.dart';
import 'package:logging/logging.dart';
import 'package:island/plugin/bridge/py_bridge.dart';
import 'package:island/plugin/models/plugin_manifest.dart';
import 'package:island/plugin/apis/plugin_api.dart';
import 'package:island/plugin/plugin_manager.dart';

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

/// Exposes event subscription to Python plugins.
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
  void register(Pointer<py_TValue> module, PyBridge py) {
    // Store this instance reference for the static callbacks
    _activeInstance = this;

    py.bindFunc(
      module,
      'subscribe',
      Pointer.fromFunction(_subscribe, false),
    );
    py.bindFunc(
      module,
      'list_events',
      Pointer.fromFunction(_listEvents, false),
    );
  }

  static EventsApi? _activeInstance;

  static bool _subscribe(int argc, py_StackRef argv) {
    if (argc < 2) return false;
    final py = PyBridge.instance;
    final eventName = py.toDart(argv.elementAt(0))?.toString();
    final handlerName = py.toDart(argv.elementAt(1))?.toString();

    if (eventName == null || handlerName == null) return false;

    // Get current plugin ID from PluginManager
    final pluginId = PluginManager.activePluginId ?? 'unknown';

    _activeInstance?._handlers.add(PluginEventHandler(
      pluginId: pluginId,
      eventName: eventName,
      handlerName: handlerName,
    ));

    _log.info('Plugin $pluginId subscribed to $eventName -> $handlerName');
    return true;
  }

  static bool _listEvents(int argc, py_StackRef argv) {
    final py = PyBridge.instance;
    final events = [
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
    final retval = pocket.py_retval();
    pocket.py_newlist(retval);
    for (final event in events) {
      final item = py.pushTmp();
      py.newStr(item, event);
      pocket.py_list_append(retval, item);
      py.pop();
    }
    return true;
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
