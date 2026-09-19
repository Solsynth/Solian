import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/personality/local_web_tools.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'personality_api.g.dart';

// ---------------------------------------------------------------------------
// Models — local client-side mirrors of the PersonalityCore backend
// (`/personality`). Kept dependency-free (plain fromJson) since these are not
// part of the typed solar_network_sdk surface.
// ---------------------------------------------------------------------------

class SnPersonalityAgent {
  final String id;
  final String name;
  final String? description;
  final String? model;
  final List<String> abilities;
  final String? systemPrompt;
  final bool enabled;

  const SnPersonalityAgent({
    required this.id,
    required this.name,
    this.description,
    this.model,
    this.abilities = const [],
    this.systemPrompt,
    this.enabled = false,
  });

  factory SnPersonalityAgent.fromJson(Map<String, dynamic> json) =>
      SnPersonalityAgent(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description']?.toString(),
        model: json['model']?.toString(),
        abilities:
            (json['abilities'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        systemPrompt: json['system_prompt']?.toString(),
        enabled: json['enabled'] is bool ? json['enabled'] : false,
      );
}

/// One persisted thread (`GET /personality/conversations`), newest first.
@immutable
class SnPersonalityConversation {
  final String id;
  final String agentId;
  final String title;
  final DateTime? lastMessageAt;

  const SnPersonalityConversation({
    required this.id,
    required this.agentId,
    required this.title,
    this.lastMessageAt,
  });

  factory SnPersonalityConversation.fromJson(Map<String, dynamic> json) =>
      SnPersonalityConversation(
        id: json['id']?.toString() ?? '',
        agentId: json['agent_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        lastMessageAt: DateTime.tryParse(
          json['last_message_at']?.toString() ?? '',
        )?.toLocal(),
      );
}

/// A tool the assistant asked for while answering (metadata of a message).
@immutable
class SnPersonalityToolCall {
  final String id;
  final String name;

  /// Raw JSON arguments string, exactly as persisted by the backend.
  final String arguments;

  const SnPersonalityToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  /// Reads `metadata.tool_calls`, which nests the OpenAI `function` envelope:
  /// `[{"id": ..., "function": {"name": ..., "arguments": ...}}]`.
  static List<SnPersonalityToolCall> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    final calls = <SnPersonalityToolCall>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final fn = entry['function'];
      calls.add(
        SnPersonalityToolCall(
          id: entry['id']?.toString() ?? '',
          name: fn is Map ? fn['name']?.toString() ?? '' : '',
          arguments: fn is Map ? fn['arguments']?.toString() ?? '' : '',
        ),
      );
    }
    return calls;
  }
}

/// One persisted message. Reasoning, tool calls and attachments ride under the
/// message's `metadata` bag rather than as top-level fields.
@immutable
class SnPersonalityMessage {
  final String role;
  final String content;
  final List<String> attachmentIds;
  final String? reasoningContent;
  final List<SnPersonalityToolCall> toolCalls;
  final String? toolCallId;
  final String? toolName;

  const SnPersonalityMessage({
    required this.role,
    required this.content,
    this.attachmentIds = const [],
    this.reasoningContent,
    this.toolCalls = const [],
    this.toolCallId,
    this.toolName,
  });

  factory SnPersonalityMessage.fromJson(Map<String, dynamic> json) {
    final rawMeta = json['metadata'];
    final meta = rawMeta is Map
        ? Map<String, dynamic>.from(rawMeta)
        : const <String, dynamic>{};
    final reasoning = meta['reasoning_content']?.toString().trim() ?? '';
    final rawAttachments = meta['attachment_ids'];
    return SnPersonalityMessage(
      role: json['role']?.toString() ?? 'user',
      content: json['content']?.toString() ?? '',
      attachmentIds: rawAttachments is List
          ? [
              for (final id in rawAttachments)
                if (id.toString().isNotEmpty) id.toString(),
            ]
          : const [],
      reasoningContent: reasoning.isEmpty ? null : reasoning,
      toolCalls: SnPersonalityToolCall.listFromJson(meta['tool_calls']),
      toolCallId: meta['tool_call_id']?.toString(),
      toolName: meta['tool_name']?.toString(),
    );
  }
}

// ---------------------------------------------------------------------------
// Run events — the `POST /personality/conversations/:id/runs` SSE grammar
// ---------------------------------------------------------------------------

/// One event of a streamed assistant turn.
sealed class PersonalityRunEvent {
  const PersonalityRunEvent();
}

class PersonalityMessageDelta extends PersonalityRunEvent {
  const PersonalityMessageDelta(this.delta);
  final String delta;
}

class PersonalityReasoningDelta extends PersonalityRunEvent {
  const PersonalityReasoningDelta(this.delta);
  final String delta;
}

