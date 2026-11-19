import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/widgets/account/account_devices.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final _now = DateTime.utc(2026, 11, 19, 12);
const _rowLabel = 'Solian/4.0.0+30 Longgang District';

SnAuthSession _session(String id, {bool current = false, String? label}) {
  return SnAuthSession(
    id: id,
    label: label ?? 'Solian/4.0.0+30',
    lastGrantedAt: _now,
    type: 0,
    accountId: 'account-1',
    createdAt: _now,
    updatedAt: _now,
    isCurrent: current,
  );
}

class _Devices extends AuthDevicesNotifier {
  @override
  Future<PaginationState<SnAuthDeviceWithSession>> build() async {
    final item = SnAuthDeviceWithSession(
      id: 'device-1',
      deviceId: 'dev-1',
      deviceName: 'MacBook Pro',
      deviceLabel: 'MacBook Pro',
      accountId: 'account-1',
      platform: 4,
      sessions: [_session('session-1', current: true)],
      isCurrent: true,
    );
    return PaginationState(
      items: [item],
      isLoading: false,
      isReloading: false,
      totalCount: 1,
      hasMore: false,
      cursor: null,
    );
  }
}

/// Left inset of a session row's title inside the sheet.
Future<double> _rowInset(WidgetTester tester, Size surface) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final items = [
    _session('session-1', current: true),
    _session('session-2', label: _rowLabel),
  ];
  final container = ProviderContainer(
    overrides: [
      authDevicesProvider.overrideWith(_Devices.new),
      authSessionsProvider().overrideWith(
        (ref) async => PaginatedResult<SnAuthSession>(
          items: items,
          totalCount: items.length,
          hasMore: false,
        ),
      ),
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
            builder: (context) => MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              // The sheet is a modal capped at 640dp, but `MediaQuery` inside
              // it still reports the whole window.
              builder: (context, child) => MediaQuery(
                data: MediaQueryData(size: surface),
                child: child!,
              ),
              home: const Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 640,
                    child: AccountSessionSheet(initialIndex: 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();

  final title = find.text(_rowLabel);
  expect(title, findsOneWidget);
  return tester.getRect(title).left -
      tester.getRect(find.byType(SheetScaffold)).left;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('session rows use the sheet gutter on a phone', (tester) async {
    expect(await _rowInset(tester, const Size(600, 1200)), lessThan(120));
  });

  testWidgets('a desktop window does not inflate the row gutter', (
    tester,
  ) async {
    // The sheet is capped at 640dp, so a window-derived gutter swallows most
    // of its width; the inset must not track the window at all.
    expect(await _rowInset(tester, const Size(1400, 1200)), lessThan(120));
  });
}
