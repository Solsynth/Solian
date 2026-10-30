import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_share_payload.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/chat/pods/chat_outbox.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/chat/services/chat_attachment_upload.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/chat/widgets/chat_link_attachments.dart';
import 'package:island/data/message.dart';
import 'package:logging/logging.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// A deliberately unloaded range between two messages in the rendered list.
class MessageLoadGap {
  final String newerMessageId;
  final String olderMessageId;
  final bool isAutoManaged;

  const MessageLoadGap({
    required this.newerMessageId,
    required this.olderMessageId,
    this.isAutoManaged = false,
  });
}

/// Universal state for a chat room, supporting multiple instances via family provider.
/// This enables multi-window chat support and consolidates all UI state in one place.
class ChatRoomState {
  // Selection state
  final bool isSelectionMode;
  final Set<String> selectedMessageIds;

  // Input state
  final List<UniversalFile> attachments;
  final Map<String, Map<int, double?>> attachmentProgress;
  final SnChatMessage? messageEditingTo;
  final SnChatMessage? messageReplyingTo;
  final SnChatMessage? messageForwardingTo;
  // Unified embeds list (surveys, funds, locations, meets, calendar events)
  final List<Map<String, dynamic>> embeds;

  // One-shot signal: the message to open a thread sheet on (with a composer
  // targeting it). Consumed by the room screen; cleared after opening.
  final SnChatMessage? threadReplyTarget;

  // Scroll state (not persisted - fresh on each navigation)
  // Set while a jump to this message is in flight and until the list widget
  // has revealed it. The list widget resolves the render index, so the index
  // is never stored here.
  final String? pendingJumpMessageId;
  final MessageLoadGap? messageLoadGap;

  // Read receipt state
  final DateTime roomOpenTime;
  final String? lastReadAnchorMessageId;
  final String? dismissedLastReadAnchorMessageId;

  const ChatRoomState({
    this.isSelectionMode = false,
    this.selectedMessageIds = const {},
    this.attachments = const [],
    this.attachmentProgress = const {},
    this.messageEditingTo,
    this.messageReplyingTo,
    this.messageForwardingTo,
    this.embeds = const [],
    this.threadReplyTarget,
    this.pendingJumpMessageId,
    this.messageLoadGap,
    required this.roomOpenTime,
    this.lastReadAnchorMessageId,
    this.dismissedLastReadAnchorMessageId,
  });

  ChatRoomState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedMessageIds,
    List<UniversalFile>? attachments,
    Map<String, Map<int, double?>>? attachmentProgress,
    SnChatMessage? messageEditingTo,
    SnChatMessage? messageReplyingTo,
    SnChatMessage? messageForwardingTo,
    List<Map<String, dynamic>>? embeds,
    SnChatMessage? threadReplyTarget,
    String? pendingJumpMessageId,
    bool clearPendingJump = false,
    MessageLoadGap? messageLoadGap,
    DateTime? roomOpenTime,
    String? lastReadAnchorMessageId,
    String? dismissedLastReadAnchorMessageId,
    bool clearEditingTo = false,
    bool clearReplyingTo = false,
    bool clearForwardingTo = false,
    bool clearEmbeds = false,
    bool clearThreadReplyTarget = false,
    bool clearLastReadAnchor = false,
    bool clearDismissedLastReadAnchor = false,
    bool clearMessageLoadGap = false,
  }) {
    return ChatRoomState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedMessageIds: selectedMessageIds ?? this.selectedMessageIds,
      attachments: attachments ?? this.attachments,
      attachmentProgress: attachmentProgress ?? this.attachmentProgress,
      messageEditingTo: clearEditingTo
          ? null
          : (messageEditingTo ?? this.messageEditingTo),
      messageReplyingTo: clearReplyingTo
          ? null
          : (messageReplyingTo ?? this.messageReplyingTo),
      messageForwardingTo: clearForwardingTo
          ? null
          : (messageForwardingTo ?? this.messageForwardingTo),
      embeds: clearEmbeds ? [] : (embeds ?? this.embeds),
      threadReplyTarget: clearThreadReplyTarget
          ? null
          : (threadReplyTarget ?? this.threadReplyTarget),
      pendingJumpMessageId: clearPendingJump
          ? null
          : (pendingJumpMessageId ?? this.pendingJumpMessageId),
      messageLoadGap: clearMessageLoadGap
          ? null
          : (messageLoadGap ?? this.messageLoadGap),
      roomOpenTime: roomOpenTime ?? this.roomOpenTime,
      lastReadAnchorMessageId: clearLastReadAnchor
          ? null
          : (lastReadAnchorMessageId ?? this.lastReadAnchorMessageId),
      dismissedLastReadAnchorMessageId: clearDismissedLastReadAnchor
          ? null
          : (dismissedLastReadAnchorMessageId ??
                this.dismissedLastReadAnchorMessageId),
    );
  }
}

