import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart'
    show CancelToken, Dio, DioException, DioExceptionType;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/personality/insight_local_store.dart';
import 'package:island/personality/local_web_tools.dart';
import 'package:island/personality/personality_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insight_chat_controller.g.dart';

/// Tool results that never come from the stream: recorded by history replay,
/// or by a turn that ended before the tool reported back. Kept as sentinels so
/// the raw protocol value survives in state and is localized at render time.
const String kPersonalityToolResultInterrupted = 'interrupted';
const String kPersonalityToolResultEarlierTurn = 'earlier turn';
const String kPersonalityToolResultUnknownTool = 'unknown tool';

enum InsightBubbleKind { user, assistant, thinking, tool }

/// One row of the conversation log. Assistant replies, reasoning traces and
/// tool calls are separate rows, exactly as the stream emits them.
@immutable
class InsightBubble {
  final InsightBubbleKind kind;
  final String text;
  final bool streaming;

  /// Trace detail folded away; a folded row reads as one log line.
  final bool collapsed;

  /// The reader toggled this row; auto-folding leaves it alone.
  final bool touched;

  /// Drive file ids persisted with a user message.
  final List<String> attachments;

  /// Identifies the turn that created this row, so a completed turn can
  /// replace its streamed segments with the authoritative text.
  final int? turnId;

  final String? toolCallId;
  final Map<String, dynamic>? toolArgs;

  /// Resolved tool result, or a sentinel while it is still running.
  final String? toolResult;
  final bool toolRunning;

  const InsightBubble({
    required this.kind,
    required this.text,
    this.streaming = false,
    this.collapsed = false,
    this.touched = false,
    this.attachments = const [],
    this.turnId,
    this.toolCallId,
    this.toolArgs,
    this.toolResult,
    this.toolRunning = false,
  });

  InsightBubble copyWith({
    String? text,
    bool? streaming,
    bool? collapsed,
    bool? touched,
    List<String>? attachments,
    Map<String, dynamic>? toolArgs,
    String? toolResult,
    bool? toolRunning,
  }) => InsightBubble(
    kind: kind,
    text: text ?? this.text,
    streaming: streaming ?? this.streaming,
    collapsed: collapsed ?? this.collapsed,
    touched: touched ?? this.touched,
    attachments: attachments ?? this.attachments,
    turnId: turnId,
    toolCallId: toolCallId,
    toolArgs: toolArgs ?? this.toolArgs,
    toolResult: toolResult ?? this.toolResult,
    toolRunning: toolRunning ?? this.toolRunning,
  );
}

@immutable
class InsightChatState {
  final List<InsightBubble> bubbles;

  /// Drive file ids picked for the next message.
  final List<String> pendingAttachments;

  final String? conversationId;
  final String? agentId;
  final bool busy;
  final String? error;

  /// Web tools run on this device (stateless client loop) instead of the
  /// server; turns of this conversation are kept device-locally.
  final bool localTools;

  const InsightChatState({
    this.bubbles = const [],
    this.pendingAttachments = const [],
    this.conversationId,
    this.agentId,
    this.busy = false,
    this.error,
    this.localTools = false,
  });

  InsightChatState copyWith({
    List<InsightBubble>? bubbles,
    List<String>? pendingAttachments,
    String? conversationId,
    bool clearConversationId = false,
    String? agentId,
    bool? busy,
    String? error,
    bool clearError = false,
    bool? localTools,
  }) => InsightChatState(
    bubbles: bubbles ?? this.bubbles,
    pendingAttachments: pendingAttachments ?? this.pendingAttachments,
    conversationId: clearConversationId
        ? null
        : conversationId ?? this.conversationId,
    agentId: agentId ?? this.agentId,
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
    localTools: localTools ?? this.localTools,
  );
}

/// The Insight page: one live conversation against the Personality backend,
/// plus the account's thread list. Port of FloatLand's `pages/pet/index.vue` run
/// handling, including its reasoning/tool trace folding rules.
@riverpod
class InsightChatController extends _$InsightChatController {
  static final RegExp _paragraphBreak = RegExp(r'\n\s*\n');

