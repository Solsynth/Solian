import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_online_count.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/chat/widgets/chat_input.dart';
import 'package:island/chat/widgets/chat_search_screen.dart';
import 'package:island/chat/widgets/public_room_preview.dart';
import 'package:island/chat/widgets/room_app_bar.dart';
import 'package:island/chat/widgets/room_message_list.dart';
import 'package:island/chat/widgets/room_selection_mode.dart';
import 'package:island/chat/hooks/use_room_file_picker.dart';
import 'package:island/chat/hooks/use_room_input.dart';
import 'package:island/chat/hooks/use_room_scroll.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/core/config.dart';
import 'package:island/core/lifecycle.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/analytics_service.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/route.gr.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/attachment_uploader.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/shared/widgets/sync_indicator.dart';
import 'package:island/thoughts/screens/think_sheet.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const kChatLastReadAnchorsStoreKey = 'chat_last_read_anchor_by_room';

@RoutePage()
class ChatRoomScreen extends HookConsumerWidget {
  final String id;
  const ChatRoomScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoom = ref.watch(chatRoomProvider(id));
    final chatIdentity = ref.watch(chatRoomIdentityProvider(id));
    final onlineCount = ref.watch(chatOnlineCountProvider(id));
    final settings = ref.watch(appSettingsProvider);

    final analyticsLogged = useRef(false);
    useEffect(() {
      if (!analyticsLogged.value &&
          !chatRoom.isLoading &&
          chatRoom.value != null) {
        analyticsLogged.value = true;
        AnalyticsService().logChatRoomOpened(
          id,
          chatRoom.value!.isCommunity == true ? 'group' : 'direct',
        );
      }
      return null;
    }, [chatRoom]);

