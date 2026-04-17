import 'dart:async';
import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_online_count.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/chat/widgets/call_overlay.dart';
import 'package:island/chat/widgets/chat_input.dart';
import 'package:island/chat/widgets/chat_search_screen.dart';
import 'package:island/chat/widgets/public_room_preview.dart';
import 'package:island/chat/widgets/room_app_bar.dart';
import 'package:island/chat/widgets/room_message_list.dart';
import 'package:island/chat/widgets/room_selection_mode.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/core/config.dart';
import 'package:island/core/lifecycle.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
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

    // Universal chat room state - manages all UI state for this room
    final chatState = ref.watch(chatRoomStateProvider(id));
    final chatStateNotifier = ref.read(chatRoomStateProvider(id).notifier);
    final messagesNotifier = ref.read(messagesProvider(id).notifier);

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
        body: Center(
          child: ConfuseSpinner(
            size: 40,
            speed: 6,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.65),
          ),
        ),
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
          body: Center(
            child: ConfuseSpinner(
              size: 40,
              speed: 6,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.65),
            ),
          ),
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
    final isSyncing = ref.watch(chatSyncingProvider);
    final syncHint = ref.watch(chatSyncHintProvider);
    final isAtLatestMessages = useState(true);
    final savedLastReadAt = useState<DateTime?>(chatIdentity.value?.lastReadAt);

    useEffect(() {
      final identity = chatIdentity.value;
      if (identity != null) {
        savedLastReadAt.value = identity.lastReadAt;
      }
      return null;
    }, [chatIdentity.value]);

    // Track when app was backgrounded for time-based provider invalidation
    final lastBackgroundTime = useRef<DateTime?>(null);
    const backgroundSyncThreshold = Duration(seconds: 30);

    useEffect(() {
      Future.microtask(() async {
        if (!context.mounted) return;
        await messagesNotifier.initialize(forceRemoteRefresh: false);
      });
      return null;
    }, [id]);

    useEffect(() {
      Future.microtask(() {
        ref.invalidate(chatOnlineCountProvider(id));
        ref.invalidate(activeCallParticipantCountProvider(id));
        ref.invalidate(activeCallParticipantsProvider(id));
      });

      final timer = Timer.periodic(const Duration(minutes: 5), (_) {
        final currentLifecycle = ref.read(appLifecycleStateProvider).value;
        if (currentLifecycle == AppLifecycleState.resumed) {
          Future.microtask(() {
            ref.invalidate(chatOnlineCountProvider(id));
            ref.invalidate(activeCallParticipantCountProvider(id));
            ref.invalidate(activeCallParticipantsProvider(id));
          });
        }
      });
      return timer.cancel;
    }, [id]);

    final lifecycleState = ref.watch(appLifecycleStateProvider);
    final previousLifecycleState = useRef<AppLifecycleState?>(null);
    final isResyncingAfterResume = useState(false);
    final wsDisconnectedSinceBackground = useRef(false);
    final wasWsConnected = useRef<bool?>(null);

    final isDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    bool checkWsConnected() {
      final wsState = ref.read(websocketStateProvider);
      return wsState.maybeWhen(connected: () => true, orElse: () => false);
    }

    useEffect(() {
      final nextState = lifecycleState.value;
      if (nextState == null) return null;

      final previousState = previousLifecycleState.value;
      final resumedFromBackground =
          nextState == AppLifecycleState.resumed &&
          previousState != null &&
          previousState != AppLifecycleState.resumed;

      if (nextState == AppLifecycleState.paused ||
          nextState == AppLifecycleState.inactive ||
          nextState == AppLifecycleState.hidden ||
          nextState == AppLifecycleState.detached) {
        wsDisconnectedSinceBackground.value = !checkWsConnected();
        lastBackgroundTime.value = DateTime.now();
      }

      if (resumedFromBackground && !isResyncingAfterResume.value) {
        final backgroundDuration = lastBackgroundTime.value != null
            ? DateTime.now().difference(lastBackgroundTime.value!)
            : Duration.zero;
        final wasBackgroundedLongEnough =
            backgroundDuration >= backgroundSyncThreshold;

        final shouldSync =
            !isDesktop ||
            wsDisconnectedSinceBackground.value ||
            wasBackgroundedLongEnough;
        isResyncingAfterResume.value = true;
        Future<void>(() async {
          try {
            if (shouldSync) {
              await messagesNotifier.initialize(forceRemoteRefresh: false);
            }
          } finally {
            if (context.mounted) {
              isResyncingAfterResume.value = false;
            }
          }
        });
        wsDisconnectedSinceBackground.value = false;
        lastBackgroundTime.value = null;
      }

      previousLifecycleState.value = nextState;
      return null;
    }, [lifecycleState.value, messagesNotifier]);

    useEffect(() {
      final isConnected = checkWsConnected();
      final previousConnected = wasWsConnected.value;

      if (previousConnected == false &&
          isConnected &&
          !isResyncingAfterResume.value) {
        isResyncingAfterResume.value = true;
        Future<void>(() async {
          try {
            await messagesNotifier.initialize(forceRemoteRefresh: false);
          } finally {
            if (context.mounted) {
              isResyncingAfterResume.value = false;
            }
          }
        });
      }

      wasWsConnected.value = isConnected;
      return null;
    }, [messagesNotifier]);

    useEffect(() {
      final currentSubscribed = ref.read(currentSubscribedChatIdProvider);
      return () {
        Future.microtask(() {
          if (currentSubscribed == id) {
            ref.read(currentSubscribedChatIdProvider.notifier).set(null);
          }
        });
      };
    }, []);

    // Auto-fill check when message count changes
    final scrollControllerRef = useRef(chatStateNotifier.scrollController);
    useEffect(() {
      final messageCount = messages.asData?.value.length ?? 0;
      // Delay to avoid modifying provider during build
      Future.microtask(() {
        chatStateNotifier.checkAutoFill(messageCount);
      });
      return null;
    }, [messages.asData?.value.length]);

    // Track "at latest" state
    final lastAtLatestRef = useRef<bool?>(true);
    useEffect(() {
      final controller = scrollControllerRef.value;
      void updateAtLatestState() {
        if (!controller.hasClients) return;
        final atLatest = controller.position.pixels <= 80;
        if (lastAtLatestRef.value == atLatest) return;
        lastAtLatestRef.value = atLatest;
        isAtLatestMessages.value = atLatest;
      }

      controller.addListener(updateAtLatestState);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => updateAtLatestState(),
      );
      return () => controller.removeListener(updateAtLatestState);
    }, []);

    // Track new messages while scrolled up
    final newMessagesCount = useState<int>(0);
    final lastMessageCount = useRef<int>(0);
    final isBackToBottomVisible = useState<bool>(false);
    final hideBackToBottomTimer = useRef<Timer?>(null);
    final lastScrollPosition = useRef<double>(0);
    final scrollStabilityCounter = useRef<int>(0);

    // Update new message count when messages change
    useEffect(() {
      final currentCount = messages.value?.length ?? 0;
      if (!isAtLatestMessages.value &&
          currentCount > lastMessageCount.value &&
          lastMessageCount.value > 0) {
        newMessagesCount.value += (currentCount - lastMessageCount.value);
      }
      lastMessageCount.value = currentCount;
      return null;
    }, [messages.value?.length, isAtLatestMessages.value]);

    // Auto-hide back-to-bottom button after 3s of no scroll
    useEffect(() {
      if (!isAtLatestMessages.value) {
        isBackToBottomVisible.value = true;

        void onScroll() {
          if (!scrollControllerRef.value.hasClients) return;
          final currentPos = scrollControllerRef.value.position.pixels;
          final delta = (currentPos - lastScrollPosition.value).abs();

          // Reset timer on significant scroll movement
          if (delta > 5) {
            scrollStabilityCounter.value = 0;
            isBackToBottomVisible.value = true;
            hideBackToBottomTimer.value?.cancel();
            hideBackToBottomTimer.value = Timer(const Duration(seconds: 3), () {
              isBackToBottomVisible.value = false;
            });
          } else {
            // Small movement, increment stability counter
            scrollStabilityCounter.value++;
          }

          lastScrollPosition.value = currentPos;
        }

        final controller = scrollControllerRef.value;
        controller.addListener(onScroll);

        // Start initial timer
        hideBackToBottomTimer.value = Timer(const Duration(seconds: 3), () {
          isBackToBottomVisible.value = false;
        });

        return () {
          controller.removeListener(onScroll);
          hideBackToBottomTimer.value?.cancel();
        };
      } else {
        // At bottom, hide button and reset counter
        isBackToBottomVisible.value = false;
        newMessagesCount.value = 0;
        hideBackToBottomTimer.value?.cancel();
        return null;
      }
    }, [isAtLatestMessages.value]);

    final inputKey = useMemoized(() => GlobalKey(), []);

    final openThinkingSheet = useCallback(() {
      if (chatState.selectedMessageIds.isEmpty) return;

      final selectedMessageData =
          messages.value
              ?.where((msg) => chatState.selectedMessageIds.contains(msg.id))
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

      chatStateNotifier.exitSelectionMode();
    }, [chatState.selectedMessageIds, messages, chatStateNotifier]);

    final uploadAttachment = useCallback((
      int index, {
      String? encryptKey,
    }) async {
      final attachment = chatState.attachments[index];
      if (attachment.isOnCloud) return;

      final config = await showModalBottomSheet<AttachmentUploadConfig>(
        context: context,
        isScrollControlled: true,
        builder: (context) => AttachmentUploaderSheet(
          ref: ref,
          attachments: chatState.attachments,
          index: index,
          encryptedUpload: chatRoom.value?.encryptionMode == 3,
        ),
      );
      if (config == null) return;

      try {
        chatStateNotifier.updateAttachmentProgress('chat-upload', 0);

        final cloudFile = await ref
            .read(driveFileUploaderProvider)
            .createCloudFile(
              fileData: attachment,
              poolId: config.poolId,
              encryptPassword: encryptKey,
              mode: attachment.type == UniversalFileType.file
                  ? FileUploadMode.generic
                  : FileUploadMode.mediaSafe,
              onProgress: (progress, _) {
                chatStateNotifier.updateAttachmentProgress(
                  'chat-upload',
                  progress ?? 0.0,
                );
              },
            )
            .future;

        if (cloudFile == null) {
          throw ArgumentError('Failed to upload file...');
        }

        final clone = List.of(chatState.attachments);
        clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
        chatStateNotifier.updateAttachments(clone);
      } catch (err) {
        showErrorAlert(err.toString());
      } finally {
        final newProgress = Map<String, Map<int, double?>>.from(
          chatState.attachmentProgress,
        );
        newProgress.remove('chat-upload');
      }
    }, [chatState.attachments, chatStateNotifier, ref, context]);

    final onJump = useCallback((String messageId) {
      messages.when(
        data: (messageList) {
          chatStateNotifier.scrollToMessage(
            messageId: messageId,
            messageList: messageList,
            jumpToMessage: messagesNotifier.jumpToMessage,
          );
        },
        loading: () {},
        error: (_, _) {},
      );
    }, [messages, chatStateNotifier, messagesNotifier]);

    final filteredMessages = messages;

    final visibleLastReadAnchorMessageId = (() {
      final anchorTime = savedLastReadAt.value;
      final list = messages.value;
      if (anchorTime == null || list == null || list.isEmpty) return null;
      if (isAtLatestMessages.value) return null;
      final anchorIndex = list.indexWhere(
        (m) =>
            m.createdAt.isBefore(anchorTime) ||
            m.createdAt.isAtSameMomentAs(anchorTime),
      );
      if (anchorIndex == -1) return null;
      if (anchorIndex > 0) return list[anchorIndex].id;
      return null;
    })();

    // Update last read anchor in state when calculated
    useEffect(() {
      // Delay modification to avoid modifying provider during build
      Future.microtask(() {
        chatStateNotifier.setLastReadAnchorMessageId(
          visibleLastReadAnchorMessageId,
        );
      });
      return null;
    }, [visibleLastReadAnchorMessageId]);

    final jumpToLastReadAnchor = useCallback(() {
      final anchorTime = savedLastReadAt.value;
      final list = messages.value;
      if (anchorTime == null || list == null || list.isEmpty) return;

      final targetIndex = list.indexWhere(
        (m) =>
            m.createdAt.isBefore(anchorTime) ||
            m.createdAt.isAtSameMomentAs(anchorTime),
      );
      if (targetIndex == -1) return;
      final targetId = list[targetIndex].id;

      messagesNotifier.jumpToMessage(targetId).then((index) {
        if (index != -1 && context.mounted) {
          ref
              .read(flashingMessagesProvider.notifier)
              .update((set) => set.union({targetId}));
          messages.when(
            data: (messageList) {
              chatStateNotifier.scrollToMessage(
                messageId: targetId,
                messageList: messageList,
                jumpToMessage: messagesNotifier.jumpToMessage,
              );
            },
            loading: () {},
            error: (_, _) {},
          );
        }
      });
    }, [savedLastReadAt.value, messagesNotifier, messages, chatStateNotifier]);

    return Stack(
      children: [
        AppScaffold(
          appBar: AppBar(
            leading: const AutoLeadingButton(),
            automaticallyImplyLeading: false,
            title: chatRoom.when(
              data: (room) => RoomAppBar(
                room: room!,
                onlineCount: onlineCount.value?.onlineCount ?? 0,
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
                            chatStateNotifier.scrollToMessage(
                              messageId: messageId,
                              messageList: messageList,
                              jumpToMessage: messagesNotifier.jumpToMessage,
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
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    AnimatedSwitcher(
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
                      child: filteredMessages.when(
                        data: (messageList) => messageList.isEmpty
                            ? Center(
                                key: const ValueKey('empty-messages'),
                                child: Text(
                                  settings.chatEventMessageMode ==
                                          kChatEventMessageModeNone
                                      ? 'No visible messages (event/system hidden)'
                                      : 'No messages yet'.tr(),
                                ),
                              )
                            : RoomMessageList(
                                key: const ValueKey('message-list'),
                                roomId: id,
                                messages: messageList,
                                roomAsync: chatRoom,
                                chatIdentity: chatIdentity,
                                onJump: onJump,
                              ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ),
                    chatRoom.when(
                      data: (room) => room != null
                          ? CallOverlayBar(room: room)
                          : const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                    ),
                    if (isSyncing)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConfuseSpinner(
                                  size: 20,
                                  speed: 7,
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                if (syncHint != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    syncHint,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Follow Back FAB - top right, small circular, ignores safe area
                    Positioned(
                      top: 12,
                      right: 12,
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: AnimatedOpacity(
                          opacity: visibleLastReadAnchorMessageId != null
                              ? 1.0
                              : 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: AnimatedScale(
                            scale: visibleLastReadAnchorMessageId != null
                                ? 1.0
                                : 0.8,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: FloatingActionButton.small(
                              heroTag: 'followBack',
                              onPressed: visibleLastReadAnchorMessageId != null
                                  ? jumpToLastReadAnchor
                                  : null,
                              elevation: visibleLastReadAnchorMessageId != null
                                  ? 2
                                  : 0,
                              backgroundColor:
                                  visibleLastReadAnchorMessageId != null
                                  ? null
                                  : Colors.transparent,
                              child: const Icon(Icons.bookmark_added_outlined),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Back to Bottom FAB - bottom right, with new message badge, ignores safe area
                    Positioned(
                      bottom: 16,
                      right: 12,
                      child: AnimatedOpacity(
                        opacity:
                            (!isAtLatestMessages.value &&
                                isBackToBottomVisible.value)
                            ? 1.0
                            : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedScale(
                          scale:
                              (!isAtLatestMessages.value &&
                                  isBackToBottomVisible.value)
                              ? 1.0
                              : 0.8,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: FloatingActionButton.small(
                            heroTag: 'backToBottom',
                            onPressed:
                                (!isAtLatestMessages.value &&
                                    isBackToBottomVisible.value)
                                ? () {
                                    chatStateNotifier.jumpToBottom();
                                    newMessagesCount.value = 0;
                                  }
                                : null,
                            elevation:
                                (!isAtLatestMessages.value &&
                                    isBackToBottomVisible.value)
                                ? 2
                                : 0,
                            backgroundColor:
                                (!isAtLatestMessages.value &&
                                    isBackToBottomVisible.value)
                                ? null
                                : Colors.transparent,
                            child: Badge(
                              isLabelVisible:
                                  newMessagesCount.value > 0 &&
                                  isBackToBottomVisible.value,
                              label: Text('${newMessagesCount.value}'),
                              child: const Icon(Icons.arrow_downward),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (messagesNotifier.e2eeRecoveryState ==
                        E2eeRecoveryState.reconnecting)
                      Positioned.fill(
                        child: Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.9),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const ConfuseSpinner(size: 40, speed: 6),
                                const SizedBox(height: 16),
                                Text(
                                  'Reconnecting to encrypted conversation...',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please wait',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (messagesNotifier.e2eeRecoveryState ==
                        E2eeRecoveryState.failed)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Material(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Unable to decrypt messages. History unavailable.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onErrorContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!chatState.isSelectionMode)
                chatRoom.when(
                  data: (room) => room != null
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: ChatInput(
                            key: inputKey,
                            messageController:
                                chatStateNotifier.messageController,
                            chatRoom: room,
                            onSend: () => chatStateNotifier.sendMessage(ref),
                            onClear: () {
                              if (chatState.messageEditingTo != null) {
                                chatStateNotifier.clearAttachmentsOnly();
                              }
                              chatStateNotifier.setEditingTo(null);
                              chatStateNotifier.setReplyingTo(null);
                              chatStateNotifier.setForwardingTo(null);
                              chatStateNotifier.setPoll(null);
                              chatStateNotifier.setFund(null);
                            },
                            messageEditingTo: chatState.messageEditingTo,
                            messageReplyingTo: chatState.messageReplyingTo,
                            messageForwardingTo: chatState.messageForwardingTo,
                            selectedPoll: chatState.selectedPoll,
                            onPollSelected: (poll) =>
                                chatStateNotifier.setPoll(poll),
                            selectedFund: chatState.selectedFund,
                            onFundSelected: (fund) =>
                                chatStateNotifier.setFund(fund),
                            isMessageListScrolling: !isAtLatestMessages.value,
                            onPickFile: (isPhoto) {
                              if (isPhoto) {
                                chatStateNotifier.pickPhotos();
                              } else {
                                chatStateNotifier.pickVideos();
                              }
                            },
                            onPickAudio: chatStateNotifier.pickAudio,
                            onPickGeneralFile: chatStateNotifier.pickFiles,
                            onLinkAttachment: () =>
                                chatStateNotifier.linkAttachment(context),
                            attachments: chatState.attachments,
                            onUploadAttachment: uploadAttachment,
                            onDeleteAttachment: (index) async {
                              final attachment = chatState.attachments[index];
                              if (attachment.isOnCloud && !attachment.isLink) {
                                final client = ref.watch(apiClientProvider);
                                await client.delete(
                                  '/drive/files/${attachment.data.id}',
                                );
                              }
                              final clone = List.of(chatState.attachments);
                              clone.removeAt(index);
                              chatStateNotifier.updateAttachments(clone);
                            },
                            onMoveAttachment: (idx, delta) {
                              if (idx + delta < 0 ||
                                  idx + delta >= chatState.attachments.length) {
                                return;
                              }
                              final clone = List.of(chatState.attachments);
                              clone.insert(idx + delta, clone.removeAt(idx));
                              chatStateNotifier.updateAttachments(clone);
                            },
                            onAttachmentsChanged:
                                chatStateNotifier.updateAttachments,
                            attachmentProgress: chatState.attachmentProgress,
                          ),
                        )
                      : const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
              if (chatState.isSelectionMode)
                RoomSelectionMode(
                  visible: chatState.isSelectionMode,
                  selectedCount: chatState.selectedMessageIds.length,
                  onClose: chatStateNotifier.exitSelectionMode,
                  onAIThink: openThinkingSheet,
                ),
            ],
          ),
        ),
        if (!isWideScreen(context)) const ChatSyncIndicator(height: 56),
      ],
    );
  }
}
