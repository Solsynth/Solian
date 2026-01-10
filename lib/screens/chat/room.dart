import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/pods/chat/chat_room.dart";
import "package:island/pods/chat/messages_notifier.dart";
import "package:island/pods/network.dart";
import "package:island/pods/chat/chat_online_count.dart";
import "package:island/pods/config.dart";
import "package:island/screens/chat/search_messages.dart";
import "package:island/screens/chat/public_room_preview.dart";
import "package:island/services/analytics_service.dart";
import "package:island/services/responsive.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/response.dart";
import "package:island/widgets/attachment_uploader.dart";
import "package:island/widgets/chat/call_button.dart";
import "package:island/widgets/chat/chat_input.dart";
import "package:island/widgets/chat/room_app_bar.dart";
import "package:island/widgets/chat/room_message_list.dart";
import "package:island/widgets/chat/room_selection_mode.dart";
import "package:island/widgets/chat/room_overlays.dart";
import "package:island/services/file_uploader.dart";
import "package:island/models/file.dart";
import "package:island/screens/thought/think_sheet.dart";
import "package:styled_widget/styled_widget.dart";
import "package:island/hooks/use_room_scroll.dart";
import "package:island/hooks/use_room_file_picker.dart";
import "package:island/hooks/use_room_input.dart";

class ChatRoomScreen extends HookConsumerWidget {
  final String id;
  const ChatRoomScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final chatRoom = ref.watch(chatRoomProvider(id));
    final chatIdentity = ref.watch(chatRoomIdentityProvider(id));
    final isSyncing = ref.watch(chatSyncingProvider);
    final onlineCount = ref.watch(chatOnlineCountProvider(id));
    final settings = ref.watch(appSettingsProvider);

    useEffect(() {
      if (!chatRoom.isLoading && chatRoom.value != null) {
        AnalyticsService().logChatRoomOpened(
          id,
          chatRoom.value!.isCommunity == true ? 'group' : 'direct',
        );
      }
      return null;
    }, [chatRoom]);

