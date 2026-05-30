sealed class AppTaskEvent {
  final String taskId;
  const AppTaskEvent({required this.taskId});
}

class TaskCreatedEvent extends AppTaskEvent {
  const TaskCreatedEvent({required super.taskId});
}

class TaskProgressEvent extends AppTaskEvent {
  final double progress;
  final String? statusMessage;
  const TaskProgressEvent({
    required super.taskId,
    required this.progress,
    this.statusMessage,
  });
}

class TaskCompletedEvent extends AppTaskEvent {
  final Map<String, dynamic>? result;
  const TaskCompletedEvent({required super.taskId, this.result});
}

class TaskFailedEvent extends AppTaskEvent {
  final String errorMessage;
  const TaskFailedEvent({required super.taskId, required this.errorMessage});
}
