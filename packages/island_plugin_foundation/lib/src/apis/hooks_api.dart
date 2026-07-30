import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/bridge/plugin_context.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:logging/logging.dart';

final _log = Logger('HooksApi');

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

class HooksApi extends PluginApi {
  HooksApi({List<String>? hookNames})
    : hookNames =
          hookNames ??
          const [
            'before_post_create',
            'before_message_send',
            'before_post_display',
            'before_message_display',
          ];

  final List<String> hookNames;
  final List<PluginHookHandler> _handlers = [];

  List<PluginHookHandler> get handlers => List.unmodifiable(_handlers);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.eventsSubscribe};

  @override
  void register(PluginContext context, JsRuntime runtime) {
    final buf = StringBuffer('var hooks = {};\n');
    for (final name in hookNames) {
      buf.writeln('hooks.$name = function(handler) {');
      buf.writeln(
        '  sendMessage("api:hooks:$name", JSON.stringify({handler: handler.name || handler.toString()}));',
      );
      buf.writeln('};');
    }
    runtime.exec(buf.toString());

    for (final name in hookNames) {
      runtime.onMessage('api:hooks:$name', (raw) {
        _registerHookFromMessage(context, name, raw);
      });
    }
  }

  void _registerHookFromMessage(PluginContext context, String hookName, dynamic raw) {
    try {
      final data = context.router.decode(raw);
      final handlerName = data['handler']?.toString();
      if (handlerName == null) return;

      _handlers.add(PluginHookHandler(
        pluginId: context.pluginId,
        hookName: hookName,
        handlerName: handlerName,
      ));
      _log.info('Plugin ${context.pluginId} registered hook: $hookName -> $handlerName');
    } catch (e) {
      _log.warning('Failed to register hook $hookName: $e');
    }
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
