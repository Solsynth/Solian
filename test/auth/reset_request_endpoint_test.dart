import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/auth/captcha.config.dart';
import 'package:island/auth/login_content.dart';
import 'package:island/auth/widgets/auth_factor_widgets.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/main.dart' show globalOverlay;
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Both entry points of "forgot password" must post their request to Stargate.
///
/// The reset spell is written into Stargate's store, and the mailed link is
/// redeemed through Stargate's `/stargate/spells/{word}` pair. The legacy
/// `/passport/accounts/recovery/...` route wrote to a database no other part of
/// the flow reads, so posting there left the recovery mail undeliverable.
///
/// The request is only observable through the network call that follows the
/// captcha sheet, so each test drives the real screen, dismisses the captcha
/// with a canned token and asserts on the recorded request.

/// Records every request and answers with an empty JSON object.
class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

/// The real notifier reads the token store and hits the network; these checks
/// only need the account name the reset payload carries.
class _StubUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => SnAccount(
    id: 'account-1',
    name: 'littlesheep',
    nick: 'LittleSheep',
    language: 'en',
    isSuperuser: false,
    automatedId: null,
    profile: SnAccountProfile(
      id: 'profile-1',
      experience: 0,
      level: 1,
      levelingProgress: 0,
      picture: null,
      background: null,
      verification: null,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      deletedAt: null,
    ),
    perkSubscription: null,
    activatedAt: null,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    deletedAt: null,
  );
}

/// The captcha sheet never finishes loading in these tests, so it can be
/// dismissed with a canned token instead of a real webview round trip; only the
/// request that follows the token is under test.
Override _pendingCaptcha() =>
    captchaUrlProvider.overrideWith((ref) => Completer<String>().future);

Widget _localized(Widget child) => EasyLocalization(
  supportedLocales: const [Locale('en', 'US')],
  path: 'assets/i18n',
  saveLocale: false,
  child: Builder(
    builder: (context) => MaterialApp(
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: [
        ...context.localizationDelegates,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: child,
    ),
  ),
);

/// Asserts the reset request was recorded against the Stargate route.
void _expectStargateReset(
  _RecordingAdapter adapter, {
  required String account,
}) {
  final reset = adapter.requests.singleWhere(
    (request) => request.path.contains('/accounts/recovery/'),
  );
  expect(reset.path, startsWith('/stargate/accounts/recovery/'));
  expect(reset.data, {'account': account, 'captcha_token': 'captcha-token'});
  expect(
    adapter.requests.where(
      (request) => request.path.startsWith('/passport/accounts/recovery/'),
    ),
    isEmpty,
    reason: 'the reset request must not go through the Passport route',
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('the login screen posts its reset request to Stargate', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));

    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) => prefs),
            solarNetworkClientProvider.overrideWithValue(
              SolarNetworkClient.fromDio(dio),
            ),
            _pendingCaptcha(),
          ],
          child: _localized(const Scaffold(body: LoginContent())),
        ),
      );
      // EasyLocalization reads its assets through a real async channel.
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'littlesheep');
    await tester.tap(find.byIcon(Symbols.key_off));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final spinner = find.byType(CircularProgressIndicator);
    expect(spinner, findsWidgets);
    Navigator.of(tester.element(spinner.first)).pop('captcha-token');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    _expectStargateReset(adapter, account: 'littlesheep');
  });

  testWidgets(
    'the account settings screen posts its reset request to Stargate',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      addTearDown(() => dio.close(force: true));

      // Wide and tall enough that the settings sections lay out without
      // scrolling to the factor list.
      await tester.binding.setSurfaceSize(const Size(900, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(dio),
          userInfoProvider.overrideWith(_StubUserInfo.new),
          authFactorsProvider.overrideWith(
            (ref) async => [
              SnAuthFactor(
                id: 'factor-1',
                type: 0,
                createdAt: DateTime.utc(2026),
                updatedAt: DateTime.utc(2026),
                deletedAt: null,
                expiredAt: null,
                enabledAt: DateTime.utc(2026),
                trustworthy: 0,
                createdResponse: null,
              ),
            ],
          ),
          accountConnectionsProvider.overrideWith((ref) async => []),
          securityPreferencesModeProvider.overrideWith(
            (ref) async => 'default',
          ),
          _pendingCaptcha(),
        ],
      );

      final router = container.read(routerProvider);
      final config = router.config();
      // Start on the login screen: the settings route needs the router for its
      // leading button, and the login screen keeps the harness light.
      await config.routerDelegate.setInitialRoutePath(
        await config.routeInformationParser!.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/auth/login')),
        ),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: EasyLocalization(
              supportedLocales: const [Locale('en', 'US')],
              path: 'assets/i18n',
              saveLocale: false,
              child: Builder(
                builder: (context) => MaterialApp.router(
                  routerConfig: config,
                  locale: const Locale('en', 'US'),
                  supportedLocales: const [Locale('en', 'US')],
                  localizationsDelegates: [
                    ...context.localizationDelegates,
                    ...GlobalMaterialLocalizations.delegates,
                  ],
                  // The confirm dialog and the loading modal are inserted into
                  // the app-wide overlay rather than the page's navigator.
                  builder: (context, child) => Overlay(
                    key: globalOverlay,
                    initialEntries: [
                      OverlayEntry(
                        builder: (_) => child ?? const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      router.push(const AccountSettingsRoute());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));

      // The factor tiles live inside a collapsed expansion tile.
      await tester.tap(find.byIcon(Symbols.security).first);
      await tester.pumpAndSettle();
      final passwordFactor = find.byIcon(kFactorTypes[0]!.$3);
      expect(passwordFactor, findsOneWidget);
      await tester.tap(passwordFactor);
      await tester.pumpAndSettle();

      // Confirm the reset dialog.
      await tester.tap(find.widgetWithText(TextButton, 'OK').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final spinner = find.byType(CircularProgressIndicator);
      expect(spinner, findsWidgets);
      Navigator.of(tester.element(spinner.first)).pop('captcha-token');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      _expectStargateReset(adapter, account: 'littlesheep');

      // Let provider-scheduled retries fire before the binding checks for
      // pending timers.
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    },
  );
}
