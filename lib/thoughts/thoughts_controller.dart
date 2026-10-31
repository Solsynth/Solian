import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart' show CancelToken, DioException, DioExceptionType;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/thoughts/personality_api.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Tool results that never come from the stream: recorded by history replay,
/// or by a turn that ended before the tool reported back. Kept as sentinels so
/// the raw protocol value survives in state and is localized at render time.
const String kThoughtToolResultInterrupted = 'interrupted';
const String kThoughtToolResultEarlierTurn = 'earlier turn';

enum ThoughtBubbleKind { user, assistant, thinking, tool }

/// Where an image chosen for the next message has got to.
enum ThoughtAttachmentUpload { ready, uploading, failed }

/// One image riding with a user turn: the drive file once it has landed, the
/// path it is read from while it is on this device, and how far the upload has
/// got.
@immutable
class ThoughtAttachment {
  const ThoughtAttachment({
    this.id = 0,
    this.fileId,
    required this.name,
    this.localPath,
    this.upload = ThoughtAttachmentUpload.ready,
    this.progress,
    this.error,
  });

  /// Identifies this attachment for as long as it is in the queue. An upload
  /// reports back against it, so a tile removed mid-flight — or the same file
  /// picked again — can never be mistaken for another.
  final int id;

  /// The drive file behind the attachment, once the upload has landed.
  final String? fileId;

  final String name;

  /// The picked file on this device. It is what the tile previews.
  final String? localPath;

  final ThoughtAttachmentUpload upload;

  /// How much of the upload has left this device, 0…1.
  final double? progress;

  final String? error;

  bool get isUploading => upload == ThoughtAttachmentUpload.uploading;

  bool get hasFailed => upload == ThoughtAttachmentUpload.failed;

  bool get isSendable => !isUploading && !hasFailed && (fileId ?? '').isNotEmpty;

  ThoughtAttachment copyWith({
    String? fileId,
    ThoughtAttachmentUpload? upload,
    double? progress,
    bool clearProgress = false,
    String? error,
    bool clearError = false,
  }) => ThoughtAttachment(
    id: id,
    fileId: fileId ?? this.fileId,
    name: name,
    localPath: localPath,
    upload: upload ?? this.upload,
    progress: clearProgress ? null : (progress ?? this.progress),
    error: clearError ? null : (error ?? this.error),
  );
}

/// One row of the conversation log. Assistant replies, reasoning traces and
/// tool calls are separate rows, exactly as the stream emits them.
@immutable
class ThoughtBubble {
  const ThoughtBubble({
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
    this.usage,
  });

  final ThoughtBubbleKind kind;
  final String text;
  final bool streaming;

  /// Trace detail folded away; a folded row reads as one log line.
  final bool collapsed;

  /// The reader toggled this row; auto-folding leaves it alone.
  final bool touched;

  /// Images persisted with a user message, or held for the next one.
  final List<ThoughtAttachment> attachments;

  /// Identifies the turn that created this row, so a completed turn can
  /// replace its streamed segments with the authoritative text.
  final int? turnId;

  final String? toolCallId;
  final Map<String, dynamic>? toolArgs;
  final String? toolResult;
  final bool toolRunning;

  /// What the turn that produced this row spent. Only the assistant row of a
  /// turn carries it.
  final SnRunUsage? usage;

  ThoughtBubble copyWith({
    String? text,
    bool? streaming,
    bool? collapsed,
    bool? touched,
    List<ThoughtAttachment>? attachments,
    Map<String, dynamic>? toolArgs,
    String? toolResult,
    bool? toolRunning,
    SnRunUsage? usage,
  }) => ThoughtBubble(
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
    usage: usage ?? this.usage,
  );
}

@immutable
class ThoughtsState {
  const ThoughtsState({
    this.bubbles = const [],
    this.pendingAttachments = const [],
    this.conversationId,
    this.agentId,
    this.busy = false,
    this.error,
    this.unauthorized = false,
    this.conversationUsage,
  });

  final List<ThoughtBubble> bubbles;

  /// Images picked for the next message.
  final List<ThoughtAttachment> pendingAttachments;

