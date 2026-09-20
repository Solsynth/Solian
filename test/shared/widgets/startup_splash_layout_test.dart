import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/app_startup_progress.dart';
import 'package:island/shared/widgets/app_startup_splash.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US')],
        path: 'assets/i18n',
        saveLocale: false,
        child: ProviderScope(
          overrides: [
            connectivityStatusProvider.overrideWith(
              (ref) => Stream.value([ConnectivityResult.wifi]),
            ),
          ],
          child: Builder(
            builder: (context) => mui.MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              theme: mui.ThemeData(
                colorScheme: mui.ColorScheme.fromSeed(seedColor: Colors.indigo),
              ),
              home: StartupSplashScreen(
                runBootstrap: false,
                showCompleted: true,
                onCompleted: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('phone: 9:16 portrait top-centered, content at bottom', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));

    expect(tester.takeException(), isNull);
    expect(find.byType(StartupSplashScreen), findsOneWidget);
    expect(find.byKey(const Key('startup-bottom-scrim')), findsOneWidget);
    expect(find.byKey(const Key('startup-portrait-glow')), findsOneWidget);
    expect(find.byType(StartupProgressBar), findsOneWidget);

    final portrait = tester.getCenter(
      find.byKey(const Key('startup-portrait-image')),
    );
    final imageSize = tester.getSize(
      find.byKey(const Key('startup-portrait-image')),
    );
    expect(imageSize.width / imageSize.height, closeTo(9 / 16, 0.01));
    // Horizontally centered, anchored to the top.
    expect(portrait.dx, closeTo(390 / 2, 1));
    expect(portrait.dy, lessThan(844 * 0.5));

    final bar = tester.getCenter(find.byType(StartupProgressBar));
    expect(bar.dy, greaterThan(844 * 0.8));

    final copyright = find.textContaining('© Solsynth');
    expect(copyright, findsOneWidget);
    final dy = tester.getCenter(copyright).dy;
    expect(dy, greaterThan(844 * 0.8));
    expect(dy, lessThan(844));

    final wordmark = find.text('Solar Network');
    expect(wordmark, findsOneWidget);
    expect(
      tester.getCenter(wordmark).dy,
      lessThan(tester.getCenter(copyright).dy),
    );
  });

  testWidgets('desktop: portrait stays 9:16 instead of stretching full-bleed', (
    tester,
  ) async {
    await _pump(tester, const Size(1440, 900));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('startup-bottom-scrim')), findsOneWidget);
    expect(find.byKey(const Key('startup-portrait-glow')), findsOneWidget);
    expect(find.byType(StartupProgressBar), findsOneWidget);

    final portrait = tester.getCenter(
      find.byKey(const Key('startup-portrait-image')),
    );
    final imageSize = tester.getSize(
      find.byKey(const Key('startup-portrait-image')),
    );
    expect(imageSize.width / imageSize.height, closeTo(9 / 16, 0.01));
    // Not full-bleed: capped to a centered 9:16 poster.
    expect(imageSize.width, lessThan(600));
    expect(portrait.dx, closeTo(1440 / 2, 1));
    // Top-anchored at the 24px frame margin.
    expect(
      tester
          .getTopLeft(find.byKey(const Key('startup-portrait-image')))
          .dy,
      closeTo(24, 1),
    );
  });
}