class PersonalityToolCallStarted extends PersonalityRunEvent {
  const PersonalityToolCallStarted({
    required this.id,
    required this.name,
    required this.arguments,
  });

  final String id;
  final String name;
  final Map<String, dynamic> arguments;
}

class PersonalityToolCallCompleted extends PersonalityRunEvent {
  const PersonalityToolCallCompleted({
    required this.id,
    required this.name,
    required this.arguments,
    required this.result,
  });

  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  final String result;
}

/// The persisted assistant text; the authoritative version of the deltas.
class PersonalityRunCompleted extends PersonalityRunEvent {
  const PersonalityRunCompleted(this.content);
  final String content;
}

class PersonalityRunFailed extends PersonalityRunEvent {
  const PersonalityRunFailed(this.error);
  final String error;
}

/// A Personality request failed; [message] is server-authored when available.
class PersonalityException implements Exception {
  const PersonalityException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A short, user-facing message for a failed Personality request.
String personalityErrorMessage(Object error) {
  if (error is PersonalityException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return error.message ?? error.toString();
  }
  return error.toString();
}

/// Parses the run endpoint's `text/event-stream` framing into events.
///
/// `event:` names the type, `data:` carries one JSON payload, and a blank line
/// dispatches. Unknown events and malformed payloads are dropped rather than
/// failing the turn, matching the web and watchOS clients.
Stream<PersonalityRunEvent> parsePersonalityRunEvents(
  Stream<List<int>> bytes,
) async* {
  String? eventName;
  final dataLines = <String>[];

  PersonalityRunEvent? dispatch() {
    final event = eventName;
    eventName = null;
    if (dataLines.isEmpty) return null;
    final payload = dataLines.join('\n');
    dataLines.clear();

    dynamic decoded;
    try {
      decoded = jsonDecode(payload);
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;
    final json = Map<String, dynamic>.from(decoded);

    switch (event) {
      case 'message.delta':
        final delta = json['delta'];
        return delta is String && delta.isNotEmpty
            ? PersonalityMessageDelta(delta)
            : null;
      case 'reasoning.delta':
        final delta = json['delta'];
        return delta is String && delta.isNotEmpty
            ? PersonalityReasoningDelta(delta)
            : null;
      case 'tool_call.delta':
        final name = json['name'];
        if (name is! String || name.isEmpty) return null;
        return PersonalityToolCallStarted(
          id: json['id']?.toString() ?? '',
          name: name,
          arguments: parsePersonalityToolArguments(json['arguments']),
        );
      case 'tool_call.completed':
        final name = json['name'];
        final result = json['result'];
        if (name is! String || name.isEmpty || result is! String) return null;
        return PersonalityToolCallCompleted(
          id: json['id']?.toString() ?? '',
          name: name,
          arguments: parsePersonalityToolArguments(json['arguments']),
          result: result,
        );
      case 'message.completed':
        final content = json['content'];
        if (content is! String || content.trim().isEmpty) return null;
        return PersonalityRunCompleted(content.trim());
      case 'run.failed':
        final error = json['error'];
        return PersonalityRunFailed(
          error is String && error.isNotEmpty
              ? error
              : 'Conversation run failed.',
        );
      default:
        return null;
    }
  }

  await for (final line
      in bytes.transform(utf8.decoder).transform(const LineSplitter())) {
    if (line.isEmpty) {
      final event = dispatch();
      if (event != null) yield event;
      continue;
    }
    if (line.startsWith('event:')) {
      eventName = line.substring(6).trim();
      continue;
    }
    if (line.startsWith('data:')) {
      dataLines.add(line.substring(5).trim());
    }
  }

  // A closed stream may end without the trailing blank line.
  final trailing = dispatch();
  if (trailing != null) yield trailing;
}

/// Tool arguments arrive either as a JSON object or as a JSON string.
Map<String, dynamic> parsePersonalityToolArguments(dynamic raw) {
  if (raw is Map) return Map<String, dynamic>.from(raw);
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // Malformed arguments: keep the trace visible without failing the turn.
    }
  }
  return const {};
}

// ---------------------------------------------------------------------------
// Client
// ---------------------------------------------------------------------------

final personalityApiProvider = Provider<PersonalityApi>(
  (ref) => PersonalityApi(ref.watch(apiClientProvider)),
);

@riverpod
Future<List<SnPersonalityAgent>> personalityAgents(Ref ref) async {
  final dio = ref.read(apiClientProvider);
  final resp = await dio.get('/personality/agents');
  final data = resp.data;
  if (data is List) {
    return [
      for (final e in data)
        SnPersonalityAgent.fromJson(e as Map<String, dynamic>),
    ];
  }
  return const [];
}

/// The account's threads, newest first.
@riverpod
Future<List<SnPersonalityConversation>> personalityConversations(Ref ref) {
  return ref.watch(personalityApiProvider).listConversations();
}

