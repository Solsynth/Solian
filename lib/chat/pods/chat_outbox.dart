import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/data/message_cache.dart';
import 'package:island/chat/data/message_repository.dart';
import 'package:island/chat/e2ee_message_service.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/send/message_sender.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/ios_share_suggestions.dart';
import 'package:island/data/message.dart';
import 'package:island/e2ee/e2ee.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:uuid/uuid.dart';

/// A message that is being sent independently of any open room screen.
enum ChatOutboxStatus { sending, failed }

/// Immutable view of one outgoing message, used by the room list to show that
/// a room has an in-flight or failed send.
class ChatOutboxEntry {
  final String id;
  final String roomId;
  final String content;
  final int attachmentCount;
  final bool isVoice;
  final ChatOutboxStatus status;
  final double? progress;
  final DateTime createdAt;
  final String? error;
  final String? pendingMessageId;
  final LocalChatMessage? pendingMessage;

  const ChatOutboxEntry({
    required this.id,
    required this.roomId,
    required this.content,
    required this.attachmentCount,
    required this.isVoice,
    required this.status,
    required this.createdAt,
    this.progress,
    this.error,
    this.pendingMessageId,
    this.pendingMessage,
  });

  ChatOutboxEntry copyWith({
    ChatOutboxStatus? status,
    double? progress,
    String? error,
    bool clearError = false,
    String? pendingMessageId,
    LocalChatMessage? pendingMessage,
  }) {
    return ChatOutboxEntry(
      id: id,
      roomId: roomId,
      content: content,
      attachmentCount: attachmentCount,
      isVoice: isVoice,
      status: status ?? this.status,
      progress: progress,
      createdAt: createdAt,
      error: clearError ? null : (error ?? this.error),
      pendingMessageId: pendingMessageId ?? this.pendingMessageId,
      pendingMessage: pendingMessage ?? this.pendingMessage,
    );
  }
}

/// Events emitted while a send progresses.
///
/// A room's [MessagesNotifier] subscribes to these while the room screen is
/// mounted. The send itself lives in [ChatOutboxNotifier], which is an
/// app-wide provider, so leaving the screen cannot cancel it; a later screen
/// rebuild reconstructs the timeline from the messages persisted to the DB.
sealed class ChatOutboxEvent {
  final String roomId;

  const ChatOutboxEvent(this.roomId);
}

class ChatOutboxPendingEvent extends ChatOutboxEvent {
  final LocalChatMessage message;

  const ChatOutboxPendingEvent(super.roomId, this.message);
}

class ChatOutboxProgressEvent extends ChatOutboxEvent {
  final String messageId;
  final double progress;

  const ChatOutboxProgressEvent(
    super.roomId, {
    required this.messageId,
    required this.progress,
  });
}

class ChatOutboxCompletedEvent extends ChatOutboxEvent {
  final String pendingMessageId;
  final LocalChatMessage message;
  final LocalChatMessage? eventMessage;
  final bool isEditing;

  const ChatOutboxCompletedEvent(
    super.roomId, {
    required this.pendingMessageId,
    required this.message,
    this.eventMessage,
    this.isEditing = false,
  });
}

class ChatOutboxFailedEvent extends ChatOutboxEvent {
  final String pendingMessageId;
  final LocalChatMessage? pendingMessage;
  final String error;

  const ChatOutboxFailedEvent(
    super.roomId, {
    required this.pendingMessageId,
    required this.error,
    this.pendingMessage,
  });
}

/// Pending messages shared by the room notifier, the sync service and the
/// outbox.
///
/// The sync service uses it to preserve the plaintext of an E2EE message the
/// user sent when the server echo arrives. It must therefore be app-wide: an
/// in-flight send can outlive the room provider that started it.
final chatPendingMessageCacheProvider = Provider<PendingMessageCache>(
  (ref) => PendingMessageCache(),
);

class _ChatSendRequest {
  final String roomId;
  final String content;
  final List<UniversalFile> attachments;
  final SnChatMember sender;
  final int encryptionMode;
  final String? mlsGroupId;
  final List<Map<String, dynamic>>? embeds;
  final SnChatMessage? editingTo;
  final SnChatMessage? forwardingTo;
  final SnChatMessage? replyingTo;
  final SnChatMessage? threadingTo;
  final bool isVoice;
  final String? voiceFilePath;
  final int? voiceDurationMs;