  CancelToken? _cancelToken;
  int _turnSerial = 0;
  bool _disposed = false;

  /// Server-side history of the open conversation, as OpenAI messages for the
  /// local loop. Text only: tool/reasoning metadata lives server-side and is
  /// not replayed into the stateless completions endpoint.
  List<Map<String, dynamic>> _serverHistory = const [];

  /// Device-local turns of the open conversation (OpenAI messages), appended
  /// to [_serverHistory] on the wire and persisted per conversation.
  List<Map<String, dynamic>> _transcript = const [];

  @override
  InsightChatState build() {
    ref.onDispose(() {
      _disposed = true;
      _cancelToken?.cancel();
      _cancelToken = null;
    });
    return InsightChatState(
      localTools: ref.read(insightLocalStoreProvider).localToolsEnabled,
    );
  }

  PersonalityApi get _api => ref.read(personalityApiProvider);

  /// riverpod throws when a provider is written after disposal, and every
  /// write here can land after the page is popped mid-turn.
  void _set(InsightChatState next) {
    if (_disposed) return;
    state = next;
  }

  // ── Thread selection ─────────────────────────────────────────────────────

  void selectAgent(String agentId) {
    if (state.busy || agentId == state.agentId) return;
    _set(
      state.copyWith(
        agentId: agentId,
        clearConversationId: true,
        bubbles: const [],
      ),
    );
    _serverHistory = const [];
    _transcript = const [];
  }

  void newConversation() {
    if (state.busy) return;
    _set(
      state.copyWith(
        clearConversationId: true,
        bubbles: const [],
        clearError: true,
      ),
    );
    _serverHistory = const [];
    _transcript = const [];
  }

  void dismissError() => _set(state.copyWith(clearError: true));

  /// Switches the transport for the next turn: the server-side run loop, or
  /// the device-local stateless loop with the on-device web tools.
  Future<void> toggleLocalTools() async {
    if (state.busy) return;
    final enabled = !state.localTools;
    await ref.read(insightLocalStoreProvider).setLocalToolsEnabled(enabled);
    _set(state.copyWith(localTools: enabled));
  }

  // ── Conversations ────────────────────────────────────────────────────────

  /// Opens a persisted thread and replays its messages into the log.
  Future<void> openConversation(String conversationId) async {
    if (state.busy) return;
    try {
      final messages = await _api.listMessages(conversationId);
      if (_disposed) return;
      final agentId =
          ref
              .read(personalityConversationsProvider)
              .value
              ?.firstWhereOrNull((c) => c.id == conversationId)
              ?.agentId ??
          state.agentId;
      _serverHistory = [
        for (final message in messages)
          if (message.role == 'user' || message.role == 'assistant')
            _openAiMessage(message),
      ];
      _transcript = ref
          .read(insightLocalStoreProvider)
          .transcript(conversationId);
      _set(
        state.copyWith(
          conversationId: conversationId,
          agentId: agentId,
          bubbles: [
            for (final message in messages) ..._bubblesFromMessage(message),
          ],
          clearError: true,
        ),
      );
    } catch (e) {
      _set(state.copyWith(error: personalityErrorMessage(e)));
    }
  }

  // ── Attachments ──────────────────────────────────────────────────────────

  /// Queues already-uploaded drive files for the next message.
  void attachFiles(List<String> fileIds) {
    final ids = fileIds.where((id) => id.isNotEmpty);
    if (ids.isEmpty) return;
    _set(
      state.copyWith(pendingAttachments: [...state.pendingAttachments, ...ids]),
    );
  }

  void removePendingAttachment(int index) {
    if (index < 0 || index >= state.pendingAttachments.length) return;
    final next = List.of(state.pendingAttachments)..removeAt(index);
    _set(state.copyWith(pendingAttachments: next));
  }

  // ── Sending ──────────────────────────────────────────────────────────────

