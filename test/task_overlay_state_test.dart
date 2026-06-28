import 'package:flutter_test/flutter_test.dart';
import 'package:island/shared/widgets/task_overlay_state.dart';
import 'package:island/tasks/app_task.dart';

void main() {
  group('buildTaskOverlaySnapshot', () {
    test('keeps recently completed tasks visible for the retention window', () {
      final now = DateTime(2026, 6, 29, 12, 0, 0);
      final task = _task(
        id: 'done',
        status: AppTaskStatus.completed,
        progress: 1,
        updatedAt: now.subtract(const Duration(seconds: 2)),
      );

      final snapshot = buildTaskOverlaySnapshot([task], now: now);

      expect(snapshot.isVisible, isTrue);
      expect(snapshot.visibleTasks, [task]);
      expect(snapshot.primaryTask, task);
      expect(snapshot.progress, 1);
    });

    test('keeps recently failed tasks visible for the retention window', () {
      final now = DateTime(2026, 6, 29, 12, 0, 0);
      final task = _task(
        id: 'failed',
        status: AppTaskStatus.failed,
        progress: 0.62,
        updatedAt: now.subtract(const Duration(seconds: 2)),
      );

      final snapshot = buildTaskOverlaySnapshot([task], now: now);

      expect(snapshot.isVisible, isTrue);
      expect(snapshot.visibleTasks, [task]);
      expect(snapshot.primaryTask, task);
    });

    test('prefers active tasks over finished ones for the primary label', () {
      final now = DateTime(2026, 6, 29, 12, 0, 0);
      final completed = _task(
        id: 'done',
        title: 'Finished upload',
        status: AppTaskStatus.completed,
        progress: 1,
        updatedAt: now.subtract(const Duration(seconds: 1)),
      );
      final active = _task(
        id: 'active',
        title: 'Current upload',
        status: AppTaskStatus.inProgress,
        progress: 0.4,
        updatedAt: now,
      );

      final snapshot = buildTaskOverlaySnapshot([completed, active], now: now);

      expect(snapshot.primaryTask, active);
      expect(snapshot.progress, closeTo(0.4, 0.001));
    });
  });

  group('finishedTaskIdsToAutoClear', () {
    test('returns finished tasks after the retention window only', () {
      final now = DateTime(2026, 6, 29, 12, 0, 0);
      final oldCompleted = _task(
        id: 'old',
        status: AppTaskStatus.completed,
        progress: 1,
        updatedAt: now.subtract(const Duration(seconds: 4)),
      );
      final freshCompleted = _task(
        id: 'fresh',
        status: AppTaskStatus.completed,
        progress: 1,
        updatedAt: now.subtract(const Duration(seconds: 2)),
      );
      final oldFailed = _task(
        id: 'failed',
        status: AppTaskStatus.failed,
        updatedAt: now.subtract(const Duration(seconds: 5)),
      );

      final ids = finishedTaskIdsToAutoClear([
        oldCompleted,
        freshCompleted,
        oldFailed,
      ], now: now);

      expect(ids, ['old', 'failed']);
    });
  });
}

AppTask _task({
  required String id,
  String title = 'Task',
  AppTaskStatus status = AppTaskStatus.pending,
  double progress = 0,
  DateTime? updatedAt,
}) {
  final timestamp = updatedAt ?? DateTime(2026, 6, 29, 12, 0, 0);
  return AppTask(
    id: id,
    title: title,
    status: status,
    createdAt: timestamp.subtract(const Duration(seconds: 1)),
    updatedAt: timestamp,
    type: AppTaskType.driveUpload,
    progress: progress,
  );
}
