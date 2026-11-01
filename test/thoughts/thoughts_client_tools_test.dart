import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/thoughts/personality_api.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/plugin_registry.dart';
import 'package:island/thoughts/thoughts_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _agent = SnPersonalityAgent(id: 'a1', name: 'Michan', enabled: true);

/// A turn whose events the test pushes one at a time, so a client tool call can
/// be answered mid-stream the way the server's namespace makes it arrive.
class _ToolApi extends PersonalityApi {
  _ToolApi() : super(Dio());

  StreamController<PersonalityRunEvent> events = StreamController();

  /// What the app handed back for the paused call, in the order it arrived.
  final List<({String runId, String toolCallId, String result, int tools})>
  submitted = [];

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
    List<Map<String, dynamic>> clientTools = const [],
    List<SnClientSkill> clientSkills = const [],
    List<String> overrides = const [],
    List<String> context = const [],
    String? reasoningEffort,
    bool? disableReasoning,
    CancelToken? cancelToken,
  }) {
    // The run the app starts is the run the tools are offered on; recording it
    // here is what lets the test assert the offer reached the wire at all.
    offeredTools = clientTools.length;
    return events.stream;
  }

  int offeredTools = 0;

  @override
  Future<void> submitClientToolResult({
    required String conversationId,
    required String runId,
    required String toolCallId,
    required String result,
    List<Map<String, dynamic>> clientTools = const [],
    List<String> overrides = const [],
  }) async {
    submitted.add((
      runId: runId,
      toolCallId: toolCallId,
      result: result,
      tools: clientTools.length,
    ));
  }
}

/// A plugin whose one tool answers from a table the test controls.
class _EchoPlugin extends SnPlugin {
  const _EchoPlugin(this.calls);

  final List<Map<String, dynamic>> calls;

  @override
  String get id => 'echo';

  @override
  String get label => 'Echo';

  @override
  String get description => '';

  @override
  String get summary => 'Answers with the argument it was given';

  @override
  bool get enabledByDefault => true;

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) => [
    SnLocalTool(
      name: 'echo',
      description: 'Echo one value back',
      parameters: const {
        'type': 'object',
        'properties': <String, dynamic>{
          'value': <String, dynamic>{'type': 'string'},
        },
        'required': <String>['value'],
      },
      execute: (arguments) async {
        calls.add(arguments);
        return 'echo:${arguments['value']}';
      },
    ),
  ];
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ToolApi api;
  late _EchoPlugin plugin;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    api = _ToolApi();
    plugin = _EchoPlugin([]);
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        personalityApiProvider.overrideWithValue(api),
        personalityAgentsProvider.overrideWith((ref) async => [_agent]),
        personalityConversationsProvider.overrideWith((ref) async => const []),
        pluginRegistryProvider.overrideWithValue([plugin]),
      ],
    );
    container.listen(thoughtsControllerProvider, (_, _) {});
    container.read(thoughtsControllerProvider);
  });

  tearDown(() {
    if (!api.events.isClosed) api.events.close();
    container.dispose();
  });

  test('a client tool call runs here and resumes the same run', () async {
    final controller = container.read(thoughtsControllerProvider.notifier);
    controller.selectAgent('a1');
    final pending = controller.send('look it up');

    // The model calls the tool under the server's namespace.
    api.events.add(
      const PersonalityToolCallClient(
        runId: 'r1',
        id: 'call-1',
        name: 'local_echo',
        arguments: {'value': 'hi'},
      ),
    );
    await _settle();

    expect(plugin.calls, hasLength(1));
    expect(plugin.calls.single['value'], 'hi');
    expect(api.submitted, hasLength(1));
    expect(api.submitted.single.runId, 'r1');
    expect(api.submitted.single.toolCallId, 'call-1');
    expect(api.submitted.single.result, 'echo:hi');

    // The trace row the call opened is still running until the server says it
    // completed, which is what keeps the dots alive during a slow tool.
    final tools = container
        .read(thoughtsControllerProvider)
        .bubbles
        .where((bubble) => bubble.kind == ThoughtBubbleKind.tool)
        .toList();
    expect(tools, hasLength(1));
    expect(tools.single.toolCallId, 'call-1');
    expect(tools.single.text, 'local_echo');

    api.events.add(
      const PersonalityToolCallCompleted(
        id: 'call-1',
        name: 'local_echo',
        arguments: {'value': 'hi'},
        result: 'echo:hi',
      ),
    );
    api.events.add(const PersonalityRunCompleted('done'));
    api.events.close();
    await pending;

    expect(
      container
          .read(thoughtsControllerProvider)
          .bubbles
          .firstWhere((bubble) => bubble.kind == ThoughtBubbleKind.tool)
          .toolResult,
      'echo:hi',
    );
  });

  test('the enabled plugins are offered on the run', () async {
    final controller = container.read(thoughtsControllerProvider.notifier);
    // Without a chosen agent the run cannot resolve a thread to start, which
    // is what a fresh page sets before its first message.
    controller.selectAgent('a1');
    final pending = controller.send('hi');
    // The run is started after the thread is created, so the offer lands one
    // async turn after `send` is called.
    await _settle();

    expect(api.offeredTools, 1);

    api.events.add(const PersonalityRunCompleted('done'));
    api.events.close();
    await pending;
  });

  test('an unknown tool is answered rather than left hanging', () async {
    final controller = container.read(thoughtsControllerProvider.notifier);
    controller.selectAgent('a1');
    final pending = controller.send('hi');

    api.events.add(
      const PersonalityToolCallClient(
        runId: 'r1',
        id: 'call-1',
        name: 'local_nope',
        arguments: <String, dynamic>{},
      ),
    );
    await _settle();

    expect(api.submitted, hasLength(1));
    expect(api.submitted.single.result, contains('unknown tool'));

    api.events.add(const PersonalityRunCompleted('done'));
    api.events.close();
    await pending;
  });

  test('a server-owned tool call is not intercepted', () async {
    final controller = container.read(thoughtsControllerProvider.notifier);
    controller.selectAgent('a1');
    final pending = controller.send('hi');

    // No `local_` prefix: the server ran it, and the client must not answer.
    api.events.add(
      const PersonalityToolCallStarted(
        id: 'call-1',
        name: 'web_search',
        arguments: {'query': 'x'},
      ),
    );
    await _settle();

    expect(api.submitted, isEmpty);

    api.events.add(const PersonalityRunCompleted('done'));
    api.events.close();
    await pending;
  });
}
