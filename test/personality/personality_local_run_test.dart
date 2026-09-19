import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/personality/local_web_tools.dart';
import 'package:island/personality/personality_api.dart';

// ---------------------------------------------------------------------------
// Fake HTTP layer — a scripted `HttpClientAdapter` (the pattern of
// test/drive/s3_direct_upload_test.dart) plus the interceptor that feeds it.
//
// The interceptor exists because a run posts through
// `Dio(options.copyWith(...))`: a fresh Dio always starts with the platform
// adapter, so interceptors — which _are_ carried over — are the only seam a
// test can reach the stream client through.
// ---------------------------------------------------------------------------

/// One scripted answer of the fake endpoint: status, body, and content type.
class _ScriptedReply {
  const _ScriptedReply(
    this.status,
    this.body, {
    this.contentType = 'text/event-stream',
  });

  final int status;
  final String body;
  final String contentType;
}

/// Serves the scripted replies in order, recording every request the client
/// actually put on the wire.
class _FakeChatAdapter implements HttpClientAdapter {
  _FakeChatAdapter(List<_ScriptedReply> replies) : _pending = [...replies];

  final List<_ScriptedReply> _pending;
  final List<RequestOptions> requests = [];
  final List<Map<String, dynamic>> requestBodies = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // An aborted request never reaches the wire, like the real adapter.
    final cancellation = options.cancelToken?.cancelError;
    if (cancellation != null) throw cancellation;

    requests.add(options);
    final builder = BytesBuilder(copy: false);
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        builder.add(chunk);
      }
    }
    requestBodies.add(
      jsonDecode(utf8.decode(builder.takeBytes())) as Map<String, dynamic>,
    );
    if (_pending.isEmpty) {
      throw StateError('The fake endpoint has no scripted reply left.');
    }
    final reply = _pending.removeAt(0);
    return ResponseBody.fromString(
      reply.body,
      reply.status,
      headers: {
        Headers.contentTypeHeader: [reply.contentType],
      },
    );
  }
}

/// Routes requests into [_FakeChatAdapter], reproducing what dio itself does
/// around the adapter: bad statuses become [DioException.badResponse] carrying
/// the still-readable error body.
class _AdapterBridge extends Interceptor {
  _AdapterBridge(this.adapter);

  final _FakeChatAdapter adapter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final body = await adapter.fetch(
        options,
        Stream.value(Uint8List.fromList(utf8.encode(jsonEncode(options.data)))),
        options.cancelToken?.whenCancel,
      );
      final response = Response<ResponseBody>(
        requestOptions: options,
        statusCode: body.statusCode,
        data: body,
      );
      if (options.validateStatus(body.statusCode)) {
        handler.resolve(response);
      } else {
        handler.reject(
          DioException.badResponse(
            statusCode: body.statusCode,
            requestOptions: options,
            response: response,
          ),
        );
      }
    } on DioException catch (error) {
      handler.reject(error);
    } catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }
}

Dio _client(_FakeChatAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://personality.test'));
  dio.interceptors.add(_AdapterBridge(adapter));
  return dio;
}

/// One `data:` frame of the streamed chat-completion grammar.
String _chunk(Map<String, dynamic> delta) =>
    'data: ${jsonEncode({
      'choices': [
        {'index': 0, 'delta': delta, 'finish_reason': null},
      ],
    })}\n\n';

/// An SSE body: the frames, then the terminal sentinel.
String _sse(List<String> frames) => [...frames, 'data: [DONE]\n\n'].join();

/// A fake `web_search_local` that reports what it was asked to run.
SnLocalTool _searchTool(List<Map<String, dynamic>> calls) => SnLocalTool(
  name: 'web_search_local',
  description: 'Search the web from this device',
  parameters: const {
    'type': 'object',
    'properties': {
      'query': {'type': 'string'},
    },
    'required': ['query'],
  },
  execute: (arguments) async {
    calls.add(arguments);
    return 'Dart is a language';
  },
);

const _toolCallFrame = {
  'tool_calls': [
    {
      'index': 0,
      'id': 'call_1',
      'type': 'function',
      'function': {
        'name': 'web_search_local',
        'arguments': '{"query":"dart"}',
      },
    },
  ],
};

