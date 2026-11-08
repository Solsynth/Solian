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

const double _kStatusTop = 44;

class _GuestUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Answers every request with an empty JSON list, so the replies panel and the
/// bookmark badge settle without touching the network.
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

/// The detail page's pill carries an [AutoLeadingButton] and its actions menu
/// routes through the page's context, so the page has to be mounted inside a
/// real router rather than a bare [MaterialApp].
class _StubRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: PostDetailRoute.page, path: '/posts/:id', initial: true),
  ];
}

SnPost _article() {
  return SnPost.fromJson({
    'id': 'article-1',
    'type': 1,
    'title': 'A long read',
    'content': [
      '## Scope of impact',
      '',
      'Body text of the first section. ' * 8,
      '',
      '## Root cause',
      '',
      'Body text of the second section.',
    ].join('\n'),
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

/// The painted capsule of the page's pill, excluding its margin.
Rect _capsule(WidgetTester tester) => tester.getRect(
  find
      .descendant(
        of: find.byType(PillBarSurface),
        matching: find.byType(DecoratedBox),
      )
      .first,
);

Future<void> _pump(WidgetTester tester, SnPost post) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1280, 900);
  final inset = const FakeViewPadding(top: _kStatusTop, bottom: 34);
  tester.view.padding = inset;
  tester.view.viewPadding = inset;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = _EmptyAdapter();
  final config = _StubRouter().config();

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(dio),
          userInfoProvider.overrideWith(() => _GuestUserInfo()),
          postProvider.overrideWith((ref, id) async => post),
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
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });

  final state = await config.routeInformationParser!
      .parseRouteInformationWithDependencies(
        RouteInformation(uri: Uri.parse('/posts/${post.id}')),
        tester.element(find.byType(MaterialApp)),
      );
  await config.routerDelegate.setNewRoutePath(state);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  // The scaffold's pill floats over the body and the page reserves its band
  // with `statusTop + kPillAppBarHeight`. Reserving only the capsule constant
  // left the status-bar half of the band uncovered: the sidebar's tabs and
  // card top ended up under the glass, and the reading-progress line was drawn
  // behind the bar instead of under it.
  testWidgets('the sidebar clears the floating pill band', (tester) async {
    final post = _article();
    await _pump(tester, post);

    expect(find.byType(PillAppBar), findsOneWidget);

    final capsule = _capsule(tester);
    expect(capsule.top, _kStatusTop + kPillSideGutter);

    // The contents tab lives in the sidebar, which is the only card column.
    final contentsTab = find.text('Contents');
    expect(contentsTab, findsOneWidget);
    expect(
      tester.getTopLeft(contentsTab).dy,
      greaterThan(capsule.bottom),
      reason: 'the sidebar card must start below the capsule, not under it',
    );
  });

  testWidgets('the reading progress line sits under the pill band', (
    tester,
  ) async {
    final post = _article();
    await _pump(tester, post);

    final line = tester.getRect(
      find.byKey(const ValueKey('article-reading-progress')),
    );
    expect(
      line.top,
      _kStatusTop + kPillAppBarHeight,
      reason: 'the line must not paint behind the pill',
    );
  });
}