  final String? conversationId;
  final String? agentId;
  final bool busy;
  final String? error;

  /// Solar Network refused an operation outright: no session, an expired one,
  /// or no right to what was asked for. Kept apart from [error] because it is
  /// not a failure the reader can carry on past.
  final bool unauthorized;

  /// The conversation's token total, as the server reports it.
  final SnConversationUsage? conversationUsage;

  bool get attachmentsUploading =>
      pendingAttachments.any((attachment) => attachment.isUploading);

  bool get hasSendableAttachments =>
      pendingAttachments.any((attachment) => attachment.isSendable);

  ThoughtsState copyWith({
    List<ThoughtBubble>? bubbles,
    List<ThoughtAttachment>? pendingAttachments,
    String? conversationId,
    bool clearConversationId = false,
    String? agentId,
    bool? busy,
    String? error,
    bool clearError = false,
    bool? unauthorized,
    SnConversationUsage? conversationUsage,
    bool clearConversationUsage = false,
  }) => ThoughtsState(
    bubbles: bubbles ?? this.bubbles,
    pendingAttachments: pendingAttachments ?? this.pendingAttachments,
    conversationId: clearConversationId
        ? null
        : conversationId ?? this.conversationId,
    agentId: agentId ?? this.agentId,
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
    unauthorized: unauthorized ?? this.unauthorized,
    conversationUsage: clearConversationUsage
        ? null
        : conversationUsage ?? this.conversationUsage,
  );
}

/// One live conversation against the Personality backend, plus the account's
/// thread list.
final thoughtsControllerProvider =
    NotifierProvider<ThoughtsController, ThoughtsState>(ThoughtsController.new);

class ThoughtsController extends Notifier<ThoughtsState> {
  CancelToken? _cancelToken;
  int _turnSerial = 0;
  int _attachmentSerial = 0;
  bool _disposed = false;

  @override
  ThoughtsState build() {
    ref.onDispose(() {
      _disposed = true;
      _cancelToken?.cancel();
      _cancelToken = null;
    });
    return const ThoughtsState();
  }

  PersonalityApi get _api => ref.read(personalityApiProvider);

