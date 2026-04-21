import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/chat/widgets/chat_link_attachments.dart';
import 'package:island/data/message.dart';
import 'package:logging/logging.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// Universal state for a chat room, supporting multiple instances via family provider.
/// This enables multi-window chat support and consolidates all UI state in one place.
class ChatRoomState {
  // Selection state
  final bool isSelectionMode;
  final Set<String> selectedMessageIds;

  // Bot group collapse state
  final Set<String> collapsedBotGroupIds;

  // Input state
  final List<UniversalFile> attachments;
  final Map<String, Map<int, double?>> attachmentProgress;
  final SnChatMessage? messageEditingTo;
  final SnChatMessage? messageReplyingTo;
  final SnChatMessage? messageForwardingTo;
  final SnPoll? selectedPoll;
  final SnWalletFund? selectedFund;

  // Scroll state (not persisted - fresh on each navigation)
  final bool isScrollingToMessage;

  // Read receipt state
  final DateTime roomOpenTime;
  final String? lastReadAnchorMessageId;

  const ChatRoomState({
    this.isSelectionMode = false,
    this.selectedMessageIds = const {},
    this.collapsedBotGroupIds = const {},
    this.attachments = const [],
    this.attachmentProgress = const {},
    this.messageEditingTo,
    this.messageReplyingTo,
    this.messageForwardingTo,
    this.selectedPoll,
    this.selectedFund,
    this.isScrollingToMessage = false,
    required this.roomOpenTime,
    this.lastReadAnchorMessageId,
  });

