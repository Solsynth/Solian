import "dart:async";
import "dart:convert";
import "dart:typed_data";
import "package:cross_file/cross_file.dart";
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/database/message.dart";
import "package:island/models/chat.dart";
import "package:island/models/file.dart";
import "package:island/models/file_pool.dart";
import "package:island/pods/config.dart";
import "package:island/pods/file_pool.dart";
import "package:island/pods/messages_notifier.dart";
import "package:island/pods/network.dart";
import "package:island/pods/websocket.dart";
import "package:island/services/file.dart";
import "package:island/screens/chat/chat.dart";
import "package:island/services/responsive.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/attachment_uploader.dart";
import "package:island/widgets/chat/call_overlay.dart";
import "package:island/widgets/chat/message_item.dart";
import "package:island/widgets/content/attachment_preview.dart";
import "package:island/widgets/content/cloud_files.dart";
import "package:island/widgets/content/sheet.dart";
import "package:island/widgets/post/compose_shared.dart";
import "package:island/widgets/response.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:styled_widget/styled_widget.dart";
import "package:super_sliver_list/super_sliver_list.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:island/widgets/chat/call_button.dart";
import "package:island/widgets/chat/chat_input.dart";
import "package:island/widgets/chat/public_room_preview.dart";

final isSyncingProvider = StateProvider.autoDispose<bool>((ref) => false);

final flashingMessagesProvider = StateProvider<Set<String>>((ref) => {});

final appLifecycleStateProvider = StreamProvider<AppLifecycleState>((ref) {
  final controller = StreamController<AppLifecycleState>();

  final observer = _AppLifecycleObserver((state) {
    if (controller.isClosed) return;
    controller.add(state);
  });
  WidgetsBinding.instance.addObserver(observer);

  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
    controller.close();
  });

  return controller.stream;
});

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final ValueChanged<AppLifecycleState> onChange;
  _AppLifecycleObserver(this.onChange);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onChange(state);
  }
}

class ChatRoomScreen extends HookConsumerWidget {
  final String id;
  const ChatRoomScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoom = ref.watch(chatroomProvider(id));
    final chatIdentity = ref.watch(chatroomIdentityProvider(id));
    final isSyncing = ref.watch(isSyncingProvider);

