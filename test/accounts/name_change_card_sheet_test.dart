import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/name_change_card_sheet.dart';
import 'package:island/creators/screens/publishers_form.dart'
    show publishersManagedProvider;
import 'package:island/realms/screens/realms.dart' show realmsJoinedProvider;
import 'package:material_ui/material_ui.dart' as mui;
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

class _FakeUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => _account;
}

SnNameChangeCardPurchase _purchase({
  required String id,
  DateTime? fulfilledAt,
  DateTime? consumedAt,
  SnNameChangeCardTargetType? targetType,
  String? targetId,
  String? oldName,
  String? newName,
}) {
  return SnNameChangeCardPurchase.fromJson({
    'id': id,
    'account_id': 'account-1',
    'order_id': 'order-$id',
    'amount': 100,
    'fulfilled_at': fulfilledAt?.toIso8601String(),
    'consumed_at': consumedAt?.toIso8601String(),
    'target_type': targetType?.wire,
    'target_id': targetId,
    'old_name': oldName,
    'new_name': newName,
    'created_at': '2026-08-15T12:00:00Z',
    'updated_at': '2026-08-15T12:00:00Z',
  });
}

SnRealm _realm({required String id, required String slug, required String accountId}) {
  return SnRealm.fromJson({
    'id': id,
    'slug': slug,
    'name': 'Realm $slug',
    'description': '',
    'verified_as': null,
    'verified_at': null,
    'is_community': false,
    'is_public': true,
    'picture': null,
    'background': null,
    'account_id': accountId,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
    'deleted_at': null,
  });
}

SnPublisher _publisher({
  required String id,
  required String name,
  required String accountId,
}) {
  return SnPublisher.fromJson({
    'id': id,
    'name': name,
    'nick': name,
    'account_id': accountId,
  });
}

Widget _wrap(Widget child, {List<Object?> overrides = const []}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => mui.MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        theme: mui.ThemeData(
          colorScheme: mui.ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: ProviderScope(
          overrides: overrides.cast(),
          child: mui.Material(child: child),
        ),
      ),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  List<Object?> overrides = const [],
}) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_wrap(child, overrides: overrides));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('renders price, cooldown, purchase button, and empty state', (
    tester,
  ) async {
    await _pump(
      tester,
      const NameChangeCardSheet(),
      overrides: [
        nameChangeCardsProvider.overrideWith((ref) async => []),
      ],
    );

    expect(find.text('100 points'), findsOneWidget);
    expect(find.text('Max 1 purchase per 30 days'), findsOneWidget);
    expect(find.text('Purchase'), findsOneWidget);
    expect(find.text('No name change cards yet.'), findsOneWidget);
  });

  testWidgets('shows ready, pending, and consumed purchase states', (
    tester,
  ) async {
    final cards = [
      _purchase(
        id: '1',
        fulfilledAt: DateTime.utc(2026, 8, 15, 12, 1),
      ),
      _purchase(id: '2'),
      _purchase(
        id: '3',
        fulfilledAt: DateTime.utc(2026, 8, 15, 12, 1),
        consumedAt: DateTime.utc(2026, 8, 15, 12, 5),
        targetType: SnNameChangeCardTargetType.account,
        oldName: 'alice',
        newName: 'alice_new',
      ),
    ];

    await _pump(
      tester,
      const NameChangeCardSheet(),
      overrides: [
        nameChangeCardsProvider.overrideWith((ref) async => cards),
      ],
    );

    expect(find.text('Ready to use'), findsOneWidget);
    expect(find.text('Awaiting payment'), findsOneWidget);
    expect(find.text('alice → alice_new'), findsOneWidget);
    // Only the fulfilled, unconsumed card is actionable.
    expect(find.text('Use card'), findsOneWidget);
  });

  testWidgets('use sheet rejects invalid account names without calling the API', (
    tester,
  ) async {
    final fulfilled = _purchase(
      id: '1',
      fulfilledAt: DateTime.utc(2026, 8, 15, 12, 1),
    );

    await _pump(
      tester,
      NameChangeCardUseSheet(purchase: fulfilled),
      overrides: [
        realmsJoinedProvider.overrideWith((ref) async => []),
        publishersManagedProvider.overrideWith((ref) async => []),
        userInfoProvider.overrideWith(() => _FakeUserInfo()),
      ],
    );

    // Account target is the default; current name hint is shown.
    expect(find.text('Current: @alice'), findsOneWidget);

    // Too short (1 char) fails validation.
    await tester.enterText(find.byType(mui.TextField), 'a');
    await tester.tap(find.text('Use card'));
    await tester.pumpAndSettle();
    expect(find.text('That name is not allowed.'), findsOneWidget);

    // Disallowed characters fail validation.
    await tester.enterText(find.byType(mui.TextField), 'has space!');
    await tester.tap(find.text('Use card'));
    await tester.pumpAndSettle();
    expect(find.text('That name is not allowed.'), findsOneWidget);
  });

  testWidgets('use sheet only offers owned realms and publishers', (
    tester,
  ) async {
    final fulfilled = _purchase(
      id: '1',
      fulfilledAt: DateTime.utc(2026, 8, 15, 12, 1),
    );

    await _pump(
      tester,
      NameChangeCardUseSheet(purchase: fulfilled),
      overrides: [
        realmsJoinedProvider.overrideWith(
          (ref) async => [
            _realm(id: 'realm-owned', slug: 'my-realm', accountId: 'account-1'),
            _realm(
              id: 'realm-other',
              slug: 'other-realm',
              accountId: 'account-9',
            ),
          ],
        ),
        publishersManagedProvider.overrideWith(
          (ref) async => [
            _publisher(id: 'pub-owned', name: 'pub1', accountId: 'account-1'),
            _publisher(id: 'pub-other', name: 'pub2', accountId: 'account-9'),
          ],
        ),
        userInfoProvider.overrideWith(() => _FakeUserInfo()),
      ],
    );

    // Select the realm target.
    await tester.tap(find.byType(mui.DropdownButtonFormField<SnNameChangeCardTargetType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Realm').last);
    await tester.pumpAndSettle();

    // The realm picker lists only the owned realm.
    await tester.tap(find.byType(mui.DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Realm my-realm (@my-realm)'), findsOneWidget);
    expect(find.text('Realm other-realm (@other-realm)'), findsNothing);
    await tester.tap(find.text('Realm my-realm (@my-realm)'));
    await tester.pumpAndSettle();

    // Select the publisher target; its picker also lists only the owned one.
    await tester.tap(find.byType(mui.DropdownButtonFormField<SnNameChangeCardTargetType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publisher').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(mui.DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('pub1 (@pub1)'), findsOneWidget);
    expect(find.text('pub2 (@pub2)'), findsNothing);
  });
}
