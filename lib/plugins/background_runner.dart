import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:island/plugins/bridge/js_bridge.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/plugins/apis/plugin_api.dart';
import 'package:island/plugins/plugin_manager.dart';

final _log = Logger('BackgroundRunner');

/// A scheduled background task from a plugin.
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

/// Exposes background task scheduling to JavaScript plugins.
///
/// Provides:
/// - `tasks.schedule(interval_seconds, handler_name)` - schedule a periodic task
class BackgroundTaskApi extends PluginApi {
  final List<PluginBackgroundTask> _tasks = [];

  List<PluginBackgroundTask> get tasks => List.unmodifiable(_tasks);

  @override
  Set<PluginPermission> get requiredPermissions =>
      {PluginPermission.tasksSchedule};

  @override
  void register(JsRuntime runtime) {
    _activeInstance = this;

    runtime.onMessage('api:tasks:schedule', (args) {
      try {
        final data = args is String ? jsonDecode(args) : args;
        final intervalSeconds = data['interval'];
        final handlerName = data['handler']?.toString();

        if (intervalSeconds == null || handlerName == null) return;
        if (intervalSeconds is! num || intervalSeconds <= 0) return;

        final pluginId = PluginManager.activePluginId ?? 'unknown';

        final task = PluginBackgroundTask(
          pluginId: pluginId,
          handlerName: handlerName,
          interval: Duration(milliseconds: (intervalSeconds * 1000).toInt()),
        );

        task.timer = Timer.periodic(task.interval, (_) {
          _executeTask(task);
        });

        _activeInstance?._tasks.add(task);
        _log.info('Plugin $pluginId scheduled task: $handlerName every ${intervalSeconds}s');
      } catch (e) {
        _log.warning('Failed to schedule task: $e');
      }
    });
  }

  static BackgroundTaskApi? _activeInstance;

  static void reset() {
    _activeInstance = null;
  }

  static void _executeTask(PluginBackgroundTask task) {
    if (task.running) return; // Skip if previous run still going
    task.running = true;

    try {
      final manager = PluginManager();
      final instance = manager.plugins[task.pluginId];
      final runtime = instance?.runtime;

      if (runtime == null) {
        _log.warning('Task handler ${task.handlerName}: no runtime for plugin ${task.pluginId}');
        return;
      }

      // Execute with a timeout
      final completer = Completer<void>();
      final timer = Timer(const Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          _log.warning('Task ${task.handlerName} timed out after 30s');
          completer.complete();
        }
      });

      try {
        runtime.callFunction(task.handlerName);
      } catch (e) {
        _log.warning('Task ${task.handlerName} failed: $e');
      }

      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
    } catch (e) {
      _log.severe('Task ${task.handlerName} threw: $e');
    } finally {
      task.running = false;
    }
  }

  /// Cancel all tasks for a specific plugin.
  void cancelTasks(String pluginId) {
    final toRemove = _tasks.where((t) => t.pluginId == pluginId).toList();
    for (final task in toRemove) {
      task.timer?.cancel();
      _tasks.remove(task);
    }
  }

  /// Cancel all tasks.
  void cancelAll() {
    for (final task in _tasks) {
      task.timer?.cancel();
    }
    _tasks.clear();
  }

  /// Dispose and clean up.
  void dispose() {
    cancelAll();
    _activeInstance = null;
  }
}