  const _ChatSendRequest({
    required this.roomId,
    required this.content,
    required this.attachments,
    required this.sender,
    required this.encryptionMode,
    required this.mlsGroupId,
    this.embeds,
    this.editingTo,
    this.forwardingTo,
    this.replyingTo,
    this.threadingTo,
    this.isVoice = false,
    this.voiceFilePath,
    this.voiceDurationMs,
  });
}

class _ChatSendTask {
  final String entryId;
  final _ChatSendRequest request;
  final MessageSender sender;
  final MessageRepository repository;

  LocalChatMessage? pending;
  double? lastReportedProgress;
  bool cancelled = false;
  bool finalized = false;
  String? finalizedMessageId;

  _ChatSendTask({
    required this.entryId,
    required this.request,
    required this.sender,
    required this.repository,
  });
}

/// App-wide send queue for chat messages.
///
/// Sending used to be a method on the room-scoped [MessagesNotifier], which
/// meant the provider had to be kept alive (and its `ref` kept valid) for the
/// whole upload. This notifier owns the actual send instead, so navigation is
/// irrelevant: the task keeps running, persists its result, and the room list
/// can show its status until it settles.
class ChatOutboxNotifier extends Notifier<Map<String, List<ChatOutboxEntry>>> {
  final _logger = Logger('ChatOutbox');
  final _eventController = StreamController<ChatOutboxEvent>.broadcast();
  final Map<String, _ChatSendTask> _tasks = {};

  @override
  Map<String, List<ChatOutboxEntry>> build() {
    ref.onDispose(() {
      _eventController.close();
    });
    return const {};
  }

  Stream<ChatOutboxEvent> get events => _eventController.stream;

  List<ChatOutboxEntry> entriesForRoom(String roomId) =>
      state[roomId] ?? const <ChatOutboxEntry>[];

  ChatOutboxEntry? latestForRoom(String roomId) =>
      entriesForRoom(roomId).lastOrNull;

  bool canRetry(String roomId, String messageId) {
    return entriesForRoom(roomId).any((entry) {
      final task = _tasks[entry.id];
      return entry.status == ChatOutboxStatus.failed &&
          task != null &&
          !task.request.isVoice &&
          (entry.id == messageId || entry.pendingMessageId == messageId);
    });
  }

  /// Marks a send as already confirmed by the server.
  ///
  /// The realtime `messages.sync.finalize` / `messages.new` frame can arrive
  /// before the device-specific acknowledgement the sender awaits. Once the
  /// timeline has the confirmed row, a later sender timeout must not put the
  /// message back into the failed state (or leave a failed row in the list).
  void markFinalized(String roomId, LocalChatMessage message) {
    final entry = entriesForRoom(roomId).where((item) {
      final pending = item.pendingMessage;
      return item.pendingMessageId == message.id ||
          pending?.id == message.id ||
          (pending?.clientMessageId != null &&
              pending!.clientMessageId == message.clientMessageId);
    }).lastOrNull;
    if (entry == null) return;

    final task = _tasks[entry.id];
    if (task != null) {
      task.finalized = true;
      task.finalizedMessageId = message.id;
    }
    _removeEntry(entry.id);
  }

