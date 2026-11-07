import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/auth_wiring.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/main.dart' show globalOverlay;
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The device-code consent screen approves through the shared step-up flow:
/// Stargate answers `403 AUTH_SUDO_REQUIRED` until the approving session is
/// elevated, so the screen must raise the elevation sheet and replay the same
/// approve request exactly once — and the approval itself grants nothing.
///
/// The behaviour is only observable through the requests it sends, so this
/// drives the real screen against a scripted adapter.

/// Scripted Stargate: records every request and answers by path.
class _StargateAdapter implements HttpClientAdapter {
  _StargateAdapter(this.respond);

  final requests = <RequestOptions>[];
  final ResponseBody Function(RequestOptions options) respond;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    requests.add(options);
    return respond(options);
  }

  List<RequestOptions> to(String path) =>
      requests.where((r) => r.path == path || r.uri.path == path).toList();
}

ResponseBody _json(Object? body, int statusCode) => ResponseBody.fromString(
  jsonEncode(body),
  statusCode,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

const _sudoRequired = {
  'code': 'AUTH_SUDO_REQUIRED',
  'message': 'This action requires re-authentication.',
  'detail': 'password',
};

Map<String, dynamic> _challenge(String id, {int stepRemain = 1}) => {
  'id': id,
  'step_remain': stepRemain,
  'step_total': 1,
  'failed_attempts': 0,
  'blacklist_factors': <String>[],
  'audiences': <String>[],
  'scopes': <String>[],
  'ip_address': '127.0.0.1',
  'user_agent': 'Solian/test',
  'account_id': 'account-1',
  'created_at': DateTime.utc(2026).toIso8601String(),
  'updated_at': DateTime.utc(2026).toIso8601String(),
};

Map<String, dynamic> _factor(String id) => {
  'id': id,
  'type': 0,
  'created_at': DateTime.utc(2026).toIso8601String(),
  'updated_at': DateTime.utc(2026).toIso8601String(),
  'deleted_at': null,
  'expired_at': null,
  'enabled_at': DateTime.utc(2026).toIso8601String(),
  'trustworthy': 1,
  'created_response': null,
};

Map<String, dynamic> _deviceCodeStatus(String clientId) => {
  'user_code': 'ABCD-EFGH',
  'client_id': clientId,
  'client_name': 'Solar TV',
  'client_slug': clientId,
  'scopes': <String>['openid'],
  'status': 'pending',
  'expires_at': DateTime.utc(2026, 1, 1, 12).toIso8601String(),
  'expires_in': 600,
  'interval': 5,
  'verification_uri': 'https://solian.app/auth/device',
};

class _StubUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// The elevation sheet's indeterminate spinner never settles, so frames are
/// pumped a fixed number of times instead.
Future<void> _settle(WidgetTester tester, {int steps = 12}) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'device approval elevates on AUTH_SUDO_REQUIRED and replays the approve',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await EasyLocalization.ensureInitialized();

      var elevated = false;
      var approvals = 0;
      var sudoStarts = 0;

      final adapter = _StargateAdapter((options) {
        final path = options.path;
        if (path == '/auth/open/device/code/ABCD-EFGH') {
          return _json(_deviceCodeStatus('solar-tv'), 200);
        }
        if (path == '/auth/open/authorize') {
          return _json({
            'client_name': 'Solar TV',
            'client_id': 'solar-tv',
            'scopes': <String>['openid'],
            'home_uri': 'https://solian.app',
          }, 200);
        }
        if (path == '/develop/apps/solar-tv') {
          return _json(<String, dynamic>{}, 404);
        }
        if (path.endsWith('/approve')) {
          approvals++;
          return elevated ? _json({'ok': true}, 200) : _json(_sudoRequired, 403);
        }
        if (path == '/stargate/auth/sudo') {
          sudoStarts++;
          return _json(_challenge('sudo-1'), 200);
        }
        if (path == '/stargate/auth/challenge/sudo-1/factors') {
          return _json([_factor('factor-password')], 200);
        }
        if (path ==
            '/stargate/auth/challenge/sudo-1/factors/factor-password') {
          return _json(<String, dynamic>{}, 200);
        }
        if (path == '/stargate/auth/challenge/sudo-1') {
          // The submitted step exhausted the demand: this session is now
          // elevated, and only the *next* approval may succeed.
          elevated = true;
          return _json(_challenge('sudo-1', stepRemain: 0), 200);
        }
        return _json(<String, dynamic>{}, 404);
      });

      // Both Stargate clients share the scripted adapter: the screen reads
      // device state through the `/stargate`-prefixed client, while the shared
      // elevation flow reads `authClientProvider`, which is built from the
      // host-wide API client.
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      final apiDio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      addTearDown(dio.close);
      addTearDown(apiDio.close);

      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          stargateApiClientProvider.overrideWithValue(dio),
          apiClientProvider.overrideWithValue(apiDio),
          userInfoProvider.overrideWith(_StubUserInfo.new),
          ...authHostOverrides() as dynamic,
        ],
      );
      addTearDown(container.dispose);

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
                  routerConfig: container.read(routerProvider).config(),
                  locale: const Locale('en', 'US'),
                  supportedLocales: const [Locale('en', 'US')],
                  localizationsDelegates: [
                    ...context.localizationDelegates,
                    ...GlobalMaterialLocalizations.delegates,
                  ],
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

      container.read(routerProvider).push(
        AuthorizeRoute(userCode: 'ABCD-EFGH'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Authorize'), findsOneWidget);
      await tester.tap(find.text('Authorize'));
      await _settle(tester);

      // The refusal opened the elevation prompt instead of surfacing an error.
      expect(sudoStarts, 1);
      expect(find.text("Confirm it's you"), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      await tester.tap(find.byType(RadioListTile<SnAuthFactor>));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await _settle(tester);

      await tester.enterText(find.byType(TextField), 'hunter2');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await _settle(tester);

      expect(elevated, isTrue);
      // Approve was sent twice: the refusal, then the replay. Never more.
      expect(approvals, 2);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    },
  );
}
