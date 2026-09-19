import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/me/ai_console.dart';
import 'package:island/core/config.dart';
import 'package:island/personality/personality_api.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';

const _agent = SnPersonalityAgent(id: 'a1', name: 'Michan', enabled: true);

class _FakePersonalityApi extends PersonalityApi {
  _FakePersonalityApi({this.reply = const [], this.history = const []})
    : super(Dio());

  final List<PersonalityRunEvent> reply;
  final List<SnPersonalityMessage> history;
  final List<String> sentMessages = [];

  @override
  Future<List<SnPersonalityConversation>> listConversations({
    int take = 50,
    int offset = 0,
  }) async => [
    SnPersonalityConversation(
      id: 'c1',
      agentId: 'a1',
      title: 'First thread',
      lastMessageAt: DateTime(2026, 1, 2),
    ),
  ];

  @override
  Future<List<SnPersonalityMessage>> listMessages(
    String conversationId, {
    int take = 200,
    int offset = 0,
  }) async => history;

  @override
  Future<String> createConversation({
    required String agentId,
    String title = '',
  }) async => 'c1';

  @override
  Stream<PersonalityRunEvent> runConversation({
    required String conversationId,
    required String message,
    List<String> attachmentIds = const [],
    CancelToken? cancelToken,
  }) {
    sentMessages.add(message);
    return Stream.fromIterable(reply);
  }
}

/// The screen needs an AutoRouter ancestor for its leading button, so the test
/// mounts the generated `/insight` route in a throwaway router.
class _InsightTestRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: InsightRoute.page, path: '/insight', initial: true),
    AutoRoute(page: AiConsoleRoute.page, path: '/ai-console'),
  ];
}

Future<void> _pumpInsightScreen(
  WidgetTester tester,
  _FakePersonalityApi api,
) async {
  final preferences = await SharedPreferences.getInstance();
  final routerConfig = _InsightTestRouter().config();
  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US')],
        path: 'assets/i18n',
        saveLocale: false,
        child: Builder(
          builder: (context) => ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(preferences),
              personalityApiProvider.overrideWithValue(api),
              personalityAgentsProvider.overrideWith((ref) async => [_agent]),
            ],
            child: mui.MaterialApp.router(
              routerConfig: routerConfig,
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              theme: mui.ThemeData(
                colorScheme: mui.ColorScheme.fromSeed(
                  seedColor: mui.Colors.indigo,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('shows the companion, the thread list, and the start hint', (
    tester,
  ) async {
    await _pumpInsightScreen(tester, _FakePersonalityApi());

    // The agent appears twice: in the header picker and as the row subtitle.
    expect(find.text('Michan'), findsNWidgets(2));
    expect(
      tester
          .widget<mui.DropdownButton<String>>(
            find.byType(mui.DropdownButton<String>),
          )
          .value,
      'a1',
    );
    expect(find.text('First thread'), findsOneWidget);
    expect(
      find.textContaining('start a conversation with Michan'),
      findsOneWidget,
    );
  });

  testWidgets('streams a turn into the thread log', (tester) async {
    final api = _FakePersonalityApi(
      reply: const [
        PersonalityReasoningDelta('weighing the options'),
        PersonalityMessageDelta('Hel'),
        PersonalityMessageDelta('lo'),
        PersonalityRunCompleted('Hello there'),
      ],
    );
    await _pumpInsightScreen(tester, api);

    await tester.enterText(find.byType(mui.TextField), 'hi there');
    await tester.pump();
    await tester.tap(find.byIcon(Symbols.send_rounded));
    await tester.pumpAndSettle();

    expect(api.sentMessages, ['hi there']);
    expect(find.text('hi there'), findsOneWidget);
    expect(find.text('Hello there', findRichText: true), findsOneWidget);
    // The reasoning trace folds itself once the reply starts.
    expect(find.text('thought'), findsOneWidget);
  });

  testWidgets('folds finished tool calls into one expandable row', (
    tester,
  ) async {
    final api = _FakePersonalityApi(
      reply: const [
        PersonalityToolCallStarted(
          id: 'c1',
          name: 'search',
          arguments: {'q': 'x'},
        ),
        PersonalityToolCallCompleted(
          id: 'c1',
          name: 'search',
          arguments: {'q': 'x'},
          result: 'ok',
        ),
        PersonalityRunCompleted('Done'),
      ],
    );
    await _pumpInsightScreen(tester, api);

    await tester.enterText(find.byType(mui.TextField), 'look it up');
    await tester.pump();
    await tester.tap(find.byIcon(Symbols.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('search'), findsOneWidget);
    // Settled machinery shows a one-line summary, not the full trace.
    expect(_plainText('ok'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is mui.SelectableText &&
            (widget.data?.contains('"q"') ?? false),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('search'));
    await tester.pumpAndSettle();

    // Opening the row swaps the summary for the arguments/result detail.
    expect(_plainText('ok'), findsNothing);
    expect(find.text('arguments'), findsOneWidget);
    expect(find.text('result'), findsOneWidget);
  });

  testWidgets('opens the thread list in a sheet on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpInsightScreen(tester, _FakePersonalityApi());

    // The side panel is a wide-screen affordance.
    expect(find.text('First thread'), findsNothing);

    await tester.tap(find.byIcon(Symbols.forum_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Conversations'), findsOneWidget);
    expect(find.text('First thread'), findsOneWidget);
  });

  testWidgets('opens the AI console from the header', (tester) async {
    await _pumpInsightScreen(tester, _FakePersonalityApi());

    await tester.tap(find.byIcon(Symbols.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(AiConsoleScreen), findsOneWidget);
  });

  testWidgets('toggles local web tools from the header', (tester) async {
    await _pumpInsightScreen(tester, _FakePersonalityApi());

    await tester.tap(find.byIcon(Symbols.public_rounded));
    await tester.pumpAndSettle();

    expect(find.text('insightLocalToolsHint'.tr()), findsOneWidget);
  });

  testWidgets('replays a persisted thread into the same rows', (tester) async {
    final api = _FakePersonalityApi(
      history: const [
        SnPersonalityMessage(
          role: 'user',
          content: 'what is up',
          attachmentIds: ['file-1'],
        ),
        SnPersonalityMessage(
          role: 'assistant',
          content: 'All good.\n\nSecond paragraph.',
          reasoningContent: 'checked the sky',
          toolCalls: [
            SnPersonalityToolCall(
              id: 't1',
              name: 'weather',
              arguments: '{"city":"Oslo"}',
            ),
          ],
        ),
        SnPersonalityMessage(role: 'tool', content: 'sunny'),
      ],
    );
    await _pumpInsightScreen(tester, api);

    await tester.tap(find.text('First thread'));
    await tester.pumpAndSettle();

    expect(find.text('what is up'), findsOneWidget);
    // Blank lines split the assistant reply into paragraph rows.
    expect(find.text('All good.', findRichText: true), findsOneWidget);
    expect(find.text('Second paragraph.', findRichText: true), findsOneWidget);
    // Reasoning and tool calls survive the round trip as folded traces.
    expect(find.text('thought'), findsOneWidget);
    expect(find.text('weather'), findsOneWidget);
    expect(_plainText('earlier turn'), findsOneWidget);
  });
}

/// Matches a plain [mui.Text] by its data, ignoring selectable trace detail.
Finder _plainText(String data) => find.byWidgetPredicate(
  (widget) => widget is mui.Text && widget.data == data,
);
