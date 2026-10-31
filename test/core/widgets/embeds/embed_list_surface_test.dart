import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/embeds/embed_list.dart';
import 'package:island/creators/screens/survey/survey_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    prefs = await SharedPreferences.getInstance();
  });

  Widget wrap(Widget child) => EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        home: ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 800,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [child],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(wrap(child));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
  }

  final notableDay = [
    {'type': 'notable_day', 'id': 'day-1'},
  ];

  ColorScheme schemeOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(EmbedListWidget))).colorScheme;

  testWidgets('embed cards paint on surfaceContainerLow', (tester) async {
    await pump(tester, EmbedListWidget(embeds: notableDay, maxWidth: 480));
    expect(
      tester.widget<Card>(find.byType(Card)).color,
      schemeOf(tester).surfaceContainerLow,
    );
  });

  testWidgets('link embed cards paint on surfaceContainerLow', (tester) async {
    final links = [
      {
        'type': 'link',
        'url': 'https://example.com/a',
        'title': 'Example',
        'description': 'Example description',
        'site_name': 'Example',
        'content_type': 'text/html',
      },
    ];
    await pump(tester, EmbedListWidget(embeds: links, maxWidth: 480));

    // AnimatedCrossFade keeps both the expanded and collapsed layouts built.
    final cards = tester.widgetList<Card>(find.byType(Card)).toList();
    expect(cards, isNotEmpty);
    for (final card in cards) {
      expect(card.color, schemeOf(tester).surfaceContainerLow);
    }
  });

  testWidgets('survey and calendar cards paint on surfaceContainerLow', (
    tester,
  ) async {
    await pump(
      tester,
      ProviderScope(
        overrides: [
          surveyWithStatsProvider('survey-1').overrideWith(
            (ref) => Future<SnSurveyWithStats>.error(Exception('offline')),
          ),
          calendarEventDetailProvider(('unknown', 'event-1')).overrideWith(
            (ref) => Future<SnUserCalendarEvent>.error(Exception('offline')),
          ),
        ],
        child: EmbedListWidget(
          embeds: const [
            {'type': 'survey'},
            {'type': 'survey', 'id': 'survey-1'},
            {'type': 'calendar_event', 'id': 'event-1'},
          ],
          maxWidth: 480,
        ),
      ),
    );

    final cards = tester.widgetList<Card>(find.byType(Card)).toList();
    expect(cards, hasLength(3));
    for (final card in cards) {
      expect(card.color, schemeOf(tester).surfaceContainerLow);
    }
  });

  testWidgets('maxWidth caps the embed list width', (tester) async {
    await pump(tester, EmbedListWidget(embeds: notableDay, maxWidth: 480));
    expect(tester.getSize(find.byType(EmbedListWidget)).width, 480);
    expect(tester.getSize(find.byType(Card)).width, 480);
  });

  testWidgets('without maxWidth the list fills the available width', (
    tester,
  ) async {
    await pump(tester, EmbedListWidget(embeds: notableDay));
    expect(tester.getSize(find.byType(EmbedListWidget)).width, 800);
  });
}