    if (chatIdentity.isLoading || chatRoom.isLoading) {
      return AppScaffold(
        appBar: AppBar(leading: const PageBackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (chatIdentity.value == null) {
      return chatRoom.when(
        data: (room) {
          if (room!.isPublic) {
            return PublicRoomPreview(id: id, room: room);
          } else {
            return AppScaffold(
              appBar: AppBar(leading: const PageBackButton()),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        room.isCommunity == true
                            ? Icons.person_add
                            : Icons.person_remove,
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
                                '/messager/chat/${room.id}/members/me',
                              );
                              ref.invalidate(chatRoomIdentityProvider(id));
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
        loading: () => AppScaffold(
          appBar: AppBar(leading: const PageBackButton()),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => AppScaffold(
          appBar: AppBar(leading: const PageBackButton()),
          body: ResponseErrorWidget(
            error: error,
            onRetry: () => ref.refresh(chatRoomProvider(id)),
          ),
        ),
      );
    }

    final messages = ref.watch(messagesProvider(id));
    final messagesNotifier = ref.read(messagesProvider(id).notifier);
    final compactHeader = isWideScreen(context);

    final scrollManager = useRoomScrollManager(
      ref,
      id,
      messagesNotifier.jumpToMessage,
      messages,
    );

    final inputKey = useMemoized(() => GlobalKey(), []);
    final inputHeight = useState<double>(80.0);
    final inputManager = useRoomInputManager(ref, id);
    final roomOpenTime = useMemoized(() => DateTime.now());

    final previousInputHeightRef = useRef<double?>(null);
    useEffect(() {
      previousInputHeightRef.value = inputHeight.value;
      return null;
    }, [inputHeight.value]);

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

    final isSelectionMode = useState<bool>(false);
    final selectedMessages = useState<Set<String>>({});

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

      final selectedMessageData =
          messages.value
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
        attachedPosts: [],
      );

      toggleSelectionMode();
    }

    Future<void> uploadAttachment(int index) async {
      final attachment = inputManager.attachments[index];
      if (attachment.isOnCloud) return;

      final config = await showModalBottomSheet<AttachmentUploadConfig>(
        context: context,
        isScrollControlled: true,
        builder: (context) => AttachmentUploaderSheet(
          ref: ref,
          attachments: inputManager.attachments,
          index: index,
        ),
      );
      if (config == null) return;

      try {
        inputManager.updateAttachmentProgress('chat-upload', 0);

        final cloudFile = await FileUploader.createCloudFile(
          ref: ref,
          fileData: attachment,
          poolId: config.poolId,
          mode: attachment.type == UniversalFileType.file
              ? FileUploadMode.generic
              : FileUploadMode.mediaSafe,
          onProgress: (progress, _) {
            inputManager.updateAttachmentProgress(
              'chat-upload',
              progress ?? 0.0,
            );
          },
        ).future;

        if (cloudFile == null) {
          throw ArgumentError('Failed to upload file...');
        }

        final clone = List.of(inputManager.attachments);
        clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
        inputManager.updateAttachments(clone);
      } catch (err) {
        showErrorAlert(err.toString());
      } finally {
        final newProgress = Map<String, Map<int, double?>>.from(
          inputManager.attachmentProgress,
        );
        newProgress.remove('chat-upload');
      }
    }

    final filePicker = useRoomFilePicker(
      context,
      inputManager.attachments,
      inputManager.updateAttachments,
    );

    void onJump(String messageId) {
      messages.when(
        data: (messageList) {
          scrollManager.scrollToMessage(
            messageId: messageId,
            messageList: messageList,
          );
        },
        loading: () {},
        error: (_, _) {},
      );
    }

    return AppScaffold(
      appBar: AppBar(
        leading: !compactHeader ? const Center(child: PageBackButton()) : null,
        automaticallyImplyLeading: false,
        toolbarHeight: compactHeader ? null : 74,
        title: chatRoom.when(
          data: (room) => RoomAppBar(
            room: room!,
            onlineCount: onlineCount.value ?? 0,
            compact: compactHeader,
          ),
          loading: () => const Text('Loading...'),
          error: (err, _) => ResponseErrorWidget(
            error: err,
            onRetry: () => messagesNotifier.loadInitial(),
          ),
        ),
        actions: [
          chatRoom.when(
            data: (data) => AudioCallButton(room: data!),
            error: (_, _) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () async {
              final result = await context.pushNamed(
                'chatDetail',
                pathParameters: {'id': id},
              );
              if (result is SearchMessagesResult && messages.value != null) {
                final messageId = result.messageId;
                messagesNotifier.jumpToMessage(messageId).then((index) {
                  if (index != -1 && context.mounted) {
                    ref
                        .read(flashingMessagesProvider.notifier)
                        .update((set) => set.union({messageId}));
                    messages.when(
                      data: (messageList) {
                        scrollManager.scrollToMessage(
                          messageId: messageId,
                          messageList: messageList,
                        );
                      },
                      loading: () {},
                      error: (_, _) {},
                    );
                  }
                });
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: messages.when(
                      data: (messageList) => messageList.isEmpty
                          ? Center(
                              key: const ValueKey('empty-messages'),
                              child: Text('No messages yet'.tr()),
                            )
                          : RoomMessageList(
                              key: const ValueKey('message-list'),
                              messages: messageList,
                              roomAsync: chatRoom,
                              chatIdentity: chatIdentity,
                              scrollController: scrollManager.scrollController,
                              listController: scrollManager.listController,
                              isSelectionMode: isSelectionMode.value,
                              selectedMessages: selectedMessages.value,
                              toggleSelectionMode: toggleSelectionMode,
                              toggleMessageSelection: toggleMessageSelection,
                              onMessageAction: inputManager.onMessageAction,
                              onJump: onJump,
                              attachmentProgress:
                                  inputManager.attachmentProgress,
                              inputHeight: inputHeight.value,
                              previousInputHeight: previousInputHeightRef.value,
                              roomOpenTime: roomOpenTime,
                              disableAnimation: settings.disableAnimation,
                            ),
                      loading: () => const Center(
                        key: ValueKey('loading-messages'),
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) => ResponseErrorWidget(
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
          RoomOverlays(
            roomAsync: chatRoom,
            isSyncing: isSyncing,
            showGradient: !isSelectionMode.value,
            bottomGradientOpacity: scrollManager.bottomGradientOpacity.value,
            inputHeight: inputHeight.value,
          ),
          if (!isSelectionMode.value)
            Positioned(
              left: 0,
              right: 0,
              bottom: mediaQuery.padding.bottom,
              child: chatRoom.when(
                data: (room) => room != null
                    ? ChatInput(
                        key: inputKey,
                        messageController: inputManager.messageController,
                        chatRoom: room,
                        onSend: () => inputManager.sendMessage(ref),
                        onClear: () {
                          if (inputManager.messageEditingTo != null) {
                            inputManager.clearAttachmentsOnly();
                          }
                          inputManager.setEditingTo(null);
                          inputManager.setReplyingTo(null);
                          inputManager.setForwardingTo(null);
                          inputManager.setPoll(null);
                          inputManager.setFund(null);
                        },
                        messageEditingTo: inputManager.messageEditingTo,
                        messageReplyingTo: inputManager.messageReplyingTo,
                        messageForwardingTo: inputManager.messageForwardingTo,
                        selectedPoll: inputManager.selectedPoll,
                        onPollSelected: (poll) => inputManager.setPoll(poll),
                        selectedFund: inputManager.selectedFund,
                        onFundSelected: (fund) => inputManager.setFund(fund),
                        onPickFile: (isPhoto) {
                          if (isPhoto) {
                            filePicker.pickPhotos();
                          } else {
                            filePicker.pickVideos();
                          }
                        },
                        onPickAudio: filePicker.pickAudio,
                        onPickGeneralFile: filePicker.pickFiles,
                        onLinkAttachment: filePicker.linkAttachment,
                        attachments: inputManager.attachments,
                        onUploadAttachment: uploadAttachment,
                        onDeleteAttachment: (index) async {
                          final attachment = inputManager.attachments[index];
                          if (attachment.isOnCloud && !attachment.isLink) {
                            final client = ref.watch(apiClientProvider);
                            await client.delete(
                              '/drive/files/${attachment.data.id}',
                            );
                          }
                          final clone = List.of(inputManager.attachments);
                          clone.removeAt(index);
                          inputManager.updateAttachments(clone);
                        },
                        onMoveAttachment: (idx, delta) {
                          if (idx + delta < 0 ||
                              idx + delta >= inputManager.attachments.length) {
                            return;
                          }
                          final clone = List.of(inputManager.attachments);
                          clone.insert(idx + delta, clone.removeAt(idx));
                          inputManager.updateAttachments(clone);
                        },
                        onAttachmentsChanged: inputManager.updateAttachments,
                        attachmentProgress: inputManager.attachmentProgress,
                      )
                    : const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
              ),
            ),
          if (isSelectionMode.value)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RoomSelectionMode(
                visible: isSelectionMode.value,
                selectedCount: selectedMessages.value.length,
                onClose: toggleSelectionMode,
                onAIThink: openThinkingSheet,
              ),
            ),
        ],
      ),
    );
  }
}
