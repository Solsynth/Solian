import 'dart:convert';

import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/bridge/plugin_context.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:logging/logging.dart';

final _log = Logger('CommandsApi');

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

class CommandsApi extends PluginApi {
  final List<PluginCommand> _commands = [];

  List<PluginCommand> get commands => List.unmodifiable(_commands);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.commandsRegister};

  @override
  void register(PluginContext context, JsRuntime runtime) {
    runtime.exec('''
var commands = {};
commands.register_command = function(name, description, handler, icon) {
  sendMessage("api:commands:register_command", JSON.stringify({name: name, description: description, handler: handler, icon: icon || null}));
};
''');
    runtime.onMessage('api:commands:register_command', (raw) {
      try {
        final data = context.router.decode(raw);
        final name = data['name']?.toString();
        final description = data['description']?.toString();
        final handler = data['handler']?.toString();
        final icon = data['icon']?.toString();
        if (name == null || description == null || handler == null) return;

        _commands.add(PluginCommand(
          pluginId: context.pluginId,
          name: name,
          description: description,
          handlerName: handler,
          icon: icon,
        ));
        _log.info('Plugin ${context.pluginId} registered command: $name -> $handler');
      } catch (e) {
        _log.warning('Failed to register command: $e');
      }
    });
  }

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
    _commands.removeWhere((c) => c.pluginId == pluginId);
  }

  @override
  void reset() {
    _commands.clear();
  }
}