  /// Starts sending a text message (or an edit) and returns when it settles.
  ///
  /// The returned future is only for callers that want to react in their own
  /// widget (the thread panel refreshes after it). The send itself is not tied
  /// to that future or to the calling provider.
  Future<SendResult> enqueueText({
    required String roomId,
    required String content,
    required List<UniversalFile> attachments,
    required SnChatMember sender,
    required int encryptionMode,
    String? mlsGroupId,
    List<Map<String, dynamic>>? embeds,
    SnChatMessage? editingTo,
    SnChatMessage? forwardingTo,
    SnChatMessage? replyingTo,
    SnChatMessage? threadingTo,
  }) async {
    if (content.trim().isEmpty &&
        attachments.isEmpty &&
        (embeds == null || embeds.isEmpty)) {
      return SendResult.failure('Empty message');
    }

    final hookResult = PluginHooks().runBeforeMessageSend(content);
    if (hookResult.cancelled) {
      showSnackBar('Message blocked by plugin: ${hookResult.cancelledBy}');
      return SendResult.failure('Blocked by plugin');
    }

    final request = _ChatSendRequest(
      roomId: roomId,
      content: hookResult.data ?? content,
      attachments: attachments,
      sender: sender,
      encryptionMode: encryptionMode,
      mlsGroupId: mlsGroupId,
      embeds: embeds,
      editingTo: editingTo,
      forwardingTo: forwardingTo,
      replyingTo: replyingTo,
      threadingTo: threadingTo,
    );
    return _start(request);
  }

  /// Starts sending a recorded voice message.
  Future<SendResult> enqueueVoice({
    required String roomId,
    required String filePath,
    required SnChatMember sender,
    required int encryptionMode,
    String? mlsGroupId,
    int? durationMs,
    SnChatMessage? forwardingTo,
    SnChatMessage? replyingTo,
  }) {
    return _start(
      _ChatSendRequest(
        roomId: roomId,
        content: '',
        attachments: const [],
        sender: sender,
        encryptionMode: encryptionMode,
        mlsGroupId: mlsGroupId,
        forwardingTo: forwardingTo,
        replyingTo: replyingTo,
        isVoice: true,
        voiceFilePath: filePath,
        voiceDurationMs: durationMs,
      ),
    );
  }

  /// Retries a failed outbox message in place. Returns null when the message
  /// was not started by this outbox (for example a message loaded from the DB
  /// after an app restart).
  Future<SendResult?> retry(String roomId, String messageId) async {
    final entry = entriesForRoom(roomId)
        .where(
          (item) =>
              item.status == ChatOutboxStatus.failed &&
              (item.id == messageId || item.pendingMessageId == messageId),
        )
        .lastOrNull;
    if (entry == null) return null;

    final task = _tasks[entry.id];
    if (task == null || task.request.isVoice) return null;
    final pendingId = task.pending?.id;
    if (pendingId == null) return null;

    _patchEntry(entry.id, (current) {
      return current.copyWith(
        status: ChatOutboxStatus.sending,
        progress: null,
        clearError: true,
      );
    });

    final result = await task.sender.retryMessage(
      pendingId,
      sender: task.request.sender,
      onProgress: (messageId, progress) =>
          _onProgress(task, messageId, progress),
    );
    await _finish(task, result);
    return result;
  }

  /// Removes the outbox row of a message the user deleted (or a sent message
  /// whose failed row no longer applies).
  void discardMessage(String roomId, String messageId) {
    final entry = entriesForRoom(roomId)
        .where(
          (item) => item.id == messageId || item.pendingMessageId == messageId,
        )
        .lastOrNull;
    if (entry == null) return;
    _tasks.remove(entry.id)?.cancelled = true;
    _removeEntry(entry.id);
  }

  /// Clears all outbox state for a room, used when local room data is cleared.
  void discardRoom(String roomId) {
    final entries = entriesForRoom(roomId);
    for (final entry in entries) {
      _tasks.remove(entry.id)?.cancelled = true;
    }
    ref.read(chatPendingMessageCacheProvider).removeForRoom(roomId);
    if (!state.containsKey(roomId)) return;
    final next = Map<String, List<ChatOutboxEntry>>.from(state)..remove(roomId);
    state = next;
  }

  Future<SendResult> _start(_ChatSendRequest request) {
    final entryId = const Uuid().v4();
    _putEntry(
      ChatOutboxEntry(
        id: entryId,
        roomId: request.roomId,
        content: request.content,
        attachmentCount: request.attachments.length,
        isVoice: request.isVoice,
        status: ChatOutboxStatus.sending,
        createdAt: DateTime.now(),
      ),
    );

    final task = _createTask(entryId, request);
    _tasks[entryId] = task;
    return request.isVoice ? _runVoice(task) : _runText(task);
  }

