import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/account_screen.dart';
import 'package:island/accounts/screens/me/account_qr.dart';
import 'package:island/core/config.dart';
import 'package:island/discovery/explore.dart';
import 'package:island/misc/dashboard/dash.dart';
import 'package:island/misc/tabs_screen.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:island/wallets/wallet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Signed-out stub: the real notifier reads the token store and hits the
/// network, which these landing-screen checks must not depend on.
class _SignedOutUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

late AppRouter _router;
late ProviderContainer _container;

/// Boots the real router at `/` with a real `SharedPreferences` store, so the
/// dashboard settings are read exactly as the app reads them.
Future<void> _pumpApp(
  WidgetTester tester,
  Map<String, Object> prefsValues,
) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();

  _container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      userInfoProvider.overrideWith(_SignedOutUserInfo.new),
    ],
  );
  addTearDown(_container.dispose);

  final router = _container.read(routerProvider);
  _router = router;
  final config = router.config();

  // Real async room so EasyLocalization's file-backed load completes.
  await tester.runAsync(() async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: _container,
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
                flutter_localizations.GlobalMaterialLocalizations.delegate,
                flutter_localizations.GlobalCupertinoLocalizations.delegate,
              ],
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();

  final state = await config.routeInformationParser!
      .parseRouteInformationWithDependencies(
        RouteInformation(uri: Uri.parse('/')),
        tester.element(find.byType(MaterialApp)),
      );
  await config.routerDelegate.setNewRoutePath(state);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

