import 'dart:async';

import 'package:island/core/tasks/app_task.dart';
import 'package:island/core/tasks/app_task_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tasks_notifier.g.dart';

@riverpod
class Tasks extends _$Tasks {
  final _eventController = StreamController<AppTaskEvent>.broadcast();

  @override
  List<AppTask> build() {
    ref.onDispose(() {
      _eventController.close();
    });
    return [];
  }

  Stream<AppTaskEvent> get events => _eventController.stream;

  String addTask({
    required String title,
    required String type,
    AppTaskStatus status = AppTaskStatus.pending,
    Map<String, dynamic>? metadata,
  }) {
    final id = 'task-${DateTime.now().millisecondsSinceEpoch}-${state.length}';
    final task = AppTask(
      id: id,
      title: title,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: type,
      metadata: metadata,
    );
    state = [...state, task];
    _eventController.add(TaskCreatedEvent(taskId: id));
    return id;
  }

  void updateTask(
    String id, {
    AppTaskStatus? status,
    double? progress,
    String? statusMessage,
    String? errorMessage,
    Map<String, dynamic>? result,
    Map<String, dynamic>? metadata,
  }) {
    state = state.map((task) {
      if (task.id != id) return task;
      return task.copyWith(
        status: status ?? task.status,
        progress: progress ?? task.progress,
        statusMessage: statusMessage ?? task.statusMessage,
        errorMessage: errorMessage ?? task.errorMessage,
        result: result ?? task.result,
        metadata: metadata ?? task.metadata,
        updatedAt: DateTime.now(),
      );
    }).toList();

    if (progress != null) {
      _eventController.add(
        TaskProgressEvent(
          taskId: id,
          progress: progress,
          statusMessage: statusMessage,
        ),
      );
    }
    if (status == AppTaskStatus.completed) {
      _eventController.add(
        TaskCompletedEvent(taskId: id, result: result),
      );
    }
    if (status == AppTaskStatus.failed) {
      _eventController.add(
        TaskFailedEvent(
          taskId: id,
          errorMessage: errorMessage ?? 'Unknown error',
        ),
      );
    }
  }

  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  void clearCompleted() {
    state = state.where((task) => !task.isFinished).toList();
  }

  void clearAll() {
    state = [];
  }

  AppTask? getTask(String id) {
    return state.where((task) => task.id == id).firstOrNull;
  }

  List<AppTask> getActiveTasks() {
    return state.where((task) => task.isActive).toList();
  }

  List<AppTask> getTasksByType(String type) {
    return state.where((task) => task.type == type).toList();
  }
}

@Riverpod(keepAlive: true)
Stream<AppTaskEvent> taskEvents(Ref ref) {
  return ref.watch(tasksProvider.notifier).events;
}