    if (chatIdentity.isLoading || chatRoom.isLoading) {
      return AppScaffold(
        appBar: AppBar(leading: const AutoLeadingButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (chatIdentity.value == null) {
      return chatRoom.when(
        data: (room) {
          if (room!.isPublic) {
            return PublicRoomPreview(id: id, room: room);
          } else {
            return AppScaffold(
              appBar: AppBar(leading: const AutoLeadingButton()),
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
          appBar: AppBar(leading: const AutoLeadingButton()),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => AppScaffold(
          appBar: AppBar(leading: const AutoLeadingButton()),
          body: ResponseErrorWidget(
            error: error,
            onRetry: () => ref.refresh(chatRoomProvider(id)),
          ),
        ),
      );
    }

    final messages = ref.watch(messagesProvider(id));
    final messagesNotifier = ref.read(messagesProvider(id).notifier);
    final prefs = ref.read(sharedPreferencesProvider);
    final lastReadAnchorMessageId = useState<String?>(null);
    final latestSeenMessageIdRef = useRef<String?>(null);

    Future<void> saveLastReadAnchor() async {
      final latestId = latestSeenMessageIdRef.value;
      if (latestId == null || latestId.isEmpty) return;

      final raw = prefs.getString(kChatLastReadAnchorsStoreKey);
      final Map<String, dynamic> anchors = raw == null || raw.isEmpty
          ? <String, dynamic>{}
          : (jsonDecode(raw) as Map<String, dynamic>);
      anchors[id] = latestId;
      await prefs.setString(kChatLastReadAnchorsStoreKey, jsonEncode(anchors));
      lastReadAnchorMessageId.value = latestId;
    }

    Future<void> loadLastReadAnchor() async {
      final raw = prefs.getString(kChatLastReadAnchorsStoreKey);
      if (raw == null || raw.isEmpty) return;
      final anchors = jsonDecode(raw) as Map<String, dynamic>;
      final anchorId = anchors[id] as String?;
      if (anchorId != null && anchorId.isNotEmpty) {
        lastReadAnchorMessageId.value = anchorId;
      }
    }

    useEffect(() {
      Future.microtask(loadLastReadAnchor);
      return null;
    }, [id]);

    useEffect(() {
      final list = messages.value;
      if (list != null && list.isNotEmpty) {
        latestSeenMessageIdRef.value = list.first.id;
      }
      return null;
    }, [messages.value]);

    final lifecycleState = ref.watch(appLifecycleStateProvider);
    final previousLifecycleState = useRef<AppLifecycleState?>(null);
    final isResyncingAfterResume = useState(false);

    useEffect(() {
      final nextState = lifecycleState.value;
      if (nextState == null) return null;

      final previousState = previousLifecycleState.value;
      final resumedFromBackground =
          nextState == AppLifecycleState.resumed &&
          (previousState == AppLifecycleState.paused ||
              previousState == AppLifecycleState.inactive ||
              previousState == AppLifecycleState.detached);

      if (nextState == AppLifecycleState.paused ||
          nextState == AppLifecycleState.inactive ||
          nextState == AppLifecycleState.detached) {
        Future.microtask(saveLastReadAnchor);
      }

      if (resumedFromBackground && !isResyncingAfterResume.value) {
        isResyncingAfterResume.value = true;
        Future<void>(() async {
          try {
            await messagesNotifier.syncMessages();
            await messagesNotifier.loadInitial(forceRemoteRefresh: true);
          } finally {
            if (context.mounted) {
              isResyncingAfterResume.value = false;
            }
          }
        });
      }

      previousLifecycleState.value = nextState;
      return null;
    }, [lifecycleState.value, messagesNotifier]);

    useEffect(() {
      return () {
        Future.microtask(saveLastReadAnchor);
      };
    }, []);

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

    final hasTrackedInputHeight = useRef(false);
    useEffect(() {
      if (hasTrackedInputHeight.value) return;
      hasTrackedInputHeight.value = true;

      void measureHeight() {
        final renderBox =
            inputKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          inputHeight.value = renderBox.size.height;
        }
      }

      measureHeight();
      WidgetsBinding.instance.addPostFrameCallback((_) => measureHeight());

      return null;
    }, []);

    final isSelectionMode = useState<bool>(false);
    final selectedMessages = useState<Set<String>>({});

    final toggleSelectionMode = useCallback(() {
      isSelectionMode.value = !isSelectionMode.value;
      if (!isSelectionMode.value) {
        selectedMessages.value = {};
      }
    }, [isSelectionMode, selectedMessages]);

    final toggleMessageSelection = useCallback((String messageId) {
      final newSelection = Set<String>.from(selectedMessages.value);
      if (newSelection.contains(messageId)) {
        newSelection.remove(messageId);
      } else {
        newSelection.add(messageId);
      }
      selectedMessages.value = newSelection;
    }, [selectedMessages]);

    final openThinkingSheet = useCallback(() {
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
    }, [selectedMessages, messages, toggleSelectionMode]);

    final uploadAttachment = useCallback((int index) async {
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

        final cloudFile = await ref
            .read(driveFileUploaderProvider)
            .createCloudFile(
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
            )
            .future;

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
    }, [inputManager, ref, context]);

    final filePicker = useRoomFilePicker(
      context,
      inputManager.attachments,
      inputManager.updateAttachments,
    );

    final onJump = useCallback((String messageId) {
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
    }, [messages, scrollManager]);

    final visibleLastReadAnchorMessageId = (() {
      final anchorId = lastReadAnchorMessageId.value;
      final list = messages.value;
      if (anchorId == null || list == null || list.isEmpty) return null;
      final anchorIndex = list.indexWhere((m) => m.id == anchorId);
      // Messages are sorted newest -> oldest.
      // Show marker only when there are newer messages before the anchor.
      if (anchorIndex > 0) return anchorId;
      return null;
    })();

    final jumpToLastReadAnchor = useCallback(() {
      final targetId = lastReadAnchorMessageId.value;
      if (targetId == null || targetId.isEmpty) return;

      messagesNotifier.jumpToMessage(targetId).then((index) {
        if (index != -1 && context.mounted) {
          ref
              .read(flashingMessagesProvider.notifier)
              .update((set) => set.union({targetId}));
          messages.when(
            data: (messageList) {
              scrollManager.scrollToMessage(
                messageId: targetId,
                messageList: messageList,
              );
            },
            loading: () {},
            error: (_, _) {},
          );
        }
      });
    }, [lastReadAnchorMessageId.value, messagesNotifier, messages, scrollManager]);

    return Stack(
      children: [
        AppScaffold(
          appBar: AppBar(
            leading: const AutoLeadingButton(),
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: chatRoom.when(
              data: (room) =>
                  RoomAppBar(room: room!, onlineCount: onlineCount.value ?? 0),
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
                  final result = await context.router.push(
                    ChatDetailRoute(id: id),
                  );
                  if (result is SearchMessagesResult &&
                      messages.value != null) {
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
              if (visibleLastReadAnchorMessageId != null)
                IconButton(
                  tooltip: 'Follow back',
                  icon: const Icon(Icons.bookmark_added_outlined),
                  onPressed: jumpToLastReadAnchor,
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
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
                            attachmentProgress: inputManager.attachmentProgress,
                            previousInputHeight: previousInputHeightRef.value,
                            roomOpenTime: roomOpenTime,
                            lastReadAnchorMessageId:
                                visibleLastReadAnchorMessageId,
                            onFollowBack: jumpToLastReadAnchor,
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
              if (!isSelectionMode.value)
                chatRoom.when(
                  data: (room) => room != null
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: ChatInput(
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
                            messageForwardingTo:
                                inputManager.messageForwardingTo,
                            selectedPoll: inputManager.selectedPoll,
                            onPollSelected: (poll) =>
                                inputManager.setPoll(poll),
                            selectedFund: inputManager.selectedFund,
                            onFundSelected: (fund) =>
                                inputManager.setFund(fund),
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
                              final attachment =
                                  inputManager.attachments[index];
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
                                  idx + delta >=
                                      inputManager.attachments.length) {
                                return;
                              }
                              final clone = List.of(inputManager.attachments);
                              clone.insert(idx + delta, clone.removeAt(idx));
                              inputManager.updateAttachments(clone);
                            },
                            onAttachmentsChanged:
                                inputManager.updateAttachments,
                            attachmentProgress: inputManager.attachmentProgress,
                          ),
                        )
                      : const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
              if (isSelectionMode.value)
                RoomSelectionMode(
                  visible: isSelectionMode.value,
                  selectedCount: selectedMessages.value.length,
                  onClose: toggleSelectionMode,
                  onAIThink: openThinkingSheet,
                ),
            ],
          ),
        ),
        // Chat sync indicator for non-wide screen
        if (!isWideScreen(context)) const ChatSyncIndicator(height: 64),
      ],
    );
  }
}
