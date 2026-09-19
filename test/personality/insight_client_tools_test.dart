import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/personality/insight_chat_controller.dart';
import 'package:island/personality/local_web_tools.dart';
import 'package:island/personality/personality_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _agent = SnPersonalityAgent(id: 'a1', name: 'Michan', enabled: true);

Future<String> _stubSearch(Map<String, dynamic> arguments) async =>
    'device result for ${arguments['query']}';

final _stubTool = SnLocalTool(
  name: 'web_search_local',
  description: 'Executes on this device in tests.',
  parameters: const {
    'type': 'object',
    'properties': {
      'query': {'type': 'string'},
    },
    'required': ['query'],
  },
  execute: _stubSearch,
);

/// Streams one client-tool handoff (optionally for an unknown tool) and then a
/// finished turn, recording what the controller asked the server to resume.
class _HandoffApi extends PersonalityApi {
  _HandoffApi({this.callName = 'web_search_local'}) : super(Dio());

  final String callName;
  List<SnLocalTool>? receivedClientTools;
  final List<(String, String, String, String)> resumed = [];

  @override
  Future<String> createConversation({
    required String agentId,
    String title = '',
  }) async => 'conv-h';

  @override
  Stream<PersonalityRunEvent> runConversation({
    required String conversationId,
    required String message,
    List<String> attachmentIds = const [],
    List<SnLocalTool> clientTools = const [],
    CancelToken? cancelToken,
  }) async* {
    receivedClientTools = clientTools;
    yield PersonalityToolCallClient(
      runId: 'run-1',
      id: 'call-local',
      name: callName,
      arguments: const {'query': 'duckdb'},
    );
    yield const PersonalityToolCallCompleted(
      id: 'call-local',
      name: 'web_search_local',
      arguments: {'query': 'duckdb'},
      result: 'Local search via Bing — 1 result(s)',
    );
    yield const PersonalityMessageDelta('Found it.');
    yield const PersonalityRunCompleted('Found it.');
  }

  @override
  Future<void> submitClientToolResult({
    required String conversationId,
    required String runId,
    required String toolCallId,
    required String result,
  }) async {
    resumed.add((conversationId, runId, toolCallId, result));
  }
}

ProviderContainer _container(SharedPreferences prefs, _HandoffApi api) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      personalityApiProvider.overrideWithValue(api),
      personalityAgentsProvider.overrideWith((ref) async => [_agent]),
      localWebToolsProvider.overrideWithValue([_stubTool]),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('offers the on-device tools on every run', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final api = _HandoffApi();
    final container = _container(prefs, api);
    addTearDown(container.dispose);
    final controller = container.read(insightChatControllerProvider.notifier);
    controller.selectAgent('a1');

    await controller.send('hello');

    expect(api.receivedClientTools, isNotNull);
    expect(api.receivedClientTools!.map((t) => t.name), ['web_search_local']);
  });

  test('executes a client tool on this device and resumes the run', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final api = _HandoffApi();
    final container = _container(prefs, api);
    addTearDown(container.dispose);
    final controller = container.read(insightChatControllerProvider.notifier);
    controller.selectAgent('a1');

    await controller.send('search duckdb');

    expect(api.resumed, hasLength(1));
    final (conversationId, runId, toolCallId, result) = api.resumed.single;
    expect(conversationId, 'conv-h');
    expect(runId, 'run-1');
    expect(toolCallId, 'call-local');
    expect(result, 'device result for duckdb');

    // The trace renders and the server's completion finishes it.
    final state = container.read(insightChatControllerProvider);
    expect(state.bubbles.map((bubble) => bubble.kind).toList(), [
      InsightBubbleKind.user,
      InsightBubbleKind.tool,
      InsightBubbleKind.assistant,
    ]);
    final toolBubble = state.bubbles[1];
    expect(toolBubble.toolRunning, isFalse);
    expect(toolBubble.toolResult, 'Local search via Bing — 1 result(s)');
    expect(state.bubbles.last.text, 'Found it.');
  });

  test('an unknown client tool becomes an error result, not a crash', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final api = _HandoffApi(callName: 'nope_local');
    final container = _container(prefs, api);
    addTearDown(container.dispose);
    final controller = container.read(insightChatControllerProvider.notifier);
    controller.selectAgent('a1');

    await controller.send('do the thing');

    expect(api.resumed, hasLength(1));
    expect(api.resumed.single.$4, contains('unknown tool'));
    expect(api.resumed.single.$4, contains('nope_local'));
  });
}