  _ChatSendTask _createTask(String entryId, _ChatSendRequest request) {
    final repository = MessageRepository(ref, request.roomId, MessageCache());
    final pendingCache = ref.read(chatPendingMessageCacheProvider);
    final e2eeService = E2eeMessageService(
      ref: ref,
      mlsGroupId: request.mlsGroupId,
      isE2eeRoom: request.encryptionMode == 3,
    );
    final sender = MessageSender(
      ref,
      request.roomId,
      repository,
      pendingCache,
      e2eeService: e2eeService,
      fileEncryptKey: request.encryptionMode == 3
          ? deriveE2eeFileEncryptKey(request.roomId)
          : null,
    );
    return _ChatSendTask(
      entryId: entryId,
      request: request,
      sender: sender,
      repository: repository,
    );
  }

  Future<SendResult> _runText(_ChatSendTask task) async {
    final request = task.request;
    final result = await task.sender.sendTextMessage(
      content: request.content,
      attachments: request.attachments,
      sender: request.sender,
      editingTo: request.editingTo,
      replyingTo: request.replyingTo,
      forwardingTo: request.forwardingTo,
      threadingTo: request.threadingTo,
      embeds: request.embeds,
      onPending: (pending) => _onPending(task, pending),
      onProgress: (messageId, progress) =>
          _onProgress(task, messageId, progress),
    );
    await _finish(task, result);
    return result;
  }

  Future<SendResult> _runVoice(_ChatSendTask task) async {
    final request = task.request;
    final result = await task.sender.sendVoiceMessage(
      filePath: request.voiceFilePath!,
      sender: request.sender,
      durationMs: request.voiceDurationMs,
      forwardingTo: request.forwardingTo,
      replyingTo: request.replyingTo,
      onPending: (pending) => _onPending(task, pending),
    );
    await _finish(task, result);
    return result;
  }

  void _onPending(_ChatSendTask task, LocalChatMessage pending) {
    task.pending = pending;
    _patchEntry(task.entryId, (entry) {
      return entry.copyWith(
        pendingMessageId: pending.id,
        pendingMessage: pending,
      );
    });

    // Persist the bubble immediately. If the user leaves now, re-entering the
    // room can rebuild the in-flight/failed message from the local DB.
    unawaited(task.repository.saveMessage(pending));

    if (!task.cancelled) {
      _eventController.add(
        ChatOutboxPendingEvent(task.request.roomId, pending),
      );
    }
  }

  void _onProgress(
    _ChatSendTask task,
    String messageId,
    Map<int, double?> progress,
  ) {
    final overall = _overallProgress(task.request.attachments, progress);
    final last = task.lastReportedProgress;
    if (last != null && overall < 1 && (overall - last).abs() < 0.02) {
      return;
    }
    task.lastReportedProgress = overall;

    _patchEntry(task.entryId, (entry) => entry.copyWith(progress: overall));
    if (!task.cancelled) {
      _eventController.add(
        ChatOutboxProgressEvent(
          task.request.roomId,
          messageId: task.pending?.id ?? messageId,
          progress: overall,
        ),
      );
    }
  }