/// Notifier that manages all UI state for a specific chat room.
/// Each room gets its own instance via the family provider.
class ChatRoomStateNotifier extends Notifier<ChatRoomState> {
  final String arg;
  late final String roomId;

  // Controllers - created per instance
  late final TextEditingController messageController;
  late final ScrollController scrollController;
  late final ListController listController;

  // Typing tracking
  String _lastMessageText = '';

  // Auto-fill tracking
  int _autoFillPasses = 0;
  bool _autoFillInProgress = false;
  int? _lastAutoFillMessageCount;
  static const int _kMaxAutoFillPasses = 12;

  // Scroll loading tracking
  bool _isLoadingMore = false;

  /// Hard cap on frames spent settling a jump before giving up and releasing
  /// the latch, so a target that can never be revealed (filtered out of the
  /// timeline, empty list) cannot wedge the room.
  static const int _kMaxJumpSettleFrames = 8;

  /// Releases the pending-jump latch if the list widget never resolves the
  /// target id (for example a message the display filter hides).
  static const Duration _kPendingJumpTimeout = Duration(seconds: 5);

  Timer? _pendingJumpWatchdog;
  String? _settleMessageId;
  int? _settleIndex;
  int _settleFrames = 0;
  bool _settleScheduled = false;

  ChatRoomStateNotifier(this.arg) {
    roomId = arg;
  }

  @override
  ChatRoomState build() {
    // Initialize controllers
    messageController = TextEditingController();
    scrollController = ScrollController();
    listController = ListController();

    // Setup listeners
    messageController.addListener(_onTextChange);
    scrollController.addListener(_onScroll);

    // Setup dispose callback
    ref.onDispose(() {
      messageController.removeListener(_onTextChange);
      messageController.dispose();
      scrollController.removeListener(_onScroll);
      scrollController.dispose();
      listController.dispose();
      _pendingJumpWatchdog?.cancel();
      _pendingJumpWatchdog = null;
    });

    return ChatRoomState(roomOpenTime: DateTime.now());
  }

  void _onTextChange() {
    final text = messageController.text;
    if (text == _lastMessageText) return;
    _lastMessageText = text;
    if (text.isNotEmpty) {
      // Read fresh notifier each time to avoid using disposed instance
      final notifier = ref.read(chatSubscribeProvider(roomId).notifier);
      notifier.sendTypingStatus();
    }
  }