/// The account's personality threads and messages, plus the run stream that
/// drives one assistant turn.
class PersonalityApi {
  const PersonalityApi(this._client);

  final Dio _client;

  /// A copy of the API client with streaming timeouts disabled: a run may idle
  /// for minutes between deltas while a tool executes.
  Dio _streamClient() {
    final dio = Dio(
      _client.options.copyWith(
        receiveTimeout: Duration.zero,
        sendTimeout: Duration.zero,
      ),
    );
    dio.interceptors.addAll(_client.interceptors);
    return dio;
  }

  Future<List<SnPersonalityConversation>> listConversations({
    int take = 50,
    int offset = 0,
  }) async {
    final resp = await _client.get(
      '/personality/conversations',
      queryParameters: {'take': take, 'offset': offset},
    );
    final data = resp.data;
    if (data is! List) return const [];
    return [
      for (final e in data.whereType<Map>())
        SnPersonalityConversation.fromJson(Map<String, dynamic>.from(e)),
    ];
  }

  /// Messages of one thread, ordered by sequence ascending.
  Future<List<SnPersonalityMessage>> listMessages(
    String conversationId, {
    int take = 200,
    int offset = 0,
  }) async {
    final resp = await _client.get(
      '/personality/conversations/${Uri.encodeComponent(conversationId)}/messages',
      queryParameters: {'take': take, 'offset': offset},
    );
    final data = resp.data;
    if (data is! List) return const [];
    return [
      for (final e in data.whereType<Map>())
        SnPersonalityMessage.fromJson(Map<String, dynamic>.from(e)),
    ];
  }

  Future<String> createConversation({
    required String agentId,
    String title = '',
  }) async {
    final resp = await _client.post(
      '/personality/conversations',
      data: {'agent_id': agentId, 'title': title},
    );
    final data = resp.data;
    final id = data is Map ? data['id']?.toString() : null;
    if (id == null || id.isEmpty) {
      throw const PersonalityException('Conversation creation returned no id.');
    }
    return id;
  }

  /// Starts one assistant turn and relays its streamed events. [cancelToken]
  /// aborts the turn; the caller keeps whatever text already arrived.
  Stream<PersonalityRunEvent> runConversation({
    required String conversationId,
    required String message,
    List<String> attachmentIds = const [],
    CancelToken? cancelToken,
  }) async* {
    final response = await _streamClient().post<ResponseBody>(
      '/personality/conversations/${Uri.encodeComponent(conversationId)}/runs',
      data: {
        'message': message,
        'stream': true,
        if (attachmentIds.isNotEmpty) 'attachment_ids': attachmentIds,
      },
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: Duration.zero,
        sendTimeout: Duration.zero,
        headers: {'Accept': 'text/event-stream'},
      ),
    );