  Future<void> _finish(_ChatSendTask task, SendResult result) async {
    final pending = task.pending;
    final pendingId = pending?.id;

    if (!result.success || result.message == null) {
      if (task.finalized) {
        // The server already delivered the confirmed message. Undo the
        // failure status the sender wrote on its way out and forget the
        // outbox row without surfacing an error.
        if (pendingId != null) {
          if (pendingId == task.finalizedMessageId) {
            await task.repository.updateStatus(pendingId, MessageStatus.sent);
          } else {
            await task.repository.deleteMessage(pendingId);
          }
        }
        _removeEntry(task.entryId);
        _tasks.remove(task.entryId);
        return;
      }

      final error = result.error ?? 'Failed to send message';
      if (pending != null) {
        pending.status = MessageStatus.failed;
        await task.repository.updateStatus(pending.id, MessageStatus.failed);
      }
      if (!task.cancelled) {
        _patchEntry(task.entryId, (entry) {
          return entry.copyWith(
            status: ChatOutboxStatus.failed,
            error: error,
            pendingMessage: pending,
          );
        });
        _eventController.add(
          ChatOutboxFailedEvent(
            task.request.roomId,
            pendingMessageId: pendingId ?? task.entryId,
            pendingMessage: pending,
            error: error,
          ),
        );
      }
      _logger.warning('[outbox:${task.entryId}] Send failed: $error');
      return;
    }

    final sent = result.message!;
    if (pendingId != null && pendingId != sent.id) {
      await task.repository.deleteMessage(pendingId);
    }

    _applySentToSummary(task, sent);
    if (!task.cancelled) {
      _eventController.add(
        ChatOutboxCompletedEvent(
          task.request.roomId,
          pendingMessageId: pendingId ?? sent.id,
          message: sent,
          eventMessage: result.eventMessage,
          isEditing: task.request.editingTo != null,
        ),
      );
    }
    _removeEntry(task.entryId);
    _tasks.remove(task.entryId);
    unawaited(_donateShareSuggestion(task.request.roomId));
  }

  void _applySentToSummary(_ChatSendTask task, LocalChatMessage sent) {
    try {
      final remote = sent.toRemoteMessage();
      final summary = ref.read(chatSummaryProvider.notifier);
      if (task.request.editingTo != null) {
        summary.updateMessageContent(task.request.roomId, remote);
      } else {
        summary.applyOwnSentMessage(task.request.roomId, remote);
      }
    } catch (error, stackTrace) {
      _logger.info('Failed to update chat summary', error, stackTrace);
    }
  }

  Future<void> _donateShareSuggestion(String roomId) async {
    try {
      final room = await ref.read(chatRoomProvider(roomId).future);
      final account = await ref.read(userInfoProvider.future);
      if (room == null) return;
      await IosShareSuggestionsService.instance.donateChatRoom(
        room,
        currentUserId: account?.id,
        currentAccountName: account?.name,
        currentAccountNick: account?.nick,
        currentUser: account,
        serverUrl: ref.read(serverUrlProvider),
      );
    } catch (error, stackTrace) {
      _logger.info(
        'Failed to donate chat share suggestion for $roomId',
        error,
        stackTrace,
      );
    }
  }

  double _overallProgress(
    List<UniversalFile> attachments,
    Map<int, double?> progress,
  ) {
    if (attachments.isEmpty) return 1.0;

    var total = 0.0;
    for (var i = 0; i < attachments.length; i++) {
      if (attachments[i].isOnCloud) {
        total += 1.0;
        continue;
      }
      total += (progress[i] ?? 0.0).clamp(0.0, 1.0);
    }
    return (total / attachments.length).clamp(0.0, 1.0);
  }

  void _putEntry(ChatOutboxEntry entry) {
    final current = state[entry.roomId] ?? const <ChatOutboxEntry>[];
    state = {
      ...state,
      entry.roomId: [...current, entry],
    };
  }

  void _patchEntry(
    String entryId,
    ChatOutboxEntry Function(ChatOutboxEntry entry) update,
  ) {
    for (final roomEntry in state.entries) {
      final index = roomEntry.value.indexWhere((entry) => entry.id == entryId);
      if (index < 0) continue;

      final updated = List<ChatOutboxEntry>.of(roomEntry.value);
      updated[index] = update(updated[index]);
      state = {...state, roomEntry.key: updated};
      return;
    }
  }

  void _removeEntry(String entryId) {
    for (final roomEntry in state.entries) {
      final index = roomEntry.value.indexWhere((entry) => entry.id == entryId);
      if (index < 0) continue;

      final updated = List<ChatOutboxEntry>.of(roomEntry.value)
        ..removeAt(index);
      if (updated.isEmpty) {
        final next = Map<String, List<ChatOutboxEntry>>.from(state)
          ..remove(roomEntry.key);
        state = next;
      } else {
        state = {...state, roomEntry.key: updated};
      }
      return;
    }
  }
}

final chatOutboxProvider =
    NotifierProvider<ChatOutboxNotifier, Map<String, List<ChatOutboxEntry>>>(
      ChatOutboxNotifier.new,
    );
