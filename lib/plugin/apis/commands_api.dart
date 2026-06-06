import 'dart:ffi';
import 'package:pocketpy/pocketpy.dart';
import 'package:pocketpy/pocketpy_bindings_generated.dart';
import 'package:logging/logging.dart';
import 'package:island/plugin/bridge/py_bridge.dart';
import 'package:island/plugin/models/plugin_manifest.dart';
import 'package:island/plugin/apis/plugin_api.dart';
import 'package:island/plugin/plugin_manager.dart';

final _log = Logger('CommandsApi');

/// A command registered by a plugin.
class PluginCommand {
  final String pluginId;
  final String name;
  final String description;
  final String handlerName;
  final String? icon;
  final Pointer<py_TValue>? module;

  const PluginCommand({
    required this.pluginId,
    required this.name,
    required this.description,
    required this.handlerName,
    this.icon,
    this.module,
  });
}

/// Exposes command registration to Python plugins.
///
/// Provides:
/// - `commands.register_command(name, description, handler, icon=None)` - register a command
class CommandsApi extends PluginApi {
  final List<PluginCommand> _commands = [];

  /// All registered commands across plugins.
  List<PluginCommand> get commands => List.unmodifiable(_commands);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.commandsRegister};

  @override
  void register(Pointer<py_TValue> module, PyBridge py) {
    _activeInstance = this;
    _activeModule = module;
    py.bindFunc(
      module,
      'register_command',
      Pointer.fromFunction(_registerCommand, false),
    );
  }

  static CommandsApi? _activeInstance;
  static Pointer<py_TValue>? _activeModule;

  static bool _registerCommand(int argc, py_StackRef argv) {
    if (argc < 3) return false;
    final py = PyBridge.instance;
    final name = py.toDart(argv.elementAt(0))?.toString();
    final description = py.toDart(argv.elementAt(1))?.toString();
    final handler = py.toDart(argv.elementAt(2))?.toString();
    final icon = argc > 3 ? py.toDart(argv.elementAt(3))?.toString() : null;

    if (name == null || description == null || handler == null) return false;

    final pluginId = PluginManager.activePluginId ?? 'unknown';

    _activeInstance?._commands.add(PluginCommand(
      pluginId: pluginId,
      name: name,
      description: description,
      handlerName: handler,
      icon: icon,
      module: _activeModule,
    ));

    _log.info('Plugin $pluginId registered command: $name');
    return true;
  }

  /// Execute a plugin command. Returns the result from the handler.
  Object? executeCommand(PluginCommand command) {
    final py = PyBridge.instance;

    // Look for the handler in the plugin's module, not __main__
    Pointer<py_TValue>? funcRef;

    if (command.module != null) {
      // Try to get the function from the module's __dict__
      final nameId = py.name(command.handlerName);
      final itemRef = pocket.py_getdict(command.module!, nameId);
      if (itemRef != nullptr) {
        funcRef = itemRef;
      }
    }

    // Fallback: try global scope
    funcRef ??= py.getGlobal(command.handlerName);

    if (funcRef == null) {
      _log.warning('Handler not found: ${command.handlerName}');
      return null;
    }

    // Check if it's callable
    final type = pocket.py_typeof(funcRef);
    if (type != py_PredefinedType.tp_function &&
        type != py_PredefinedType.tp_nativefunc) {
      _log.warning('Handler is not callable: ${command.handlerName}');
      return null;
    }

    final ok = pocket.py_call(funcRef, 0, nullptr);
    if (!ok) {
      _log.warning('Command ${command.name} failed: ${py.formatException()}');
      return null;
    }

    return py.toDart(pocket.py_retval());
  }

  /// Clear commands for a specific plugin.
  void clearCommands(String pluginId) {
    _commands.removeWhere((c) => c.pluginId == pluginId);
  }

  /// Clear all commands.
  void clearAll() {
    _commands.clear();
  }
}