  ChatRoomState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedMessageIds,
    Set<String>? collapsedBotGroupIds,
    List<UniversalFile>? attachments,
    Map<String, Map<int, double?>>? attachmentProgress,
    SnChatMessage? messageEditingTo,
    SnChatMessage? messageReplyingTo,
    SnChatMessage? messageForwardingTo,
    SnPoll? selectedPoll,
    SnWalletFund? selectedFund,
    bool? isScrollingToMessage,
    DateTime? roomOpenTime,
    String? lastReadAnchorMessageId,
    bool clearEditingTo = false,
    bool clearReplyingTo = false,
    bool clearForwardingTo = false,
    bool clearPoll = false,
    bool clearFund = false,
    bool clearLastReadAnchor = false,
  }) {
    return ChatRoomState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedMessageIds: selectedMessageIds ?? this.selectedMessageIds,
      collapsedBotGroupIds: collapsedBotGroupIds ?? this.collapsedBotGroupIds,
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
      selectedPoll: clearPoll ? null : (selectedPoll ?? this.selectedPoll),
      selectedFund: clearFund ? null : (selectedFund ?? this.selectedFund),
      isScrollingToMessage: isScrollingToMessage ?? this.isScrollingToMessage,
      roomOpenTime: roomOpenTime ?? this.roomOpenTime,
      lastReadAnchorMessageId: clearLastReadAnchor
          ? null
          : (lastReadAnchorMessageId ?? this.lastReadAnchorMessageId),
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

  // Auto-fill tracking
  int _autoFillPasses = 0;
  bool _autoFillInProgress = false;
  int? _lastAutoFillMessageCount;
  static const int _kMaxAutoFillPasses = 12;

  // Scroll loading tracking
  bool _isLoadingMore = false;

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
    });

    return ChatRoomState(roomOpenTime: DateTime.now());
  }

  void _onTextChange() {
    if (messageController.text.isNotEmpty) {
      // Read fresh notifier each time to avoid using disposed instance
      final notifier = ref.read(chatSubscribeProvider(roomId).notifier);
      notifier.sendTypingStatus();
    }
  }

  void _onScroll() {
    final position = _getSingleScrollPosition();
    if (position == null) return;

    if (position.pixels >= position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _isLoadingMore = true;
        // Read fresh notifier each time to avoid using disposed instance
        final notifier = ref.read(messagesProvider(roomId).notifier);
        notifier.loadMore().whenComplete(() {
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

  // ==================== Bot Group Collapse ====================

  void toggleBotGroup(String groupId) {
    final current = Set<String>.from(state.collapsedBotGroupIds);
    if (current.contains(groupId)) {
      current.remove(groupId);
    } else {
      current.add(groupId);
    }
    state = state.copyWith(collapsedBotGroupIds: current);
  }

  // ==================== Input Management ====================

  void updateAttachments(List<UniversalFile> attachments) {
    state = state.copyWith(attachments: attachments);
  }

  void updateAttachmentProgress(String messageId, double? progress) {
    final newProgress = Map<String, Map<int, double?>>.from(
      state.attachmentProgress,
    );
    newProgress[messageId] = {0: progress};
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

  void setForwardingTo(SnChatMessage? message) {
    state = state.copyWith(
      messageForwardingTo: message,
      clearForwardingTo: message == null,
    );
  }

  void setPoll(SnPoll? poll) {
    state = state.copyWith(selectedPoll: poll, clearPoll: poll == null);
  }

  void setFund(SnWalletFund? fund) {
    state = state.copyWith(selectedFund: fund, clearFund: fund == null);
  }

  void clearInput() {
    messageController.clear();
    state = state.copyWith(
      clearEditingTo: true,
      clearReplyingTo: true,
      clearForwardingTo: true,
      clearPoll: true,
      clearFund: true,
      attachments: [],
    );
  }

  void clearAttachmentsOnly() {
    messageController.clear();
    state = state.copyWith(attachments: []);
  }

  Future<void> handlePaste() async {
    final image = await Pasteboard.image;
    if (image != null) {
      final newAttachments = [
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
      ];
      state = state.copyWith(attachments: newAttachments);
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
      case 'resend':
        notifier.retryMessage(message.id);
    }
  }

  void sendMessage(WidgetRef outerRef) {
    final text = messageController.text.trim();
    if (text.isEmpty &&
        state.attachments.isEmpty &&
        state.selectedPoll == null &&
        state.selectedFund == null) {
      return;
    }

    // Read fresh notifier each time to avoid using disposed instance
    final notifier = ref.read(messagesProvider(roomId).notifier);
    notifier.sendMessage(
      outerRef,
      text,
      state.attachments,
      poll: state.selectedPoll,
      fund: state.selectedFund,
      editingTo: state.messageEditingTo,
      forwardingTo: state.messageForwardingTo,
      replyingTo: state.messageReplyingTo,
      onProgress: (messageId, progress) {
        updateAttachmentProgress(messageId, progress[0]);
      },
    );

    clearInput();
  }

  // ==================== Scroll Actions ====================

  Future<void> scrollToMessage({
    required String messageId,
    required List<LocalChatMessage> messageList,
    required Future<int> Function(String) jumpToMessage,
  }) async {
    if (state.isScrollingToMessage) return;

    state = state.copyWith(isScrollingToMessage: true);

    // Add flashing effect
    ref
        .read(flashingMessagesProvider.notifier)
        .update((set) => set.union({messageId}));

    final messageIndex = messageList.indexWhere((m) => m.id == messageId);

    if (messageIndex == -1) {
      // Message not loaded, need to jump
      final index = await jumpToMessage(messageId);
      if (index != -1) {
        _performScrollAnimation(index: index, messageId: messageId);
      } else {
        state = state.copyWith(isScrollingToMessage: false);
      }
    } else {
      _performScrollAnimation(index: messageIndex, messageId: messageId);
    }
  }

  void _performScrollAnimation({
    required int index,
    required String messageId,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        listController.animateToItem(
          index: index,
          scrollController: scrollController,
          alignment: 0.5,
          duration: (estimatedDistance) => Duration(
            milliseconds: (estimatedDistance * 0.5).clamp(200, 800).toInt(),
          ),
          curve: (estimatedDistance) => Curves.easeOutCubic,
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          state = state.copyWith(isScrollingToMessage: false);
        });
      } catch (e) {
        state = state.copyWith(isScrollingToMessage: false);
      }
    });
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

    final newAttachments = [
      ...state.attachments,
      ...results.map(
        (xfile) => UniversalFile(data: xfile, type: UniversalFileType.image),
      ),
    ];
    state = state.copyWith(attachments: newAttachments);
  }

  Future<void> pickVideos() async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result == null || result.count == 0) return;

    final newAttachments = [
      ...state.attachments,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.video),
      ),
    ];
    state = state.copyWith(attachments: newAttachments);
  }

  Future<void> pickAudio() async {
    final result = await FilePicker.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null || result.count == 0) return;

    final newAttachments = [
      ...state.attachments,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.audio),
      ),
    ];
    state = state.copyWith(attachments: newAttachments);
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result == null || result.count == 0) return;

    final newAttachments = [
      ...state.attachments,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.file),
      ),
    ];
    state = state.copyWith(attachments: newAttachments);
  }

  Future<void> linkAttachment(BuildContext context) async {
    final cloudFile = await showModalBottomSheet<SnCloudFile?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ChatLinkAttachment(),
    );
    if (cloudFile == null) return;

    final newAttachments = [
      ...state.attachments,
      UniversalFile(
        data: cloudFile,
        type: switch (cloudFile.mimeType?.split('/').firstOrNull) {
          'image' => UniversalFileType.image,
          'video' => UniversalFileType.video,
          'audio' => UniversalFileType.audio,
          _ => UniversalFileType.file,
        },
        isLink: true,
      ),
    ];
    state = state.copyWith(attachments: newAttachments);
  }

  // ==================== Read Receipts ====================

  void setLastReadAnchorMessageId(String? messageId) {
    state = state.copyWith(
      lastReadAnchorMessageId: messageId,
      clearLastReadAnchor: messageId == null,
    );
  }

  void dismissLastReadMarker() {
    state = state.copyWith(clearLastReadAnchor: true);
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
