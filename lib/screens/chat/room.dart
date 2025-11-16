import "dart:async";
import "dart:math" as math;
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:image_picker/image_picker.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/database/message.dart";
import "package:island/models/chat.dart";
import "package:island/models/file.dart";
import "package:island/pods/chat/chat_rooms.dart";
import "package:island/pods/chat/chat_subscribe.dart";
import "package:island/pods/chat/messages_notifier.dart";
import "package:island/pods/network.dart";
import "package:island/pods/chat/chat_online_count.dart";
import "package:island/pods/config.dart";
import "package:island/screens/chat/search_messages.dart";
import "package:island/services/file_uploader.dart";
import "package:island/screens/chat/chat.dart";
import "package:island/services/responsive.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/attachment_uploader.dart";
import "package:island/widgets/chat/call_overlay.dart";
import "package:island/widgets/chat/message_item.dart";
import "package:island/widgets/content/cloud_files.dart";
import "package:island/widgets/response.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:styled_widget/styled_widget.dart";
import "package:super_sliver_list/super_sliver_list.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:island/widgets/chat/call_button.dart";
import "package:island/widgets/chat/chat_input.dart";
import "package:island/widgets/chat/chat_link_attachments.dart";
import "package:island/widgets/chat/public_room_preview.dart";
import "package:island/screens/thought/think_sheet.dart";

class ChatRoomScreen extends HookConsumerWidget {
  final String id;
  const ChatRoomScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoom = ref.watch(chatroomProvider(id));
    final chatIdentity = ref.watch(chatroomIdentityProvider(id));
    final isSyncing = ref.watch(isSyncingProvider);
    final onlineCount = ref.watch(chatOnlineCountNotifierProvider(id));
    final settings = ref.watch(appSettingsNotifierProvider);

    final hasOnlineCount = onlineCount.hasValue;

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
    final chatSubscribeNotifier = ref.read(
      chatSubscribeNotifierProvider(id).notifier,
    );

    final messageController = useTextEditingController();
    final scrollController = useScrollController();

    // Input height measurement for dynamic padding
    final inputKey = useMemoized(() => GlobalKey());
    final inputHeight = useState<double>(80.0);

