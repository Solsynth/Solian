import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/accounts/widgets/account/account_devices.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/core/config.dart';
import 'package:island/core/server_compatibility.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final _account = SnAccount.fromJson({
  'id': 'account-1',
  'name': 'alice',
  'nick': 'Alice',
  'language': 'en-US',
  'is_superuser': false,
  'automated_id': null,
  'profile': {
    'id': 'profile-1',
    'experience': 0,
    'level': 0,
    'leveling_progress': 0.0,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  },
  'perk_subscription': null,
  'activated_at': '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

/// Only the settings page: the full app router also mounts the account tab
/// header, whose widgets overflow under the test viewport.
class _SettingsOnlyRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: AccountSettingsRoute.page,
      path: '/settings',
      initial: true,
    ),
  ];
}

class _SignedInUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => _account;
}

/// Empty device page: the real notifier hits the network on build.
class _NoDevices extends AuthDevicesNotifier {
  @override
  Future<PaginationState<SnAuthDeviceWithSession>> build() async {
    return const PaginationState<SnAuthDeviceWithSession>(
      items: <SnAuthDeviceWithSession>[],
      isLoading: false,
      isReloading: false,
      totalCount: 0,
      hasMore: false,
      cursor: null,
    );
  }
}

Future<void> _pumpSettings(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      userInfoProvider.overrideWith(_SignedInUserInfo.new),
      authFactorsProvider.overrideWith((ref) async => <SnAuthFactor>[]),
      contactMethodsProvider.overrideWith((ref) async => <SnContactMethod>[]),
      accountConnectionsProvider.overrideWith(
        (ref) async => <SnAccountConnection>[],
      ),
      publishingSettingsProvider.overrideWith(
        (ref) async => SnPublishingSettings(
          id: 'settings-1',
          accountId: 'account-1',
          createdAt: DateTime.utc(2026),
        ),
      ),
      fediverseAvailabilityProvider.overrideWith(
        (ref) async => const SnFediverseAvailabilityResponse(
          isEnabled: false,
          publishers: <SnFediversePublisherAvailability>[],
        ),
      ),
      securityPreferencesModeProvider.overrideWith((ref) async => 'default'),
      authDevicesProvider.overrideWith(_NoDevices.new),
      authSessionsProvider().overrideWith(
        (ref) async => const PaginatedResult<SnAuthSession>(
          items: <SnAuthSession>[],
          totalCount: 0,
          hasMore: false,
        ),
      ),
      publishersManagedProvider.overrideWith((ref) async => <SnPublisher>[]),
      serverCapabilitiesProvider.overrideWith(
        (ref) async => <String, ServerCapability>{},
      ),
    ],
  );
  addTearDown(container.dispose);

  final config = _SettingsOnlyRouter().config();

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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('tickets entry opens the identity console in the browser', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final launchedUrls = <String>[];
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'launch') {
        launchedUrls.add((call.arguments as Map)['url'] as String);
        return true;
      }
      return false;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    await _pumpSettings(tester);
    expect(find.byType(AccountSettingsScreen), findsOneWidget);

    final ticketsTile = find.ancestor(
      of: find.text('Tickets'),
      matching: find.byType(ListTile),
    );
    expect(ticketsTile, findsOneWidget);
    expect(
      find.descendant(of: ticketsTile, matching: find.byIcon(Symbols.report)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: ticketsTile,
        matching: find.byIcon(Symbols.open_in_new),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(ticketsTile);
    await tester.pumpAndSettle();
    await tester.tap(ticketsTile);
    await tester.pumpAndSettle();

    expect(launchedUrls, ['https://id.solian.app']);
  });
}
