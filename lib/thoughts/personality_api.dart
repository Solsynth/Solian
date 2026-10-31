import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';

// ---------------------------------------------------------------------------
// Models — client-side mirrors of the PersonalityCore backend (`/personality`).
//
// Kept dependency-free (plain fromJson) because the typed SDK does not cover
// these endpoints.
// ---------------------------------------------------------------------------

@immutable
class SnPersonalityAgent {
  const SnPersonalityAgent({
    required this.id,
    required this.name,
    this.description,
    this.model,
    this.abilities = const [],
    this.enabled = false,
  });

  final String id;
  final String name;
  final String? description;
  final String? model;
  final List<String> abilities;
  final bool enabled;

  factory SnPersonalityAgent.fromJson(Map<String, dynamic> json) =>
      SnPersonalityAgent(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        model: json['model']?.toString(),
        abilities:
            (json['abilities'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        enabled: json['enabled'] is bool ? json['enabled'] as bool : false,
      );
}

/// One persisted thread (`GET /personality/conversations`), newest first.
@immutable
class SnPersonalityConversation {
  const SnPersonalityConversation({
    required this.id,
    required this.agentId,
    required this.title,
    this.lastMessageAt,
    this.groupId,
  });

  final String id;
  final String agentId;
  final String title;
  final DateTime? lastMessageAt;
  final String? groupId;

  factory SnPersonalityConversation.fromJson(Map<String, dynamic> json) {
    final groupId = json['group_id']?.toString();
    return SnPersonalityConversation(
      id: json['id']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      lastMessageAt: DateTime.tryParse(
        json['last_message_at']?.toString() ?? '',
      )?.toLocal(),
      groupId: groupId == null || groupId.isEmpty ? null : groupId,
    );
  }
}

/// A tool the assistant asked for while answering (metadata of a message).
@immutable
class SnPersonalityToolCall {
  const SnPersonalityToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  final String id;
  final String name;

  /// Raw JSON arguments string, exactly as persisted by the backend.
  final String arguments;

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

/// One part of a multimodal user message: text the caller contributes
/// directly, or a drive file the model reads as an image.
@immutable
class SnRunInputPart {
  const SnRunInputPart._({
    required this.type,
    this.text,
    this.name,
    this.attachmentId,
  });

  const SnRunInputPart.text(String text, {String name = ''})
    : this._(type: 'text', text: text, name: name);

  const SnRunInputPart.image(String attachmentId)
    : this._(type: 'image', attachmentId: attachmentId);

  final String type;
  final String? text;
  final String? name;
  final String? attachmentId;

  static List<SnRunInputPart> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final entry in raw.whereType<Map>())
        if (entry['type'] != null)
          SnRunInputPart._(
            type: entry['type'].toString(),
            text: entry['text']?.toString(),
            name: entry['name']?.toString(),
            attachmentId: entry['attachment_id']?.toString(),
          ),
    ];
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (text != null && text!.isNotEmpty) 'text': text,
    if (name != null && name!.isNotEmpty) 'name': name,
    if (attachmentId != null && attachmentId!.isNotEmpty)
      'attachment_id': attachmentId,
  };
}

/// One persisted message. Reasoning, tool calls and attachments ride under the
/// message's `metadata` bag rather than as top-level fields.
@immutable
class SnPersonalityMessage {
  const SnPersonalityMessage({
    required this.role,
    required this.content,
    this.attachmentIds = const [],
    this.inputParts = const [],
    this.reasoningContent,
    this.toolCalls = const [],
  });

  final String role;
  final String content;
  final List<String> attachmentIds;
  final List<SnRunInputPart> inputParts;
  final String? reasoningContent;
  final List<SnPersonalityToolCall> toolCalls;

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
      inputParts: SnRunInputPart.listFromJson(meta['input_parts']),
      reasoningContent: reasoning.isEmpty ? null : reasoning,
      toolCalls: SnPersonalityToolCall.listFromJson(meta['tool_calls']),
    );
  }
}

// ---------------------------------------------------------------------------
// Usage
// ---------------------------------------------------------------------------

int _usageInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw?.toString() ?? '') ?? 0;
}

double? _usageDouble(dynamic raw) {
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw.trim());
  return null;
}

int? _positiveOrNull(dynamic raw) {
  final value = _usageInt(raw);
  return value > 0 ? value : null;
}

/// How much one run spent.
@immutable
class SnRunUsage {
  const SnRunUsage({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.rounds,
    this.contextUsedTokens,
    this.contextWindowTokens,
    this.contextUsedRatio,
  });

  final int inputTokens;
  final int outputTokens;
  final int totalTokens;

  /// Model calls the run made. A tool-calling turn makes one per round.
  final int rounds;

  final int? contextUsedTokens;
  final int? contextWindowTokens;
  final double? contextUsedRatio;

  /// Reads a run's `usage` bag. A run the provider reported nothing for stores
  /// `{}`, which parses to null so callers render no footer instead of zeros.
  static SnRunUsage? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final input = _usageInt(json['input_tokens']);
    final output = _usageInt(json['output_tokens']);
    final total = _usageInt(json['total_tokens']);
    if (input == 0 && output == 0 && total == 0) return null;

