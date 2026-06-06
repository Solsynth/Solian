import 'dart:async';
import 'dart:ffi';
import 'package:pocketpy/pocketpy.dart';
import 'package:pocketpy/pocketpy_bindings_generated.dart';
import 'package:logging/logging.dart';
import 'package:island/plugin/bridge/py_bridge.dart';
import 'package:island/plugin/models/plugin_manifest.dart';
import 'package:island/plugin/apis/plugin_api.dart';
import 'package:island/plugin/plugin_manager.dart';

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

/// Exposes background task scheduling to Python plugins.
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
  void register(Pointer<py_TValue> module, PyBridge py) {
    _activeInstance = this;
    py.bindFunc(
      module,
      'schedule',
      Pointer.fromFunction(_schedule, false),
    );
  }

  static BackgroundTaskApi? _activeInstance;

  static bool _schedule(int argc, py_StackRef argv) {
    if (argc < 2) return false;
    final py = PyBridge.instance;
    final intervalSeconds = py.toDart(argv.elementAt(0));
    final handlerName = py.toDart(argv.elementAt(1))?.toString();

    if (intervalSeconds == null || handlerName == null) return false;
    if (intervalSeconds is! num || intervalSeconds <= 0) return false;

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
    return true;
  }

  static void _executeTask(PluginBackgroundTask task) {
    if (task.running) return; // Skip if previous run still going
    task.running = true;

    try {
      final py = PyBridge.instance;
      final funcRef = py.getGlobal(task.handlerName);
      if (funcRef == null) {
        _log.warning('Task handler not found: ${task.handlerName}');
        return;
      }

      // Use watchdog for background tasks (30s timeout)
      py.watchdogBegin(30000);
      try {
        final ok = pocket.py_call(funcRef, 0, nullptr);
        if (!ok) {
          _log.warning(
            'Task ${task.handlerName} failed: ${py.formatException()}',
          );
        }
      } finally {
        py.watchdogEnd();
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