void main() {
  test('streams a text turn and appends the assistant answer', () async {
    final adapter = _FakeChatAdapter([
      _ScriptedReply(
        200,
        _sse([
          _chunk({'reasoning_content': 'weighing'}),
          _chunk({'content': 'Hel'}),
          _chunk({'content': 'lo'}),
        ]),
      ),
    ]);
    final api = PersonalityApi(_client(adapter));
    final transcript = <Map<String, dynamic>>[
      {'role': 'user', 'content': 'hi'},
    ];

    final events = await api
        .runConversationWithLocalTools(
          agentId: 'agent-1',
          transcript: transcript,
          tools: const [],
        )
        .toList();

    expect(events, hasLength(4));
    expect((events[0] as PersonalityReasoningDelta).delta, 'weighing');
    expect((events[1] as PersonalityMessageDelta).delta, 'Hel');
    expect((events[2] as PersonalityMessageDelta).delta, 'lo');
    expect(events[3], isA<PersonalityRunCompleted>());
    expect((events[3] as PersonalityRunCompleted).content, 'Hello');

    expect(transcript, hasLength(2));
    expect(transcript.last, {'role': 'assistant', 'content': 'Hello'});

    // The stateless endpoint gets the client-owned history, the client-owned
    // tool list, and no server-owned tools — with timeouts off, since a tool
    // round may idle for minutes.
    final request = adapter.requests.single;
    expect(request.path, '/personality/v1/chat/completions');
    expect(request.headers['Accept'], 'text/event-stream');
    expect(request.receiveTimeout, Duration.zero);
    expect(adapter.requestBodies.single, {
      'agent_id': 'agent-1',
      'messages': [
        {'role': 'user', 'content': 'hi'},
      ],
      'tools': <Object>[],
      'server_tools': false,
      'stream': true,
    });
  });

  test('runs a client-owned tool and returns its result to the model', () async {
    final calls = <Map<String, dynamic>>[];
    final tool = _searchTool(calls);
    final adapter = _FakeChatAdapter([
      // The arguments arrive in fragments, as providers stream them.
      _ScriptedReply(
        200,
        _sse([
          _chunk({
            'tool_calls': [
              {
                'index': 0,
                'id': 'call_1',
                'type': 'function',
                'function': {
                  'name': 'web_search_local',
                  'arguments': '{"query":',
                },
              },
            ],
          }),
          _chunk({
            'tool_calls': [
              {
                'index': 0,
                'function': {'arguments': '"dart"}'},
              },
            ],
          }),
        ]),
      ),
      _ScriptedReply(200, _sse([_chunk({'content': 'Found it.'})])),
    ]);
    final api = PersonalityApi(_client(adapter));
    final transcript = <Map<String, dynamic>>[
      {'role': 'user', 'content': 'search dart'},
    ];

    final events = await api
        .runConversationWithLocalTools(
          agentId: 'agent-1',
          transcript: transcript,
          tools: [tool],
        )
        .toList();

    expect(events, [
      isA<PersonalityToolCallStarted>(),
      isA<PersonalityToolCallCompleted>(),
      // The final answer streams as deltas, then closes the turn.
      isA<PersonalityMessageDelta>(),
      isA<PersonalityRunCompleted>(),
    ]);
    final started = events[0] as PersonalityToolCallStarted;
    expect(started.id, 'call_1');
    expect(started.name, 'web_search_local');
    expect(started.arguments, {'query': 'dart'});

    final completed = events[1] as PersonalityToolCallCompleted;
    expect(completed.id, 'call_1');
    expect(completed.name, 'web_search_local');
    expect(completed.arguments, {'query': 'dart'});
    expect(completed.result, 'Dart is a language');
    expect((events[2] as PersonalityMessageDelta).delta, 'Found it.');
    expect((events[3] as PersonalityRunCompleted).content, 'Found it.');

    // The search ran here, on the parsed arguments.
    expect(calls, [
      {'query': 'dart'},
    ]);

    // The tool is declared to the endpoint in OpenAI form.
    final declared = (adapter.requestBodies[0]['tools'] as List).single as Map;
    expect(declared['type'], 'function');
    final function = declared['function'] as Map;
    expect(function['name'], 'web_search_local');
    expect(function['description'], 'Search the web from this device');
    expect(function['parameters'], tool.parameters);

    // Round two carries the whole exchange: the assistant's call and the tool
    // result the model must reason over, arguments concatenated from the two
    // fragments.
    expect(adapter.requestBodies, hasLength(2));
    expect(adapter.requestBodies[1]['messages'], [
      {'role': 'user', 'content': 'search dart'},
      {
        'role': 'assistant',
        'content': '',
        'tool_calls': [
          {
            'id': 'call_1',
            'type': 'function',
            'function': {
              'name': 'web_search_local',
              'arguments': '{"query":"dart"}',
            },
          },
        ],
      },
      {
        'role': 'tool',
        'tool_call_id': 'call_1',
        'name': 'web_search_local',
        'content': 'Dart is a language',
      },
    ]);
    expect(transcript, hasLength(4));
    expect(transcript.last, {'role': 'assistant', 'content': 'Found it.'});
  });

  test('an unknown tool name becomes an error result, not a crash', () async {
    final adapter = _FakeChatAdapter([
      _ScriptedReply(200, _sse([_chunk(_toolCallFrame)])),
      _ScriptedReply(200, _sse([_chunk({'content': 'no such tool'})])),
    ]);
    final api = PersonalityApi(_client(adapter));
    var ownedToolRan = false;

    final events = await api
        .runConversationWithLocalTools(
          agentId: 'agent-1',
          transcript: <Map<String, dynamic>>[
            {'role': 'user', 'content': 'search dart'},
          ],
          // The model asked for a tool this client does not own.
          tools: [
            SnLocalTool(
              name: 'web_fetch_local',
              description: 'Fetch a page from this device',
              parameters: const {'type': 'object'},
              execute: (_) async {
                ownedToolRan = true;
                return 'unreachable';
              },
            ),
          ],
        )
        .toList();

    expect(ownedToolRan, isFalse);

    final completed = events.whereType<PersonalityToolCallCompleted>().single;
    expect(completed.result, 'Error: unknown tool "web_search_local"');
    expect(events.last, isA<PersonalityRunCompleted>());
    expect((adapter.requestBodies[1]['messages'] as List)[2], {
      'role': 'tool',
      'tool_call_id': 'call_1',
      'name': 'web_search_local',
      'content': 'Error: unknown tool "web_search_local"',
    });
  });

  test('a tool that throws becomes an error result, not a crash', () async {
    final adapter = _FakeChatAdapter([
      _ScriptedReply(200, _sse([_chunk(_toolCallFrame)])),
      _ScriptedReply(200, _sse([_chunk({'content': 'ok'})])),
    ]);
    final api = PersonalityApi(_client(adapter));

    final events = await api
        .runConversationWithLocalTools(
          agentId: 'agent-1',
          transcript: <Map<String, dynamic>>[
            {'role': 'user', 'content': 'search dart'},
          ],
          tools: [
            SnLocalTool(
              name: 'web_search_local',
              description: 'Search the web from this device',
              parameters: const {'type': 'object'},
              execute: (_) async => throw StateError('search backend down'),
            ),
          ],
        )
        .toList();

    final completed = events.whereType<PersonalityToolCallCompleted>().single;
    expect(completed.result, startsWith('Error: '));
    expect(completed.result, contains('search backend down'));
    expect(events.last, isA<PersonalityRunCompleted>());
  });

  test('a server error body becomes the PersonalityException message', () async {
    const bodies = {
      '{"error":{"message":"model unavailable"}}': 'model unavailable',
      '{"error":"quota exhausted"}': 'quota exhausted',
    };

    for (final entry in bodies.entries) {
      final adapter = _FakeChatAdapter([
        _ScriptedReply(503, entry.key, contentType: 'application/json'),
      ]);
      final api = PersonalityApi(_client(adapter));

      await expectLater(
        api
            .runConversationWithLocalTools(
              agentId: 'agent-1',
              transcript: <Map<String, dynamic>>[
                {'role': 'user', 'content': 'hi'},
              ],
              tools: const [],
            )
            .toList(),
        throwsA(
          isA<PersonalityException>().having(
            (e) => e.message,
            'message',
            entry.value,
          ),
        ),
      );
    }
  });

  test('an unreadable error body falls back to a generic message', () async {
    final adapter = _FakeChatAdapter([
      _ScriptedReply(502, '<html>gateway</html>', contentType: 'text/html'),
    ]);
    final api = PersonalityApi(_client(adapter));

    await expectLater(
      api
          .runConversationWithLocalTools(
            agentId: 'agent-1',
            transcript: <Map<String, dynamic>>[
              {'role': 'user', 'content': 'hi'},
            ],
            tools: const [],
          )
          .toList(),
      throwsA(
        isA<PersonalityException>().having(
          (e) => e.message,
          'message',
          'Chat completion failed.',
        ),
      ),
    );
  });

  test('a cancelled turn surfaces the cancellation itself', () async {
    final adapter = _FakeChatAdapter([
      _ScriptedReply(200, _sse([_chunk({'content': 'hi'})])),
    ]);
    final api = PersonalityApi(_client(adapter));
    final cancelToken = CancelToken()..cancel('user stopped the turn');

    await expectLater(
      api
          .runConversationWithLocalTools(
            agentId: 'agent-1',
            transcript: <Map<String, dynamic>>[
              {'role': 'user', 'content': 'hi'},
            ],
            tools: const [],
            cancelToken: cancelToken,
          )
          .toList(),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
  });

  test('stops after maxRounds tool rounds without a final answer', () async {
    final calls = <Map<String, dynamic>>[];
    final adapter = _FakeChatAdapter([
      for (var round = 1; round <= 3; round++)
        _ScriptedReply(200, _sse([_chunk(_toolCallFrame)])),
    ]);
    final api = PersonalityApi(_client(adapter));
    final transcript = <Map<String, dynamic>>[
      {'role': 'user', 'content': 'search dart'},
    ];

    final events = await api
        .runConversationWithLocalTools(
          agentId: 'agent-1',
          transcript: transcript,
          tools: [_searchTool(calls)],
          maxRounds: 3,
        )
        .toList();

    expect(adapter.requestBodies, hasLength(3));
    expect(events.whereType<PersonalityToolCallStarted>(), hasLength(3));
    expect(events.whereType<PersonalityRunCompleted>(), isEmpty);
    final failed = events.last as PersonalityRunFailed;
    expect(failed.error, contains('3'));
    // Every round is on the record: the user turn, then each call plus result.
    expect(transcript, hasLength(1 + 3 * 2));
  });
}
