import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/thoughts/personality_api.dart';
import 'package:island/thoughts/screens/thoughts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApi extends PersonalityApi {
  _FakeApi() : super(Dio());

  @override
  Future<List<SnPersonalityConversation>> listConversations({
    int take = 50,
    int offset = 0,
  }) async => const [
    SnPersonalityConversation(
      id: 'c1',
      agentId: 'a1',
      title: 'Paris refactor',
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      // A stored session: the page renders its composer instead of the
      // sign-in. The token is never sent — every request is stubbed.
      kTokenPairStoreKey: '{"token":"stub","expires_at":"2099-01-01T00:00:00Z"}',
    });
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pump(WidgetTester tester, ProviderContainer container) async {
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
                localizationsDelegates: [
                  ...context.localizationDelegates,
                  ...flutter_localizations.GlobalMaterialLocalizations
                      .delegates,
                ],
                home: const Scaffold(body: ThoughtsScreen()),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('a signed-in page carries the composer and the thread panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        personalityApiProvider.overrideWithValue(_FakeApi()),
        personalityConversationsProvider.overrideWith(
          (ref) async => const [
            SnPersonalityConversation(
              id: 'c1',
              agentId: 'a1',
              title: 'Paris refactor',
            ),
          ],
        ),
        personalityAgentsProvider.overrideWith(
          (ref) async => const [
            SnPersonalityAgent(id: 'a1', name: 'Michan', enabled: true),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    await pump(tester, container);

    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);
    // The empty state names the agent the turn would go to.
    expect(find.text('What is on your mind?'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    // Wide layout: the thread list sits in the docked panel.
    expect(find.text('Paris refactor'), findsOneWidget);
  });
}
