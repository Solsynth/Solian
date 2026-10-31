import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/app_startup_progress.dart';
import 'package:island/shared/widgets/app_startup_splash.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:package_info_plus/package_info_plus.dart';
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
    PackageInfo.setMockInitialValues(
      appName: 'Solar Network',
      packageName: 'dev.solsynth.solian',
      version: '3.15.0',
      buildNumber: '306',
      buildSignature: '',
    );
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('phone: artwork top, progress divider, bottom bar with icon and wordmark', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));

    expect(tester.takeException(), isNull);
    expect(find.byType(StartupSplashScreen), findsOneWidget);
    expect(find.byType(StartupProgressBar), findsOneWidget);
    expect(find.byKey(const Key('startup-app-icon')), findsOneWidget);

    final portrait = tester.getCenter(
      find.byKey(const Key('startup-portrait-image')),
    );
    final barBox = tester.getRect(find.byType(StartupProgressBar));
    final iconBox = tester.getRect(find.byKey(const Key('startup-app-icon')));
    final wordmark = find.text('Solar Network');
    expect(wordmark, findsOneWidget);
    final wordmarkBox = tester.getRect(wordmark);

    // Artwork is in top section above progress bar.
    expect(portrait.dy, lessThan(barBox.top));

    // Progress bar sits above the fixed 80px bottom panel.
    final bottomBarBox = tester.getRect(find.byKey(const Key('startup-bottom-bar')));
    expect(bottomBarBox.height, closeTo(80, 0.1));
    expect(barBox.bottom, closeTo(bottomBarBox.top, 0.1));
    expect(bottomBarBox.top, lessThanOrEqualTo(iconBox.top));

    // App icon sits on the left of the wordmark.
    expect(iconBox.right, lessThan(wordmarkBox.left));

    // Bottom cluster is located near the bottom of the screen.
    expect(iconBox.bottom, greaterThan(844 * 0.8));
    expect(wordmarkBox.bottom, greaterThan(844 * 0.8));

    // Version label is present next to wordmark (including build number).
    expect(find.text('v3.15.0+306'), findsOneWidget);
  });

  testWidgets('desktop: artwork stays centered with 9:16 aspect ratio', (
    tester,
  ) async {
    await _pump(tester, const Size(1440, 900));

    expect(tester.takeException(), isNull);
    expect(find.byType(StartupProgressBar), findsOneWidget);
    expect(find.byKey(const Key('startup-app-icon')), findsOneWidget);

    final portrait = tester.getCenter(
      find.byKey(const Key('startup-portrait-image')),
    );
    final imageSize = tester.getSize(
      find.byKey(const Key('startup-portrait-image')),
    );
    expect(imageSize.width / imageSize.height, closeTo(9 / 16, 0.01));
    // Centered horizontally.
    expect(portrait.dx, closeTo(1440 / 2, 1));

    final barBox = tester.getRect(find.byType(StartupProgressBar));
    expect(portrait.dy, lessThan(barBox.top));
  });
}
