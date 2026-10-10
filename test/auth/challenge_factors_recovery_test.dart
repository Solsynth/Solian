import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/auth/login.dart';
import 'package:island/auth/login_content.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/main.dart' show globalOverlay;
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Stargate binds `GET /stargate/auth/challenge/{id}/factors` to the client IP
/// and user agent recorded when the challenge was created, and answers 404 —
/// the same status as a missing challenge — when they no longer match. The
/// login lookup step must therefore re-create the challenge once and retry the
/// factor read, instead of dropping the user into an error dialog for a
/// challenge the client can still replace.
///
/// The behaviour is only observable through the requests the screen sends, so
/// each test drives the real lookup step against a scripted HTTP adapter.

/// Answers every request through [respond] and records it, so a test can assert
/// on both the scripted path and what the client actually sent.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.respond);

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
}

final _factorsPath = RegExp(r'^/stargate/auth/challenge/([^/]+)/factors$');

/// The 404 Stargate answers a challenge that does not match the caller with.
const _challengeNotFound = {
  'error': {
    'code': 'AUTH_CHALLENGE_NOT_FOUND',
    'message': 'Auth challenge was not found.',
  },
};

ResponseBody _json(Object? body, int statusCode) => ResponseBody.fromString(
  jsonEncode(body),
  statusCode,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

Map<String, dynamic> _challengeJson(String id) => {
  'id': id,
  'step_remain': 2,
  'step_total': 2,
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

Map<String, dynamic> _factorJson(String id) => {
  'id': id,
  'type': 0,
  'created_at': DateTime.utc(2026).toIso8601String(),
  'updated_at': DateTime.utc(2026).toIso8601String(),
  'deleted_at': null,
  'expired_at': null,
  'enabled_at': DateTime.utc(2026).toIso8601String(),
  'trustworthy': 5,
  'created_response': null,
};

/// Builds the challenge request payload, which reads the device identity
/// through the device_info plugin; the test host answers it with a canned
/// macOS payload so the lookup step can reach the network.
void _mockMacOsDeviceInfo() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const channel = MethodChannel('dev.fluttercommunity.plus/device_info');
  messenger.setMockMethodCallHandler(channel, (call) async {
    if (call.method != 'getDeviceInfo') return null;
    return <String, dynamic>{
      'computerName': 'test-mac',
      'hostName': 'test-mac',
      'arch': 'arm64',
      'model': 'Mac16,2',
      'modelName': 'MacBook Pro',
      'kernelVersion': 'Darwin',
      'osRelease': '27.0.0',
      'majorVersion': 27,
      'minorVersion': 0,
      'patchVersion': 0,
      'activeCPUs': 8,
      'memorySize': 17179869184,
      'cpuFrequency': 3200000000,
      'systemGUID': 'test-guid',
    };
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
}

Widget _localized(Widget child, {TransitionBuilder? builder}) =>
    EasyLocalization(
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
          builder: builder,
          home: child,
        ),
      ),
    );

/// The error dialog is inserted into the app-wide overlay rather than the
/// page's navigator, so the harness has to provide it.
Widget _overlayBuilder(BuildContext context, Widget? child) => Overlay(
  key: globalOverlay,
  initialEntries: [
    OverlayEntry(builder: (_) => child ?? const SizedBox.shrink()),
  ],
);

/// Drives the lookup step against a scripted adapter and returns it once the
/// challenge request has been answered.
Future<_ScriptedAdapter> _pumpLookup(
  WidgetTester tester,
  ResponseBody Function(RequestOptions options) respond, {
  bool withOverlay = false,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final adapter = _ScriptedAdapter(respond);
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
          // The shipped provider reads the device and package plugins, which
          // never settle under `flutter test`; the flow only needs it resolved
          // before the first auth request goes out.
          userAgentProvider.overrideWith((ref) async => 'Solian/test'),
        ],
        child: _localized(
          const Scaffold(body: LoginContent()),
          builder: withOverlay ? _overlayBuilder : null,
        ),
      ),
    );
    // EasyLocalization reads its assets through a real async channel.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).first, 'littlesheep');
  await tester.tap(find.widgetWithText(FilledButton, 'Next'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
  return adapter;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('re-creates the challenge once when the factor read is refused', (
    tester,
  ) async {
    _mockMacOsDeviceInfo();
    var created = 0;
    final factorReads = <String>[];
    final adapter = await _pumpLookup(tester, (options) {
      if (options.method == 'POST' &&
          options.path == '/stargate/auth/challenge') {
        created++;
        return _json(_challengeJson('challenge-$created'), 200);
      }
      final factors = _factorsPath.firstMatch(options.path);
      if (factors != null) {
        final id = factors.group(1)!;
        factorReads.add(id);
        // The first read is refused the way a challenge that no longer matches
        // the caller's IP / user agent is.
        if (id == 'challenge-1') return _json(_challengeNotFound, 404);
        return _json([_factorJson('factor-1')], 200);
      }
      return _json(<String, dynamic>{}, 200);
    });

    expect(
      created,
      2,
      reason:
          'the refused factor read must re-create the challenge; '
          'requests: ${adapter.requests.map((r) => '${r.method} ${r.path}').toList()}',
    );
    expect(factorReads, ['challenge-1', 'challenge-2']);

    // The flow proceeded to the factor picker with the recovered factors.
    expect(find.text('Pick a factor'), findsOneWidget);
    expect(find.byIcon(kFactorTypes[0]!.$3), findsOneWidget);

    // Dispose the picker so its challenge poll timer stops before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'surfaces the error when the factor read keeps being refused',
    (tester) async {
      _mockMacOsDeviceInfo();
      var created = 0;
      final factorReads = <String>[];
      final adapter = await _pumpLookup(
        tester,
        (options) {
          if (options.method == 'POST' &&
              options.path == '/stargate/auth/challenge') {
            created++;
            return _json(_challengeJson('challenge-$created'), 200);
          }
          final factors = _factorsPath.firstMatch(options.path);
          if (factors != null) {
            factorReads.add(factors.group(1)!);
            return _json(_challengeNotFound, 404);
          }
          return _json(<String, dynamic>{}, 200);
        },
        withOverlay: true,
      );

      // The retry happens exactly once — the recovery must never loop.
      expect(created, 2);
      expect(factorReads, ['challenge-1', 'challenge-2']);

      // The flow stayed on the lookup step and raised the usual error alert.
      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('Pick a factor'), findsNothing);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(
        adapter.requests.last.path,
        '/stargate/auth/challenge/challenge-2/factors',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    },
  );
}
