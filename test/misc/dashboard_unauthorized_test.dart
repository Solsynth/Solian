import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/misc/dashboard/dash.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Signed-out stub: the real notifier would read the token store and hit the
/// network, which the guest view must not depend on.
class _SignedOutUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

Widget _wrap({
  required Brightness brightness,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: brightness,
          ),
        ),
        home: const Scaffold(body: DashboardGrid()),
      ),
    ),
  );
}

/// Pumps with real async room so EasyLocalization's file-backed load
/// completes before the tree settles.
Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required Brightness brightness,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          userInfoProvider.overrideWith(_SignedOutUserInfo.new),
        ],
        child: _wrap(brightness: brightness),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('guest dashboard greets with the mascot sticker and a login CTA',
      (tester) async {
    await _pump(tester, size: const Size(400, 800), brightness: Brightness.light);

    // The resident mascot waves hello instead of a generic person icon.
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/images/stickers/hello.webp',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Solar Network'), findsOneWidget);
    // Subcopy comes from the catalog, not a hardcoded English string.
    expect(find.textContaining('personalized dashboard'), findsOneWidget);
    expect(find.byIcon(Symbols.login), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets(
      'guest view renders in dark mode and the wide layout without errors',
      (tester) async {
    await _pump(
      tester,
      size: const Size(1200, 800),
      brightness: Brightness.dark,
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Solar Network'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
