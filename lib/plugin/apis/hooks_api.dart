import 'dart:ffi';
import 'package:pocketpy/pocketpy_bindings_generated.dart';
import 'package:logging/logging.dart';
import 'package:island/plugin/bridge/py_bridge.dart';
import 'package:island/plugin/models/plugin_manifest.dart';
import 'package:island/plugin/apis/plugin_api.dart';
import 'package:island/plugin/plugin_manager.dart';

final _log = Logger('HooksApi');

/// A registered hook handler from a plugin.
class PluginHookHandler {
  final String pluginId;
  final String hookName;
  final String handlerName;
  final Pointer<py_TValue>? module;

  const PluginHookHandler({
    required this.pluginId,
    required this.hookName,
    required this.handlerName,
    this.module,
  });
}

/// Exposes content-transforming hooks to Python plugins.
///
/// Plugins can intercept and modify data before it reaches the server:
/// - `hooks.before_post_create(handler)` — modify post payload before creation
/// - `hooks.before_message_send(handler)` — modify message content before send
/// - `hooks.before_post_display(handler)` — modify post data before rendering
/// - `hooks.before_message_display(handler)` — modify message before rendering
///
/// Handler signature in Python:
/// ```python
/// def my_handler(data: dict) -> dict:
///     data["content"] = data["content"].upper()
///     return data
/// ```
///
/// Return `None` from a handler to cancel the operation entirely.
class HooksApi extends PluginApi {
  final List<PluginHookHandler> _handlers = [];

  List<PluginHookHandler> get handlers => List.unmodifiable(_handlers);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.eventsSubscribe};

  @override
  void register(Pointer<py_TValue> module, PyBridge py) {
    _activeInstance = this;
    _activeModule = module;

    py.bindFunc(
      module,
      'before_post_create',
      Pointer.fromFunction(_registerBeforePostCreate, false),
    );
    py.bindFunc(
      module,
      'before_message_send',
      Pointer.fromFunction(_registerBeforeMessageSend, false),
    );
    py.bindFunc(
      module,
      'before_post_display',
      Pointer.fromFunction(_registerBeforePostDisplay, false),
    );
    py.bindFunc(
      module,
      'before_message_display',
      Pointer.fromFunction(_registerBeforeMessageDisplay, false),
    );
  }

  static HooksApi? _activeInstance;
  static Pointer<py_TValue>? _activeModule;

  static bool _registerHook(String hookName, int argc, py_StackRef argv) {
    if (argc < 1) return false;
    final py = PyBridge.instance;
    final handlerName = py.toDart(argv.elementAt(0))?.toString();
    if (handlerName == null) return false;

    final pluginId = PluginManager.activePluginId ?? 'unknown';

    _activeInstance?._handlers.add(PluginHookHandler(
      pluginId: pluginId,
      hookName: hookName,
      handlerName: handlerName,
      module: _activeModule,
    ));

    _log.info('Plugin $pluginId registered hook: $hookName -> $handlerName');
    return true;
  }

  static bool _registerBeforePostCreate(int argc, py_StackRef argv) =>
      _registerHook('before_post_create', argc, argv);

  static bool _registerBeforeMessageSend(int argc, py_StackRef argv) =>
      _registerHook('before_message_send', argc, argv);

  static bool _registerBeforePostDisplay(int argc, py_StackRef argv) =>
      _registerHook('before_post_display', argc, argv);

  static bool _registerBeforeMessageDisplay(int argc, py_StackRef argv) =>
      _registerHook('before_message_display', argc, argv);

  /// Clear hooks for a specific plugin.
  void clearHooks(String pluginId) {
    _handlers.removeWhere((h) => h.pluginId == pluginId);
  }

  /// Clear all hooks.
  void clearAll() {
    _handlers.clear();
  }
}