    final body = response.data;
    if (body == null) {
      throw const PersonalityException('Conversation stream unavailable.');
    }
    yield* parsePersonalityRunEvents(body.stream.cast<List<int>>());
  }

  /// Drives one assistant turn through the stateless OpenAI-compatible
  /// endpoint (`POST /personality/v1/chat/completions`), running the tools in
  /// [tools] on this device: the server hands every call of a client-owned
  /// tool straight back instead of executing it, which is what lets a web
  /// search leave from the user's own connection rather than the backend's
  /// egress IP.
  ///
  /// [transcript] is the caller-owned history: every message exchanged is
  /// appended to it (the assistant's text, its tool calls, and each tool
  /// result), so the caller can persist the thread. [maxRounds] caps the tool
  /// rounds, so an assistant that only ever asks for tools cannot loop
  /// forever.
  Stream<PersonalityRunEvent> runConversationWithLocalTools({
    required String agentId,
    required List<Map<String, dynamic>> transcript,
    required List<SnLocalTool> tools,
    CancelToken? cancelToken,
    int maxRounds = 6,
  }) async* {
    final client = _streamClient();
    final toolsByName = {for (final tool in tools) tool.name: tool};

    for (var round = 0; round < maxRounds; round++) {
      final ResponseBody body;
      try {
        final response = await client.post<ResponseBody>(
          '/personality/v1/chat/completions',
          data: {
            'agent_id': agentId,
            'messages': transcript,
            'tools': [for (final tool in tools) tool.toOpenAiTool()],
            'server_tools': false,
            'stream': true,
          },
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: Duration.zero,
            sendTimeout: Duration.zero,
            headers: {'Accept': 'text/event-stream'},
          ),
        );
        final received = response.data;
        if (received == null) {
          throw const PersonalityException('Conversation stream unavailable.');
        }
        body = received;
      } on DioException catch (error) {
        // A cancelled turn keeps its transport error: the caller tells "the
        // user stopped it" apart from "the server refused".
        if (CancelToken.isCancel(error)) rethrow;
        throw PersonalityException(
          await _chatCompletionErrorMessage(error.response?.data),
        );
      }

      final content = StringBuffer();

      // Tool calls stream in fragments, so they are merged by `index`: the id
      // and name arrive with the first fragment, the JSON arguments are
      // concatenated across the rest.
      final calls = <int, Map<String, dynamic>>{};

      await for (final line in body.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (!line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload.isEmpty) continue;
        if (payload == '[DONE]') break;

        dynamic decoded;
        try {
          decoded = jsonDecode(payload);
        } catch (_) {
          continue; // A malformed chunk must not kill the turn.
        }
        if (decoded is! Map) continue;
        final choices = decoded['choices'];
        if (choices is! List || choices.isEmpty) continue;
        final choice = choices.first;
        final delta = choice is Map ? choice['delta'] : null;
        if (delta is! Map) continue;

        final text = delta['content'];
        if (text is String && text.isNotEmpty) {
          content.write(text);
          yield PersonalityMessageDelta(text);
        }
        final reasoning = delta['reasoning_content'];
        if (reasoning is String && reasoning.isNotEmpty) {
          yield PersonalityReasoningDelta(reasoning);
        }
        final fragments = delta['tool_calls'];
        if (fragments is! List) continue;
        for (final fragment in fragments.whereType<Map>()) {
          final rawIndex = fragment['index'];
          final index = rawIndex is num ? rawIndex.toInt() : calls.length;
          final call = calls.putIfAbsent(
            index,
            () => {
              'id': '',
              'type': 'function',
              'function': <String, dynamic>{'name': '', 'arguments': ''},
            },
          );
          final id = fragment['id'];
          if (id is String && id.isNotEmpty && (call['id'] as String).isEmpty) {
            call['id'] = id;
          }
          final function = fragment['function'];
          if (function is! Map) continue;
          final target = call['function'] as Map<String, dynamic>;
          final name = function['name'];
          if (name is String &&
              name.isNotEmpty &&
              (target['name'] as String).isEmpty) {
            target['name'] = name;
          }
          final arguments = function['arguments'];
          if (arguments is String) {
            target['arguments'] = (target['arguments'] as String) + arguments;
          }
        }
      }

      if (calls.isEmpty) {
        final answer = content.toString();
        transcript.add({'role': 'assistant', 'content': answer});
        // Mirrors `parsePersonalityRunEvents`: an empty answer is no event.
        if (answer.trim().isNotEmpty) yield PersonalityRunCompleted(answer);
        return;
      }

      final toolCalls = [
        for (final index in calls.keys.toList()..sort()) calls[index]!,
      ];
      transcript.add({
        'role': 'assistant',
        'content': content.toString(),
        'tool_calls': toolCalls,
      });

      for (final call in toolCalls) {
        final id = call['id'] as String;
        final function = call['function'] as Map<String, dynamic>;
        final name = function['name'] as String;
        final arguments = parsePersonalityToolArguments(function['arguments']);
        yield PersonalityToolCallStarted(
          id: id,
          name: name,
          arguments: arguments,
        );

        // A broken tool (or one this client does not own) still owes the model
        // an answer, and neither may abort the turn.
        final tool = toolsByName[name];
        String result;
        if (tool == null) {
          result = 'Error: unknown tool "$name"';
        } else {
          try {
            result = await tool.execute(arguments);
          } catch (error) {
            result = 'Error: $error';
          }
        }

        yield PersonalityToolCallCompleted(
          id: id,
          name: name,
          arguments: arguments,
          result: result,
        );
        transcript.add({
          'role': 'tool',
          'tool_call_id': id,
          'name': name,
          'content': result,
        });
      }
    }

    yield PersonalityRunFailed(
      'Stopped after $maxRounds tool rounds without a final answer.',
    );
  }
}

/// Reads the message of a failed chat-completion request: the backend answers
/// `{"error": {"message": ...}}` (and sometimes `{"error": ...}`), anything
/// else collapses to a short generic message so the caller still has one.
Future<String> _chatCompletionErrorMessage(Object? body) async {
  const fallback = 'Chat completion failed.';
  if (body is! ResponseBody) return fallback;

  final String text;
  try {
    text = await utf8.decoder.bind(body.stream.cast<List<int>>()).join();
  } catch (_) {
    return fallback;
  }

  dynamic decoded;
  try {
    decoded = jsonDecode(text);
  } catch (_) {
    return fallback;
  }
  if (decoded is! Map) return fallback;

  final error = decoded['error'];
  if (error is String && error.isNotEmpty) return error;
  if (error is Map) {
    final message = error['message'];
    if (message is String && message.isNotEmpty) return message;
  }
  return fallback;
}