    final context = json['context'];
    final contextJson = context is Map
        ? Map<String, dynamic>.from(context)
        : const <String, dynamic>{};
    return SnRunUsage(
      inputTokens: input,
      outputTokens: output,
      totalTokens: total == 0 ? input + output : total,
      rounds: _usageInt(json['rounds']),
      contextUsedTokens: _positiveOrNull(contextJson['used_tokens']),
      contextWindowTokens: _positiveOrNull(contextJson['window_tokens']),
      contextUsedRatio: _usageDouble(contextJson['used_ratio']),
    );
  }
}

/// The token total across every run in one conversation
/// (`GET /personality/conversations/:id/usage`).
@immutable
class SnConversationUsage {
  const SnConversationUsage({
    required this.runs,
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    this.peakContextUsedTokens,
    this.contextWindowTokens,
  });

  final int runs;
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final int? peakContextUsedTokens;
  final int? contextWindowTokens;

  factory SnConversationUsage.fromJson(Map<String, dynamic> json) =>
      SnConversationUsage(
        runs: _usageInt(json['runs']),
        inputTokens: _usageInt(json['input_tokens']),
        outputTokens: _usageInt(json['output_tokens']),
        totalTokens: _usageInt(json['total_tokens']),
        peakContextUsedTokens: _positiveOrNull(json['peak_context_used_tokens']),
        contextWindowTokens: _positiveOrNull(json['context_window_tokens']),
      );
}

// ---------------------------------------------------------------------------
// Run events — the `POST /personality/conversations/:id/runs` SSE grammar
// ---------------------------------------------------------------------------

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

/// What the finished run spent, reported after its text.
class PersonalityUsageReported extends PersonalityRunEvent {
  const PersonalityUsageReported(this.usage);
  final SnRunUsage usage;
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
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return error.message ?? error.toString();
  }
  return error.toString();
}

/// Whether [error] is Solar Network refusing the request itself: no session,
/// an expired one, or an account without the right to what was asked for.
bool isPersonalityUnauthorized(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    return status == 401 || status == 403;
  }
  return false;
}

/// Parses the run endpoint's `text/event-stream` framing into events.
///
/// `event:` names the type, `data:` carries one JSON payload, and a blank line
/// dispatches. Unknown events and malformed payloads are dropped rather than
/// failing the turn.
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
      case 'tool_call.client':
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
      case 'run.completed':
        final usage = SnRunUsage.fromJson(json['usage']);
        return usage == null ? null : PersonalityUsageReported(usage);
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
// Providers and client
// ---------------------------------------------------------------------------

/// The account's agent catalog.
final personalityAgentsProvider = FutureProvider<List<SnPersonalityAgent>>((
  ref,
) async {
  final resp = await ref.watch(apiClientProvider).get('/personality/agents');
  final data = resp.data;
  if (data is! List) return const [];
  return [
    for (final e in data.whereType<Map>())
      SnPersonalityAgent.fromJson(Map<String, dynamic>.from(e)),
  ];
});

/// The account's threads, newest first.
final personalityConversationsProvider =
    FutureProvider<List<SnPersonalityConversation>>((ref) {
      return ref.watch(personalityApiProvider).listConversations();
    });

final personalityApiProvider = Provider<PersonalityApi>(
  (ref) => PersonalityApi(ref.watch(apiClientProvider)),
);

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

  /// Deletes one thread, and with it its messages and runs.
  Future<void> deleteConversation(String id) async {
    await _client.delete(
      '/personality/conversations/${Uri.encodeComponent(id)}',
    );
  }

  /// Starts one assistant turn and relays its streamed events.
  Stream<PersonalityRunEvent> runConversation({
    required String conversationId,
    required String message,
    List<String> attachmentIds = const [],
    List<SnRunInputPart> inputParts = const [],
    String? reasoningEffort,
    bool? disableReasoning,
    CancelToken? cancelToken,
  }) async* {
    final response = await _streamClient().post<ResponseBody>(
      '/personality/conversations/${Uri.encodeComponent(conversationId)}/runs',
      data: {
        'message': message,
        'stream': true,
        if (attachmentIds.isNotEmpty) 'attachment_ids': attachmentIds,
        if (inputParts.isNotEmpty)
          'input_parts': [for (final part in inputParts) part.toJson()],
        if (reasoningEffort != null && reasoningEffort.trim().isNotEmpty)
          'reasoning_effort': reasoningEffort.trim(),
        'disable_reasoning': ?disableReasoning,
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

  /// The conversation's token total, summed from every run in it.
  Future<SnConversationUsage> conversationUsage(String conversationId) async {
    final resp = await _client.get(
      '/personality/conversations/${Uri.encodeComponent(conversationId)}/usage',
    );
    final data = resp.data;
    if (data is! Map) {
      return const SnConversationUsage(
        runs: 0,
        inputTokens: 0,
        outputTokens: 0,
        totalTokens: 0,
      );
    }
    return SnConversationUsage.fromJson(Map<String, dynamic>.from(data));
  }
}