    if (chatIdentity.isLoading || chatRoom.isLoading) {
      return AppScaffold(
        appBar: AppBar(leading: const PageBackButton()),
        body: CircularProgressIndicator().center(),
      );
    } else if (chatIdentity.value == null) {
      // Identity was not found, user was not joined
      return chatRoom.when(
        data: (room) {
          if (room!.isPublic) {
            // Show public room preview with messages but no input
            return PublicRoomPreview(id: id, room: room);
          } else {
            // Show regular "not joined" screen for private rooms
            return AppScaffold(
              appBar: AppBar(leading: const PageBackButton()),
              body: Center(
                child:
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            room.isCommunity == true
                                ? Symbols.person_add
                                : Symbols.person_remove,
                            size: 36,
                            fill: 1,
                          ).padding(bottom: 4),
                          Text('chatNotJoined').tr(),
                          if (room.isCommunity != true)
                            Text(
                              'chatUnableJoin',
                              textAlign: TextAlign.center,
                            ).tr().bold()
                          else
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                try {
                                  showLoadingModal(context);
                                  final apiClient = ref.read(apiClientProvider);
                                  await apiClient.post(
                                    '/sphere/chat/${room.id}/members/me',
                                  );
                                  ref.invalidate(chatroomIdentityProvider(id));
                                } catch (err) {
                                  showErrorAlert(err);
                                } finally {
                                  if (context.mounted) {
                                    hideLoadingModal(context);
                                  }
                                }
                              },
                              label: Text('chatJoin').tr(),
                              icon: const Icon(Icons.add),
                            ).padding(top: 8),
                        ],
                      ),
                    ).center(),
              ),
            );
          }
        },
        loading:
            () => AppScaffold(
              appBar: AppBar(leading: const PageBackButton()),
              body: CircularProgressIndicator().center(),
            ),
        error:
            (error, _) => AppScaffold(
              appBar: AppBar(leading: const PageBackButton()),
              body: ResponseErrorWidget(
                error: error,
                onRetry: () => ref.refresh(chatroomProvider(id)),
              ),
            ),
      );
    }

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
          WebSocketPacket(
            type: 'messages.read',
            data: {'chat_room_id': id},
            endpoint: 'DysonNetwork.Sphere',
          ),
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
          WebSocketPacket(
            type: 'messages.typing',
            data: {'chat_room_id': id},
            endpoint: 'DysonNetwork.Sphere',
          ),
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

    final listController = useMemoized(() => ListController(), []);

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
          if (pkt.data?['room_id'] != chatRoom.value?.id) return;
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
            messagesNotifier.receiveMessageUpdate(message).then((_) {
              messagesNotifier.receiveMessage(message);
            });
          case 'messages.delete':
            messagesNotifier.receiveMessageDeletion(message.id).then((_) {
              messagesNotifier.receiveMessage(message);
            });
        }
      }

      sendReadReceipt();
      final subscription = ws.dataStream.listen(onMessage);
      return () => subscription.cancel();
    }, [ws, chatRoom]);

    useEffect(() {
      final wsState = ref.read(websocketStateProvider.notifier);
      wsState.sendMessage(
        jsonEncode(
          WebSocketPacket(
            type: 'messages.subscribe',
            data: {'chat_room_id': id},
          ),
        ),
      );
      return () {
        wsState.sendMessage(
          jsonEncode(
            WebSocketPacket(
              type: 'messages.unsubscribe',
              data: {'chat_room_id': id},
            ),
          ),
        );
      };
    }, [id]);

    Future<void> pickPhotoMedia() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowCompression: false,
      );
      if (result == null || result.count == 0) return;
      attachments.value = [
        ...attachments.value,
        ...result.files.map(
          (e) => UniversalFile(data: e.xFile, type: UniversalFileType.image),
        ),
      ];
    }

    Future<void> pickVideoMedia() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
        allowCompression: false,
      );
      if (result == null || result.count == 0) return;
      attachments.value = [
        ...attachments.value,
        ...result.files.map(
          (e) => UniversalFile(data: e.xFile, type: UniversalFileType.video),
        ),
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

    Widget comfortHeaderWidget(SnChatRoom? room) => Column(
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
                            .map((e) => e.account.profile.picture?.id)
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
              ? room.members!.map((e) => e.account.nick).join(', ')
              : room.name!,
        ).fontSize(15),
      ],
    );

    Widget compactHeaderWidget(SnChatRoom? room) => Row(
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
                            .map((e) => e.account.profile.picture?.id)
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
              ? room.members!.map((e) => e.account.nick).join(', ')
              : room.name!,
        ).fontSize(19),
      ],
    );

    const messageKeyPrefix = 'message-';

    Future<void> uploadAttachment(int index) async {
      final attachment = attachments.value[index];
      if (attachment.isOnCloud) return;

      final config = await showModalBottomSheet<AttachmentUploadConfig>(
        context: context,
        isScrollControlled: true,
        builder:
            (context) => ChatAttachmentUploaderSheet(
              ref: ref,
              attachments: attachments.value,
              index: index,
            ),
      );
      if (config == null) return;

      final baseUrl = ref.watch(serverUrlProvider);
      final token = await getToken(ref.watch(tokenProvider));
      if (token == null) throw ArgumentError('Token is null');

      try {
        // Use 'chat-upload' as temporary key for progress
        attachmentProgress.value = {
          ...attachmentProgress.value,
          'chat-upload': {index: 0},
        };

        final cloudFile =
            await putFileToCloud(
              fileData: attachment,
              atk: token,
              baseUrl: baseUrl,
              poolId: config.poolId,
              filename: attachment.data.name ?? 'Chat media',
              mimetype:
                  attachment.data.mimeType ??
                  ComposeLogic.getMimeTypeFromFileType(attachment.type),
              mode:
                  attachment.type == UniversalFileType.file
                      ? FileUploadMode.generic
                      : FileUploadMode.mediaSafe,
              onProgress: (progress, _) {
                attachmentProgress.value = {
                  ...attachmentProgress.value,
                  'chat-upload': {index: progress},
                };
              },
            ).future;

        if (cloudFile == null) {
          throw ArgumentError('Failed to upload the file...');
        }

        final clone = List.of(attachments.value);
        clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
        attachments.value = clone;
      } catch (err) {
        showErrorAlert(err.toString());
      } finally {
        attachmentProgress.value = {...attachmentProgress.value}
          ..remove('chat-upload');
      }
    }

    Widget chatMessageListWidget(List<LocalChatMessage> messageList) =>
        SuperListView.builder(
          listController: listController,
          padding: EdgeInsets.symmetric(vertical: 16),
          controller: scrollController,
          reverse: true, // Show newest messages at the bottom
          itemCount: messageList.length,
          findChildIndexCallback: (key) {
            final valueKey = key as ValueKey;
            final messageId = (valueKey.value as String).substring(
              messageKeyPrefix.length,
            );
            return messageList.indexWhere((m) => m.id == messageId);
          },
          extentEstimation: (_, _) => 40,
          itemBuilder: (context, index) {
            final message = messageList[index];
            final nextMessage =
                index < messageList.length - 1 ? messageList[index + 1] : null;
            final isLastInGroup =
                nextMessage == null ||
                nextMessage.senderId != message.senderId ||
                nextMessage.createdAt
                        .difference(message.createdAt)
                        .inMinutes
                        .abs() >
                    3;

            final key = ValueKey('$messageKeyPrefix${message.id}');

            return chatIdentity.when(
              skipError: true,
              data:
                  (identity) => MessageItem(
                    key: key,
                    message: message,
                    isCurrentUser: identity?.id == message.senderId,
                    onAction: (action) {
                      switch (action) {
                        case MessageItemAction.delete:
                          messagesNotifier.deleteMessage(message.id);
                        case MessageItemAction.edit:
                          messageEditingTo.value = message.toRemoteMessage();
                          messageController.text =
                              messageEditingTo.value?.content ?? '';
                          attachments.value =
                              messageEditingTo.value!.attachments
                                  .map((e) => UniversalFile.fromAttachment(e))
                                  .toList();
                        case MessageItemAction.forward:
                          messageForwardingTo.value = message.toRemoteMessage();
                        case MessageItemAction.reply:
                          messageReplyingTo.value = message.toRemoteMessage();
                      }
                    },
                    onJump: (messageId) {
                      final messageIndex = messageList.indexWhere(
                        (m) => m.id == messageId,
                      );
                      if (messageIndex == -1) {
                        messagesNotifier.jumpToMessage(messageId).then((index) {
                          if (index != -1) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              listController.animateToItem(
                                index: index,
                                scrollController: scrollController,
                                alignment: 0.5,
                                duration:
                                    (estimatedDistance) =>
                                        Duration(milliseconds: 250),
                                curve: (estimatedDistance) => Curves.easeInOut,
                              );
                            });
                            ref
                                .read(flashingMessagesProvider.notifier)
                                .update((set) => set.union({messageId}));
                          }
                        });
                        return;
                      }
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        listController.animateToItem(
                          index: messageIndex,
                          scrollController: scrollController,
                          alignment: 0.5,
                          duration:
                              (estimatedDistance) =>
                                  Duration(milliseconds: 250),
                          curve: (estimatedDistance) => Curves.easeInOut,
                        );
                      });
                      ref
                          .read(flashingMessagesProvider.notifier)
                          .update((set) => set.union({messageId}));
                    },
                    progress: attachmentProgress.value[message.id],
                    showAvatar: isLastInGroup,
                  ),
              loading:
                  () => MessageItem(
                    key: key,
                    message: message,
                    isCurrentUser: false,
                    onAction: null,
                    progress: null,
                    showAvatar: false,
                    onJump: (_) {},
                  ),
              error: (_, _) => SizedBox.shrink(key: key),
            );
          },
        );

    return AppScaffold(
      appBar: AppBar(
        leading: !compactHeader ? const Center(child: PageBackButton()) : null,
        automaticallyImplyLeading: false,
        toolbarHeight: compactHeader ? null : 64,
        title: chatRoom.when(
          data:
              (room) =>
                  compactHeader
                      ? compactHeaderWidget(room)
                      : comfortHeaderWidget(room),
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
            onPressed: () async {
              final result = await context.pushNamed(
                'chatDetail',
                pathParameters: {'id': id},
              );
              if (result is String && messages.valueOrNull != null) {
                // Jump to the message that was selected in search
                final messageList = messages.valueOrNull!;
                final messageIndex = messageList.indexWhere(
                  (m) => m.id == result,
                );
                if (messageIndex == -1) {
                  messagesNotifier.jumpToMessage(result).then((index) {
                    if (index != -1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        listController.animateToItem(
                          index: index,
                          scrollController: scrollController,
                          alignment: 0.5,
                          duration:
                              (estimatedDistance) =>
                                  Duration(milliseconds: 250),
                          curve: (estimatedDistance) => Curves.easeInOut,
                        );
                      });
                      ref
                          .read(flashingMessagesProvider.notifier)
                          .update((set) => set.union({result}));
                    }
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    listController.animateToItem(
                      index: messageIndex,
                      scrollController: scrollController,
                      alignment: 0.5,
                      duration:
                          (estimatedDistance) => Duration(milliseconds: 250),
                      curve: (estimatedDistance) => Curves.easeInOut,
                    );
                  });
                  ref
                      .read(flashingMessagesProvider.notifier)
                      .update((set) => set.union({result}));
                }
              }
            },
          ),
          const Gap(8),
        ],
        bottom:
            isSyncing
                ? const PreferredSize(
                  preferredSize: Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.zero,
                  ),
                )
                : null,
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
                              : chatMessageListWidget(messageList),
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
                        ChatInput(
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
                          onUploadAttachment: uploadAttachment,
                          onDeleteAttachment: (index) async {
                            final attachment = attachments.value[index];
                            if (attachment.isOnCloud) {
                              final client = ref.watch(apiClientProvider);
                              await client.delete(
                                '/drive/files/${attachment.data.id}',
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
                          attachmentProgress: attachmentProgress.value,
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

class ChatAttachmentUploaderSheet extends StatefulWidget {
  final WidgetRef ref;
  final List<UniversalFile> attachments;
  final int index;

  const ChatAttachmentUploaderSheet({
    super.key,
    required this.ref,
    required this.attachments,
    required this.index,
  });

  @override
  State<ChatAttachmentUploaderSheet> createState() =>
      _ChatAttachmentUploaderSheetState();
}

class _ChatAttachmentUploaderSheetState
    extends State<ChatAttachmentUploaderSheet> {
  String? selectedPoolId;

  @override
  Widget build(BuildContext context) {
    final attachment = widget.attachments[widget.index];

    return SheetScaffold(
      titleText: 'uploadAttachment'.tr(),
      child: FutureBuilder<List<SnFilePool>>(
        future: widget.ref.read(poolsProvider.future),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('errorLoadingPools'.tr()));
          }
          final pools = snapshot.data!;
          selectedPoolId ??= resolveDefaultPoolId(widget.ref, pools);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedPoolId,
                        items:
                            pools.map((pool) {
                              return DropdownMenuItem<String>(
                                value: pool.id,
                                child: Text(pool.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPoolId = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'selectPool'.tr(),
                          border: const OutlineInputBorder(),
                          hintText: 'choosePool'.tr(),
                        ),
                      ),
                      const Gap(16),
                      FutureBuilder<int?>(
                        future: _getFileSize(attachment),
                        builder: (context, sizeSnapshot) {
                          if (!sizeSnapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final fileSize = sizeSnapshot.data!;
                          final selectedPool = pools.firstWhere(
                            (p) => p.id == selectedPoolId,
                          );

                          // Check file size limit
                          final maxFileSize =
                              selectedPool.policyConfig?['max_file_size']
                                  as int?;
                          final fileSizeExceeded =
                              maxFileSize != null && fileSize > maxFileSize;

                          // Check accepted types
                          final acceptTypes =
                              selectedPool.policyConfig?['accept_types']
                                  as List?;
                          final mimeType =
                              attachment.data.mimeType ??
                              ComposeLogic.getMimeTypeFromFileType(
                                attachment.type,
                              );
                          final typeAccepted =
                              acceptTypes == null ||
                              acceptTypes.isEmpty ||
                              acceptTypes.any(
                                (type) => mimeType.startsWith(type),
                              );

                          final hasIssues = fileSizeExceeded || !typeAccepted;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasIssues) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Symbols.warning,
                                            size: 18,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                          ),
                                          const Gap(8),
                                          Text(
                                            'uploadConstraints'.tr(),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (fileSizeExceeded) ...[
                                        const Gap(4),
                                        Text(
                                          'fileSizeExceeded'.tr(
                                            args: [
                                              _formatFileSize(maxFileSize),
                                            ],
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                          ),
                                        ),
                                      ],
                                      if (!typeAccepted) ...[
                                        const Gap(4),
                                        Text(
                                          'fileTypeNotAccepted'.tr(),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Gap(12),
                              ],
                              Row(
                                spacing: 6,
                                children: [
                                  const Icon(
                                    Symbols.account_balance_wallet,
                                    size: 18,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'quotaCostInfo'.tr(
                                        args: [
                                          _formatQuotaCost(
                                            fileSize,
                                            selectedPool,
                                          ),
                                        ],
                                      ),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ).fontSize(13),
                                  ),
                                ],
                              ).padding(horizontal: 4),
                            ],
                          );
                        },
                      ),
                      const Gap(4),
                      Row(
                        spacing: 6,
                        children: [
                          const Icon(Symbols.info, size: 18),
                          Text(
                            'attachmentPreview'.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ).fontSize(13),
                        ],
                      ).padding(horizontal: 4),
                      const Gap(8),
                      AttachmentPreview(item: attachment, isCompact: true),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Symbols.close),
                      label: Text('cancel').tr(),
                    ),
                    const Gap(8),
                    TextButton.icon(
                      onPressed: () => _confirmUpload(),
                      icon: const Icon(Symbols.upload),
                      label: Text('upload').tr(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<AttachmentUploadConfig?> _getUploadConfig() async {
    final attachment = widget.attachments[widget.index];
    final fileSize = await _getFileSize(attachment);

    if (fileSize == null) return null;

    // Get the selected pool to check constraints
    final pools = await widget.ref.read(poolsProvider.future);
    final selectedPool = pools.firstWhere((p) => p.id == selectedPoolId);

    // Check constraints
    final maxFileSize = selectedPool.policyConfig?['max_file_size'] as int?;
    final fileSizeExceeded = maxFileSize != null && fileSize > maxFileSize;

    final acceptTypes = selectedPool.policyConfig?['accept_types'] as List?;
    final mimeType =
        attachment.data.mimeType ??
        ComposeLogic.getMimeTypeFromFileType(attachment.type);
    final typeAccepted =
        acceptTypes == null ||
        acceptTypes.isEmpty ||
        acceptTypes.any((type) => mimeType.startsWith(type));

    final hasConstraints = fileSizeExceeded || !typeAccepted;

    return AttachmentUploadConfig(
      poolId: selectedPoolId!,
      hasConstraints: hasConstraints,
    );
  }

  Future<void> _confirmUpload() async {
    final config = await _getUploadConfig();
    if (config != null && mounted) {
      Navigator.pop(context, config);
    }
  }

  Future<int?> _getFileSize(UniversalFile attachment) async {
    if (attachment.data is XFile) {
      try {
        return await (attachment.data as XFile).length();
      } catch (e) {
        return null;
      }
    } else if (attachment.data is SnCloudFile) {
      return (attachment.data as SnCloudFile).size;
    } else if (attachment.data is List<int>) {
      return (attachment.data as List<int>).length;
    } else if (attachment.data is Uint8List) {
      return (attachment.data as Uint8List).length;
    }
    return null;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes bytes';
    }
  }

  String _formatQuotaCost(int fileSize, SnFilePool pool) {
    final costMultiplier = pool.billingConfig?['cost_multiplier'] ?? 1.0;
    final quotaCost = ((fileSize / 1024 / 1024) * costMultiplier).round();
    return _formatNumber(quotaCost);
  }
}
