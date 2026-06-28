import 'package:island/tasks/app_task.dart';

const kTaskOverlayCompletedRetention = Duration(seconds: 3);

class TaskOverlaySnapshot {
  final List<AppTask> visibleTasks;
  final AppTask? primaryTask;
  final double progress;

  const TaskOverlaySnapshot({
    required this.visibleTasks,
    required this.primaryTask,
    required this.progress,
  });

  bool get isVisible => visibleTasks.isNotEmpty;
  bool get hasActiveTasks => visibleTasks.any((task) => task.isActive);
}

TaskOverlaySnapshot buildTaskOverlaySnapshot(
  List<AppTask> tasks, {
  required DateTime now,
  Duration completedRetention = kTaskOverlayCompletedRetention,
}) {
  final visibleTasks =
      tasks
          .where(
            (task) =>
                task.isActive ||
                (task.isFinished &&
                    now.difference(task.updatedAt) < completedRetention),
          )
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  final primaryTask =
      _pickPrimaryTask(visibleTasks) ??
      (visibleTasks.isEmpty ? null : visibleTasks.first);

  return TaskOverlaySnapshot(
    visibleTasks: visibleTasks,
    primaryTask: primaryTask,
    progress: _calculateProgress(visibleTasks),
  );
}

List<String> finishedTaskIdsToAutoClear(
  List<AppTask> tasks, {
  required DateTime now,
  Duration completedRetention = kTaskOverlayCompletedRetention,
}) {
  return tasks
      .where(
        (task) =>
            task.isFinished &&
            now.difference(task.updatedAt) >= completedRetention,
      )
      .map((task) => task.id)
      .toList(growable: false);
}

AppTask? _pickPrimaryTask(List<AppTask> tasks) {
  final activeTasks = tasks.where((task) => task.isActive).toList()
    ..sort((a, b) {
      final priority = _taskPriority(
        a.status,
      ).compareTo(_taskPriority(b.status));
      if (priority != 0) return priority;
      return b.updatedAt.compareTo(a.updatedAt);
    });

  if (activeTasks.isNotEmpty) return activeTasks.first;
  return tasks.where((task) => task.isFinished).firstOrNull;
}

int _taskPriority(AppTaskStatus status) {
  return switch (status) {
    AppTaskStatus.inProgress => 0,
    AppTaskStatus.pending => 1,
    AppTaskStatus.paused => 2,
    _ => 3,
  };
}

double _calculateProgress(List<AppTask> tasks) {
  if (tasks.isEmpty) return 0;

  final activeTasks = tasks.where((task) => task.isActive).toList();
  final sourceTasks = activeTasks.isNotEmpty ? activeTasks : tasks;
  final total = sourceTasks.fold<double>(
    0,
    (sum, task) => sum + _taskProgress(task),
  );
  return (total / sourceTasks.length).clamp(0, 1);
}

double _taskProgress(AppTask task) {
  if (task.status == AppTaskStatus.completed || task.progress >= 1) {
    return 1;
  }
  if (task.status == AppTaskStatus.pending) return 0;
  return task.progress.clamp(0, 1);
}