  /// Sends one user turn: creates the thread on first use, then relays the
  /// assistant reply into the log. In local-tools mode the reply comes from
  /// the device-local stateless loop instead of the server's run stream.
  Future<void> send(String text) async {
    final content = text.trim();
    final attachments = state.pendingAttachments;
    final localTools = state.localTools;
    if (state.busy || (content.isEmpty && attachments.isEmpty)) return;
    // The stateless completions endpoint accepts text parts only.
    if (localTools && attachments.isNotEmpty) {
      _set(state.copyWith(error: 'insightLocalNoAttachments'.tr()));
      return;
    }

    final turnId = ++_turnSerial;
    _set(
      state.copyWith(
        bubbles: [
          ...state.bubbles,
          InsightBubble(
            kind: InsightBubbleKind.user,
            text: content,
            attachments: attachments,
          ),
        ],
        pendingAttachments: const [],
        clearError: true,
      ),
    );

    try {
      var conversationId = state.conversationId;
      if (conversationId == null) {
        // The picker may never have been touched, in which case the first
        // available agent is the one the page is showing.
        final agentId =
            state.agentId ??
            ref.read(personalityAgentsProvider).value?.firstOrNull?.id;
        if (agentId == null) {
          throw PersonalityException('insightNoAgent'.tr());
        }
        conversationId = await _api.createConversation(agentId: agentId);
        if (_disposed) return;
        _set(state.copyWith(conversationId: conversationId));
        // The new thread belongs at the top of the list.
        ref.invalidate(personalityConversationsProvider);
      }

      final cancelToken = CancelToken();
      _cancelToken = cancelToken;
      _set(state.copyWith(busy: true));

      if (localTools) {
        final agentId =
            state.agentId ??
            ref.read(personalityAgentsProvider).value?.firstOrNull?.id;
        if (agentId == null) {
          throw PersonalityException('insightNoAgent'.tr());
        }
        // Everything before the server history is device-owned: the local
        // turns plus the new user message. The loop appends the assistant
        // tool calls, tool results and final reply to this list.
        final request = <Map<String, dynamic>>[
          ..._serverHistory,
          ..._transcript,
          {'role': 'user', 'content': content},
        ];
        await for (final event in _api.runConversationWithLocalTools(
          agentId: agentId,
          transcript: request,
          tools: ref.read(localWebToolsProvider),
          cancelToken: cancelToken,
        )) {
          if (_disposed) return;
          _handleEvent(event, turnId);
        }
        if (!_disposed) {
          _transcript = request.sublist(_serverHistory.length);
          await ref
              .read(insightLocalStoreProvider)
              .saveTranscript(conversationId, _transcript);
        }
      } else {
        await for (final event in _api.runConversation(
          conversationId: conversationId,
          message: content,
          attachmentIds: attachments,
          cancelToken: cancelToken,
        )) {
          if (_disposed) return;
          _handleEvent(event, turnId);
        }
      }
    } catch (e) {
      // An aborted turn keeps its partial text and ends silently.
      if (!_isAbort(e)) {
        _set(state.copyWith(error: personalityErrorMessage(e)));
      }
    } finally {
      _cancelToken = null;
      if (!_disposed) {
        _finalizeTurn();
        _set(state.copyWith(busy: false));
        ref.invalidate(personalityConversationsProvider);
      }
    }
  }

