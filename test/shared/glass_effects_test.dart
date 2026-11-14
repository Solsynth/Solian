import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/widgets/call_chrome.dart';
import 'package:island/shared/widgets/glass_effects.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

Widget _harness({required bool glass}) => GlassEffects(
  enabled: glass,
  child: MaterialApp(
    home: Scaffold(
      body: Center(
        child: PillSurface(
          t: 1,
          margin: EdgeInsets.zero,
          radius: const BorderRadius.all(Radius.circular(999)),
          contentPadding: const EdgeInsets.all(8),
          child: const SizedBox(width: 200, height: 40),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('glass on draws the liquid material', (tester) async {
    await tester.pumpWidget(_harness(glass: true));
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassLayer), findsOneWidget);
  });

  testWidgets('glass off swaps in a solid fill with no layer', (tester) async {
    await tester.pumpWidget(_harness(glass: false));
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassLayer), findsNothing);

    // The capsule still occupies the same box, now painted as a pure surface
    // fill with an outer shadow and no border.
    final boxes = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(PillSurface),
            matching: find.byType(DecoratedBox),
          ),
        )
        .toList();
    final shadowDecoration = boxes[0].decoration as BoxDecoration;
    final decoration = boxes[1].decoration as BoxDecoration;
    expect(
      decoration.borderRadius,
      const BorderRadius.all(Radius.circular(999)),
    );
    expect(decoration.border, isNull);
    expect(decoration.color, isNotNull);
    expect(decoration.color!.a, greaterThan(0));
    expect(shadowDecoration.boxShadow, isNotEmpty);
  });

  testWidgets('a fading pill still paints nothing at t = 0', (tester) async {
    await tester.pumpWidget(
      GlassEffects(
        enabled: true,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: PillSurface(
                t: 0,
                margin: EdgeInsets.zero,
                radius: const BorderRadius.all(Radius.circular(999)),
                contentPadding: const EdgeInsets.all(8),
                child: const SizedBox(width: 200, height: 40),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassLayer), findsNothing);
  });

  testWidgets(
    'toggling GlassEffects outside an Overlay dynamically updates descendant surfaces',
    (tester) async {
      final enabled = ValueNotifier<bool>(true);
      final overlayKey = GlobalKey<OverlayState>();

      await tester.pumpWidget(
        ValueListenableBuilder<bool>(
          valueListenable: enabled,
          builder: (context, glass, _) => GlassEffects(
            enabled: glass,
            child: MaterialApp(
              home: Overlay(
                key: overlayKey,
                initialEntries: [
                  OverlayEntry(
                    builder: (_) => Scaffold(
                      body: Center(
                        child: PillSurface(
                          t: 1,
                          margin: EdgeInsets.zero,
                          radius: const BorderRadius.all(Radius.circular(999)),
                          contentPadding: const EdgeInsets.all(8),
                          child: const SizedBox(width: 200, height: 40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LiquidGlassLayer), findsOneWidget);

      enabled.value = false;
      await tester.pumpAndSettle();

      expect(find.byType(LiquidGlassLayer), findsNothing);

      enabled.value = true;
      await tester.pumpAndSettle();

      expect(find.byType(LiquidGlassLayer), findsOneWidget);
    },
  );

  testWidgets('CallHeaderPill uses liquid glass texture and renders actions', (
    tester,
  ) async {
    final enabled = ValueNotifier<bool>(true);

    await tester.pumpWidget(
      ValueListenableBuilder<bool>(
        valueListenable: enabled,
        builder: (context, glass, _) => GlassEffects(
          enabled: glass,
          child: MaterialApp(
            home: Scaffold(
              body: CallHeaderPill(
                title: 'Test Call',
                status: '00:42',
                statusTop: 20,
                actions: const [
                  IconButton(
                    onPressed: null,
                    icon: Icon(Icons.star, key: ValueKey('test-action-star')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Renders liquid glass and action button
    expect(find.byType(LiquidGlassLayer), findsOneWidget);
    expect(find.byType(PillSurface), findsOneWidget);
    expect(find.byKey(const ValueKey('test-action-star')), findsOneWidget);

    // Toggling off removes liquid glass layer
    enabled.value = false;
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassLayer), findsNothing);
    expect(find.byType(PillSurface), findsOneWidget);
    expect(find.byKey(const ValueKey('test-action-star')), findsOneWidget);
  });

  testWidgets(
    'non-glass material uses surface color with no border in light and dark mode',
    (tester) async {
      Future<BoxDecoration> pumpWithBrightness(Brightness brightness) async {
        final theme = ThemeData(
          brightness: brightness,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.amber,
            brightness: brightness,
          ),
        );
        await tester.pumpWidget(
          GlassEffects(
            enabled: false,
            child: MaterialApp(
              theme: theme,
              home: const Scaffold(
                body: Center(
                  child: PillSurface(
                    t: 1,
                    child: SizedBox(width: 120, height: 40),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        return tester
                .widgetList<DecoratedBox>(
                  find.descendant(
                    of: find.byType(PillSurface),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .elementAt(1)
                .decoration
            as BoxDecoration;
      }

      final lightTheme = ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
      );
      final lightDecoration = await pumpWithBrightness(Brightness.light);
      expect(lightDecoration.color, lightTheme.colorScheme.surface);
      expect(lightDecoration.border, isNull);

      final darkTheme = ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      );
      final darkDecoration = await pumpWithBrightness(Brightness.dark);
      expect(darkDecoration.color, darkTheme.colorScheme.surface);
      expect(darkDecoration.border, isNull);
    },
  );
}
