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
import 'package:island/chat/widgets/chat_room_list_tile.dart';
import 'package:island/chat/widgets/chat_search_screen.dart';
import 'package:island/chat/widgets/pinned_messages_sheet.dart';
import 'package:island/chat/widgets/public_room_preview.dart';
import 'package:island/chat/widgets/room_app_bar.dart';
import 'package:island/chat/widgets/room_message_list.dart';
import 'package:island/chat/widgets/room_selection_mode.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/core/config.dart';
import 'package:island/core/lifecycle.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:island/core/services/analytics_service.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/route.gr.dart';

import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/attachment_uploader.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/shared/widgets/sync_indicator.dart';
import 'package:island/thoughts/screens/think_sheet.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class ChatRoomScreen extends HookConsumerWidget {
  final String id;
  const ChatRoomScreen({super.key, @PathParam("id") required this.id});

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
    final isAtLatestMessages = useState(true);
    final savedLastReadAt = useState<DateTime?>(chatIdentity.value?.lastReadAt);
    final pinnedPins = useState<List<SnChatMessagePin>>([]);
    final isPinnedBarCollapsed = useState(false);

    useEffect(() {
      final identity = chatIdentity.value;
      if (identity != null) {
        savedLastReadAt.value = identity.lastReadAt;
      }
      return null;
    }, [chatIdentity.value]);

    // Fetch pinned messages and listen for realtime updates
    useEffect(() {
      Future.microtask(() async {
        final pins = await messagesNotifier.fetchPinnedMessages();
        if (context.mounted) {
          pinnedPins.value = pins;
        }
      });

      final sub = eventBus.on<ChatMessageNewEvent>().listen((event) {
        if (event.message.chatRoomId != id) return;
        if (event.message.type == 'messages.pinned' ||
            event.message.type == 'messages.unpinned') {
          Future.microtask(() async {
            final pins = await messagesNotifier.fetchPinnedMessages();
            if (context.mounted) {
              pinnedPins.value = pins;
            }
          });
        }
      });
      return sub.cancel;
    }, [id]);

    // Track when app was backgrounded for time-based provider invalidation
    final lastBackgroundTime = useRef<DateTime?>(null);
    const backgroundSyncThreshold = Duration(seconds: 30);

    final lastResyncAt = useRef<DateTime?>(null);
    final isResyncing = useRef(false);

    Future<void> resyncRoom({
      bool force = false,
      String reason = 'unknown',
    }) async {
      if (isResyncing.value) return;
      final now = DateTime.now();
      final cooldownPassed =
          lastResyncAt.value == null ||
          now.difference(lastResyncAt.value!) > const Duration(seconds: 8);
      if (!force && !cooldownPassed) return;

      isResyncing.value = true;
      lastResyncAt.value = now;
      try {
        await messagesNotifier.initialize(forceRemoteRefresh: false);
      } finally {
        isResyncing.value = false;
      }
    }

    useEffect(() {
      Future.microtask(() {
        if (!context.mounted) return;
        resyncRoom(force: true, reason: 'room-open');
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

      if (resumedFromBackground) {
        final backgroundDuration = lastBackgroundTime.value != null
            ? DateTime.now().difference(lastBackgroundTime.value!)
            : Duration.zero;
        final wasBackgroundedLongEnough =
            backgroundDuration >= backgroundSyncThreshold;

        final shouldSync =
            !isDesktop ||
            wsDisconnectedSinceBackground.value ||
            wasBackgroundedLongEnough;
        Future<void>(() async {
          if (shouldSync) {
            await resyncRoom(reason: 'app-resume');
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

      if (previousConnected == false && isConnected) {
        Future<void>(() async {
          await resyncRoom(reason: 'ws-reconnected');
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
        if (!controller.hasClients || controller.positions.length != 1) return;
        final atLatest = controller.positions.first.pixels <= 80;
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
    final isBackToBottomVisible = useState<bool>(false);
    final hideBackToBottomTimer = useRef<Timer?>(null);

    // Count only actual incoming/synced new-message events. Older pagination
    // loads and list regrouping can change message count without being new.
    useEffect(() {
      final sub = eventBus.on<ChatMessageNewEvent>().listen((event) {
        if (event.message.chatRoomId != id) return;
        if (isAtLatestMessages.value) return;
        newMessagesCount.value += 1;
      });
      return sub.cancel;
    }, [id]);

    // Auto-hide back-to-bottom button after idle period.
    useEffect(() {
      if (!isAtLatestMessages.value) {
        isBackToBottomVisible.value = true;

        void onScroll() {
          final controller = scrollControllerRef.value;
          if (!controller.hasClients || controller.positions.length != 1) {
            return;
          }
          isBackToBottomVisible.value = true;
          hideBackToBottomTimer.value?.cancel();
          hideBackToBottomTimer.value = Timer(const Duration(seconds: 2), () {
            isBackToBottomVisible.value = false;
          });
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
        // At bottom, hide button and reset badge.
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

    final openRedirectSheet = useCallback(
      () async {
        if (chatState.selectedMessageIds.isEmpty) return;

        final allMessages = messages.value ?? const <LocalChatMessage>[];
        final selectedMessages =
            allMessages
                .where((msg) => chatState.selectedMessageIds.contains(msg.id))
                .toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // Safety: ensure selected ids are from current source room only.
        final crossRoomSelected = selectedMessages
            .where((msg) => msg.roomId != id)
            .toList();
        if (crossRoomSelected.isNotEmpty) {
          showErrorAlert('chatRedirectSameRoomOnly'.tr());
          return;
        }

        if (selectedMessages.isEmpty) return;
        if (selectedMessages.length > 100) {
          showErrorAlert('chatRedirectTooMany'.tr());
          return;
        }
        if (selectedMessages.any((msg) => msg.type != 'text')) {
          showErrorAlert('chatRedirectTextOnly'.tr());
          return;
        }

        if (!context.mounted) return;

        final destinationRoomId = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _RedirectRoomSelectorSheet(currentRoomId: id),
        );

        if (destinationRoomId == null || !context.mounted) return;

        final rooms = ref
            .read(chatRoomJoinedProvider)
            .maybeWhen(data: (items) => items, orElse: () => <SnChatRoom>[]);
        SnChatRoom? destinationRoom;
        for (final room in rooms) {
          if (room.id == destinationRoomId) {
            destinationRoom = room;
            break;
          }
        }
        if (destinationRoom == null) {
          final loadedRooms = await ref.read(chatRoomJoinedProvider.future);
          for (final room in loadedRooms) {
            if (room.id == destinationRoomId) {
              destinationRoom = room;
              break;
            }
          }
        }
        final destinationName = destinationRoom?.name?.trim().isNotEmpty == true
            ? destinationRoom!.name!
            : 'this room';

        if (!context.mounted) return;

        final shouldProceed =
            await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('chatRedirectConfirmTitle'.tr()),
                content: Text(
                  'chatRedirectConfirmBody'.tr(
                    args: [selectedMessages.length.toString(), destinationName],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('cancel'.tr()),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text('redirect'.tr()),
                  ),
                ],
              ),
            ) ??
            false;

        if (!shouldProceed || !context.mounted) return;

        try {
          showLoadingModal(context);
          final client = ref.read(solarNetworkClientProvider);
          await client.chat.redirectMessages(
            roomId: destinationRoomId,
            messageIds: selectedMessages.map((m) => m.id).toList(),
          );

          if (!context.mounted) return;
          chatStateNotifier.exitSelectionMode();
          showSnackBar(
            'chatRedirectSuccess'.tr(
              args: [selectedMessages.length.toString()],
            ),
          );
        } catch (err) {
          showErrorAlert(err);
        } finally {
          if (context.mounted) {
            hideLoadingModal(context);
          }
        }
      },
      [
        chatState.selectedMessageIds,
        messages,
        ref,
        context,
        id,
        chatStateNotifier,
      ],
    );

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

      var trackedIndex = index;
      try {
        chatStateNotifier.updateAttachmentUploadProgress(trackedIndex, 0);

        final cloudFile = await ref
            .read(driveFileUploaderProvider)
            .createCloudFile(
              fileData: attachment,
              poolId: config.poolId,
              encryptPassword: encryptKey,
              usage: 'chat_message',
              mode: attachment.type == UniversalFileType.file
                  ? FileUploadMode.generic
                  : FileUploadMode.mediaSafe,
              onProgress: (progress, _) {
                final latestAttachments = ref
                    .read(chatRoomStateProvider(id))
                    .attachments;
                final currentIndex = latestAttachments.indexOf(attachment);
                if (currentIndex == -1) return;
                if (currentIndex != trackedIndex) {
                  chatStateNotifier.clearAttachmentUploadProgress(trackedIndex);
                  trackedIndex = currentIndex;
                }
                chatStateNotifier.updateAttachmentUploadProgress(
                  currentIndex,
                  progress ?? 0.0,
                );
              },
            )
            .future;

        if (cloudFile == null) {
          throw ArgumentError('Failed to upload file...');
        }

        final latestAttachments = ref
            .read(chatRoomStateProvider(id))
            .attachments;
        final currentIndex = latestAttachments.indexOf(attachment);
        if (currentIndex == -1) return;

        final clone = List<UniversalFile>.of(latestAttachments);
        clone[currentIndex] = UniversalFile(
          data: cloudFile,
          type: attachment.type,
        );
        chatStateNotifier.updateAttachments(clone);
      } catch (err) {
        showErrorAlert(err.toString());
      } finally {
        chatStateNotifier.clearAttachmentUploadProgress(trackedIndex);
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

    final jumpAndRevealMessage = useCallback((String messageId) {
      messagesNotifier.jumpToMessage(messageId).then((index) {
        if (index != -1 && context.mounted) {
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
    }, [messagesNotifier, messages, chatStateNotifier, context]);

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

      jumpAndRevealMessage(targetId);
    }, [savedLastReadAt.value, messages, jumpAndRevealMessage]);

    return Stack(
      children: [
        AppScaffold(
          appBar: AppBar(
            leading: const AutoLeadingButton(),
            automaticallyImplyLeading: false,
            title: chatRoom.when(
              data: (room) =>
                  RoomAppBar(room: room!, onlineStatus: onlineCount.value),
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
                    jumpAndRevealMessage(messageId);
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              if (pinnedPins.value.isNotEmpty)
                _PinnedMessagesBar(
                  pins: pinnedPins.value,
                  isCollapsed: isPinnedBarCollapsed.value,
                  onToggleCollapse: () {
                    isPinnedBarCollapsed.value = !isPinnedBarCollapsed.value;
                  },
                  onTapPin: (pin) {
                    if (pin.messageId.isNotEmpty) {
                      jumpAndRevealMessage(pin.messageId);
                    }
                  },
                  onViewAll: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => PinnedMessagesSheet(
                        roomId: id,
                        onJumpToMessage: jumpAndRevealMessage,
                      ),
                    );
                  },
                ),
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
                        loading: () => Center(
                          key: const ValueKey('messages-loading'),
                          child: ConfuseSpinner(
                            size: 40,
                            speed: 6,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withOpacity(0.65),
                          ),
                        ),
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
                          child: Badge(
                            isLabelVisible:
                                newMessagesCount.value > 0 &&
                                isBackToBottomVisible.value,
                            label: Text('${newMessagesCount.value}'),
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
                            onSend: chatStateNotifier.sendMessage,
                            onClear: () {
                              if (chatState.messageEditingTo != null) {
                                chatStateNotifier.clearAttachmentsOnly();
                              }
                              chatStateNotifier.setEditingTo(null);
                              chatStateNotifier.setReplyingTo(null);
                              chatStateNotifier.setForwardingTo(null);
                              chatStateNotifier.setPoll(null);
                              chatStateNotifier.setFund(null);
                              chatStateNotifier.setLocation();
                              chatStateNotifier.setMeet(null);
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
                            selectedLocationName:
                                chatState.selectedLocationName,
                            selectedLocationAddress:
                                chatState.selectedLocationAddress,
                            selectedLocationWkt: chatState.selectedLocationWkt,
                            selectedMeetId: chatState.selectedMeetId,
                            onLocationSelected:
                                ({
                                  String? name,
                                  String? address,
                                  String? wkt,
                                }) => chatStateNotifier.setLocation(
                                  name: name,
                                  address: address,
                                  wkt: wkt,
                                ),
                            onMeetSelected: (meetId) =>
                                chatStateNotifier.setMeet(meetId),
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
                                  '/fs/files/${attachment.data.id}',
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
                  onRedirect: openRedirectSheet,
                ),
            ],
          ),
        ),
        const ChatSyncIndicator(height: 56),
      ],
    );
  }
}

class _RedirectRoomSelectorSheet extends HookConsumerWidget {
  final String currentRoomId;

  const _RedirectRoomSelectorSheet({required this.currentRoomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomJoinedProvider);

    return SheetScaffold(
      titleText: 'chatRedirectSelectRoom'.tr(),
      child: roomsAsync.when(
        data: (rooms) {
          final communityRooms = <SnChatRoom>[];
          final directRooms = <SnChatRoom>[];

          for (final room in rooms) {
            if (room.encryptionMode != 0) continue;
            if (room.type == 1) {
              directRooms.add(room);
            } else {
              communityRooms.add(room);
            }
          }

          int byName(SnChatRoom a, SnChatRoom b) {
            final aName = (a.name ?? '').toLowerCase();
            final bName = (b.name ?? '').toLowerCase();
            return aName.compareTo(bName);
          }

          communityRooms.sort(byName);
          directRooms.sort(byName);

          final hasAny = communityRooms.isNotEmpty || directRooms.isNotEmpty;
          if (!hasAny) {
            return Center(
              child: Text(
                'noChatRoomsAvailable'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView(
            children: [
              if (communityRooms.isNotEmpty)
                _RedirectRoomGroup(
                  title: 'chatTabGroup'.tr(),
                  rooms: communityRooms,
                  currentRoomId: currentRoomId,
                ),
              if (directRooms.isNotEmpty)
                _RedirectRoomGroup(
                  title: 'chatTabDirect'.tr(),
                  rooms: directRooms,
                  currentRoomId: currentRoomId,
                ),
            ],
          );
        },
        loading: () => Center(
          child: ConfuseSpinner(
            size: 34,
            speed: 6,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.65),
          ),
        ),
        error: (error, _) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(chatRoomJoinedProvider),
        ),
      ),
    );
  }
}

class _RedirectRoomGroup extends StatelessWidget {
  final String title;
  final List<SnChatRoom> rooms;
  final String currentRoomId;

  const _RedirectRoomGroup({
    required this.title,
    required this.rooms,
    required this.currentRoomId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final room in rooms)
          ChatRoomListTile(
            room: room,
            isDirect: room.type == 1,
            selected: room.id == currentRoomId,
            subtitle: room.id == currentRoomId
                ? Text(
                    'Current room',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : null,
            onTap: () => Navigator.of(context).pop(room.id),
          ),
      ],
    );
  }
}

class _PinnedMessagesBar extends StatelessWidget {
  final List<SnChatMessagePin> pins;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final void Function(SnChatMessagePin pin) onTapPin;
  final VoidCallback onViewAll;

  const _PinnedMessagesBar({
    required this.pins,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onTapPin,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (pins.isEmpty) return const SizedBox.shrink();

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggleCollapse,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Symbols.push_pin,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${pins.length} pinned message${pins.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  if (pins.length > 1)
                    TextButton(
                      onPressed: onViewAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'viewAll'.tr(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (!isCollapsed)
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: pins.length,
                itemBuilder: (context, index) {
                  final pin = pins[index];
                  final message = pin.message;
                  final sender = message?.sender;
                  final senderNick = sender?.nick;
                  final accountNick = sender?.account.nick;
                  final senderName = senderNick?.isNotEmpty == true
                      ? senderNick!
                      : accountNick ?? '';
                  final content = message?.content ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      avatar: Icon(
                        Symbols.push_pin,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          senderName.isNotEmpty
                              ? '$senderName: $content'
                              : content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      onPressed: () => onTapPin(pin),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                },
              ),
            ),
          Divider(
            height: 1,
            thickness: 1 / MediaQuery.devicePixelRatioOf(context),
          ),
        ],
      ),
    );
  }
}