  /// Aborts the running turn; whatever streamed in stays on screen.
  void stop() {
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  void toggleTrace(int index) {
    if (index < 0 || index >= state.bubbles.length) return;
    final bubble = state.bubbles[index];
    if (bubble.kind != InsightBubbleKind.thinking &&
        bubble.kind != InsightBubbleKind.tool) {
      return;
    }
    final bubbles = List.of(state.bubbles);
    bubbles[index] = bubble.copyWith(
      collapsed: !bubble.collapsed,
      touched: true,
    );
    _set(state.copyWith(bubbles: bubbles));
  }

  // ── Stream handling ──────────────────────────────────────────────────────

  void _handleEvent(PersonalityRunEvent event, int turnId) {
    switch (event) {
      case PersonalityMessageDelta(:final delta):
        _appendAssistantDelta(delta, turnId);
      case PersonalityReasoningDelta(:final delta):
        _appendReasoningDelta(delta);
      case PersonalityToolCallStarted(:final id, :final name, :final arguments):
        _set(
          state.copyWith(
            bubbles: [
              ...state.bubbles,
              InsightBubble(
                kind: InsightBubbleKind.tool,
                text: name,
                toolCallId: id,
                toolArgs: arguments,
                toolRunning: true,
              ),
            ],
          ),
        );
      case PersonalityToolCallCompleted(
        :final id,
        :final name,
        :final arguments,
        :final result,
      ):
        _completeToolCall(id, name, arguments, result);
      case PersonalityRunCompleted(:final content):
        _completeTurn(content, turnId);
      case PersonalityRunFailed(:final error):
        // The run is over; surface it as a failed turn.
        _set(state.copyWith(error: error));
    }
  }

  void _appendReasoningDelta(String delta) {
    final bubbles = List.of(state.bubbles);
    final last = bubbles.lastOrNull;
    // Reasoning that arrives after the reply started belongs to no trace.
    if (last != null && last.kind == InsightBubbleKind.assistant) return;
    if (last != null &&
        last.kind == InsightBubbleKind.thinking &&
        last.streaming) {
      bubbles[bubbles.length - 1] = last.copyWith(text: last.text + delta);
    } else {
      bubbles.add(
        InsightBubble(
          kind: InsightBubbleKind.thinking,
          text: delta,
          streaming: true,
        ),
      );
    }
    _set(state.copyWith(bubbles: bubbles));
  }

  void _appendAssistantDelta(String delta, int turnId) {
    // The reply has started; reasoning is over.
    _foldThinking();
    final bubbles = List.of(state.bubbles);
    final last = bubbles.lastOrNull;
    if (last != null &&
        last.kind == InsightBubbleKind.assistant &&
        last.turnId == turnId) {
      bubbles[bubbles.length - 1] = last.copyWith(text: last.text + delta);
    } else {
      bubbles.add(
        InsightBubble(
          kind: InsightBubbleKind.assistant,
          text: delta,
          streaming: true,
          turnId: turnId,
        ),
      );
    }
    _set(state.copyWith(bubbles: bubbles));
    _splitStreamingBubble(turnId);
  }

  void _completeToolCall(
    String id,
    String name,
    Map<String, dynamic> arguments,
    String result,
  ) {
    final bubbles = List.of(state.bubbles);
    final index = bubbles.lastIndexWhere(
      (b) => b.toolCallId != null && b.toolCallId == id,
    );
    if (index >= 0) {
      final bubble = bubbles[index];
      bubbles[index] = bubble.copyWith(
        toolRunning: false,
        toolResult: result,
        toolArgs: arguments,
        collapsed: bubble.touched ? bubble.collapsed : true,
      );
    } else {
      bubbles.add(
        InsightBubble(
          kind: InsightBubbleKind.tool,
          text: name,
          toolCallId: id,
          toolArgs: arguments,
          toolResult: result,
          collapsed: true,
        ),
      );
    }
    _set(state.copyWith(bubbles: bubbles));
  }

  void _completeTurn(String content, int turnId) {
    // Deltas are already rendered; replace every row of this turn with the
    // authoritative persisted text, including segments split mid-stream.
    final bubbles = [
      for (final bubble in state.bubbles)
        if (bubble.turnId != turnId) bubble,
    ];
    for (final part in content.split(_paragraphBreak)) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty) {
        bubbles.add(
          InsightBubble(kind: InsightBubbleKind.assistant, text: trimmed),
        );
      }
    }
    _set(state.copyWith(bubbles: bubbles));
    _foldThinking();
  }

  /// The assistant marks message boundaries with a blank line; promote each
  /// finished segment into its own row while streaming.
  void _splitStreamingBubble(int turnId) {
    final bubbles = List.of(state.bubbles);
    final last = bubbles.lastOrNull;
    if (last == null || last.kind != InsightBubbleKind.assistant) return;
    if (!last.streaming) return;

    final parts = last.text.split(_paragraphBreak);
    if (parts.length < 2) return;

    bubbles[bubbles.length - 1] = last.copyWith(
      text: parts.removeLast().trim(),
    );
    bubbles.insertAll(bubbles.length - 1, [
      for (final part in parts)
        if (part.trim().isNotEmpty)
          InsightBubble(
            kind: InsightBubbleKind.assistant,
            text: part.trim(),
            streaming: true,
            turnId: turnId,
          ),
    ]);
    _set(state.copyWith(bubbles: bubbles));
  }

  /// The reply started or the turn ended; fold every open reasoning trace
  /// unless the reader pinned it.
  void _foldThinking() {
    final bubbles = List.of(state.bubbles);
    var changed = false;
    for (var i = 0; i < bubbles.length; i++) {
      final bubble = bubbles[i];
      if (bubble.kind != InsightBubbleKind.thinking || !bubble.streaming) {
        continue;
      }
      bubbles[i] = bubble.copyWith(
        streaming: false,
        collapsed: bubble.touched ? bubble.collapsed : true,
      );
      changed = true;
    }
    if (changed) _set(state.copyWith(bubbles: bubbles));
  }

  /// A turn ended while rows still showed as running (abort or error): log
  /// them as interrupted rather than leaving them spinning.
  void _finalizeTurn() {
    final bubbles = <InsightBubble>[];
    for (final bubble in state.bubbles) {
      var next = bubble;
      if (next.streaming) {
        next = next.copyWith(
          streaming: false,
          collapsed: next.kind == InsightBubbleKind.thinking && !next.touched
              ? true
              : next.collapsed,
        );
      }
      if (next.kind == InsightBubbleKind.tool && next.toolRunning) {
        next = next.copyWith(
          toolRunning: false,
          toolResult: next.toolResult ?? kPersonalityToolResultInterrupted,
          collapsed: next.touched ? next.collapsed : true,
        );
      }
      if (next.kind == InsightBubbleKind.assistant &&
          next.text.trim().isEmpty) {
        continue;
      }
      bubbles.add(next);
    }
    _set(state.copyWith(bubbles: bubbles));
  }
}