  void _onScroll() {
    final position = _getSingleScrollPosition();
    if (position == null) return;
    // The reveal drives the offset across the whole history for a deep jump;
    // paging from that transient position would corrupt the loaded window.
    if (state.pendingJumpMessageId != null) return;

    if (position.pixels >= position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _isLoadingMore = true;
        // Read fresh notifier each time to avoid using disposed instance
        final notifier = ref.read(messagesProvider(roomId).notifier);
        final loadMore = state.messageLoadGap?.isAutoManaged == true
            ? notifier.loadMoreBeforeOldest()
            : notifier.loadMore();
        loadMore
            .then((_) async {
              if (state.messageLoadGap == null ||
                  state.messageLoadGap!.isAutoManaged) {
                final gap = await notifier.compactForOlderScroll();
                if (gap != null && ref.mounted) {
                  updateMessageLoadGap(gap);
                }
              }
            })
            .whenComplete(() {
              _isLoadingMore = false;
            });
      }
    }
  }

  /// Check if we need to auto-fill more messages (when content doesn't fill screen)
  void checkAutoFill(int messageCount) {
    if (_autoFillPasses >= _kMaxAutoFillPasses) return;
    if (_autoFillInProgress) return;
    final position = _getSingleScrollPosition();
    if (position == null) return;
    if (state.pendingJumpMessageId != null) return;

    final isScrollable = position.maxScrollExtent > 0;
    if (isScrollable) {
      _autoFillPasses = 0;
      _lastAutoFillMessageCount = null;
      return;
    }

    if (_lastAutoFillMessageCount == messageCount) {
      // Previous autofill didn't add messages, stop retrying
      return;
    }

    _autoFillInProgress = true;
    _autoFillPasses++;
    _lastAutoFillMessageCount = messageCount;

    Logger.root.info(
      'Room auto-fill triggering loadMore '
      '(roomId=$roomId, pass=$_autoFillPasses, count=$messageCount)',
    );

    // Read fresh notifier each time to avoid using disposed instance
    final notifier = ref.read(messagesProvider(roomId).notifier);
    notifier.loadMore().whenComplete(() {
      _autoFillInProgress = false;
    });
  }

  ScrollPosition? _getSingleScrollPosition() {
    if (!scrollController.hasClients) return null;
    final positions = scrollController.positions;
    if (positions.length != 1) {
      Logger.root.fine(
        'Skip scroll action because controller has ${positions.length} positions (roomId=$roomId)',
      );
      return null;
    }
    return positions.first;
  }

  // ==================== Selection Mode ====================

  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedMessageIds: state.isSelectionMode ? {} : null,
    );
  }

  void exitSelectionMode() {
    state = state.copyWith(isSelectionMode: false, selectedMessageIds: {});
  }

  void toggleMessageSelection(String messageId) {
    final current = Set<String>.from(state.selectedMessageIds);
    if (current.contains(messageId)) {
      current.remove(messageId);
    } else {
      current.add(messageId);
    }
    state = state.copyWith(selectedMessageIds: current);
  }

  void selectAllMessages(List<String> messageIds) {
    state = state.copyWith(selectedMessageIds: Set<String>.from(messageIds));
  }

  // ==================== Input Management ====================

  void updateAttachments(List<UniversalFile> attachments) {
    state = state.copyWith(attachments: attachments);
    _syncAttachmentUploads();
  }

  /// Uploads newly added attachments (auto upload) and stops the uploads of
  /// attachments that are no longer part of the composer.
  void _syncAttachmentUploads() {
    final uploads = ref.read(chatAttachmentUploadsProvider(roomId));
    uploads.cancelMissing(state.attachments);
    if (!uploads.canAutoUpload) return;

    for (var index = 0; index < state.attachments.length; index++) {
      final attachment = state.attachments[index];
      if (attachment.isOnCloud) continue;
      if (uploads.manager.entryFor(attachment) != null) continue;
      unawaited(uploadAttachment(index));
    }
  }

  /// Uploads the attachment at [index] and stores the resulting cloud file in
  /// the composer.
  ///
  /// Joins the upload instead of starting a second one when auto upload (or a
  /// send that took it over) is already uploading the same file.
  Future<void> uploadAttachment(
    int index, {
    String? poolId,
    bool? imageCompressionEnabled,
    int? imageCompressionQuality,
    String? encryptKey,
  }) async {
    if (index < 0 || index >= state.attachments.length) return;
    final attachment = state.attachments[index];
    if (attachment.isOnCloud) return;

    final uploads = ref.read(chatAttachmentUploadsProvider(roomId));
    final startedHere = uploads.manager.entryFor(attachment) == null;
    final entry = uploads.start(
      attachment,
      poolId: poolId,
      imageCompressionEnabled: imageCompressionEnabled,
      imageCompressionQuality: imageCompressionQuality,
      encryptKey: encryptKey,
      onProgress: (progress) =>
          updateAttachmentUploadProgressFor(attachment, progress),
    );
    if (startedHere) updateAttachmentUploadProgressFor(attachment, 0);

    try {
      final cloudFile = await entry.completer.future;
      if (cloudFile == null) {
        throw ArgumentError('Failed to upload the file...');
      }
      _applyUploadedAttachment(attachment, cloudFile);
    } catch (err) {
      // Cancelling an upload is a user action, and an upload taken over by the
      // send process reports its own failures there.
      if (startedHere && !entry.isCancelled && !entry.isAdopted) {
        showErrorAlert(err);
      }
    } finally {
      clearAttachmentUploadProgressFor(attachment);
    }
  }

  /// Replaces the on-device [attachment] with the file it uploaded to.
  void _applyUploadedAttachment(
    UniversalFile attachment,
    SnCloudFile cloudFile,
  ) {
    final index = state.attachments.indexOf(attachment);
    if (index == -1) return;
    final clone = List<UniversalFile>.of(state.attachments);
    clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
    clearAttachmentUploadProgressFor(attachment, index: index);
    state = state.copyWith(attachments: clone);
  }

  /// Cancels the upload running for the attachment at [index]; the file stays
  /// attached and can be uploaded again later.
  void cancelAttachmentUpload(int index) {
    if (index < 0 || index >= state.attachments.length) return;
    final attachment = state.attachments[index];
    ref.read(chatAttachmentUploadsProvider(roomId)).cancel(attachment);
    clearAttachmentUploadProgressFor(attachment, index: index);
  }

  void updateAttachmentProgress(String messageId, double? progress) {
    final newProgress = Map<String, Map<int, double?>>.from(
      state.attachmentProgress,
    );
    if (progress == null) {
      newProgress.remove(messageId);
    } else {
      newProgress[messageId] = {0: progress};
    }
    state = state.copyWith(attachmentProgress: newProgress);
  }

  void updateAttachmentUploadProgress(int index, double? progress) {
    if (index < 0 || index >= state.attachments.length) return;
    final newProgress = Map<String, Map<int, double?>>.from(
      state.attachmentProgress,
    );
    final uploadProgress = Map<int, double?>.from(
      newProgress['chat-upload'] ?? const {},
    );
    uploadProgress[index] = progress;
    newProgress['chat-upload'] = uploadProgress;
    state = state.copyWith(attachmentProgress: newProgress);
  }

  /// Reports [progress] for [attachment], wherever it currently sits in the
  /// composer (attachments can be reordered while an upload runs).
  void updateAttachmentUploadProgressFor(
    UniversalFile attachment,
    double? progress,
  ) {
    final index = state.attachments.indexOf(attachment);
    if (index == -1) return;
    updateAttachmentUploadProgress(index, progress);
  }

  /// Clears the upload progress rows of [attachment].
  ///
  /// [index] is the row to clear when the attachment itself is no longer in
  /// the list (it was swapped for its cloud file, moved or deleted); rows that
  /// no longer belong to an on-device attachment are dropped as a fallback.
  void clearAttachmentUploadProgressFor(
    UniversalFile attachment, {
    int? index,
  }) {
    final newProgress = Map<String, Map<int, double?>>.from(
      state.attachmentProgress,
    );
    final uploadProgress = Map<int, double?>.from(
      newProgress['chat-upload'] ?? const {},
    );
    if (index != null) uploadProgress.remove(index);
    final currentIndex = state.attachments.indexOf(attachment);
    if (currentIndex != -1) uploadProgress.remove(currentIndex);
    uploadProgress.removeWhere(
      (key, _) =>
          key < 0 ||
          key >= state.attachments.length ||
          state.attachments[key].isOnCloud,
    );
    if (uploadProgress.isEmpty) {
      newProgress.remove('chat-upload');
    } else {
      newProgress['chat-upload'] = uploadProgress;
    }
    state = state.copyWith(attachmentProgress: newProgress);
  }

  void clearAttachmentUploadProgress(int index) {
    final newProgress = Map<String, Map<int, double?>>.from(
      state.attachmentProgress,
    );
    final uploadProgress = Map<int, double?>.from(
      newProgress['chat-upload'] ?? const {},
    );
    uploadProgress.remove(index);
    if (uploadProgress.isEmpty) {
      newProgress.remove('chat-upload');
    } else {
      newProgress['chat-upload'] = uploadProgress;
    }
    state = state.copyWith(attachmentProgress: newProgress);
  }

  void setEditingTo(SnChatMessage? message) {
    if (message != null) {
      messageController.text = message.content ?? '';
      state = state.copyWith(
        messageEditingTo: message,
        attachments: message.attachments
            .map((e) => UniversalFile.fromAttachment(e))
            .toList(),
      );
      _syncAttachmentUploads();
    } else {
      state = state.copyWith(clearEditingTo: true);
    }
  }

  void setReplyingTo(SnChatMessage? message) {
    state = state.copyWith(
      messageReplyingTo: message,
      clearReplyingTo: message == null,
    );
  }

  void clearThreadReplyTarget() {
    state = state.copyWith(clearThreadReplyTarget: true);
  }

  void setForwardingTo(SnChatMessage? message) {
    state = state.copyWith(
      messageForwardingTo: message,
      clearForwardingTo: message == null,
    );
  }

  void setEmbeds(List<Map<String, dynamic>> embeds) {
    state = state.copyWith(embeds: embeds);
  }

  void clearInput() {
    messageController.clear();
    state = state.copyWith(
      clearEditingTo: true,
      clearReplyingTo: true,
      clearForwardingTo: true,
      clearEmbeds: true,
      attachments: [],
    );
    // Uploads already taken over by a send keep running; see
    // [AttachmentUploadManager.cancelMissing].
    ref.read(chatAttachmentUploadsProvider(roomId)).cancelMissing(const []);
  }

  void clearAttachmentsOnly() {
    messageController.clear();
    state = state.copyWith(attachments: []);
    ref.read(chatAttachmentUploadsProvider(roomId)).cancelMissing(const []);
  }

  Future<void> handlePaste() async {
    final image = await Pasteboard.image;
    if (image != null) {
      updateAttachments([
        ...state.attachments,
        UniversalFile(
          displayName: 'image.jpeg',
          data: XFile.fromData(
            image,
            mimeType: "image/jpeg",
            name: 'image.jpeg',
          ),
          type: UniversalFileType.image,
        ),
      ]);
    }

    final textData = await Clipboard.getData(Clipboard.kTextPlain);
    if (textData != null && textData.text != null) {
      final text = messageController.text;
      final selection = messageController.selection;
      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;
      final newText = text.replaceRange(start, end, textData.text!);
      messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: start + textData.text!.length,
        ),
      );
    }
  }

  // ==================== Message Actions ====================

  void onMessageAction(String action, LocalChatMessage message) {
    // Read fresh notifier each time to avoid using disposed instance
    final notifier = ref.read(messagesProvider(roomId).notifier);

    switch (action) {
      case 'delete':
        notifier.deleteMessage(message.id);
      case 'edit':
        setEditingTo(message.toRemoteMessage());
      case 'forward':
        setForwardingTo(message.toRemoteMessage());
      case 'reply':
        setReplyingTo(message.toRemoteMessage());
      case 'reply_in_thread':
        state = state.copyWith(threadReplyTarget: message.toRemoteMessage());
      case 'resend':
        notifier.retryMessage(message.id);
      case 'redirect':
        _redirectSingleMessage(message);
      case 'pin':
        notifier.pinMessage(message.id);
      case 'unpin':
        notifier.unpinMessage(message.id);
    }
  }

  void _redirectSingleMessage(LocalChatMessage message) {
    // Enter selection mode with this single message selected
    state = state.copyWith(
      isSelectionMode: true,
      selectedMessageIds: {message.id},
    );
  }

  void sendMessage() {
    final text = messageController.text.trim();
    final attachments = List<UniversalFile>.of(state.attachments);
    if (text.isEmpty && attachments.isEmpty && state.embeds.isEmpty) {
      return;
    }

    final room = ref.read(chatRoomProvider(roomId)).value;
    final identity = ref.read(chatRoomIdentityProvider(roomId)).value;
    if (room == null || identity == null) return;

    // Hand any running upload of these attachments over to the send process
    // before the composer state is cleared: the pending message bubble then
    // shows their progress and the send joins them instead of uploading the
    // same files again.
    final uploads = ref.read(chatAttachmentUploadsProvider(roomId));
    for (final attachment in attachments) {
      if (attachment.isOnCloud) continue;
      uploads.adoptProgress(attachment, (_) {});
    }

    // The send lives in the app-wide outbox, not in this room-scoped
    // notifier. Clearing the composer (or closing the room) cannot cancel it.
    unawaited(
      ref
          .read(chatOutboxProvider.notifier)
          .enqueueText(
            roomId: roomId,
            content: text,
            attachments: attachments,
            sender: identity,
            encryptionMode: room.encryptionMode,
            mlsGroupId: room.mlsGroupId,
            embeds: state.embeds,
            editingTo: state.messageEditingTo,
            forwardingTo: state.messageForwardingTo,
            replyingTo: state.messageReplyingTo,
          ),
    );

    clearInput();
  }

  void applySharedPayload(ChatComposerSharePayload payload) {
    if (payload.text.trim().isNotEmpty) {
      final existingText = messageController.text.trim();
      final nextText = existingText.isEmpty
          ? payload.text.trim()
          : '$existingText\n\n${payload.text.trim()}';
      messageController.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }

    if (payload.attachments.isNotEmpty) {
      updateAttachments([...state.attachments, ...payload.attachments]);
    }
  }

  // ==================== Scroll Actions ====================

  /// Starts a jump to [messageId].
  ///
  /// The render index is resolved by the list widget against the list it
  /// actually renders, so this hands off an id, never an index. Loads the
  /// message window when the target is not in memory, then records the gap the
  /// jump left between the previously loaded newest region and that window.
  Future<void> scrollToMessage({
    required String messageId,
    required Future<bool> Function(String) jumpToMessage,
    required Future<bool> Function(String, String) hasMessagesBetween,
  }) async {
    if (state.pendingJumpMessageId != null) return;
    state = state.copyWith(pendingJumpMessageId: messageId);
    _armPendingJumpWatchdog(messageId);

    final before =
        ref.read(messagesProvider(roomId)).value ?? const <LocalChatMessage>[];
    // Already rendered: the list widget reveals it as soon as it resolves the id.
    if (before.any((message) => message.id == messageId)) return;

    final found = await jumpToMessage(messageId);
    if (!ref.mounted) return;
    if (!found) {
      _clearPendingJump(messageId);
      return;
    }
    state = state.copyWith(clearMessageLoadGap: true);

    // Record the hole the jump left between the previously loaded newest
    // region and the window loaded around the target.
    if (before.isEmpty) return;
    final updated =
        ref.read(messagesProvider(roomId)).value ?? const <LocalChatMessage>[];
    final newerIndex = updated.indexWhere(
      (message) => message.id == before.last.id,
    );
    if (newerIndex == -1 || newerIndex + 1 >= updated.length) return;
    final newerMessageId = updated[newerIndex].id;
    final olderMessageId = updated[newerIndex + 1].id;
    if (!await hasMessagesBetween(newerMessageId, olderMessageId) ||
        !ref.mounted) {
      return;
    }
    state = state.copyWith(
      messageLoadGap: MessageLoadGap(
        newerMessageId: newerMessageId,
        olderMessageId: olderMessageId,
      ),
    );
  }

  /// Reveals the pending jump target once the list widget has resolved
  /// [displayIndex] against the list it actually renders.
  void revealPendingJump(int displayIndex) {
    final messageId = state.pendingJumpMessageId;
    if (messageId == null || !ref.mounted) return;
    if (_settleMessageId != messageId || _settleIndex != displayIndex) {
      _settleMessageId = messageId;
      _settleIndex = displayIndex;
      _settleFrames = 0;
      _settleScheduled = false;
      _pendingJumpWatchdog?.cancel();
      _pendingJumpWatchdog = null;
      ref.read(flashingMessagesProvider.notifier).trigger(messageId);
      _revealJumpFrame(messageId, displayIndex);
      return;
    }
    if (!_settleScheduled) _revealJumpFrame(messageId, displayIndex);
  }

  /// One reveal attempt per frame. A single `animateToItem` cannot be trusted
  /// for an off-screen target: every unmeasured row is estimated at a flat
  /// 40 px, so the estimated destination is far short of the real one, and the
  /// per-frame clamp pins that undershoot to `minScrollExtent`, which in a
  /// reversed list is the newest messages. Re-running `jumpToItem` from the
  /// new position lets the list measure the rows in between, so each frame's
  /// estimate improves.
  void _revealJumpFrame(String messageId, int displayIndex) {
    _settleScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.mounted || state.pendingJumpMessageId != messageId) {
        _settleScheduled = false;
        return;
      }
      if (!listController.isAttached) {
        _clearPendingJump(messageId);
        return;
      }
      final maxIndex = listController.numberOfItems - 1;
      if (maxIndex < 0) {
        _clearPendingJump(messageId);
        return;
      }
      final target = displayIndex.clamp(0, maxIndex);
      final range = listController.visibleRange;
      final onScreen =
          range != null && target >= range.$1 && target <= range.$2;
      if (onScreen) {
        // The row is built, so its extent is measured and the animated
        // reveal cannot undershoot.
        listController.animateToItem(
          index: target,
          scrollController: scrollController,
          alignment: 0.5,
          duration: (distance) =>
              Duration(milliseconds: (distance * 0.5).clamp(200, 800).toInt()),
          curve: (_) => Curves.easeOutCubic,
        );
        _clearPendingJump(messageId);
        return;
      }
      if (_settleFrames >= _kMaxJumpSettleFrames) {
        Logger.root.info(
          'Jump to $messageId did not settle within '
          '$_kMaxJumpSettleFrames frames (roomId=$roomId)',
        );
        _clearPendingJump(messageId);
        return;
      }
      _settleFrames += 1;
      listController.jumpToItem(
        index: target,
        scrollController: scrollController,
        alignment: 0.5,
      );
      _revealJumpFrame(messageId, displayIndex);
    });
  }

  void _clearPendingJump(String messageId) {
    _pendingJumpWatchdog?.cancel();
    _pendingJumpWatchdog = null;
    _settleMessageId = null;
    _settleIndex = null;
    _settleFrames = 0;
    _settleScheduled = false;
    if (!ref.mounted || state.pendingJumpMessageId != messageId) return;
    state = state.copyWith(clearPendingJump: true);
  }

  void _armPendingJumpWatchdog(String messageId) {
    _pendingJumpWatchdog?.cancel();
    _pendingJumpWatchdog = Timer(_kPendingJumpTimeout, () {
      if (!ref.mounted || state.pendingJumpMessageId != messageId) return;
      // The target never resolved (filtered out of the timeline, plugin
      // cancelled, list never attached): release the latch.
      Logger.root.info('Pending jump to $messageId timed out (roomId=$roomId)');
      _clearPendingJump(messageId);
    });
  }

  void updateMessageLoadGap(MessageLoadGap? gap) {
    state = gap == null
        ? state.copyWith(clearMessageLoadGap: true)
        : state.copyWith(messageLoadGap: gap);
  }

  void jumpToBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  // ==================== File Picker ====================

  Future<void> pickPhotos() async {
    final picker = ImagePicker();
    final results = await picker.pickMultiImage();
    if (results.isEmpty) return;

    updateAttachments([
      ...state.attachments,
      ...results.map(
        (xfile) => UniversalFile(data: xfile, type: UniversalFileType.image),
      ),
    ]);
  }

  Future<void> pickVideos() async {
    final result = await FilePicker.pickFiles(type: FileType.video);
    if (result.isEmpty) return;

    updateAttachments([
      ...state.attachments,
      ...result.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.video),
      ),
    ]);
  }

  Future<void> pickAudio() async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    if (result.isEmpty) return;

    updateAttachments([
      ...state.attachments,
      ...result.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.audio),
      ),
    ]);
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.pickFiles();
    if (result.isEmpty) return;

    updateAttachments([
      ...state.attachments,
      ...result.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.file),
      ),
    ]);
  }

  Future<void> linkAttachment(BuildContext context) async {
    final cloudFile = await showModalBottomSheet<SnCloudFile?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ChatLinkAttachment(),
    );
    if (cloudFile == null) return;

    updateAttachments([
      ...state.attachments,
      UniversalFile(
        data: cloudFile,
        type: switch (cloudFile.mimeType.split('/').firstOrNull) {
          'image' => UniversalFileType.image,
          'video' => UniversalFileType.video,
          'audio' => UniversalFileType.audio,
          _ => UniversalFileType.file,
        },
        isLink: true,
      ),
    ]);
  }

  // ==================== Read Receipts ====================

  void setLastReadAnchorMessageId(String? messageId) {
    state = state.copyWith(
      lastReadAnchorMessageId: messageId,
      clearLastReadAnchor: messageId == null,
      dismissedLastReadAnchorMessageId:
          state.dismissedLastReadAnchorMessageId == messageId
          ? state.dismissedLastReadAnchorMessageId
          : null,
      clearDismissedLastReadAnchor:
          messageId == null ||
          state.dismissedLastReadAnchorMessageId != null &&
              state.dismissedLastReadAnchorMessageId != messageId,
    );
  }

  void dismissLastReadMarker() {
    final currentAnchor = state.lastReadAnchorMessageId;
    if (currentAnchor == null) return;
    state = state.copyWith(dismissedLastReadAnchorMessageId: currentAnchor);
  }
}

/// Family provider that creates a separate ChatRoomStateNotifier for each room ID.
/// This enables multi-window chat support where each room has isolated state.
///
/// Usage:
/// ```dart
/// final chatState = ref.watch(chatRoomStateProvider(roomId));
/// final chatStateNotifier = ref.read(chatRoomStateProvider(roomId).notifier);
/// ```
final chatRoomStateProvider =
    NotifierProvider.family<ChatRoomStateNotifier, ChatRoomState, String>(
      ChatRoomStateNotifier.new,
    );
