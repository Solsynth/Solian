import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _GuestUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

class _EmptyAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(const <dynamic>[]),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

class _StubRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: PostDetailRoute.page, path: '/posts/:id', initial: true),
  ];
}

SnPost _post() => SnPost.fromJson({
  'id': 'post-1',
  'type': 0,
  'title': 'A post with a headline',
  'content': 'Body text',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('PostDetailScreen shows loading pill ring until post arrives', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 800);
    const inset = FakeViewPadding(top: 44, bottom: 34);
    tester.view.padding = inset;
    tester.view.viewPadding = inset;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _EmptyAdapter();
    final config = _StubRouter().config();
    final completer = Completer<SnPost?>();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            apiClientProvider.overrideWithValue(dio),
            userInfoProvider.overrideWith(() => _GuestUserInfo()),
            postProvider.overrideWith((ref, id) => completer.future),
          ],
          child: EasyLocalization(
            supportedLocales: const [Locale('en', 'US')],
            path: 'assets/i18n',
            saveLocale: false,
            child: Builder(
              builder: (context) => MaterialApp.router(
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: context.localizationDelegates,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
                ),
                routerConfig: config,
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    final state = await config.routeInformationParser!
        .parseRouteInformationWithDependencies(
          RouteInformation(uri: Uri.parse('/posts/post-1')),
          tester.element(find.byType(MaterialApp)),
        );
    await config.routerDelegate.setNewRoutePath(state);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final loadingBar = tester.widget<PillAppBar>(find.byType(PillAppBar));
    expect(loadingBar.loading, isTrue);
    expect(
      tester.widget<PillSurface>(find.byType(PillSurface)).loading,
      isTrue,
    );
    expect(find.byKey(const ValueKey('pill-ring')), findsOneWidget);

    completer.complete(_post());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.byType(PillSliverAppBar), findsOneWidget);
    final sliverBar = tester.widget<PillSliverAppBar>(
      find.byType(PillSliverAppBar),
    );
    expect(sliverBar.loading, isFalse);
    expect(
      tester.widget<PillSurface>(find.byType(PillSurface)).loading,
      isFalse,
    );
    // Flush VisibilityDetector's 500ms debounce timer before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  });
}
