import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:island/pods/websocket.dart';
import 'package:island/route.gr.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/chat/call_overlay.dart';
import 'package:island/widgets/chat/message_item.dart';
import 'package:island/widgets/content/attachment_preview.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:uuid/uuid.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'chat.dart';
import 'package:island/widgets/chat/call_button.dart';

part 'room.g.dart';

final messageRepositoryProvider =
    FutureProvider.family<MessageRepository, String>((ref, roomId) async {
      final room = await ref.watch(chatroomProvider(roomId).future);
      final identity = await ref.watch(chatroomIdentityProvider(roomId).future);
      final apiClient = ref.watch(apiClientProvider);
      final database = ref.watch(databaseProvider);
      return MessageRepository(room!, identity!, apiClient, database);
    });

@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  late final String _roomId;
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;

  @override
  FutureOr<List<LocalChatMessage>> build(String roomId) async {
    _roomId = roomId;
    return await loadInitial();
  }

  Future<List<LocalChatMessage>> loadInitial() async {
    try {
      final repository = await ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      final synced = await repository.syncMessages();
      final messages = await repository.listMessages(
        offset: 0,
        take: _pageSize,
        synced: synced,
      );
      _currentPage = 0;
      _hasMore = messages.length == _pageSize;
      return messages;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is AsyncLoading) return;

    try {
      final currentMessages = state.value ?? [];
      _currentPage++;
      final repository = await ref.read(
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
    SnChatMessage? editingTo,
    SnChatMessage? forwardingTo,
    SnChatMessage? replyingTo,
    Function(String, Map<int, double>)? onProgress,
  }) async {
    try {
      final repository = await ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      final baseUrl = ref.read(serverUrlProvider);
      final token = await getToken(ref.watch(tokenProvider));
      if (token == null) throw ArgumentError('Access token is null');

      final currentMessages = state.value ?? [];
      await repository.sendMessage(
        token,
        baseUrl,
        _roomId,
        content,
        const Uuid().v4(),
        attachments: attachments,
        editingTo: editingTo,
        forwardingTo: forwardingTo,
        replyingTo: replyingTo,
        onPending: (pending) {
          state = AsyncValue.data([pending, ...currentMessages]);
        },
        onProgress: onProgress,
      );

      // Refresh messages
      final messages = await repository.listMessages(
        offset: 0,
        take: _pageSize,
      );
      state = AsyncValue.data(messages);
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> retryMessage(String pendingMessageId) async {
    try {
      final repository = await ref.read(
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
      final repository = await ref.read(
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
      final repository = await ref.read(
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
      final repository = await ref.read(
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

  Future<void> deleteMessage(String messageId) async {
    try {
      final repository = await ref.read(
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
      final repository = await ref.read(
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
  final String id;
  const ChatRoomScreen({super.key, @PathParam("id") required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoom = ref.watch(chatroomProvider(id));
    final chatIdentity = ref.watch(chatroomIdentityProvider(id));
    final messages = ref.watch(messagesNotifierProvider(id));
    final messagesNotifier = ref.read(messagesNotifierProvider(id).notifier);
    final ws = ref.watch(websocketProvider);

    final messageController = useTextEditingController();
    final scrollController = useScrollController();

    final messageReplyingTo = useState<SnChatMessage?>(null);
    final messageForwardingTo = useState<SnChatMessage?>(null);
    final messageEditingTo = useState<SnChatMessage?>(null);
    final attachments = useState<List<UniversalFile>>([]);
    final attachmentProgress = useState<Map<String, Map<int, double>>>({});

    // Function to send read receipt
    void sendReadReceipt() async {
      // Send websocket packet
      final wsState = ref.read(websocketStateProvider.notifier);
      wsState.sendMessage(
        jsonEncode(
          WebSocketPacket(type: 'messages.read', data: {'chat_room_id': id}),
        ),
      );
    }

    // Members who are typing
    final typingStatuses = useState<List<SnChatMember>>([]);
    final typingDebouncer = useState<Timer?>(null);

    void sendTypingStatus() {
      // Don't send if we're already in a cooldown period
      if (typingDebouncer.value != null) return;

      // Send typing status immediately
      final wsState = ref.read(websocketStateProvider.notifier);
      wsState.sendMessage(
        jsonEncode(
          WebSocketPacket(type: 'messages.typing', data: {'chat_room_id': id}),
        ),
      );

      typingDebouncer.value = Timer(const Duration(milliseconds: 850), () {
        typingDebouncer.value = null;
      });
    }

    // Add timer to remove typing status after inactivity
    useEffect(() {
      final removeTypingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (typingStatuses.value.isNotEmpty) {
          // Remove typing statuses older than 5 seconds
          final now = DateTime.now();
          typingStatuses.value =
              typingStatuses.value.where((member) {
                final lastTyped =
                    member.lastTyped ??
                    DateTime.now().subtract(const Duration(milliseconds: 1350));
                return now.difference(lastTyped).inSeconds < 5;
              }).toList();
        }
      });

      return () => removeTypingTimer.cancel();
    }, []);

    var isLoading = false;

    // Add scroll listener for pagination
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (isLoading) return;
          isLoading = true;
          messagesNotifier.loadMore().then((_) => isLoading = false);
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    // Add websocket listener for new messages
    useEffect(() {
      void onMessage(WebSocketPacket pkt) {
        if (!pkt.type.startsWith('messages')) return;
        if (['messages.read'].contains(pkt.type)) return;

        if (pkt.type == 'messages.typing' && pkt.data?['sender'] != null) {
          if (pkt.data?['sender_id'] == chatIdentity.value?.id) return;

          final sender = SnChatMember.fromJson(
            pkt.data?['sender'],
          ).copyWith(lastTyped: DateTime.now());

          // Check if the sender is already in the typing list
          final existingIndex = typingStatuses.value.indexWhere(
            (member) => member.id == sender.id,
          );
          if (existingIndex >= 0) {
            // Update the existing entry with new timestamp
            final updatedList = [...typingStatuses.value];
            updatedList[existingIndex] = sender;
            typingStatuses.value = updatedList;
          } else {
            // Add new typing status
            typingStatuses.value = [...typingStatuses.value, sender];
          }
          return;
        }

        final message = SnChatMessage.fromJson(pkt.data!);
        if (message.chatRoomId != chatRoom.value?.id) return;
        switch (pkt.type) {
          case 'messages.new':
            if (message.type.startsWith('call')) {
              // Handle the ongoing call.
              ref.invalidate(ongoingCallProvider(message.chatRoomId));
            }
            messagesNotifier.receiveMessage(message);
            // Send read receipt for new message
            sendReadReceipt();
          case 'messages.update':
            messagesNotifier.receiveMessageUpdate(message);
          case 'messages.delete':
            messagesNotifier.receiveMessageDeletion(message.id);
        }
      }

      sendReadReceipt();
      final subscription = ws.dataStream.listen(onMessage);
      return () => subscription.cancel();
    }, [ws, chatRoom]);

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
        messagesNotifier
            .sendMessage(
              messageController.text.trim(),
              attachments.value,
              editingTo: messageEditingTo.value,
              forwardingTo: messageForwardingTo.value,
              replyingTo: messageReplyingTo.value,
              onProgress: (messageId, progress) {
                attachmentProgress.value = {
                  ...attachmentProgress.value,
                  messageId: progress,
                };
              },
            )
            .then((_) => sendReadReceipt());
        messageController.clear();
        messageEditingTo.value = null;
        messageReplyingTo.value = null;
        messageForwardingTo.value = null;
        attachments.value = [];
      }
    }

    // Add listener to message controller for typing status
    useEffect(() {
      void onTextChange() {
        if (messageController.text.isNotEmpty) {
          sendTypingStatus();
        }
      }

      messageController.addListener(onTextChange);
      return () => messageController.removeListener(onTextChange);
    }, [messageController]);

    final compactHeader = isWideScreen(context);

    final listController = useMemoized(() => ListController(), []);

    return AppScaffold(
      appBar: AppBar(
        leading: !compactHeader ? const Center(child: PageBackButton()) : null,
        automaticallyImplyLeading: false,
        toolbarHeight: compactHeader ? null : 64,
        title: chatRoom.when(
          data:
              (room) =>
                  compactHeader
                      ? Row(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 26,
                            width: 26,
                            child:
                                (room!.type == 1 && room.picture?.id == null)
                                    ? SplitAvatarWidget(
                                      filesId:
                                          room.members!
                                              .map(
                                                (e) =>
                                                    e
                                                        .account
                                                        .profile
                                                        .picture
                                                        ?.id,
                                              )
                                              .toList(),
                                    )
                                    : room.picture?.id != null
                                    ? ProfilePictureWidget(
                                      fileId: room.picture?.id,
                                      fallbackIcon: Symbols.chat,
                                    )
                                    : CircleAvatar(
                                      child: Text(
                                        room.name![0].toUpperCase(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                          ),
                          Text(
                            (room.type == 1 && room.name == null)
                                ? room.members!
                                    .map((e) => e.account.nick)
                                    .join(', ')
                                : room.name!,
                          ).fontSize(19),
                        ],
                      )
                      : Column(
                        spacing: 4,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 26,
                            width: 26,
                            child:
                                (room!.type == 1 && room.picture?.id == null)
                                    ? SplitAvatarWidget(
                                      filesId:
                                          room.members!
                                              .map(
                                                (e) =>
                                                    e
                                                        .account
                                                        .profile
                                                        .picture
                                                        ?.id,
                                              )
                                              .toList(),
                                    )
                                    : room.picture?.id != null
                                    ? ProfilePictureWidget(
                                      fileId: room.picture?.id,
                                      fallbackIcon: Symbols.chat,
                                    )
                                    : CircleAvatar(
                                      child: Text(
                                        room.name![0].toUpperCase(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                          ),
                          Text(
                            (room.type == 1 && room.name == null)
                                ? room.members!
                                    .map((e) => e.account.nick)
                                    .join(', ')
                                : room.name!,
                          ).fontSize(15),
                        ],
                      ),
          loading: () => const Text('Loading...'),
          error:
              (err, _) => ResponseErrorWidget(
                error: err,
                onRetry: () => messagesNotifier.loadInitial(),
              ),
        ),
        actions: [
          AudioCallButton(roomId: id),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              context.router.push(ChatDetailRoute(id: id));
            },
          ),
          const Gap(8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: messages.when(
                  data:
                      (messageList) =>
                          messageList.isEmpty
                              ? Center(child: Text('No messages yet'.tr()))
                              : SuperListView.builder(
                                listController: listController,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                controller: scrollController,
                                reverse:
                                    true, // Show newest messages at the bottom
                                itemCount: messageList.length,
                                findChildIndexCallback: (key) {
                                  final valueKey = key as ValueKey;
                                  final messageId = valueKey.value as String;
                                  return messageList.indexWhere(
                                    (m) => m.id == messageId,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  final message = messageList[index];
                                  final nextMessage =
                                      index < messageList.length - 1
                                          ? messageList[index + 1]
                                          : null;
                                  final isLastInGroup =
                                      nextMessage == null ||
                                      nextMessage.senderId !=
                                          message.senderId ||
                                      nextMessage.createdAt
                                              .difference(message.createdAt)
                                              .inMinutes
                                              .abs() >
                                          3;

                                  return chatIdentity.when(
                                    skipError: true,
                                    data:
                                        (identity) => MessageItem(
                                          message: message,
                                          isCurrentUser:
                                              identity?.id == message.senderId,
                                          onAction: (action) {
                                            switch (action) {
                                              case MessageItemAction.delete:
                                                messagesNotifier.deleteMessage(
                                                  message.id,
                                                );
                                              case MessageItemAction.edit:
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
                                              case MessageItemAction.forward:
                                                messageForwardingTo.value =
                                                    message.toRemoteMessage();
                                              case MessageItemAction.reply:
                                                messageReplyingTo.value =
                                                    message.toRemoteMessage();
                                            }
                                          },
                                          onJump: (messageId) {
                                            final messageIndex = messageList
                                                .indexWhere(
                                                  (m) => m.id == messageId,
                                                );
                                            listController.jumpToItem(
                                              index: messageIndex,
                                              scrollController:
                                                  scrollController,
                                              alignment: 0.5,
                                            );
                                          },
                                          progress:
                                              attachmentProgress.value[message
                                                  .id],
                                          showAvatar: isLastInGroup,
                                        ),
                                    loading:
                                        () => MessageItem(
                                          message: message,
                                          isCurrentUser: false,
                                          onAction: null,
                                          progress: null,
                                          showAvatar: false,
                                          onJump: (_) {},
                                        ),
                                    error: (_, _) => const SizedBox.shrink(),
                                  );
                                },
                              ),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, _) => ResponseErrorWidget(
                        error: error,
                        onRetry: () => messagesNotifier.loadInitial(),
                      ),
                ),
              ),
              chatRoom.when(
                data:
                    (room) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          switchInCurve: Curves.fastEaseInToSlowEaseOut,
                          switchOutCurve: Curves.fastEaseInToSlowEaseOut,
                          transitionBuilder: (
                            Widget child,
                            Animation<double> animation,
                          ) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.3),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                              child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1.0,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child:
                              typingStatuses.value.isNotEmpty
                                  ? Container(
                                    key: const ValueKey('typing-indicator'),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Symbols.more_horiz,
                                          size: 16,
                                        ).padding(horizontal: 8),
                                        const Gap(8),
                                        Expanded(
                                          child: Text(
                                            'typingHint'.plural(
                                              typingStatuses.value.length,
                                              args: [
                                                typingStatuses.value
                                                    .map(
                                                      (x) =>
                                                          x.nick ??
                                                          x.account.nick,
                                                    )
                                                    .join(', '),
                                              ],
                                            ),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : const SizedBox.shrink(
                                    key: ValueKey('typing-indicator-none'),
                                  ),
                        ),
                        _ChatInput(
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
                              await client.delete(
                                '/files/${attachment.data.id}',
                              );
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
                          onAttachmentsChanged: (newAttachments) {
                            attachments.value = newAttachments;
                          },
                        ),
                      ],
                    ),
                error: (_, _) => const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: CallOverlayBar().padding(horizontal: 8, top: 12),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends HookConsumerWidget {
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
  final Function(List<UniversalFile>) onAttachmentsChanged;

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
    required this.onAttachmentsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputFocusNode = useFocusNode();

    final enterToSend = ref.watch(appSettingsNotifierProvider).enterToSend;

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    void send() {
      inputFocusNode.requestFocus();
      onSend.call();
    }

    Future<void> handlePaste() async {
      final clipboard = await Pasteboard.image;
      if (clipboard == null) return;

      onAttachmentsChanged([
        ...attachments,
        UniversalFile(
          data: XFile.fromData(clipboard, mimeType: "image/jpeg"),
          type: UniversalFileType.image,
        ),
      ]);
    }

    void handleKeyPress(
      BuildContext context,
      WidgetRef ref,
      RawKeyEvent event,
    ) {
      if (event is! RawKeyDownEvent) return;

      final isPaste = event.logicalKey == LogicalKeyboardKey.keyV;
      final isModifierPressed = event.isMetaPressed || event.isControlPressed;

      if (isPaste && isModifierPressed) {
        handlePaste();
        return;
      }

      final enterToSend = ref.read(appSettingsNotifierProvider).enterToSend;
      final isEnter = event.logicalKey == LogicalKeyboardKey.enter;

      if (isEnter) {
        if (enterToSend && !isModifierPressed) {
          send();
        } else if (!enterToSend && isModifierPressed) {
          send();
        }
      }
    }

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
                separatorBuilder: (_, _) => const Gap(8),
              ),
            ).padding(top: 12),
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
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) => handleKeyPress(context, ref, event),
                    child: TextField(
                      focusNode: inputFocusNode,
                      controller: messageController,
                      onSubmitted:
                          (enterToSend && isMobile)
                              ? (_) {
                                send();
                              }
                              : null,
                      keyboardType:
                          (enterToSend && isMobile)
                              ? TextInputType.text
                              : TextInputType.multiline,
                      textInputAction: TextInputAction.send,
                      inputFormatters: [
                        if (enterToSend && !isMobile)
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.endsWith('\n')) {
                              return oldValue;
                            }
                            return newValue;
                          }),
                      ],
                      decoration: InputDecoration(
                        hintText:
                            (chatRoom.type == 1 && chatRoom.name == null)
                                ? 'chatDirectMessageHint'.tr(
                                  args: [
                                    chatRoom.members!
                                        .map((e) => e.account.nick)
                                        .join(', '),
                                  ],
                                )
                                : 'chatMessageHint'.tr(args: [chatRoom.name!]),
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
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: send,
                ),
              ],
            ).padding(bottom: MediaQuery.of(context).padding.bottom),
          ),
        ],
      ),
    );
  }
}
