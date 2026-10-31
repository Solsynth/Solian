import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/thoughts/personality_api.dart';
import 'package:island/thoughts/thoughts_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _agent = SnPersonalityAgent(id: 'a1', name: 'Michan', enabled: true);

/// A turn whose events the test pushes one at a time, so the log can be read
/// mid-stream rather than only once the turn settled.
class _ScriptedApi extends PersonalityApi {
  _ScriptedApi() : super(Dio());

  StreamController<PersonalityRunEvent> events = StreamController();

  @override
  Future<String> createConversation({
    required String agentId,
    String title = '',
  }) async => 'c1';

  @override
  Future<SnConversationUsage> conversationUsage(String conversationId) async =>
      const SnConversationUsage(
        runs: 0,
        inputTokens: 0,
        outputTokens: 0,
        totalTokens: 0,
      );

  @override
  Stream<PersonalityRunEvent> runConversation({
    required String conversationId,
    required String message,
    List<String> attachmentIds = const [],
    List<SnRunInputPart> inputParts = const [],
    String? reasoningEffort,
    bool? disableReasoning,
    CancelToken? cancelToken,
  }) => events.stream;
}

/// Lets the controller drain whatever was just pushed into the stream.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ScriptedApi api;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    api = _ScriptedApi();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        personalityApiProvider.overrideWithValue(api),
        personalityAgentsProvider.overrideWith((ref) async => [_agent]),
        personalityConversationsProvider.overrideWith((ref) async => const []),
      ],
    );
    container.listen(thoughtsControllerProvider, (_, _) {});
    container.read(thoughtsControllerProvider);
  });

  tearDown(() {
    if (!api.events.isClosed) api.events.close();
    container.dispose();
  });

  List<ThoughtBubble> thoughts() => container
      .read(thoughtsControllerProvider)
      .bubbles
      .where((bubble) => bubble.kind == ThoughtBubbleKind.thinking)
      .toList();

  test('a new thought opens where the trace above it sits', () async {
    final controller = container.read(thoughtsControllerProvider.notifier);
    controller.selectAgent('a1');
    final pending = controller.send('hi');

    api.events.add(const PersonalityReasoningDelta('first thought'));
    await _settle();
    api.events.add(
      const PersonalityToolCallStarted(
        id: 'c1',
        name: 'search',
        arguments: {'q': 'x'},
      ),
    );
    api.events.add(
      const PersonalityToolCallCompleted(
        id: 'c1',
        name: 'search',
        arguments: {'q': 'x'},
        result: 'ok',
      ),
    );
    await _settle();
    api.events.add(const PersonalityReasoningDelta('second thought'));
    await _settle();

    final streamed = thoughts();
    expect(streamed.map((bubble) => bubble.text).toList(), [
      'first thought',
      'second thought',
    ]);
    // Nothing above the first thought of a turn, so it streams open.
    expect(streamed.first.collapsed, isFalse);
    // The trace above the second is a settled row: folded, so it stays folded.
    expect(streamed.last.streaming, isTrue);
    expect(streamed.last.collapsed, isTrue);

    api.events.add(const PersonalityRunCompleted('done'));
    // Closing is not awaited: a single-subscription controller only reports
    // `done` once the stream has a listener, and `send` is that listener.
    api.events.close();
    await pending;

    expect(thoughts().last.collapsed, isTrue);
  });

  test('a thought the reader opened keeps the next one open', () async {
    final notifier = container.read(thoughtsControllerProvider.notifier);
    notifier.selectAgent('a1');

    final firstTurn = notifier.send('hi');
    api.events.add(const PersonalityReasoningDelta('first thought'));
    api.events.add(const PersonalityRunCompleted('done'));
    api.events.close();
    await firstTurn;

    // The reader taps the folded thought open.
    final index = container
        .read(thoughtsControllerProvider)
        .bubbles
        .indexWhere((bubble) => bubble.kind == ThoughtBubbleKind.thinking);
    notifier.toggleTrace(index);
    expect(thoughts().single.collapsed, isFalse);
    expect(thoughts().single.touched, isTrue);

    final secondTurn = notifier.send('again');
    api.events = StreamController<PersonalityRunEvent>();
    api.events.add(const PersonalityReasoningDelta('second thought'));
    await _settle();

    expect(thoughts().last.collapsed, isFalse);
    api.events.close();
    await secondTurn;
  });

  test('a tool that never reports back ends as interrupted', () async {
    final notifier = container.read(thoughtsControllerProvider.notifier);
    notifier.selectAgent('a1');
    final pending = notifier.send('hi');
    api.events.add(
      const PersonalityToolCallStarted(
        id: 'c1',
        name: 'search',
        arguments: {'q': 'x'},
      ),
    );
    await _settle();
    api.events.close();
    await pending;

    final tool = container
        .read(thoughtsControllerProvider)
        .bubbles
        .firstWhere((bubble) => bubble.kind == ThoughtBubbleKind.tool);
    expect(tool.toolRunning, isFalse);
    expect(tool.toolResult, kThoughtToolResultInterrupted);
    expect(
      container.read(thoughtsControllerProvider).busy,
      isFalse,
    );
  });
}
