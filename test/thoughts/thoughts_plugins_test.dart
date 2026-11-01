import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/plugin_registry.dart';
import 'package:island/thoughts/plugins/social_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A client that records what each tool asked for and answers from a table, so
/// the assertions are about the request a tool builds rather than about parsing
/// a live gateway.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.respond);

  final Object? Function(RequestOptions options) respond;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(respond(options) ?? <String, dynamic>{}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingAdapter adapter;
  late SnPluginContext context;

  setUp(() {
    adapter = _RecordingAdapter((options) => <String, dynamic>{'id': 'x'});
    final dio = Dio(BaseOptions(baseUrl: 'https://gateway.test'));
    dio.httpClientAdapter = adapter;
    context = SnPluginContext(api: dio, http: dio);
  });

  Future<String> run(
    SocialPlugin plugin,
    String tool,
    Map<String, dynamic> arguments,
  ) {
    final definition = plugin
        .buildTools(context)
        .firstWhere((candidate) => candidate.name == tool);
    return definition.execute(arguments);
  }

  test('a reply names its parent on the wire', () async {
    await run(const SocialPlugin(), 'reply_to_post', {
      'post_id': 'p1',
      'content': 'hello',
    });

    final request = adapter.requests.single;
    expect(request.path, '/sphere/posts');
    expect(request.data, {
      'content': 'hello',
      'replied_post_id': 'p1',
    });
  });

  test('a missing argument is answered, not thrown', () async {
    final result = await run(const SocialPlugin(), 'reply_to_post', {
      'content': 'hello',
    });

    expect(adapter.requests, isEmpty);
    expect(jsonDecode(result), containsPair('error', contains('post_id')));
  });

  test('a failed request comes back as an answer the model can act on', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://gateway.test'));
    dio.httpClientAdapter = _RecordingAdapter(
      (_) => throw DioException(
        requestOptions: RequestOptions(path: '/sphere/posts'),
        response: Response(
          requestOptions: RequestOptions(path: '/sphere/posts'),
          statusCode: 401,
          data: {'message': 'Sign in again'},
        ),
        type: DioExceptionType.badResponse,
      ),
    );
    final failing = SnPluginContext(api: dio, http: dio);
    final tool = const SocialPlugin()
        .buildTools(failing)
        .firstWhere((candidate) => candidate.name == 'read_timeline');

    final result = await tool.execute(const {});

    expect(jsonDecode(result), containsPair('error', contains('Sign in')));
  });

  test('the plugin store key names this app, not the app it came from', () {
    expect(
      pluginStoreKey('social'),
      startsWith('solian_thought_plugin_'),
    );
  });

  test('the switch is the grant: an off plugin offers no tools', () async {
    SharedPreferences.setMockInitialValues({
      pluginStoreKey('social'): true,
      pluginStoreKey('chat'): false,
    });
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    final enabled = container.read(enabledPluginsProvider).map((p) => p.id);
    expect(enabled, contains('social'));
    expect(enabled, isNot(contains('chat')));

    // Social is on demand, so turning it on advertises the skill without
    // putting its tools on the run yet; an off plugin advertises neither.
    final skills = container.read(pluginSkillsProvider).map((s) => s.name);
    expect(skills, contains('social'));
    expect(skills, isNot(contains('chat')));

    final toolNames = container
        .read(pluginToolsProvider)
        .map((tool) => tool.name);
    expect(toolNames, isNot(contains('create_post')));
    // The activation tool is the one thing an on-demand-only run carries.
    expect(toolNames, contains(loadSkillToolName));
  });
}
