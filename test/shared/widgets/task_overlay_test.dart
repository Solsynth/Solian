import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/task_overlay.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';

class _FixedTasks extends Tasks {
  _FixedTasks(this.tasks);

  final List<AppTask> tasks;

  @override
  List<AppTask> build() => tasks;
}

AppTask _uploadTask({
  required AppTaskStatus status,
  double progress = 0,
  Map<String, dynamic>? metadata,
}) {
  return AppTask(
    id: 'task-1',
    title: 'Upload photo',
    status: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    type: AppTaskType.driveUpload,
    progress: progress,
    metadata: metadata,
  );
}

Widget _wrap(List<AppTask> tasks) {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: ProviderScope(
      overrides: [tasksProvider.overrideWith(() => _FixedTasks(tasks))],
      child: Builder(
        builder: (context) => mui.MaterialApp(
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US')],
          localizationsDelegates: context.localizationDelegates,
          theme: mui.ThemeData(
            colorScheme: mui.ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          home: const mui.Scaffold(
            body: mui.Align(
              alignment: mui.Alignment.topCenter,
              child: TaskOverlay(),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester, List<AppTask> tasks) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_wrap(tasks));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('top bar shows percentage progress for a running task', (
    tester,
  ) async {
    await _pump(tester, [
      _uploadTask(status: AppTaskStatus.inProgress, progress: 0.5),
    ]);

    final indicator = find.byType(mui.LinearProgressIndicator);
    expect(indicator, findsOneWidget);
    expect(
      tester.widget<mui.LinearProgressIndicator>(indicator).value,
      closeTo(0.5, 0.01),
    );
    expect(tester.getSize(indicator).height, greaterThan(0));
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('top bar stays indeterminate while an upload is preparing', (
    tester,
  ) async {
    await _pump(tester, [
      _uploadTask(
        status: AppTaskStatus.inProgress,
        progress: 0.3,
        metadata: {'stage': DriveUploadStage.hashing},
      ),
    ]);

    final indicator = find.byType(mui.LinearProgressIndicator);
    expect(indicator, findsOneWidget);
    expect(tester.widget<mui.LinearProgressIndicator>(indicator).value, isNull);
  });
}
