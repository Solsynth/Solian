import 'dart:convert';

import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:island_plugin_foundation/src/plugin_manager.dart';
import 'package:logging/logging.dart';

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
/// - `commands.register_command(name, description, handler, icon=None)`
class CommandsApi extends PluginApi {
  final List<PluginCommand> _commands = [];

  /// All registered commands across plugins.
  List<PluginCommand> get commands => List.unmodifiable(_commands);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.commandsRegister};

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    if (!granted.contains(PluginPermission.commandsRegister)) return '';
    return '''
var commands = {};
commands.register_command = function(name, description, handler, icon) {
  sendMessage("api:commands:register_command", JSON.stringify({name: name, description: description, handler: handler, icon: icon || null}));
};
''';
  }

  @override
  void register(JsRuntime runtime) {
    runtime.onMessage('api:commands:register_command', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final name = data['name']?.toString();
        final description = data['description']?.toString();
        final handler = data['handler']?.toString();
        final icon = data['icon']?.toString();

        if (name == null || description == null || handler == null) return;

        final pluginId = PluginManager.activePluginId ?? 'unknown';

        _commands.add(
          PluginCommand(
            pluginId: pluginId,
            name: name,
            description: description,
            handlerName: handler,
            icon: icon,
          ),
        );

        _log.info('Plugin $pluginId registered command: $name -> $handler');
      } catch (e) {
        _log.warning('Failed to register command: $e');
      }
    });
  }

  /// Execute a plugin command. Returns the result from the handler.
  Object? executeCommand(PluginCommand command, JsRuntime runtime) {
    try {
      return runtime.callFunction(command.handlerName);
    } catch (e) {
      _log.warning('Command ${command.name} failed: $e');
      return null;
    }
  }

  @override
  void onPluginUnload(String pluginId) {
    clearCommands(pluginId);
  }

  /// Clear commands for a specific plugin.
  void clearCommands(String pluginId) {
    _commands.removeWhere((c) => c.pluginId == pluginId);
  }

  /// Clear all commands.
  void clearAll() {
    _commands.clear();
  }

  @override
  void reset() {
    clearAll();
  }
}