/// Tears the tree down and lets provider-scheduled timers fire, so the binding
/// sees none pending.
Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  _container.dispose();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('app settings', () {
    Future<(ProviderContainer, SharedPreferences)> makeContainer(
      Map<String, Object> values,
    ) async {
      SharedPreferences.setMockInitialValues(values);
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      return (container, prefs);
    }

    test('the dashboard is enabled unless turned off', () async {
      final (container, _) = await makeContainer(const {});
      expect(container.read(appSettingsProvider).dashboardEnabled, isTrue);

      final (offContainer, _) = await makeContainer(const {
        kAppDashboardEnabled: false,
      });
      expect(offContainer.read(appSettingsProvider).dashboardEnabled, isFalse);
    });

    test(
      'turning the dashboard off never leaves it as the start screen',
      () async {
        final (container, prefs) = await makeContainer(const {
          kAppDefaultScreen: 'dashboard',
        });

        container.read(appSettingsProvider.notifier).setDashboardEnabled(false);

        expect(prefs.getBool(kAppDashboardEnabled), isFalse);
        expect(prefs.getString(kAppDefaultScreen), 'explore');
        expect(container.read(appSettingsProvider).defaultScreen, 'explore');
      },
    );

    test('turning the dashboard off keeps an unrelated start screen', () async {
      final (container, prefs) = await makeContainer(const {
        kAppDefaultScreen: 'chat',
      });

      container.read(appSettingsProvider.notifier).setDashboardEnabled(false);

      expect(prefs.getString(kAppDefaultScreen), 'chat');
      expect(container.read(appSettingsProvider).defaultScreen, 'chat');
    });
  });

  testWidgets('dashboard on by default: / renders the dashboard', (
    tester,
  ) async {
    await _pumpApp(tester, const {});

    expect(tester.takeException(), isNull);
    expect(find.byType(DashboardGrid), findsOneWidget);
    expect(find.byType(ExploreScreen), findsNothing);
    // The dashboard is one of the nine navigation destinations.
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.destinations.length, 9);

    await _teardown(tester);
  });

  testWidgets('dashboard disabled: / lands on explore and drops the tab', (
    tester,
  ) async {
    await _pumpApp(tester, const {'app_dashboard_enabled': false});

    expect(tester.takeException(), isNull);
    expect(find.byType(DashboardGrid), findsNothing);
    expect(find.byType(ExploreScreen), findsOneWidget);
    expect(_router.currentPath, '/explore');
    // One fewer navigation destination: the dashboard is not reachable.
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.destinations.length, 8);

    await _teardown(tester);
  });

  testWidgets('long-pressing Explore opens its entrance sheet', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, const {'app_dashboard_enabled': false});

    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.longPress(find.byIcon(Symbols.explore_rounded));
    await tester.pumpAndSettle();

    // The entrances that used to sit in the explore app bar and in the account
    // menu / creator hub now live in the long-press sheet.
    expect(find.byIcon(Symbols.category), findsOneWidget);
    expect(find.byIcon(Symbols.shuffle), findsOneWidget);
    expect(find.byIcon(Symbols.footprint), findsOneWidget);
    expect(find.byIcon(Symbols.drafts), findsOneWidget);

    // The draft box entry resolves: it is a top-level route.
    await tester.tap(find.byIcon(Symbols.drafts));
    await tester.pumpAndSettle();
    expect(_router.currentPath, '/drafts');

    await _teardown(tester);
  });

  testWidgets('the footprints entrance pushes the bookmarks page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, const {'app_dashboard_enabled': false});
    await tester.longPress(find.byIcon(Symbols.explore_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Symbols.footprint));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(_router.currentPath, '/bookmarks');

    await _teardown(tester);
  });

  testWidgets('long-pressing Explore in the rail opens its entrance sheet', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, const {'app_dashboard_enabled': false});
    expect(find.byType(NavigationRail), findsOneWidget);

    final railExplore = find.descendant(
      of: find.byType(NavigationRail),
      matching: find.byIcon(Symbols.explore_rounded),
    );
    expect(railExplore, findsOneWidget);
    await tester.longPress(railExplore);
    await tester.pumpAndSettle();

    expect(find.byIcon(Symbols.category), findsOneWidget);
    expect(find.byIcon(Symbols.shuffle), findsOneWidget);
    expect(find.byIcon(Symbols.footprint), findsOneWidget);
    expect(find.byIcon(Symbols.drafts), findsOneWidget);

    await _teardown(tester);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('the menu expands the rail instead of opening a drawer', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // A rail the user trimmed to two entries: the drawer's job here is to
    // reach what the collapsed rail dropped.
    await _pumpApp(tester, const {
      'app_dashboard_enabled': false,
      'app_rail_nav_layouts': '["explore","chat"]',
    });

    NavigationRail rail() =>
        tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail().destinations.length, 2);
    expect(rail().extended, isFalse);
    // The wide layout carries no drawer at all.
    expect(find.byType(Drawer), findsNothing);
    expect(find.byType(NavigationDrawer), findsNothing);

    await tester.tap(find.byIcon(Symbols.menu_rounded).first);
    await tester.pumpAndSettle();

    // Expanded: the whole reachable set, in rail order with the rest behind.
    expect(rail().extended, isTrue);
    expect(rail().destinations.length, 8);
    expect(find.byType(Drawer), findsNothing);

    // A destination only the expanded rail offers is selectable, and picking
    // one navigates without collapsing the rail.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Wallet'),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(_router.currentPath, '/wallet');
    expect(rail().extended, isTrue);
    expect(rail().destinations.length, 8);

    await _teardown(tester);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
    'long-pressing Explore in the expanded rail opens its entrance sheet',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _pumpApp(tester, const {'app_dashboard_enabled': false});
      await tester.tap(find.byIcon(Symbols.menu_rounded).first);
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );

      final railExplore = find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Explore'),
      );
      expect(railExplore, findsOneWidget);
      await tester.longPress(railExplore);
      await tester.pumpAndSettle();

      expect(find.byIcon(Symbols.category), findsOneWidget);
      expect(find.byIcon(Symbols.shuffle), findsOneWidget);
      expect(find.byIcon(Symbols.footprint), findsOneWidget);
      expect(find.byIcon(Symbols.drafts), findsOneWidget);

      await _teardown(tester);
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('the menu still opens the drawer on a narrow layout', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, const {'app_dashboard_enabled': false});
    expect(find.byType(NavigationRail), findsNothing);

    await tester.tap(find.byIcon(Symbols.menu_rounded).first);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDrawer), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationDrawer),
        matching: find.text('Wallet'),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(_router.currentPath, '/wallet');
    expect(find.byType(NavigationDrawer), findsNothing);

    await _teardown(tester);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('a tab the rail does not carry selects no rail entry', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, const {
      'app_rail_nav_layouts': '["explore","chat"]',
    });
    final tabs = _router.innerRouterOf<TabsRouter>(TabsRoute.name)!;

    // Explore is carried, so it is the selection.
    tabs.setActiveIndex(1);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      0,
    );

    // Wallet is not carried. Selecting the first entry instead would paint
    // Explore as the current page while the wallet is open — and that first
    // entry is what a tap on the false selection navigates to.
    tabs.setActiveIndex(6);
    await tester.pumpAndSettle();
    expect(_router.currentPath, '/wallet');
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      isNull,
      reason: 'an uncarried tab selects no rail entry',
    );

    await _teardown(tester);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('opening the wallet from the account tab switches tabs', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, const {});
    await tester.tap(find.byIcon(Symbols.account_circle_rounded).first);
    await tester.pumpAndSettle();
    expect(_router.currentPath, '/account');

    openWalletFromAccount(tester.element(find.byType(AccountScreen)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(_router.currentPath, '/wallet');
    // Pushing the tab route would stack a second shell, and the two collide on
    // the shared scaffold key.
    expect(find.byType(TabsScreen), findsOneWidget);
    expect(find.byType(WalletScreen), findsOneWidget);

    await _teardown(tester);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('the wallet opens from a page above the shell too', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, const {});
    _router.push(PostDetailRoute(id: 'abc'));
    await tester.pumpAndSettle();

    // No tab to switch to up here: the route is navigated, which pops back to
    // the shell and selects the tab there.
    openWalletFromAccount(tester.element(find.byType(Scaffold).first));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(_router.currentPath, '/wallet');
    expect(find.byType(TabsScreen), findsOneWidget);
    expect(_router.stack.map((p) => p.name), [TabsRoute.name]);

    await _teardown(tester);
    debugDefaultTargetPlatformOverride = null;
  });
}
