import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/personality/insight_chat_controller.dart';
import 'package:island/personality/local_web_tools.dart';
import 'package:island/personality/personality_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _agent = SnPersonalityAgent(id: 'a1', name: 'Michan', enabled: true);

/// Emulates the stateless local loop: appends the assistant turn to the
/// transcript and replays it as stream events, exactly like the real loop.
class _FakeLocalApi extends PersonalityApi {
  _FakeLocalApi() : super(Dio());

  int localRuns = 0;

  @override
  Future<String> createConversation({
    required String agentId,
    String title = '',
  }) async => 'conv-local';

  @override
  Stream<PersonalityRunEvent> runConversationWithLocalTools({
    required String agentId,
    required List<Map<String, dynamic>> transcript,
    required List<SnLocalTool> tools,
    CancelToken? cancelToken,
    int maxRounds = 6,
  }) async* {
    localRuns += 1;
    transcript.add(const {'role': 'assistant', 'content': 'local answer'});
    yield const PersonalityMessageDelta('local answer');
    yield const PersonalityRunCompleted('local answer');
  }
}

ProviderContainer _container(SharedPreferences prefs, _FakeLocalApi api) {
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      personalityApiProvider.overrideWithValue(api),
      personalityAgentsProvider.overrideWith((ref) async => [_agent]),
      localWebToolsProvider.overrideWithValue(const []),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('toggles local tools and persists the flag', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = _container(prefs, _FakeLocalApi());
    addTearDown(container.dispose);
    final controller = container.read(insightChatControllerProvider.notifier);

    expect(container.read(insightChatControllerProvider).localTools, isFalse);

    await controller.toggleLocalTools();
    expect(container.read(insightChatControllerProvider).localTools, isTrue);
    expect(prefs.getBool('insight.localTools'), isTrue);

    await controller.toggleLocalTools();
    expect(container.read(insightChatControllerProvider).localTools, isFalse);
    expect(prefs.getBool('insight.localTools'), isFalse);
  });

  test('local mode sends through the device loop and persists the transcript',
      () async {
    SharedPreferences.setMockInitialValues({'insight.localTools': true});
    final prefs = await SharedPreferences.getInstance();
    final api = _FakeLocalApi();
    final container = _container(prefs, api);
    addTearDown(container.dispose);
    final controller = container.read(insightChatControllerProvider.notifier);
    controller.selectAgent('a1');

    expect(container.read(insightChatControllerProvider).localTools, isTrue);
    await controller.send('hello');

    expect(api.localRuns, 1);
    final state = container.read(insightChatControllerProvider);
    expect(state.busy, isFalse);
    expect(
      state.bubbles.map((bubble) => bubble.kind).toList(),
      [InsightBubbleKind.user, InsightBubbleKind.assistant],
    );
    expect(state.bubbles.last.text, 'local answer');

    final saved = prefs.getString('insight.localTranscript.conv-local');
    expect(saved, isNotNull);
    expect(saved, contains('"role":"assistant"'));
    expect(saved, contains('local answer'));
  });

  test('local mode keeps the conversation context across turns', () async {
    SharedPreferences.setMockInitialValues({'insight.localTools': true});
    final prefs = await SharedPreferences.getInstance();
    final api = _FakeLocalApi();
    final container = _container(prefs, api);
    addTearDown(container.dispose);
    final controller = container.read(insightChatControllerProvider.notifier);
    controller.selectAgent('a1');

    await controller.send('first');
    await controller.send('second');

    final saved = prefs.getString('insight.localTranscript.conv-local')!;
    final decoded = List<Map<String, dynamic>>.from(
      (jsonDecode(saved) as List).cast<Map<String, dynamic>>(),
    );
    // Turn 1: user, assistant. Turn 2: user, assistant.
    expect(
      decoded.map((m) => m['role']).toList(),
      ['user', 'assistant', 'user', 'assistant'],
    );
  });

  test('local mode refuses attachments with a clear error', () async {
    SharedPreferences.setMockInitialValues({'insight.localTools': true});
    final prefs = await SharedPreferences.getInstance();
    final api = _FakeLocalApi();
    final container = _container(prefs, api);
    addTearDown(container.dispose);
    final controller = container.read(insightChatControllerProvider.notifier);

    controller.attachFiles(['f1']);
    await controller.send('hello');

    final state = container.read(insightChatControllerProvider);
    expect(api.localRuns, 0);
    expect(state.bubbles, isEmpty);
    expect(state.error, isNotNull);
    expect(state.pendingAttachments, ['f1']);
  });
}