  /// Riverpod throws when a provider is written after disposal, and every
  /// write here can land after the page is popped mid-turn.
  void _set(ThoughtsState next) {
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
        clearConversationUsage: true,
      ),
    );
  }

  void newConversation() {
    if (state.busy) return;
    _set(
      state.copyWith(
        clearConversationId: true,
        bubbles: const [],
        clearError: true,
        clearConversationUsage: true,
      ),
    );
  }

  /// A conversation was deleted from the thread list. When it is the open one,
  /// the composer and thread reset exactly as starting a new chat does.
  void conversationRemoved(String id) {
    if (state.conversationId != id) return;
    newConversation();
  }

  void dismissError() => _set(state.copyWith(clearError: true));

  void clearUnauthorized() => _set(state.copyWith(unauthorized: false));

  void _fail(Object error) {
    if (_isAbort(error)) return;
    if (isPersonalityUnauthorized(error)) {
      _set(state.copyWith(unauthorized: true, clearError: true));
      return;
    }
    _set(state.copyWith(error: personalityErrorMessage(error)));
  }

  /// Opens a persisted thread and replays its messages into the log.
  Future<void> openConversation(String conversationId) async {
    if (state.busy) return;
    try {
      final messages = await _api.listMessages(conversationId);
      final agentId =
          ref
              .read(personalityConversationsProvider)
              .value
              ?.firstWhereOrNull((c) => c.id == conversationId)
              ?.agentId ??
          state.agentId;
      _set(
        state.copyWith(
          conversationId: conversationId,
          agentId: agentId,
          bubbles: [
            for (final message in messages) ..._bubblesFromMessage(message),
          ],
          clearError: true,
          unauthorized: false,
        ),
      );
      unawaited(_refreshUsage());
    } catch (e) {
      _fail(e);
    }
  }

  // ── Attachments ──────────────────────────────────────────────────────────

  /// Uploads the picked images to the drive and links them to the next turn.
  ///
  /// The tile appears as soon as the pick is queued, so the reader sees what
  /// they chose and how far it has got instead of an empty strip.
  Future<void> attachImages(List<UniversalFile> files) async {
    for (final file in files) {
      if (file.type != UniversalFileType.image) continue;
      final data = file.data;
      if (data is! XFile || data.path.isEmpty) continue;
      final name = (file.displayName ?? '').isEmpty
          ? data.name
          : file.displayName!;
      final attachment = ThoughtAttachment(
        id: ++_attachmentSerial,
        name: name,
        localPath: data.path,
        upload: ThoughtAttachmentUpload.uploading,
      );
      _set(
        state.copyWith(
          pendingAttachments: [...state.pendingAttachments, attachment],
        ),
      );
      try {
        final uploaded = await ref
            .read(driveFileUploaderProvider)
            .createCloudFile(
              fileData: UniversalFile(
                data: data,
                type: UniversalFileType.image,
                displayName: name,
              ),
              usage: 'ai_thought',
              onProgress: (progress, _) {
                if (_disposed) return;
                _updateAttachment(
                  attachment.id,
                  (queued) => queued.copyWith(progress: progress),
                );
              },
            )
            .future;
        if (uploaded == null) {
          throw const PersonalityException('The upload returned no file.');
        }
        if (_disposed) return;
        _updateAttachment(
          attachment.id,
          (queued) => queued.copyWith(
            fileId: uploaded.id,
            upload: ThoughtAttachmentUpload.ready,
            clearProgress: true,
            clearError: true,
          ),
        );
      } catch (error) {
        if (_disposed) return;
        _updateAttachment(
          attachment.id,
          (queued) => queued.copyWith(
            upload: ThoughtAttachmentUpload.failed,
            error: personalityErrorMessage(error),
            clearProgress: true,
          ),
        );
      }
    }
  }

  /// Links a file the drive already holds, by id. Nothing is uploaded.
  void linkCloudFile({required String fileId, String name = ''}) {
    final id = fileId.trim();
    if (id.isEmpty) return;
    if (state.pendingAttachments.any((queued) => queued.fileId == id)) return;
    _set(
      state.copyWith(
        pendingAttachments: [
          ...state.pendingAttachments,
          ThoughtAttachment(
            id: ++_attachmentSerial,
            fileId: id,
            name: name,
            upload: ThoughtAttachmentUpload.ready,
          ),
        ],
      ),
    );
  }

  void removePendingAttachment(int index) {
    if (index < 0 || index >= state.pendingAttachments.length) return;
    final next = List.of(state.pendingAttachments)..removeAt(index);
    _set(state.copyWith(pendingAttachments: next));
  }

  /// Sends one failed image up again.
  Future<void> retryAttachment(int index) async {
    if (index < 0 || index >= state.pendingAttachments.length) return;
    final attachment = state.pendingAttachments[index];
    if (!attachment.hasFailed || attachment.localPath == null) return;
    removePendingAttachment(index);
    await attachImages([
      UniversalFile(
        data: XFile(attachment.localPath!),
        type: UniversalFileType.image,
        displayName: attachment.name,
      ),
    ]);
  }

  /// Rewrites one queued attachment in place, leaving the rest of the queue —
  /// and the order the reader sees — untouched.
  void _updateAttachment(
    int id,
    ThoughtAttachment Function(ThoughtAttachment attachment) update,
  ) {
    final current = state.pendingAttachments;
    final index = current.indexWhere((queued) => queued.id == id);
    if (index < 0) return;
    final next = List.of(current);
    next[index] = update(current[index]);
    _set(state.copyWith(pendingAttachments: next));
  }


  // ── Sending ──────────────────────────────────────────────────────────────

  /// Sends one user turn: creates the thread on first use, then relays the
  /// streamed assistant reply into the log.
  Future<void> send(String text) async {
    final content = text.trim();
    final pending = state.pendingAttachments;
    if (state.busy || (content.isEmpty && pending.isEmpty)) return;
    if (state.attachmentsUploading) return;

    final turnId = ++_turnSerial;
    _set(
      state.copyWith(
        busy: true,
        clearError: true,
        bubbles: [
          ...state.bubbles,
          ThoughtBubble(
            kind: ThoughtBubbleKind.user,
            text: content,
            attachments: pending,
          ),
        ],
        pendingAttachments: const [],
      ),
    );

    try {
      var conversationId = state.conversationId;
      if (conversationId == null) {
        final agentId =
            state.agentId ??
            ref.read(personalityAgentsProvider).value?.firstOrNull?.id;
        if (agentId == null) {
          throw const PersonalityException('No agent available.');
        }
        conversationId = await _api.createConversation(agentId: agentId);
        _set(state.copyWith(conversationId: conversationId));
        ref.invalidate(personalityConversationsProvider);
      }

      final cancelToken = CancelToken();
      _cancelToken = cancelToken;
      final reasoningEffort = ref.read(thoughtReasoningEffortProvider);

      await for (final event in _api.runConversation(
        conversationId: conversationId,
        message: content,
        attachmentIds: [
          for (final attachment in pending)
            if (attachment.fileId != null) attachment.fileId!,
        ],
        reasoningEffort: reasoningEffort,
        disableReasoning: reasoningEffort == null ? null : false,
        cancelToken: cancelToken,
      )) {
        _handleEvent(event, turnId);
      }
    } catch (e) {
      _fail(e);
    } finally {
      _cancelToken = null;
      _finalizeTurn();
      _set(state.copyWith(busy: false));
      ref.invalidate(personalityConversationsProvider);
      unawaited(_refreshUsage());
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
    if (bubble.kind != ThoughtBubbleKind.thinking &&
        bubble.kind != ThoughtBubbleKind.tool) {
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
        _startToolBubble(id, name, arguments);
      case PersonalityToolCallCompleted(
        :final id,
        :final name,
        :final arguments,
        :final result,
      ):
        _completeToolCall(id, name, arguments, result);
      case PersonalityRunCompleted(:final content):
        _completeTurn(content, turnId);
      case PersonalityUsageReported(:final usage):
        _applyUsage(usage, turnId);
      case PersonalityRunFailed(:final error):
        _set(state.copyWith(error: error));
    }
  }

  /// The finished run's tokens, attached to the reply it belongs to. The
  /// per-conversation total is then re-read from the server.
  void _applyUsage(SnRunUsage usage, int turnId) {
    final bubbles = List.of(state.bubbles);
    final index = bubbles.lastIndexWhere(
      (b) => b.turnId == turnId && b.kind == ThoughtBubbleKind.assistant,
    );
    if (index >= 0) {
      bubbles[index] = bubbles[index].copyWith(usage: usage);
      _set(state.copyWith(bubbles: bubbles));
    }
    unawaited(_refreshUsage());
  }

  Future<void> _refreshUsage() async {
    final conversationId = state.conversationId;
    if (conversationId == null) {
      _set(state.copyWith(clearConversationUsage: true));
      return;
    }
    try {
      final usage = await _api.conversationUsage(conversationId);
      if (state.conversationId != conversationId) return;
      _set(state.copyWith(conversationUsage: usage));
    } catch (_) {
      // Informational only.
    }
  }

  void _startToolBubble(
    String id,
    String name,
    Map<String, dynamic> arguments,
  ) {
    final fold = _traceFold();
    _set(
      state.copyWith(
        bubbles: [
          ...state.bubbles,
          ThoughtBubble(
            kind: ThoughtBubbleKind.tool,
            text: name,
            toolCallId: id,
            toolArgs: arguments,
            toolRunning: true,
            collapsed: fold.collapsed,
            touched: fold.touched,
          ),
        ],
      ),
    );
  }

  /// The fold state a new trace row opens in: the state of the trace above it,
  /// the reader's pin included.
  ({bool collapsed, bool touched}) _traceFold() {
    for (final bubble in state.bubbles.reversed) {
      if (bubble.kind == ThoughtBubbleKind.thinking ||
          bubble.kind == ThoughtBubbleKind.tool) {
        return (collapsed: bubble.collapsed, touched: bubble.touched);
      }
    }
    // Nothing above it: the first trace of a turn streams open.
    return (collapsed: false, touched: false);
  }

  void _appendReasoningDelta(String delta) {
    final bubbles = List.of(state.bubbles);
    final last = bubbles.lastOrNull;
    // Reasoning that arrives after the reply started belongs to no trace.
    if (last != null && last.kind == ThoughtBubbleKind.assistant) return;
    if (last != null &&
        last.kind == ThoughtBubbleKind.thinking &&
        last.streaming) {
      bubbles[bubbles.length - 1] = last.copyWith(text: last.text + delta);
    } else {
      final fold = _traceFold();
      bubbles.add(
        ThoughtBubble(
          kind: ThoughtBubbleKind.thinking,
          text: delta,
          streaming: true,
          collapsed: fold.collapsed,
          touched: fold.touched,
        ),
      );
    }
    _set(state.copyWith(bubbles: bubbles));
  }

  /// Appends one reply delta to the turn's open text. A reply that resumes
  /// after a tool call opens a new row.
  void _appendAssistantDelta(String delta, int turnId) {
    _foldThinking();
    final bubbles = List.of(state.bubbles);
    final last = bubbles.lastOrNull;
    if (last != null &&
        last.kind == ThoughtBubbleKind.assistant &&
        last.turnId == turnId) {
      bubbles[bubbles.length - 1] = last.copyWith(text: last.text + delta);
    } else {
      bubbles.add(
        ThoughtBubble(
          kind: ThoughtBubbleKind.assistant,
          text: delta,
          streaming: true,
          turnId: turnId,
        ),
      );
    }
    _set(state.copyWith(bubbles: bubbles));
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
      final fold = _traceFold();
      bubbles.add(
        ThoughtBubble(
          kind: ThoughtBubbleKind.tool,
          text: name,
          toolCallId: id,
          toolArgs: arguments,
          toolResult: result,
          collapsed: fold.collapsed,
          touched: fold.touched,
        ),
      );
    }
    _set(state.copyWith(bubbles: bubbles));
  }

  /// Ends the turn with the authoritative text of its final reply: the
  /// trailing assistant rows of [turnId] are replaced by it.
  void _completeTurn(String content, int turnId) {
    final bubbles = List.of(state.bubbles);
    var start = bubbles.length;
    while (start > 0 &&
        bubbles[start - 1].kind == ThoughtBubbleKind.assistant &&
        bubbles[start - 1].turnId == turnId) {
      start--;
    }
    final trimmed = content.trim();
    bubbles.replaceRange(
      start,
      bubbles.length,
      [
        if (trimmed.isNotEmpty)
          ThoughtBubble(
            kind: ThoughtBubbleKind.assistant,
            text: trimmed,
            turnId: turnId,
          ),
      ],
    );
    _set(state.copyWith(bubbles: bubbles));
    _foldThinking();
  }

  /// The reply started or the turn ended; fold every open reasoning trace
  /// unless the reader pinned it.
  void _foldThinking() {
    final bubbles = List.of(state.bubbles);
    var changed = false;
    for (var i = 0; i < bubbles.length; i++) {
      final bubble = bubbles[i];
      if (bubble.kind != ThoughtBubbleKind.thinking || !bubble.streaming) {
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
    final bubbles = <ThoughtBubble>[];
    for (final bubble in state.bubbles) {
      var next = bubble;
      if (next.streaming) {
        next = next.copyWith(
          streaming: false,
          collapsed: next.kind == ThoughtBubbleKind.thinking && !next.touched
              ? true
              : next.collapsed,
        );
      }
      if (next.kind == ThoughtBubbleKind.tool && next.toolRunning) {
        next = next.copyWith(
          toolRunning: false,
          toolResult: next.toolResult ?? kThoughtToolResultInterrupted,
          collapsed: next.touched ? next.collapsed : true,
        );
      }
      if (next.kind == ThoughtBubbleKind.assistant &&
          next.text.trim().isEmpty) {
        continue;
      }
      bubbles.add(next);
    }
    _set(state.copyWith(bubbles: bubbles));
  }
}

/// Replays a persisted message into rows, exactly like the live stream does.
List<ThoughtBubble> _bubblesFromMessage(SnPersonalityMessage message) {
  switch (message.role) {
    case 'assistant':
      final bubbles = <ThoughtBubble>[];
      final reasoning = message.reasoningContent;
      if (reasoning != null) {
        bubbles.add(
          ThoughtBubble(
            kind: ThoughtBubbleKind.thinking,
            text: reasoning,
            collapsed: true,
          ),
        );
      }
      for (final call in message.toolCalls) {
        bubbles.add(
          ThoughtBubble(
            kind: ThoughtBubbleKind.tool,
            text: call.name,
            toolCallId: call.id,
            toolArgs: parsePersonalityToolArguments(call.arguments),
            toolResult: kThoughtToolResultEarlierTurn,
            collapsed: true,
          ),
        );
      }
      final content = message.content.trim();
      if (content.isNotEmpty) {
        bubbles.add(
          ThoughtBubble(kind: ThoughtBubbleKind.assistant, text: content),
        );
      }
      return bubbles;
    case 'user':
      final content = message.content.trim();
      final attachments = _attachmentsFromMessage(message);
      if (content.isEmpty && attachments.isEmpty) return const [];
      return [
        ThoughtBubble(
          kind: ThoughtBubbleKind.user,
          text: content,
          attachments: attachments,
        ),
      ];
    default:
      // Tool results belong to the call above them; skip orphaned rows.
      return const [];
  }
}

bool _isAbort(Object error) =>
    error is DioException && error.type == DioExceptionType.cancel;

/// The files a persisted user turn carried: the parts the model was handed, or
/// — for rows written before parts were stored — the drive ids alone.
List<ThoughtAttachment> _attachmentsFromMessage(SnPersonalityMessage message) {
  if (message.inputParts.isEmpty) {
    return [
      for (final id in message.attachmentIds)
        ThoughtAttachment(fileId: id, name: ''),
    ];
  }
  return [
    for (final part in message.inputParts)
      if ((part.attachmentId ?? '').isNotEmpty)
        ThoughtAttachment(
          fileId: part.attachmentId,
          name: part.name ?? '',
        ),
  ];
}

// ---------------------------------------------------------------------------
// Reasoning effort — a standing choice sent with every run
// ---------------------------------------------------------------------------

const kThoughtReasoningStoreKey = 'app_thought_reasoning_effort';

/// How hard the companion should think, persisted across launches.
///
/// Three levels, because the composer's pill has room for a dial, not a menu.
/// Null is the model's own default: the run goes out without an effort at all.
class ThoughtReasoningNotifier extends Notifier<String?> {
  @override
  String? build() {
    final stored = ref.watch(
      sharedPreferencesProvider.select(
        (prefs) => prefs.getString(kThoughtReasoningStoreKey),
      ),
    );
    final value = stored?.trim() ?? '';
    return value.isEmpty ? null : value;
  }

  Future<void> set(String? effort) async {
    final value = effort?.trim() ?? '';
    state = value.isEmpty ? null : value;
    final prefs = ref.read(sharedPreferencesProvider);
    if (state == null) {
      await prefs.remove(kThoughtReasoningStoreKey);
    } else {
      await prefs.setString(kThoughtReasoningStoreKey, state!);
    }
  }
}

final thoughtReasoningEffortProvider =
    NotifierProvider<ThoughtReasoningNotifier, String?>(
      ThoughtReasoningNotifier.new,
    );

/// Deletes one thread from the server, then takes it out of the list and out
/// of the open conversation.
Future<void> deleteThoughtConversation(WidgetRef ref, String id) async {
  final confirmed = await showConfirmAlert(
    'deleteConversationConfirmation'.tr(),
    'deleteConversation'.tr(),
    icon: Symbols.delete_rounded,
    isDanger: true,
  );
  if (!confirmed) return;
  try {
    await ref.read(personalityApiProvider).deleteConversation(id);
    ref.read(thoughtsControllerProvider.notifier).conversationRemoved(id);
    ref.invalidate(personalityConversationsProvider);
    showSnackBar('conversationDeleted'.tr());
  } catch (error) {
    showErrorAlert(error);
  }
}
