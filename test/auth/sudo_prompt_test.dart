import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/auth/sudo_prompt.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/api_error.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Stargate gates auth-critical mutations behind per-session step-up
/// elevation: the first attempt answers 403 `AUTH_SUDO_REQUIRED`, and only
/// after the caller completes a sudo challenge does the same request go
/// through. The app must therefore prompt, elevate, and retry the *same*
/// request exactly once — and hand the refusal back untouched when the user
/// backs out of the prompt.
///
/// The behaviour is only observable through the requests the helper sends, so
/// each test drives [withSudoRetry] from a real widget against a scripted HTTP
/// adapter and asserts on the exchanged requests.

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

ResponseBody _json(Object? body, int statusCode) => ResponseBody.fromString(
  jsonEncode(body),
  statusCode,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

/// The 403 Stargate answers a gated endpoint with before elevation.
const _sudoRequired = {
  'code': 'AUTH_SUDO_REQUIRED',
  'message': 'This action requires re-authentication.',
  'detail': 'password,timed_code',
};

Map<String, dynamic> _challengeJson(String id, {int stepRemain = 2}) => {
  'id': id,
  'step_remain': stepRemain,
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

Map<String, dynamic> _factorJson(String id, {int type = 0, int trustworthy = 1}) => {
  'id': id,
  'type': type,
  'created_at': DateTime.utc(2026).toIso8601String(),
  'updated_at': DateTime.utc(2026).toIso8601String(),
  'deleted_at': null,
  'expired_at': null,
  'enabled_at': DateTime.utc(2026).toIso8601String(),
  'trustworthy': trustworthy,
  'created_response': null,
};

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

typedef _GatedRun = Future<void> Function(BuildContext context, WidgetRef ref);

/// Hosts a single button whose action runs through [withSudoRetry].
class _GatedHost extends ConsumerWidget {
  final _GatedRun run;

  const _GatedHost({required this.run});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => run(context, ref),
          child: const Text('Do gated thing'),
        ),
      ),
    );
  }
}

/// Pumps a fixed number of frames. `pumpAndSettle` cannot be used here: the
/// elevation sheet shows an indeterminate progress indicator while it works,
/// which never settles.
Future<void> _settle(WidgetTester tester, {int steps = 12}) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

Future<_ScriptedAdapter> _pumpHost(
  WidgetTester tester,
  ResponseBody Function(RequestOptions options) respond,
  _GatedRun run,
) async {
  final prefs = await SharedPreferences.getInstance();
  final adapter = _ScriptedAdapter(respond);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = adapter;
  addTearDown(() => dio.close(force: true));

  // Size the *view* rather than the render surface: SheetScaffold (and the
  // modal route) size themselves from `MediaQuery`, which only follows the
  // view, and a sheet sized against the default 800x600 window would clip its
  // actions in a 420x900 surface.
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          solarNetworkClientProvider.overrideWithValue(
            SolarNetworkClient.fromDio(dio),
          ),
        ],
        child: _localized(_GatedHost(run: run)),
      ),
    );
    // EasyLocalization reads its assets through a real async channel.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump();
  return adapter;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('elevates on AUTH_SUDO_REQUIRED and retries the request once', (
    tester,
  ) async {
    var gatedCalls = 0;
    var sudoStarts = 0;
    var elevated = false;
    Object? failure;
    String? outcome;

    final adapter = await _pumpHost(tester, (options) {
      switch (options.path) {
        case '/stargate/gated-action':
          gatedCalls++;
          return elevated
              ? _json({'ok': true}, 200)
              : _json(_sudoRequired, 403);
        case '/stargate/auth/sudo':
          sudoStarts++;
          return _json(_challengeJson('sudo-1'), 200);
        case '/stargate/auth/challenge/sudo-1/factors':
          return _json([
            _factorJson('factor-password'),
          ], 200);
        case '/stargate/auth/challenge/sudo-1/factors/factor-password':
          return _json(<String, dynamic>{}, 200);
        case '/stargate/auth/challenge/sudo-1':
          // The submitted step exhausted the demand: the session is elevated.
          elevated = true;
          return _json(_challengeJson('sudo-1', stepRemain: 0), 200);
      }
      return _json(<String, dynamic>{}, 404);
    }, (context, ref) async {
      try {
        await withSudoRetry(
          context,
          ref,
          () => ref
              .read(solarNetworkClientProvider)
              .dio
              .post('/stargate/gated-action'),
        );
        outcome = 'ok';
      } catch (err) {
        failure = err;
      }
    });

    await tester.tap(find.text('Do gated thing'));
    await _settle(tester);

    // The refusal opened the elevation prompt with the factor picker.
    expect(sudoStarts, 1);
    expect(find.text("Confirm it's you"), findsOneWidget);
    expect(find.text('Pick a factor'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Pick the password factor and deliver its code.
    await tester.tap(find.byType(RadioListTile<SnAuthFactor>));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await _settle(tester);

    // Enter the credential and submit the step.
    await tester.enterText(find.byType(TextField), 'correct horse battery');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await _settle(tester);

    expect(elevated, isTrue);
    expect(gatedCalls, 2, reason: 'the gated request is retried exactly once');
    expect(outcome, 'ok');
    expect(failure, isNull);
    expect(
      adapter.requests.map((r) => '${r.method} ${r.path}').toList(),
      [
        'POST /stargate/gated-action',
        'POST /stargate/auth/sudo',
        'GET /stargate/auth/challenge/sudo-1/factors',
        'POST /stargate/auth/challenge/sudo-1/factors/factor-password',
        'PATCH /stargate/auth/challenge/sudo-1',
        'POST /stargate/gated-action',
      ],
    );
  });

  testWidgets('backs out of the prompt and surfaces the original 403', (
    tester,
  ) async {
    var gatedCalls = 0;
    Object? failure;
    String? outcome;

    final adapter = await _pumpHost(tester, (options) {
      switch (options.path) {
        case '/stargate/gated-action':
          gatedCalls++;
          return _json(_sudoRequired, 403);
        case '/stargate/auth/sudo':
          return _json(_challengeJson('sudo-1'), 200);
        case '/stargate/auth/challenge/sudo-1/factors':
          return _json([_factorJson('factor-password')], 200);
      }
      return _json(<String, dynamic>{}, 200);
    }, (context, ref) async {
      try {
        await withSudoRetry(
          context,
          ref,
          () => ref
              .read(solarNetworkClientProvider)
              .dio
              .post('/stargate/gated-action'),
        );
        outcome = 'ok';
      } catch (err) {
        failure = err;
      }
    });

    await tester.tap(find.text('Do gated thing'));
    await _settle(tester);
    expect(find.text('Pick a factor'), findsOneWidget);

    // Dismiss the sheet without elevating anything.
    await tester.tap(find.byIcon(Symbols.close));
    await _settle(tester);

    expect(find.text('Pick a factor'), findsNothing);
    expect(
      gatedCalls,
      1,
      reason: 'a cancelled elevation must not retry the gated request',
    );
    expect(outcome, isNull);
    expect(isSudoRequired(failure!), isTrue);
    expect(
      ApiError.tryParse(failure! as DioException)?.code,
      'AUTH_SUDO_REQUIRED',
    );
    expect(
      adapter.requests.map((r) => '${r.method} ${r.path}').toList(),
      [
        'POST /stargate/gated-action',
        'POST /stargate/auth/sudo',
        'GET /stargate/auth/challenge/sudo-1/factors',
      ],
    );
  });
}
