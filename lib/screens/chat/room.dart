import "dart:async";
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
import "package:island/pods/chat/chat_subscribe.dart";
import "package:island/pods/config.dart";
import "package:island/pods/chat/messages_notifier.dart";
import "package:island/pods/network.dart";
import "package:island/pods/chat/chat_online_count.dart";
import "package:island/services/file.dart";
import "package:island/screens/chat/chat.dart";
import "package:island/services/responsive.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/attachment_uploader.dart";
import "package:island/widgets/chat/call_overlay.dart";
import "package:island/widgets/chat/message_item.dart";
import "package:island/widgets/content/cloud_files.dart";
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

class ChatRoomScreen extends HookConsumerWidget {
  final String id;
  const ChatRoomScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoom = ref.watch(chatroomProvider(id));
    final chatIdentity = ref.watch(chatroomIdentityProvider(id));
    final isSyncing = ref.watch(isSyncingProvider);
    final onlineCount = ref.watch(chatOnlineCountNotifierProvider(id));

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
    final chatSubscribe = ref.watch(chatSubscribeNotifierProvider(id));
    final chatSubscribeNotifier = ref.read(
      chatSubscribeNotifierProvider(id).notifier,
    );

    final messageController = useTextEditingController();
    final scrollController = useScrollController();

    final messageReplyingTo = useState<SnChatMessage?>(null);
    final messageForwardingTo = useState<SnChatMessage?>(null);
    final messageEditingTo = useState<SnChatMessage?>(null);
    final attachments = useState<List<UniversalFile>>([]);
    final attachmentProgress = useState<Map<String, Map<int, double>>>({});

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
        messagesNotifier.sendMessage(
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
            (context) => AttachmentUploaderSheet(
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
          padding: EdgeInsets.only(
            top: 16,
            bottom: 96 + MediaQuery.of(context).padding.bottom,
          ),
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
        bottom: () {
          final hasProgress = isSyncing;
          final hasOnlineCount = onlineCount.hasValue;
          if (!hasProgress && !hasOnlineCount) return null;
          return PreferredSize(
            preferredSize: Size.fromHeight(
              (hasProgress ? 2 : 0) + (hasOnlineCount ? 24 : 0),
            ),
            child: Column(
              children: [
                if (hasProgress)
                  const LinearProgressIndicator(
                    borderRadius: BorderRadius.zero,
                  ),
                if (hasOnlineCount)
                  Container(
                    height: 24,
                    alignment: Alignment.center,
                    child: Text(
                      '${(onlineCount as AsyncData).value} online',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          );
        }(),
      ),
      body: Stack(
        children: [
          // Messages
          Positioned.fill(
            child: messages.when(
              data:
                  (messageList) =>
                      messageList.isEmpty
                          ? Center(child: Text('No messages yet'.tr()))
                          : chatMessageListWidget(messageList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) => ResponseErrorWidget(
                    error: error,
                    onRetry: () => messagesNotifier.loadInitial(),
                  ),
            ),
          ),
          // Input
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: chatRoom.when(
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
                            chatSubscribe.isNotEmpty
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
                                            chatSubscribe.length,
                                            args: [
                                              chatSubscribe
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
                      Gap(MediaQuery.of(context).padding.bottom),
                    ],
                  ),
              error: (_, _) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            ),
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