/// Replays a persisted message into rows, exactly like the live stream does.
List<InsightBubble> _bubblesFromMessage(SnPersonalityMessage message) {
  switch (message.role) {
    case 'assistant':
      final bubbles = <InsightBubble>[];
      final reasoning = message.reasoningContent;
      if (reasoning != null) {
        bubbles.add(
          InsightBubble(
            kind: InsightBubbleKind.thinking,
            text: reasoning,
            collapsed: true,
          ),
        );
      }
      for (final call in message.toolCalls) {
        bubbles.add(
          InsightBubble(
            kind: InsightBubbleKind.tool,
            text: call.name,
            toolCallId: call.id,
            toolArgs: parsePersonalityToolArguments(call.arguments),
            toolResult: kPersonalityToolResultEarlierTurn,
            collapsed: true,
          ),
        );
      }
      for (final part in message.content.split(
        InsightChatController._paragraphBreak,
      )) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty) {
          bubbles.add(
            InsightBubble(kind: InsightBubbleKind.assistant, text: trimmed),
          );
        }
      }
      return bubbles;
    case 'user':
      return [
        for (final part in message.content.split(
          InsightChatController._paragraphBreak,
        ))
          if (part.trim().isNotEmpty)
            InsightBubble(
              kind: InsightBubbleKind.user,
              text: part.trim(),
              attachments: message.attachmentIds,
            ),
      ];
    default:
      // Tool results belong to the call above them; skip orphaned rows.
      return const [];
  }
}

bool _isAbort(Object error) =>
    error is DioException && error.type == DioExceptionType.cancel;

/// The on-device web tools with a bare HTTP client: never carries the app's
/// Authorization header, so search-engine traffic leaves from the user's own
/// connection without leaking the account token.
final localWebToolsProvider = Provider<List<SnLocalTool>>((ref) {
  return buildLocalWebTools(Dio());
});

/// One persisted server message as OpenAI history for the local loop. Tool and
/// reasoning metadata is not replayed; their substance lives server-side.
Map<String, dynamic> _openAiMessage(SnPersonalityMessage message) {
  return {'role': message.role, 'content': message.content};
}
