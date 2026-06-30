import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/screens/event_hub_screen.dart';
import 'package:island/accounts/screens/profile.dart';
import 'package:island/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('shows month by default and exposes agenda/day switches', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          eventCalendarProvider.overrideWith((ref, query) async => const []),
          accountProvider.overrideWith((ref, name) async => _account(name)),
        ],
        child: const MaterialApp(home: EventHubScreen(name: 'me')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Day'), findsOneWidget);
  });

  testWidgets('shows add action only for the current user', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          eventCalendarProvider.overrideWith((ref, query) async => const []),
          accountProvider.overrideWith((ref, name) async => _account(name)),
        ],
        child: const MaterialApp(home: EventHubScreen(name: 'someone')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsNothing);
  });
}

SnAccount _account(String name) {
  final now = DateTime(2026, 6, 30, 12);
  return SnAccount(
    id: 'account-$name',
    name: name,
    nick: name,
    language: 'en',
    isSuperuser: false,
    automatedId: null,
    profile: SnAccountProfile(
      id: 'profile-$name',
      experience: 0,
      level: 1,
      levelingProgress: 0,
      picture: null,
      background: null,
      verification: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    perkSubscription: null,
    activatedAt: now,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}
