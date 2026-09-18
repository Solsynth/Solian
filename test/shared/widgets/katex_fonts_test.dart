import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/shared/widgets/content/katex_fonts.dart';

void main() {
  setUp(() {
    KaTeXFonts.debugReset();
  });

  testWidgets('all KaTeX font families load from the bundled assets',
      (tester) async {
    // Regression guard: the vendored flutter_math_fork declares its KaTeX
    // fonts as plain assets, so a missing/changed asset path must fail here
    // instead of silently rendering math with fallback fonts.
    await KaTeXFonts.ensureLoaded();
  });

  testWidgets('gate shows the placeholder until fonts are loaded',
      (tester) async {
    Widget buildMath(BuildContext context) => const Text('math-rendered');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KaTeXFontGate(
            placeholder: (context) => const Text('math-placeholder'),
            builder: buildMath,
          ),
        ),
      ),
    );

    // Asset loading is async, so the first frame must gate on the placeholder.
    expect(find.text('math-placeholder'), findsOneWidget);
    expect(find.text('math-rendered'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('math-placeholder'), findsNothing);
    expect(find.text('math-rendered'), findsOneWidget);
  });

  testWidgets('math renders once the KaTeX fonts are loaded', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KaTeXFontGate(
            placeholder: (context) => const Text('math-placeholder'),
            builder: (context) => Math.tex(
              r'x^2 + y^2 = z^2',
              mathStyle: MathStyle.text,
              textStyle: const TextStyle(fontSize: 18, color: Colors.black),
              onErrorFallback: (error) => const Text('math-error'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('math-placeholder'), findsOneWidget);
    await tester.pumpAndSettle();

    // Neither the placeholder nor the parse/build error fallback remains.
    expect(find.text('math-placeholder'), findsNothing);
    expect(find.text('math-error'), findsNothing);
  });
}
