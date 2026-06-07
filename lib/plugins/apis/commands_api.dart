import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/plugins/apis/plugin_api.dart';
import 'package:island/plugins/plugin_manager.dart';

final _log = Logger('CommandsApi');

/// A command registered by a plugin.
class PluginCommand {
  final String pluginId;
  final String name;
  final String description;
  final String handlerName;
  final String? icon;

  const PluginCommand({
    required this.pluginId,
    required this.name,
    required this.description,
    required this.handlerName,
    this.icon,
  });
}

/// Exposes command registration to JavaScript plugins.
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
  void register(JsRuntime runtime) {
    _activeInstance = this;

    runtime.onMessage('api:commands:register_command', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final name = data['name']?.toString();
        final description = data['description']?.toString();
        final handler = data['handler']?.toString();
        final icon = data['icon']?.toString();

        if (name == null || description == null || handler == null) return;

        final pluginId = PluginManager.activePluginId ?? 'unknown';

        _activeInstance?._commands.add(PluginCommand(
          pluginId: pluginId,
          name: name,
          description: description,
          handlerName: handler,
          icon: icon,
        ));

        _log.info('Plugin $pluginId registered command: $name -> $handler');
      } catch (e) {
        _log.warning('Failed to register command: $e');
      }
    });
  }

  static CommandsApi? _activeInstance;

  static void reset() {
    _activeInstance = null;
  }

  /// Execute a plugin command. Returns the result from the handler.
  Object? executeCommand(PluginCommand command, JsRuntime runtime) {
    try {
      final result = runtime.callFunction(command.handlerName);
      return result;
    } catch (e) {
      _log.warning('Command ${command.name} failed: $e');
      return null;
    }
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
