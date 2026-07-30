import 'dart:async';

import 'package:island_plugin_foundation/src/apis/plugin_api.dart';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:island_plugin_foundation/src/bridge/plugin_context.dart';
import 'package:island_plugin_foundation/src/models/plugin_manifest.dart';
import 'package:island_plugin_foundation/src/plugin_manager.dart';
import 'package:logging/logging.dart';

final _log = Logger('BackgroundRunner');

class PluginBackgroundTask {
  final String pluginId;
  final String handlerName;
  final Duration interval;
  Timer? timer;
  bool running;

  PluginBackgroundTask({
    required this.pluginId,
    required this.handlerName,
    required this.interval,
    this.timer,
    this.running = false,
  });
}

class BackgroundTaskApi extends PluginApi {
  final List<PluginBackgroundTask> _tasks = [];

  List<PluginBackgroundTask> get tasks => List.unmodifiable(_tasks);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.tasksSchedule};

  @override
  void register(PluginContext context, JsRuntime runtime) {
    runtime.exec('''
var tasks = {};
tasks.schedule = function(intervalSeconds, handler) {
  sendMessage("api:tasks:schedule", JSON.stringify({interval: intervalSeconds, handler: handler}));
};
''');
    runtime.onMessage('api:tasks:schedule', (raw) {
      try {
        final data = context.router.decode(raw);
        final intervalSeconds = data['interval'];
        final handlerName = data['handler']?.toString();
        if (intervalSeconds == null || handlerName == null) return;
        if (intervalSeconds is! num || intervalSeconds <= 0) return;

        final task = PluginBackgroundTask(
          pluginId: context.pluginId,
          handlerName: handlerName,
          interval: Duration(milliseconds: (intervalSeconds * 1000).toInt()),
        );
        task.timer = Timer.periodic(task.interval, (_) {
          _executeTask(task);
        });
        _tasks.add(task);
        _log.info('Plugin ${context.pluginId} scheduled task: $handlerName every ${intervalSeconds}s');
      } catch (e) {
        _log.warning('Failed to schedule task: $e');
      }
    });
  }

  static void _executeTask(PluginBackgroundTask task) {
    if (task.running) return;
    task.running = true;
    try {
      final manager = PluginManager();
      final instance = manager.plugins[task.pluginId];
      final runtime = instance?.runtime;
      if (runtime != null) {
        try {
          runtime.callFunction(task.handlerName);
        } catch (e) {
          _log.warning('Task ${task.handlerName} failed: $e');
        }
      } else {
        _log.warning('Task handler ${task.handlerName}: no runtime for plugin ${task.pluginId}');
      }
    } catch (e) {
      _log.severe('Task ${task.handlerName} threw: $e');
    } finally {
      task.running = false;
    }
  }

  @override
  void onPluginUnload(String pluginId) {
    final toRemove = _tasks.where((t) => t.pluginId == pluginId).toList();
    for (final task in toRemove) {
      task.timer?.cancel();
      _tasks.remove(task);
    }
  }

  @override
  void reset() {
    for (final task in _tasks) {
      task.timer?.cancel();
    }
    _tasks.clear();
  }
}
