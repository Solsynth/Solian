import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/database/message.dart';
import 'package:island/database/message_repository.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/database.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/route.gr.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/services/rtc.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_file_collection.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:uuid/uuid.dart';
import 'chat.dart';

final messageRepositoryProvider = FutureProvider.family<MessageRepository, int>(
  (ref, roomId) async {
    final room = await ref.watch(chatroomProvider(roomId).future);
    final identity = await ref.watch(chatroomIdentityProvider(roomId).future);
    final apiClient = ref.watch(apiClientProvider);
    final database = ref.watch(databaseProvider);
    return MessageRepository(room!, identity!, apiClient, database);
  },
);

// Provider for messages with pagination
final messagesProvider = StateNotifierProvider.family<
  MessagesNotifier,
  AsyncValue<List<LocalChatMessage>>,
  int
>((ref, roomId) => MessagesNotifier(ref, roomId));

class MessagesNotifier
    extends StateNotifier<AsyncValue<List<LocalChatMessage>>> {
  final Ref _ref;
  final int _roomId;
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;

  MessagesNotifier(this._ref, this._roomId)
    : super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      final synced = await repository.syncMessages();
      final messages = await repository.listMessages(
        offset: 0,
        take: _pageSize,
        synced: synced,
      );
      state = AsyncValue.data(messages);
      _currentPage = 0;
      _hasMore = messages.length == _pageSize;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is AsyncLoading) return;

    try {
      final currentMessages = state.value ?? [];
      _currentPage++;
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      final newMessages = await repository.listMessages(
        offset: _currentPage * _pageSize,
        take: _pageSize,
      );

      if (newMessages.isEmpty || newMessages.length < _pageSize) {
        _hasMore = false;
      }

      state = AsyncValue.data([...currentMessages, ...newMessages]);
    } catch (err) {
      showErrorAlert(err);
      _currentPage--;
    }
  }

  Future<void> sendMessage(
    String content,
    List<UniversalFile> attachments, {
    SnChatMessage? replyingTo,
    SnChatMessage? forwardingTo,
    SnChatMessage? editingTo,
  }) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );

      final nonce = const Uuid().v4();

      final baseUrl = _ref.read(serverUrlProvider);
      final atk = await getFreshAtk(
        _ref.watch(tokenPairProvider),
        baseUrl,
        onRefreshed: (atk, rtk) {
          setTokenPair(_ref.watch(sharedPreferencesProvider), atk, rtk);
          _ref.invalidate(tokenPairProvider);
        },
      );
      if (atk == null) throw Exception("Unauthorized");

      LocalChatMessage? pendingMessage;
      final messageTask = repository.sendMessage(
        atk,
        baseUrl,
        _roomId,
        content,
        nonce,
        attachments: attachments,
        replyingTo: replyingTo,
        forwardingTo: forwardingTo,
        editingTo: editingTo,
        onPending: (pending) {
          pendingMessage = pending;
          final currentMessages = state.value ?? [];
          state = AsyncValue.data([pending, ...currentMessages]);
        },
      );

      final message = await messageTask;

      final updatedMessages = state.value ?? [];
      if (pendingMessage != null) {
        final index = updatedMessages.indexWhere(
          (m) => m.id == pendingMessage!.id,
        );
        if (index >= 0) {
          final newList = [...updatedMessages];
          newList[index] = message;
          state = AsyncValue.data(newList);
        }
      } else {
        state = AsyncValue.data([message, ...updatedMessages]);
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> retryMessage(String pendingMessageId) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      final updatedMessage = await repository.retryMessage(pendingMessageId);

      // Update the message in the list
      final currentMessages = state.value ?? [];
      final index = currentMessages.indexWhere((m) => m.id == pendingMessageId);
      if (index >= 0) {
        final newList = [...currentMessages];
        newList[index] = updatedMessage;
        state = AsyncValue.data(newList);
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> receiveMessage(SnChatMessage remoteMessage) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );

      // Skip if this message is not for this room
      if (remoteMessage.chatRoomId != _roomId) return;

      final localMessage = await repository.receiveMessage(remoteMessage);

      // Add the new message to the state
      final currentMessages = state.value ?? [];

      // Check if the message already exists (by id or nonce)
      final existingIndex = currentMessages.indexWhere(
        (m) =>
            m.id == localMessage.id ||
            (localMessage.nonce != null && m.nonce == localMessage.nonce),
      );

      if (existingIndex >= 0) {
        // Replace existing message
        final newList = [...currentMessages];
        newList[existingIndex] = localMessage;
        state = AsyncValue.data(newList);
      } else {
        // Add new message at the beginning (newest first)
        state = AsyncValue.data([localMessage, ...currentMessages]);
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> receiveMessageUpdate(SnChatMessage remoteMessage) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );

      // Skip if this message is not for this room
      if (remoteMessage.chatRoomId != _roomId) return;

      final updatedMessage = await repository.receiveMessageUpdate(
        remoteMessage,
      );

      // Update the message in the list
      final currentMessages = state.value ?? [];
      final index = currentMessages.indexWhere(
        (m) => m.id == updatedMessage.id,
      );

      if (index >= 0) {
        final newList = [...currentMessages];
        newList[index] = updatedMessage;
        state = AsyncValue.data(newList);
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> receiveMessageDeletion(String messageId) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );

      await repository.receiveMessageDeletion(messageId);

      // Remove the message from the list
      final currentMessages = state.value ?? [];
      final filteredMessages =
          currentMessages.where((m) => m.id != messageId).toList();

      if (filteredMessages.length != currentMessages.length) {
        state = AsyncValue.data(filteredMessages);
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> updateMessage(
    String messageId,
    String content, {
    List<SnCloudFile>? attachments,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );

      final updatedMessage = await repository.updateMessage(
        messageId,
        content,
        attachments: attachments,
        meta: meta,
      );

      // Update the message in the list
      final currentMessages = state.value ?? [];
      final index = currentMessages.indexWhere((m) => m.id == messageId);

      if (index >= 0) {
        final newList = [...currentMessages];
        newList[index] = updatedMessage;
        state = AsyncValue.data(newList);
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );

      await repository.deleteMessage(messageId);

      // Remove the message from the list
      final currentMessages = state.value ?? [];
      final filteredMessages =
          currentMessages.where((m) => m.id != messageId).toList();

      if (filteredMessages.length != currentMessages.length) {
        state = AsyncValue.data(filteredMessages);
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<LocalChatMessage?> fetchMessageById(String messageId) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      return await repository.getMessageById(messageId);
    } catch (err) {
      showErrorAlert(err);
      return null;
    }
  }
}

@RoutePage()
class ChatRoomScreen extends HookConsumerWidget {
  final int id;
  const ChatRoomScreen({super.key, @PathParam("id") required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoom = ref.watch(chatroomProvider(id));
    final chatIdentity = ref.watch(chatroomIdentityProvider(id));
    final messages = ref.watch(messagesProvider(id));
    final messagesNotifier = ref.read(messagesProvider(id).notifier);
    final ws = ref.watch(websocketProvider);

    final messageController = useTextEditingController();
    final scrollController = useScrollController();

    final messageReplyingTo = useState<SnChatMessage?>(null);
    final messageForwardingTo = useState<SnChatMessage?>(null);
    final messageEditingTo = useState<SnChatMessage?>(null);

    // Add scroll listener for pagination
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          messagesNotifier.loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    // Add websocket listener
    // Add websocket listener for new messages
    useEffect(() {
      void onMessage(WebSocketPacket pkt) {
        if (!pkt.type.startsWith('messages')) return;
        final message = SnChatMessage.fromJson(pkt.data!);
        if (message.chatRoomId != chatRoom.value?.id) return;
        switch (pkt.type) {
          case 'messages.new':
            messagesNotifier.receiveMessage(message);
          case 'messages.update':
            messagesNotifier.receiveMessageUpdate(message);
          case 'messages.delete':
            messagesNotifier.receiveMessageDeletion(message.id);
        }
      }

      final subscription = ws.dataStream.listen(onMessage);
      return () => subscription.cancel();
    }, [ws, chatRoom]);

    final attachments = useState<List<UniversalFile>>([]);

    Future<void> pickPhotoMedia() async {
      final result = await ref
          .watch(imagePickerProvider)
          .pickMultiImage(requestFullMetadata: true);
      if (result.isEmpty) return;
      attachments.value = [
        ...attachments.value,
        ...result.map(
          (e) => UniversalFile(data: e, type: UniversalFileType.image),
        ),
      ];
    }

    Future<void> pickVideoMedia() async {
      final result = await ref
          .watch(imagePickerProvider)
          .pickVideo(source: ImageSource.gallery);
      if (result == null) return;
      attachments.value = [
        ...attachments.value,
        UniversalFile(data: result, type: UniversalFileType.video),
      ];
    }

    void sendMessage() {
      if (messageController.text.trim().isNotEmpty ||
          attachments.value.isNotEmpty) {
        messagesNotifier.sendMessage(
          messageController.text.trim(),
          attachments.value,
          editingTo: messageEditingTo.value,
          forwardingTo: messageForwardingTo.value,
          replyingTo: messageReplyingTo.value,
        );
        messageController.clear();
        messageEditingTo.value = null;
        messageReplyingTo.value = null;
        messageForwardingTo.value = null;
        attachments.value = [];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: chatRoom.when(
          data:
              (room) => Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 26,
                    width: 26,
                    child:
                        room!.type == 1
                            ? ProfilePictureWidget(
                              fileId:
                                  room.members!.first.account.profile.pictureId,
                            )
                            : room.pictureId != null
                            ? ProfilePictureWidget(
                              fileId: room.pictureId,
                              fallbackIcon: Symbols.chat,
                            )
                            : CircleAvatar(
                              child: Text(
                                room.name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                  ),
                  Text(
                    room.type == 1
                        ? room.members!.first.account.nick
                        : room.name,
                  ).fontSize(19),
                ],
              ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final user = ref.watch(userInfoProvider);
              if (currentlyJoined) {
                leaveRealtimeChat(chatRoom.value!);
              } else {
                joinRealtimeChat(
                  ref.watch(apiClientProvider),
                  chatRoom.value!,
                  user.value!,
                );
              }
            },
            icon: const Icon(Symbols.video_call),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              context.router.push(ChatDetailRoute(id: id));
            },
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data:
                  (messageList) =>
                      messageList.isEmpty
                          ? Center(child: Text('No messages yet'.tr()))
                          : ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            controller: scrollController,
                            reverse: true, // Show newest messages at the bottom
                            itemCount: messageList.length,
                            itemBuilder: (context, index) {
                              final message = messageList[index];
                              return chatIdentity.when(
                                skipError: true,
                                data:
                                    (identity) => _MessageBubble(
                                      message: message,
                                      isCurrentUser:
                                          identity?.id == message.senderId,
                                      onAction: (action) {
                                        switch (action) {
                                          case _MessageBubbleAction.delete:
                                            messagesNotifier.deleteMessage(
                                              message.id,
                                            );
                                          case _MessageBubbleAction.edit:
                                            messageEditingTo.value =
                                                message.toRemoteMessage();
                                            messageController.text =
                                                messageEditingTo
                                                    .value
                                                    ?.content ??
                                                '';
                                            attachments.value =
                                                messageEditingTo
                                                    .value!
                                                    .attachments
                                                    .map(
                                                      (e) =>
                                                          UniversalFile.fromAttachment(
                                                            e,
                                                          ),
                                                    )
                                                    .toList();
                                          case _MessageBubbleAction.forward:
                                            messageForwardingTo.value =
                                                message.toRemoteMessage();
                                          case _MessageBubbleAction.reply:
                                            messageReplyingTo.value =
                                                message.toRemoteMessage();
                                        }
                                      },
                                    ),
                                loading:
                                    () => _MessageBubble(
                                      message: message,
                                      isCurrentUser: false,
                                      onAction: null,
                                    ),
                                error: (_, __) => const SizedBox.shrink(),
                              );
                            },
                          ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error: $error'),
                        ElevatedButton(
                          onPressed: () => messagesNotifier.loadInitial(),
                          child: Text('Retry'.tr()),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
          chatRoom.when(
            data:
                (room) => _ChatInput(
                  messageController: messageController,
                  chatRoom: room!,
                  onSend: sendMessage,
                  onClear: () {
                    if (messageEditingTo.value != null) {
                      attachments.value.clear();
                      messageController.clear();
                    }
                    messageEditingTo.value = null;
                    messageReplyingTo.value = null;
                    messageForwardingTo.value = null;
                  },
                  messageEditingTo: messageEditingTo.value,
                  messageReplyingTo: messageReplyingTo.value,
                  messageForwardingTo: messageForwardingTo.value,
                  onPickFile: (bool isPhoto) {
                    if (isPhoto) {
                      pickPhotoMedia();
                    } else {
                      pickVideoMedia();
                    }
                  },
                  attachments: attachments.value,
                  onUploadAttachment: (_) {
                    // not going to do anything, only upload when send the message
                  },
                  onDeleteAttachment: (index) async {
                    final attachment = attachments.value[index];
                    if (attachment.isOnCloud) {
                      final client = ref.watch(apiClientProvider);
                      await client.delete('/files/${attachment.data.id}');
                    }
                    final clone = List.of(attachments.value);
                    clone.removeAt(index);
                    attachments.value = clone;
                  },
                  onMoveAttachment: (idx, delta) {
                    if (idx + delta < 0 ||
                        idx + delta >= attachments.value.length) {
                      return;
                    }
                    final clone = List.of(attachments.value);
                    clone.insert(idx + delta, clone.removeAt(idx));
                    attachments.value = clone;
                  },
                ),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController messageController;
  final SnChatRoom chatRoom;
  final VoidCallback onSend;
  final VoidCallback onClear;
  final Function(bool isPhoto) onPickFile;
  final SnChatMessage? messageReplyingTo;
  final SnChatMessage? messageForwardingTo;
  final SnChatMessage? messageEditingTo;
  final List<UniversalFile> attachments;
  final Function(int) onUploadAttachment;
  final Function(int) onDeleteAttachment;
  final Function(int, int) onMoveAttachment;

  const _ChatInput({
    required this.messageController,
    required this.chatRoom,
    required this.onSend,
    required this.onClear,
    required this.onPickFile,
    required this.messageReplyingTo,
    required this.messageForwardingTo,
    required this.messageEditingTo,
    required this.attachments,
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onMoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          if (attachments.isNotEmpty)
            SizedBox(
              height: 280,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: attachments.length,
                itemBuilder: (context, idx) {
                  return AttachmentPreview(
                    item: attachments[idx],
                    onRequestUpload: () => onUploadAttachment(idx),
                    onDelete: () => onDeleteAttachment(idx),
                    onMove: (delta) => onMoveAttachment(idx, delta),
                  );
                },
                separatorBuilder: (_, __) => const Gap(8),
              ),
            ),
          if (messageReplyingTo != null ||
              messageForwardingTo != null ||
              messageEditingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Row(
                children: [
                  Icon(
                    messageReplyingTo != null
                        ? Symbols.reply
                        : messageForwardingTo != null
                        ? Symbols.forward
                        : Symbols.edit,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      messageReplyingTo != null
                          ? 'Replying to ${messageReplyingTo?.sender.account.nick}'
                          : messageForwardingTo != null
                          ? 'Forwarding message'
                          : 'Editing message',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onClear,
                    padding: EdgeInsets.zero,
                    style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(28, 28)),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              children: [
                PopupMenuButton(
                  icon: const Icon(Symbols.photo_library),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          onTap: () => onPickFile(true),
                          child: Row(
                            spacing: 12,
                            children: [
                              const Icon(Symbols.photo),
                              Text('addPhoto').tr(),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () => onPickFile(false),
                          child: Row(
                            spacing: 12,
                            children: [
                              const Icon(Symbols.video_call),
                              Text('addVideo').tr(),
                            ],
                          ),
                        ),
                      ],
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText:
                          chatRoom.type == 1
                              ? 'chatDirectMessageHint'.tr(
                                args: [chatRoom.members!.first.account.nick],
                              )
                              : 'chatMessageHint'.tr(args: [chatRoom.name]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    maxLines: null,
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: onSend,
                ),
              ],
            ).padding(bottom: MediaQuery.of(context).padding.bottom),
          ),
        ],
      ),
    );
  }
}

class _MessageBubbleAction {
  static const String edit = "edit";
  static const String delete = "delete";
  static const String reply = "reply";
  static const String forward = "forward";
}

class _MessageBubble extends HookConsumerWidget {
  final LocalChatMessage message;
  final bool isCurrentUser;
  final Function(String action)? onAction;

  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor =
        isCurrentUser
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant;
    final containerColor =
        isCurrentUser
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
            : Theme.of(context).colorScheme.surfaceContainer;

    return ContextMenuWidget(
      menuProvider: (_) {
        if (onAction == null) return Menu(children: []);
        return Menu(
          children: [
            if (isCurrentUser)
              MenuAction(
                title: 'edit'.tr(),
                image: MenuImage.icon(Symbols.edit),
                callback: () {
                  onAction!.call(_MessageBubbleAction.edit);
                },
              ),
            if (isCurrentUser)
              MenuAction(
                title: 'delete'.tr(),
                image: MenuImage.icon(Symbols.delete),
                callback: () {
                  onAction!.call(_MessageBubbleAction.delete);
                },
              ),
            if (isCurrentUser) MenuSeparator(),
            MenuAction(
              title: 'reply'.tr(),
              image: MenuImage.icon(Symbols.reply),
              callback: () {
                onAction!.call(_MessageBubbleAction.reply);
              },
            ),
            MenuAction(
              title: 'forward'.tr(),
              image: MenuImage.icon(Symbols.forward),
              callback: () {
                onAction!.call(_MessageBubbleAction.forward);
              },
            ),
          ],
        );
      },
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isCurrentUser)
                ProfilePictureWidget(
                  fileId:
                      message
                          .toRemoteMessage()
                          .sender
                          .account
                          .profile
                          .pictureId,
                  radius: 18,
                ),
              const Gap(8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.toRemoteMessage().repliedMessageId != null)
                        _MessageQuoteWidget(
                          message: message,
                          textColor: textColor,
                          isReply: true,
                        ),
                      if (message.toRemoteMessage().forwardedMessageId != null)
                        _MessageQuoteWidget(
                          message: message,
                          textColor: textColor,
                          isReply: false,
                        ),
                      if (message.toRemoteMessage().content?.isNotEmpty ??
                          false)
                        Text(
                          message.toRemoteMessage().content!,
                          style: TextStyle(color: textColor),
                        ),
                      if (message.toRemoteMessage().attachments.isNotEmpty)
                        CloudFileList(
                          files: message.toRemoteMessage().attachments,
                        ).padding(top: 4),
                      const Gap(4),
                      Row(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat.Hm().format(message.createdAt.toLocal()),
                            style: TextStyle(fontSize: 10, color: textColor),
                          ),
                          if (message.toRemoteMessage().editedAt != null)
                            Text(
                              'edited'.tr().toLowerCase(),
                              style: TextStyle(fontSize: 10, color: textColor),
                            ),
                          if (isCurrentUser)
                            _buildStatusIcon(
                              context,
                              message.status,
                              textColor,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(8),
              if (isCurrentUser)
                ProfilePictureWidget(
                  fileId:
                      message
                          .toRemoteMessage()
                          .sender
                          .account
                          .profile
                          .pictureId,
                  radius: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(
    BuildContext context,
    MessageStatus status,
    Color textColor,
  ) {
    switch (status) {
      case MessageStatus.pending:
        return Icon(Icons.access_time, size: 12, color: textColor);
      case MessageStatus.sent:
        return Icon(Icons.check, size: 12, color: textColor);
      case MessageStatus.failed:
        return Consumer(
          builder:
              (context, ref, _) => GestureDetector(
                onTap: () {
                  ref
                      .read(messagesProvider(message.roomId).notifier)
                      .retryMessage(message.id);
                },
                child: const Icon(
                  Icons.error_outline,
                  size: 12,
                  color: Colors.red,
                ),
              ),
        );
    }
  }
}

class _MessageQuoteWidget extends HookConsumerWidget {
  final LocalChatMessage message;
  final Color textColor;
  final bool isReply;

  const _MessageQuoteWidget({
    required this.message,
    required this.textColor,
    required this.isReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesNotifier = ref.watch(
      messagesProvider(message.roomId).notifier,
    );

    return FutureBuilder<LocalChatMessage?>(
      future: messagesNotifier.fetchMessageById(
        isReply
            ? message.toRemoteMessage().repliedMessageId!
            : message.toRemoteMessage().forwardedMessageId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              color: Theme.of(
                context,
              ).colorScheme.primaryFixedDim.withOpacity(0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isReply)
                    Row(
                      spacing: 4,
                      children: [
                        Icon(Symbols.reply, size: 16, color: textColor),
                        Text(
                          'Replying to ${snapshot.data!.toRemoteMessage().sender.account.nick}',
                        ).textColor(textColor).bold(),
                      ],
                    )
                  else
                    Row(
                      spacing: 4,
                      children: [
                        Icon(Symbols.forward, size: 16, color: textColor),
                        Text(
                          'Forwarded from ${snapshot.data!.toRemoteMessage().sender.account.nick}',
                        ).textColor(textColor).bold(),
                      ],
                    ),
                  if (snapshot.data!.toRemoteMessage().content?.isNotEmpty ??
                      false)
                    Text(
                      snapshot.data!.toRemoteMessage().content!,
                      style: TextStyle(color: textColor),
                    ),
                ],
              ),
            ),
          ).padding(bottom: 4);
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
