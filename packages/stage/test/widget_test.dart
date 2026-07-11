import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stage/main.dart';

void main() {
  testWidgets('Stage config panel is shown over chroma green', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const StageApp());

    expect(find.text('Island Stage'), findsOneWidget);
    expect(find.textContaining('Record'), findsOneWidget);
    expect(find.text('1 second'), findsOneWidget);
    expect(find.text('3 seconds'), findsOneWidget);

    final greenBox = tester.widget<ColoredBox>(
      find.byWidgetPredicate(
        (widget) => widget is ColoredBox && widget.color == kChromaKeyGreen,
      ),
    );
    expect(greenBox.color, kChromaKeyGreen);
  });

  testWidgets('Recording hides config UI during pad and restores after', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const StageApp());

    final recordButton = find.textContaining('Record');
    await tester.ensureVisible(recordButton);
    await tester.tap(recordButton);
    await tester.pump();

    // Config should be hidden immediately while recording.
    expect(find.text('Island Stage'), findsNothing);
    expect(find.textContaining('Record'), findsNothing);

    // Lead-in pad (1s) still pure green — no snackbar message yet.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Something happened'), findsNothing);

    // After pad, snackbar appears.
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Something happened'), findsOneWidget);

    // Content duration (2.5s) + animation buffer (0.6s) + lead-out (1s)
    // plus a little slack for reverse animations.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));

    // Config UI restored.
    expect(find.text('Island Stage'), findsOneWidget);
    expect(find.textContaining('Record'), findsOneWidget);
  });
}