    // Periodic height measurement for dynamic sizing
    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        final renderBox =
            inputKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final newHeight = renderBox.size.height;
          if (newHeight != inputHeight.value) {
            inputHeight.value = newHeight;
          }
        }
      });
      return timer.cancel;
    }, []);

    // Scroll animation notifiers
    final bottomGradientNotifier = useState(ValueNotifier<double>(0.0));

    final messageReplyingTo = useState<SnChatMessage?>(null);
    final messageForwardingTo = useState<SnChatMessage?>(null);
    final messageEditingTo = useState<SnChatMessage?>(null);
    final attachments = useState<List<UniversalFile>>([]);
    final attachmentProgress = useState<Map<String, Map<int, double?>>>({});

    // Selection mode state
    final isSelectionMode = useState<bool>(false);
    final selectedMessages = useState<Set<String>>({});

    var isLoading = false;
    var isScrollingToMessage = false; // Flag to prevent scroll conflicts

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

        // Update gradient animations
        final pixels = scrollController.position.pixels;

        // Bottom gradient: appears when not at bottom (pixels > 0)
        bottomGradientNotifier.value.value = (pixels / 500.0).clamp(0.0, 1.0);
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    Future<void> pickPhotoMedia() async {
      final ImagePicker picker = ImagePicker();
      final List<XFile> results = await picker.pickMultiImage();
      if (results.isEmpty) return;
      attachments.value = [
        ...attachments.value,
        ...results.map(
          (xfile) => UniversalFile(data: xfile, type: UniversalFileType.image),
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

    Future<void> pickAudioMedia() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        allowCompression: false,
      );
      if (result == null || result.count == 0) return;
      attachments.value = [
        ...attachments.value,
        ...result.files.map(
          (e) => UniversalFile(data: e.xFile, type: UniversalFileType.audio),
        ),
      ];
    }

    Future<void> pickGeneralFile() async {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowCompression: false,
      );
      if (result == null || result.count == 0) return;
      attachments.value = [
        ...attachments.value,
        ...result.files.map(
          (e) => UniversalFile(data: e.xFile, type: UniversalFileType.file),
        ),
      ];
    }

    void linkAttachment() async {
      final cloudFile = await showModalBottomSheet<SnCloudFile?>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => const ChatLinkAttachment(),
      );
      if (cloudFile == null) return;

      attachments.value = [
        ...attachments.value,
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
    }

    void sendMessage() {
      if (messageController.text.trim().isNotEmpty ||
          attachments.value.isNotEmpty) {
        messagesNotifier.sendMessage(
          ref,
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
        );
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
          chatSubscribeNotifier.sendTypingStatus();
        }
      }

      messageController.addListener(onTextChange);
      return () => messageController.removeListener(onTextChange);
    }, [messageController]);

    // Selection functions
    void toggleSelectionMode() {
      isSelectionMode.value = !isSelectionMode.value;
      if (!isSelectionMode.value) {
        selectedMessages.value = {};
      }
    }

    void toggleMessageSelection(String messageId) {
      final newSelection = Set<String>.from(selectedMessages.value);
      if (newSelection.contains(messageId)) {
        newSelection.remove(messageId);
      } else {
        newSelection.add(messageId);
      }
      selectedMessages.value = newSelection;
    }

    void openThinkingSheet() {
      if (selectedMessages.value.isEmpty) return;

      // Convert selected message IDs to message data
      final selectedMessageData =
          messages.valueOrNull
              ?.where((msg) => selectedMessages.value.contains(msg.id))
              .map(
                (msg) => {
                  'id': msg.id,
                  'content': msg.content,
                  'senderId': msg.senderId,
                  'createdAt': msg.createdAt.toIso8601String(),
                  'attachments': msg.attachments,
                },
              )
              .toList() ??
          [];

      ThoughtSheet.show(
        context,
        attachedMessages: selectedMessageData,
        attachedPosts: [], // Could be extended to include posts
      );

      // Exit selection mode after opening
      toggleSelectionMode();
    }

    final compactHeader = isWideScreen(context);

    Widget onlineIndicator() => Row(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (onlineCount as AsyncData).value > 1 ? Colors.green : null,
            border:
                (onlineCount as AsyncData).value <= 1
                    ? Border.all(color: Colors.grey)
                    : null,
          ),
        ),
        Text(
          '${(onlineCount as AsyncData).value} online',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor!,
          ),
        ),
      ],
    );

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
        if (hasOnlineCount) onlineIndicator(),
      ],
    );

    Widget compactHeaderWidget(SnChatRoom? room) => Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 28,
          width: 28,
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
        if (hasOnlineCount) onlineIndicator().padding(left: 4, top: 6),
      ],
    );

    const messageKeyPrefix = 'message-';

    // Helper function for scroll animation
    void performScrollAnimation({
      required int index,
      required ListController listController,
      required ScrollController scrollController,
      required String messageId,
      required WidgetRef ref,
    }) {
      // Update flashing message first
      ref
          .read(flashingMessagesProvider.notifier)
          .update((set) => set.union({messageId}));

      // Use multiple post-frame callbacks to ensure stability
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            listController.animateToItem(
              index: index,
              scrollController: scrollController,
              alignment: 0.5,
              duration:
                  (estimatedDistance) => Duration(
                    milliseconds:
                        (estimatedDistance * 0.5).clamp(200, 800).toInt(),
                  ),
              curve: (estimatedDistance) => Curves.easeOutCubic,
            );

            // Reset the scroll flag after animation completes
            Future.delayed(const Duration(milliseconds: 800), () {
              isScrollingToMessage = false;
            });
          } catch (e) {
            // If animation fails, reset the flag
            isScrollingToMessage = false;
          }
        });
      });
    }

    // Robust scroll-to-message function to prevent jumping back
    void scrollToMessage({
      required String messageId,
      required List<LocalChatMessage> messageList,
      required MessagesNotifier messagesNotifier,
      required ListController listController,
      required ScrollController scrollController,
      required WidgetRef ref,
    }) {
      // Prevent concurrent scroll operations
      if (isScrollingToMessage) return;
      isScrollingToMessage = true;

      final messageIndex = messageList.indexWhere((m) => m.id == messageId);

      if (messageIndex == -1) {
        // Message not in current list, need to load it first
        messagesNotifier.jumpToMessage(messageId).then((index) {
          if (index != -1) {
            // Wait for UI to rebuild before animating
            WidgetsBinding.instance.addPostFrameCallback((_) {
              performScrollAnimation(
                index: index,
                listController: listController,
                scrollController: scrollController,
                messageId: messageId,
                ref: ref,
              );
            });
          } else {
            isScrollingToMessage = false;
          }
        });
      } else {
        // Message is already in list, scroll directly with slight delay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          performScrollAnimation(
            index: messageIndex,
            listController: listController,
            scrollController: scrollController,
            messageId: messageId,
            ref: ref,
          );
        });
      }
    }

    Future<void> uploadAttachment(int index) async {
      final attachment = attachments.value[index];
      if (attachment.isOnCloud) return;

      final config = await showModalBottomSheet<AttachmentUploadConfig>(
        context: context,
        isScrollControlled: true,
        builder:
            (context) => AttachmentUploaderSheet(
              ref: ref,
              attachments: attachments.value,
              index: index,
            ),
      );
      if (config == null) return;

      try {
        // Use 'chat-upload' as temporary key for progress
        attachmentProgress.value = {
          ...attachmentProgress.value,
          'chat-upload': {index: 0},
        };

        final cloudFile =
            await FileUploader.createCloudFile(
              ref: ref,
              fileData: attachment,
              poolId: config.poolId,
              mode:
                  attachment.type == UniversalFileType.file
                      ? FileUploadMode.generic
                      : FileUploadMode.mediaSafe,
              onProgress: (progress, _) {
                attachmentProgress.value = {
                  ...attachmentProgress.value,
                  'chat-upload': {index: progress ?? 0.0},
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

    Widget chatMessageListWidget(
      List<LocalChatMessage> messageList,
    ) => SuperListView.builder(
      listController: listController,
      padding: EdgeInsets.only(
        top: 16,
        bottom:
            MediaQuery.of(context).padding.bottom +
            8 +
            inputHeight.value, // Leave space for chat input
      ),
      controller: scrollController,
      reverse: true, // Show newest messages at the bottom
      itemCount: messageList.length,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<String>) return null;
        final messageId = key.value.substring(messageKeyPrefix.length);
        final index = messageList.indexWhere(
          (m) => (m.nonce ?? m.id) == messageId,
        );
        // Return null for invalid indices to let SuperListView handle it properly
        return index >= 0 ? index : null;
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

        // Use a stable animation key that doesn't change during message lifecycle
        final key = Key('$messageKeyPrefix${message.nonce ?? message.id}');

        final messageWidget = chatIdentity.when(
          skipError: true,
          data:
              (identity) => GestureDetector(
                onLongPress: () {
                  if (!isSelectionMode.value) {
                    toggleSelectionMode();
                    toggleMessageSelection(message.id);
                  }
                },
                onTap: () {
                  if (isSelectionMode.value) {
                    toggleMessageSelection(message.id);
                  }
                },
                child: Container(
                  color:
                      selectedMessages.value.contains(message.id)
                          ? Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.3)
                          : null,
                  child: Stack(
                    children: [
                      MessageItem(
                        key: settings.disableAnimation ? key : null,
                        message: message,
                        isCurrentUser: identity?.id == message.senderId,
                        onAction:
                            isSelectionMode.value
                                ? null
                                : (action) {
                                  switch (action) {
                                    case MessageItemAction.delete:
                                      messagesNotifier.deleteMessage(
                                        message.id,
                                      );
                                    case MessageItemAction.edit:
                                      messageEditingTo.value =
                                          message.toRemoteMessage();
                                      messageController.text =
                                          messageEditingTo.value?.content ?? '';
                                      attachments.value =
                                          messageEditingTo.value!.attachments
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
                                    case MessageItemAction.resend:
                                      messagesNotifier.retryMessage(message.id);
                                  }
                                },
                        onJump: (messageId) {
                          scrollToMessage(
                            messageId: messageId,
                            messageList: messageList,
                            messagesNotifier: messagesNotifier,
                            listController: listController,
                            scrollController: scrollController,
                            ref: ref,
                          );
                        },
                        progress: attachmentProgress.value[message.id],
                        showAvatar: isLastInGroup,
                        isSelectionMode: isSelectionMode.value,
                        isSelected: selectedMessages.value.contains(message.id),
                        onToggleSelection: toggleMessageSelection,
                        onEnterSelectionMode: () {
                          if (!isSelectionMode.value) {
                            toggleSelectionMode();
                          }
                        },
                      ),
                      if (selectedMessages.value.contains(message.id))
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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

        return settings.disableAnimation
            ? messageWidget
            : TweenAnimationBuilder<double>(
              key: key,
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: 400 + (index % 5) * 50,
              ), // Staggered delay
              curve: Curves.easeOutCubic,
              builder: (context, animationValue, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    20 * (1 - animationValue),
                  ), // Slide up from bottom
                  child: Opacity(opacity: animationValue, child: child),
                );
              },
              child: messageWidget,
            );
      },
    );

    return AppScaffold(
      appBar: AppBar(
        leading: !compactHeader ? const Center(child: PageBackButton()) : null,
        automaticallyImplyLeading: false,
        toolbarHeight: compactHeader ? null : 80,
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
              if (result is SearchMessagesResult &&
                  messages.valueOrNull != null) {
                final messageId = result.messageId;

                // Jump to the message and trigger flash effect
                messagesNotifier.jumpToMessage(messageId).then((index) {
                  if (index != -1 && context.mounted) {
                    // Update flashing message
                    ref
                        .read(flashingMessagesProvider.notifier)
                        .update((set) => set.union({messageId}));

                    // Scroll to the message with animation
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      try {
                        listController.animateToItem(
                          index: index,
                          scrollController: scrollController,
                          alignment: 0.5,
                          duration:
                              (estimatedDistance) => Duration(
                                milliseconds:
                                    (estimatedDistance * 0.5)
                                        .clamp(200, 800)
                                        .toInt(),
                              ),
                          curve: (estimatedDistance) => Curves.easeOutCubic,
                        );
                      } catch (e) {
                        // If animation fails, just update flashing state
                      }
                    });
                  }
                });
              }
            },
          ),
          const Gap(8),
        ],
      ),
      body: Stack(
        children: [
          // Messages only in Column
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: messages.when(
                      data:
                          (messageList) =>
                              messageList.isEmpty
                                  ? Center(
                                    key: const ValueKey('empty-messages'),
                                    child: Text('No messages yet'.tr()),
                                  )
                                  : chatMessageListWidget(messageList),
                      loading:
                          () => const Center(
                            key: ValueKey('loading-messages'),
                            child: CircularProgressIndicator(),
                          ),
                      error:
                          (error, _) => ResponseErrorWidget(
                            key: const ValueKey('error-messages'),
                            error: error,
                            onRetry: () => messagesNotifier.loadInitial(),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: CallOverlayBar().padding(horizontal: 8, top: 12),
          ),
          if (isSyncing)
            Positioned(
              top: 8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Syncing...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          // Bottom gradient - appears when scrolling towards newer messages (behind chat input)
          if (!isSelectionMode.value)
            AnimatedBuilder(
              animation: bottomGradientNotifier.value,
              builder:
                  (context, child) => Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: bottomGradientNotifier.value.value,
                      child: Container(
                        height: math.min(
                          MediaQuery.of(context).size.height * 0.1,
                          128,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainer.withOpacity(0.8),
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainer.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          // Chat Input positioned above gradient (higher z-index)
          if (!isSelectionMode.value)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0, // At the very bottom, above gradient
              child: chatRoom.when(
                data:
                    (room) => Column(
                      key: inputKey,
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                          onPickAudio: pickAudioMedia,
                          onPickGeneralFile: pickGeneralFile,
                          onLinkAttachment: linkAttachment,
                          attachments: attachments.value,
                          onUploadAttachment: uploadAttachment,
                          onDeleteAttachment: (index) async {
                            final attachment = attachments.value[index];
                            if (attachment.isOnCloud && !attachment.isLink) {
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
                        Gap(MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                error: (_, _) => const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
              ),
            ),
          // Selection mode toolbar
          if (isSelectionMode.value)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: toggleSelectionMode,
                      tooltip: 'Cancel selection',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedMessages.value.length} selected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (selectedMessages.value.isNotEmpty)
                      FilledButton.icon(
                        onPressed: openThinkingSheet,
                        icon: Icon(Symbols.smart_toy),
                        label: const Text('AI Think'),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
