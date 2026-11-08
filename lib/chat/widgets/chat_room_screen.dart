import 'dart:async';
import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/message_indicators.dart';
import 'package:island/chat/pods/chat_online_count.dart';
import 'package:island/chat/pods/chat_foreground_rooms.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/utils/chat_room_ordering.dart';
import 'package:island/chat/widgets/chat_room_picker_filter.dart';
import 'package:island/chat/pods/chat_share_payload.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/content/media_playback.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/chat/widgets/call_overlay.dart';
import 'package:island/chat/widgets/chat_input.dart';
import 'package:island/chat/widgets/chat_room_list_tile.dart';
import 'package:island/chat/widgets/chat_search_screen.dart';
import 'package:island/chat/widgets/chat_thread_panel.dart';
import 'package:island/chat/widgets/pinned_messages_sheet.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';
import 'package:island/chat/widgets/public_room_preview.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/widgets/room_app_bar.dart';
import 'package:island/chat/widgets/room_message_list.dart';
import 'package:island/chat/widgets/room_selection_mode.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:gap/gap.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/core/lifecycle.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/services/ios_share_suggestions.dart';
import 'package:island/core/websocket.dart';
import 'package:island/core/services/analytics_service.dart';
import 'package:island/data/message.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/chat/widgets/pinned_messages_bar.dart';
import 'package:island/route.gr.dart';

import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/attachment_uploader.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/measure_height.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _DirectMessageConfirmationBanner extends HookConsumerWidget {
  final SnChatRoom chatRoom;
  final SnChatMember identity;
  final bool isBlocked;
  final Future<void> Function()? onBlocked;

  const _DirectMessageConfirmationBanner({
    required this.chatRoom,
    required this.identity,
    required this.isBlocked,
    this.onBlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final client = ref.read(solarNetworkClientProvider);
    final peer = (chatRoom.members ?? const <SnChatMember>[])
        .where((member) => member.accountId != identity.accountId)
        .firstOrNull;

    Future<void> confirm() async {
      if (isBusy.value) return;
      isBusy.value = true;
      try {
        if (isBlocked) {
          await client.chat.unblockDirectChat(chatRoom.id);
        } else {
          await client.chat.confirmDirectChat(chatRoom.id);
        }
        ref.invalidate(chatRoomJoinedProvider);
        ref.invalidate(chatRoomProvider(chatRoom.id));
        ref.invalidate(chatRoomIdentityProvider(chatRoom.id));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> block() async {
      if (isBusy.value) return;
      final shouldBlock = await showConfirmAlert(
        'directMessage'.tr(),
        'blockUser'.tr(),
        isDanger: true,
      );
      if (!shouldBlock || !context.mounted) return;

      isBusy.value = true;
      try {
        await client.chat.blockDirectChat(chatRoom.id);
        ref.invalidate(chatRoomJoinedProvider);
        ref.invalidate(chatRoomProvider(chatRoom.id));
        ref.invalidate(chatRoomIdentityProvider(chatRoom.id));
        await onBlocked?.call();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final messageLabel = peer == null
        ? 'directMessage'.tr()
        : 'directMessageFrom'.tr(args: [peer.account.nick]);

    return Container(
      key: ValueKey('dm-confirm-${chatRoom.id}'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceContainerHigh,
      child: Row(
        children: [
          Icon(Symbols.mark_chat_unread, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              messageLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          FilledButton.tonal(
            onPressed: isBusy.value ? null : confirm,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text(isBlocked ? 'chatJoin'.tr() : 'confirm'.tr()),
          ),
          if (!isBlocked)
            TextButton(
              onPressed: isBusy.value ? null : block,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text('blockUser'.tr()),
            ),
        ],
      ),
    );
  }
}

@RoutePage()
class ChatRoomScreen extends HookConsumerWidget {
  final String id;
  final String? initialMessageId;

  const ChatRoomScreen({
    super.key,
    @PathParam("id") required this.id,
    this.initialMessageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoom = ref.watch(chatRoomProvider(id));
    final chatIdentity = ref.watch(chatRoomIdentityProvider(id));
    final chatEventMessageMode = ref.watch(
      appSettingsProvider.select((settings) => settings.chatEventMessageMode),
    );

    // Leaving the room tears down its message widgets. Chat voice playback
    // must not survive that in the docked player: stop it on unmount.
    useEffect(() {
      final controller = ref.read(mediaPlaybackProvider.notifier);
      return () {
        // Deferred: modifying a provider during a lifecycle is forbidden.
        scheduleMicrotask(() {
          if (controller.isChatVoiceOf(id)) controller.close();
        });
      };
    }, [id]);

    // Universal chat room state - manages all UI state for this room.
    // Watch only the fields that affect the whole screen; input state stays
    // inside the ChatInput Consumer so attachments/typing don't rebuild the list.
    final isSelectionMode = ref.watch(
      chatRoomStateProvider(id).select((state) => state.isSelectionMode),
    );
    final selectedMessageIds = ref.watch(
      chatRoomStateProvider(id).select((state) => state.selectedMessageIds),
    );
    final dismissedLastReadAnchorMessageId = ref.watch(
      chatRoomStateProvider(
        id,
      ).select((state) => state.dismissedLastReadAnchorMessageId),
    );
    final threadReplyTarget = ref.watch(
      chatRoomStateProvider(id).select((state) => state.threadReplyTarget),
    );
    final showThreadSidebar = useRef(ValueNotifier<bool>(false)).value;
    final openedThreadTarget = useRef<SnChatMessage?>(null);
    final chatStateNotifier = ref.read(chatRoomStateProvider(id).notifier);
    final messagesNotifier = ref.read(messagesProvider(id).notifier);
    final currentSubscribedChatId = ref.watch(currentSubscribedChatIdProvider);
    final currentSubscribedChatIdNotifier = ref.read(
      currentSubscribedChatIdProvider.notifier,
    );
    final foregroundChatRoomIdsNotifier = ref.read(
      foregroundChatRoomIdsProvider.notifier,
    );
    final currentSubscribedChatIdRef = useRef(currentSubscribedChatId);
    currentSubscribedChatIdRef.value = currentSubscribedChatId;
    final pendingSharePayloadNotifier = ref.watch(chatSharePayloadProvider(id));
    final pendingSharePayload = useValueListenable(pendingSharePayloadNotifier);

    final analyticsLogged = useRef(false);
    final donatedRoomId = useRef<String?>(null);
    final appliedSharePayloadSignature = useRef<String?>(null);
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

    useEffect(() {
      final room = chatRoom.value;
      final currentUser = ref.read(userInfoProvider).value;
      if (room == null || room.id == donatedRoomId.value) {
        return null;
      }

      Future.microtask(() async {
        await IosShareSuggestionsService.instance.donateChatRoom(
          room,
          currentUserId: currentUser?.id,
          currentAccountName: currentUser?.name,
          currentAccountNick: currentUser?.nick,
          currentUser: currentUser,
          serverUrl: ref.read(serverUrlProvider),
        );
        donatedRoomId.value = room.id;
      });

      return null;
    }, [chatRoom.value]);

    if (chatIdentity.isLoading || chatRoom.isLoading) {
      return AppScaffold(
        appBarOverContent: true,
        appBar: _RoomPillAppBar(
          roomId: id,
          statusTop: MediaQuery.paddingOf(context).top,
          room: chatRoom.value,
        ),
        body: Column(
          children: [
            _roomHeaderBand(context),
            Expanded(
              child: Center(
                child: ConfuseSpinner(
                  size: 40,
                  speed: 6,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.65),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (chatIdentity.value == null) {
      return chatRoom.when(
        data: (room) {
          final currentUserId = ref.read(userInfoProvider).value?.id;
          if (room == null) return const SizedBox.shrink();
          final blockedDirectMember = room.members
              ?.where(
                (member) =>
                    room.type == 1 &&
                    member.accountId == currentUserId &&
                    member.leaveAt != null &&
                    member.confirmedAt == null,
              )
              .firstOrNull;
          if (blockedDirectMember != null) {
            return AppScaffold(
              appBarOverContent: true,
              appBar: _RoomPillAppBar(
                roomId: id,
                statusTop: MediaQuery.paddingOf(context).top,
              ),
              body: Column(
                children: [
                  _roomHeaderBand(context),
                  Expanded(
                    child: Center(
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          try {
                            showLoadingModal(context);
                            final client = ref.read(solarNetworkClientProvider);
                            await client.chat.unblockDirectChat(room.id);
                            ref.invalidate(chatRoomJoinedProvider);
                            ref.invalidate(chatRoomProvider(id));
                            ref.invalidate(chatRoomIdentityProvider(id));
                          } catch (err) {
                            showErrorAlert(err);
                          } finally {
                            if (context.mounted) hideLoadingModal(context);
                          }
                        },
                        label: Text('chatJoin').tr(),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (room.isPublic) {
            return PublicRoomPreview(id: id, room: room);
          } else {
            return AppScaffold(
              appBarOverContent: true,
              appBar: _RoomPillAppBar(
                roomId: id,
                statusTop: MediaQuery.paddingOf(context).top,
              ),
              body: Column(
                children: [
                  _roomHeaderBand(context),
                  Expanded(
                    child: Center(
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
                                    final apiClient = ref.read(
                                      apiClientProvider,
                                    );
                                    await apiClient.post(
                                      '/messager/chat/${room.id}/members/me',
                                    );
                                    ref.invalidate(
                                      chatRoomIdentityProvider(id),
                                    );
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
                  ),
                ],
              ),
            );
          }
        },
        loading: () => AppScaffold(
          appBarOverContent: true,
          appBar: _RoomPillAppBar(
            roomId: id,
            statusTop: MediaQuery.paddingOf(context).top,
          ),
          body: Column(
            children: [
              _roomHeaderBand(context),
              Expanded(
                child: Center(
                  child: ConfuseSpinner(
                    size: 40,
                    speed: 6,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.65),
                  ),
                ),
              ),
            ],
          ),
        ),
        error: (error, _) => AppScaffold(
          appBarOverContent: true,
          appBar: _RoomPillAppBar(
            roomId: id,
            statusTop: MediaQuery.paddingOf(context).top,
          ),
          body: Column(
            children: [
              _roomHeaderBand(context),
              Expanded(
                child: ResponseErrorWidget(
                  error: error,
                  onRetry: () => ref.refresh(chatRoomProvider(id)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final messages = ref.watch(messagesProvider(id));
    final isAtLatestMessages = useState(true);
    final savedLastReadAt = useState<DateTime?>(chatIdentity.value?.lastReadAt);
    final pinnedPins = useState<List<SnChatMessagePin>>([]);
    final isPinnedBarCollapsed = useState(false);
    // Heights of the chrome painted over the timeline, measured from the
    // laid-out widgets rather than guessed: banners appearing, the composer
    // growing to five lines, or the keyboard opening all change what the list
    // has to clear.
    final topChromeHeight = useState(0.0);
    final composerHeight = useState(0.0);

    useEffect(() {
      final payload = pendingSharePayload;
      if (payload == null) return null;

      final signature =
          '${payload.text}|${payload.attachments.map((file) => file.data.path).join(",")}';
      if (appliedSharePayloadSignature.value == signature) {
        return null;
      }

      Future.microtask(() {
        if (!context.mounted) return;
        chatStateNotifier.applySharedPayload(payload);
        ref.read(chatSharePayloadProvider(id)).value = null;
        appliedSharePayloadSignature.value = signature;
      });

      return null;
    }, [pendingSharePayload]);

    // Open the thread panel when the user picks "Reply in thread".
    useEffect(() {
      if (threadReplyTarget == null) return null;
      openedThreadTarget.value = threadReplyTarget;
      showThreadSidebar.value = true;
      // Deferred: modifying a provider during a lifecycle is forbidden.
      Future.microtask(() {
        chatStateNotifier.clearThreadReplyTarget();
      });
      return null;
    }, [threadReplyTarget?.id]);

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
    final weakConnectionMode = ref.watch(
      appSettingsProvider.select((settings) => settings.weakConnectionMode),
    );

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

    // A global sync is also started from the room list and reconnect flows.
    // Refresh this room from its local cache once its rows have been committed,
    // so a long sync does not leave the open conversation visually stale.
    useEffect(() {
      final sub = eventBus.on<ChatMessagesSyncedEvent>().listen((event) {
        if (!event.roomIds.contains(id)) return;
        Future.microtask(() async {
          await messagesNotifier.loadInitial(forceRemoteRefresh: false);
        });
      });
      return sub.cancel;
    }, [id, messagesNotifier]);

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

    useEffect(() {
      if (!weakConnectionMode) return null;

      const weakConnectionSyncInterval = Duration(seconds: 45);
      final timer = Timer.periodic(weakConnectionSyncInterval, (_) {
        final currentLifecycle = ref.read(appLifecycleStateProvider).value;
        if (currentLifecycle != AppLifecycleState.resumed) return;
        Future.microtask(() {
          resyncRoom(reason: 'weak-connection-periodic');
        });
      });

      return timer.cancel;
    }, [id, weakConnectionMode, messagesNotifier]);

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

    // Watched so the resync effect below re-runs on a connect/disconnect
    // transition. Reading the provider without watching it left the
    // 'ws-reconnected' branch dead: the effect only ran when the notifier
    // itself was rebuilt for an unrelated reason.
    final wsConnected = ref.watch(websocketConnectedProvider);

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
      final previousConnected = wasWsConnected.value;

      if (isWebSocketReconnect(
        wasConnected: previousConnected,
        isConnected: wsConnected,
      )) {
        Future<void>(() async {
          await resyncRoom(reason: 'ws-reconnected');
        });
      }

      wasWsConnected.value = wsConnected;
      return null;
    }, [messagesNotifier, wsConnected]);

    useEffect(() {
      var disposed = false;
      Future.microtask(() {
        if (disposed) return;
        currentSubscribedChatIdNotifier.set(id);
        foregroundChatRoomIdsNotifier.add(id);
      });

      return () {
        disposed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (currentSubscribedChatIdRef.value == id) {
            currentSubscribedChatIdNotifier.set(null);
          }
          foregroundChatRoomIdsNotifier.remove(id);
        });
      };
    }, [id]);

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
      var retryCount = 0;

      void updateAtLatestState() {
        if (!controller.hasClients || controller.positions.length != 1) return;
        final atLatest = controller.positions.first.pixels <= 80;
        if (lastAtLatestRef.value == atLatest) return;
        lastAtLatestRef.value = atLatest;
        isAtLatestMessages.value = atLatest;
      }

      void syncWhenAttached() {
        if (!controller.hasClients || controller.positions.length != 1) {
          if (retryCount < 10) {
            retryCount += 1;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) syncWhenAttached();
            });
          }
          return;
        }
        updateAtLatestState();
      }

      controller.addListener(updateAtLatestState);
      WidgetsBinding.instance.addPostFrameCallback((_) => syncWhenAttached());
      return () => controller.removeListener(updateAtLatestState);
    }, []);

    // Track new messages while scrolled up
    final newMessagesCount = useState<int>(0);
    final isBackToBottomVisible = useState<bool>(false);
    final hideBackToBottomTimer = useRef<Timer?>(null);
    final hasLeftLatestMessages = useRef(false);

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

    // Optimistically update own read marker so read-receipt avatars move
    // immediately when the user is viewing the latest messages.
    useEffect(() {
      final list = messages.asData?.value;
      if (list == null || list.isEmpty) return null;

      final atBottom =
          scrollControllerRef.value.hasClients &&
          scrollControllerRef.value.positions.isNotEmpty &&
          scrollControllerRef.value.position.pixels <= 80;
      if (!atBottom) return null;

      // The list is newest-first (reverse: true), so the chronologically
      // latest message is at index 0.
      final latestMsg = list.first;
      final currentUserId = ref.read(userInfoProvider).value?.id;
      if (currentUserId == null) return null;

      Future.microtask(() async {
        if (!context.mounted) return;
        await markRoomRead(ref, id, currentUserId, latestMsg.createdAt);
      });

      return null;
    }, [messages.asData?.value.length]);

    // Auto-hide back-to-bottom button after idle period.
    useEffect(() {
      if (!isAtLatestMessages.value) {
        hasLeftLatestMessages.value = true;
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

        // A new row can arrive while the reversed list is outside its cache
        // area. Re-read the local timeline after returning to the latest
        // position. This applies to every return from scrollback, even if the
        // event listener did not observe a new-message notification.
        if (hasLeftLatestMessages.value) {
          hasLeftLatestMessages.value = false;
          unawaited(messagesNotifier.loadInitial(forceRemoteRefresh: false));
        }
        return null;
      }
    }, [isAtLatestMessages.value]);

    final inputKey = useMemoized(() => GlobalKey(), []);

    final redirectSelectedMessages = useCallback((
      String destinationRoomId,
    ) async {
      if (selectedMessageIds.isEmpty) return;

      final allMessages = messages.value ?? const <LocalChatMessage>[];
      final selectedMessages =
          allMessages
              .where((msg) => selectedMessageIds.contains(msg.id))
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
          : 'chatRedirectUnknownRoom'.tr();
      final countPhrase = 'chatRedirectMessagesCount'.plural(
        selectedMessages.length,
      );

      if (!context.mounted) return;

      final shouldProceed = await showConfirmAlert(
        'chatRedirectConfirmBody'.tr(args: [countPhrase, destinationName]),
        'chatRedirectConfirmTitle'.tr(),
      );

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
        showSnackBar('chatRedirectSuccess'.tr(args: [countPhrase]));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) {
          hideLoadingModal(context);
        }
      }
    }, [selectedMessageIds, messages, ref, context, id, chatStateNotifier]);

    final openRedirectSheet = useCallback(() async {
      if (selectedMessageIds.isEmpty) return;
      if (!context.mounted) return;

      final destinationRoomId = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _RedirectRoomSelectorSheet(currentRoomId: id),
      );

      if (destinationRoomId == null || !context.mounted) return;
      await redirectSelectedMessages(destinationRoomId);
    }, [selectedMessageIds, context, id, redirectSelectedMessages]);

    final redirectToCurrentChat = useCallback(() {
      redirectSelectedMessages(id);
    }, [redirectSelectedMessages, id]);

    final uploadAttachment = useCallback((
      int index, {
      String? encryptKey,
    }) async {
      final attachments = ref.read(chatRoomStateProvider(id)).attachments;
      final attachment = attachments[index];
      if (attachment.isOnCloud) return;

      final config = await showAttachmentUploaderModal(
        ref: ref,
        attachments: attachments,
        index: index,
        encryptedUpload: chatRoom.value?.encryptionMode == 3,
      );
      if (config == null) return;

      // Uploads (or joins) the upload and stores the cloud file in the
      // composer; see [ChatRoomStateNotifier.uploadAttachment].
      await chatStateNotifier.uploadAttachment(
        index,
        poolId: config.poolId,
        imageCompressionEnabled: config.imageCompressionEnabled,
        imageCompressionQuality: config.imageCompressionQuality,
        encryptKey: encryptKey,
      );
    }, [chatStateNotifier, ref, context, id, chatRoom.value?.encryptionMode]);

    final onJump = useCallback((String messageId) {
      showThreadSidebar.value = false;
      chatStateNotifier.scrollToMessage(
        messageId: messageId,
        jumpToMessage: messagesNotifier.jumpToMessage,
        hasMessagesBetween: messagesNotifier.hasMessagesBetween,
      );
    }, [chatStateNotifier, messagesNotifier, showThreadSidebar]);

    final jumpAndRevealMessage = useCallback(
      (String messageId) => onJump(messageId),
      [onJump],
    );
    final loadMessageGap = useCallback((MessageLoadGap gap) async {
      final fromOlderSide = chatStateNotifier.captureGapScrollAnchor(gap);
      final nextGap = await messagesNotifier.loadMessagesBetween(
        gap,
        fromOlderSide: fromOlderSide,
      );
      chatStateNotifier.updateMessageLoadGap(nextGap);
    }, [messagesNotifier, chatStateNotifier]);
    final initialMessageJumpHandled = useRef(false);
    useEffect(() {
      final messageId = initialMessageId;
      if (messageId == null ||
          initialMessageJumpHandled.value ||
          messages.value == null) {
        return null;
      }

      initialMessageJumpHandled.value = true;
      Future.microtask(() => jumpAndRevealMessage(messageId));
      return null;
    }, [initialMessageId, messages, jumpAndRevealMessage]);

    final filteredMessages = messages;

    final visibleLastReadAnchorMessageId = (() {
      final anchorTime = savedLastReadAt.value;
      final list = messages.value;
      if (anchorTime == null || list == null || list.isEmpty) return null;
      final anchorIndex = list.indexWhere(
        (m) =>
            m.createdAt.isBefore(anchorTime) ||
            m.createdAt.isAtSameMomentAs(anchorTime),
      );
      if (anchorIndex == -1) return null;
      if (anchorIndex > 0) return list[anchorIndex].id;
      return null;
    })();
    final effectiveLastReadAnchorMessageId =
        (isAtLatestMessages.value ||
            visibleLastReadAnchorMessageId == dismissedLastReadAnchorMessageId)
        ? null
        : visibleLastReadAnchorMessageId;

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
    final currentRoom = chatRoom.value;
    final currentIdentity = chatIdentity.value;

    final mainContent = Stack(
      children: [
        AppScaffold(
          // The pill floats over the timeline; the column below clears it.
          appBarOverContent: !isSelectionMode,
          appBar: isSelectionMode
              ? AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'exitSelectionMode'.tr(),
                    onPressed: chatStateNotifier.exitSelectionMode,
                  ),
                  automaticallyImplyLeading: false,
                  title: Text(
                    selectedMessageIds.isEmpty
                        ? 'chatSelectMessages'.tr()
                        : 'selectedCount'.tr(
                            args: [selectedMessageIds.length.toString()],
                          ),
                  ),
                  actions: const [SizedBox(width: 8)],
                )
              : _RoomPillAppBar(
                  roomId: id,
                  statusTop: MediaQuery.paddingOf(context).top,
                  room: chatRoom.value,
                  onOpenDetail: () async {
                    final result = await context.router.push(
                      ChatDetailRoute(id: id),
                    );
                    if (result is SearchMessagesResult &&
                        messages.value != null) {
                      jumpAndRevealMessage(result.messageId);
                    }
                  },
                ),
          // The timeline owns the whole page: the pill header, the banners
          // and the composer are painted over it, and the list pads itself
          // clear of both chrome bands. At rest nothing hides behind chrome;
          // while scrolling, rows slide under it.
          body: Stack(
            children: [
              // The timeline owns the whole page and paints first; every
              // other band below is chrome floating over it.
              Positioned.fill(
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
                                  chatEventMessageMode ==
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
                                onLoadMessageGap: loadMessageGap,
                                topInset: topChromeHeight.value,
                                bottomInset: composerHeight.value,
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
                      top: topChromeHeight.value + 12,
                      right: 12,
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: AnimatedOpacity(
                          opacity: effectiveLastReadAnchorMessageId != null
                              ? 1.0
                              : 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: AnimatedScale(
                            scale: effectiveLastReadAnchorMessageId != null
                                ? 1.0
                                : 0.8,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: FloatingActionButton.small(
                              heroTag: 'followBack',
                              onPressed:
                                  effectiveLastReadAnchorMessageId != null
                                  ? jumpToLastReadAnchor
                                  : null,
                              elevation:
                                  effectiveLastReadAnchorMessageId != null
                                  ? 2
                                  : 0,
                              backgroundColor:
                                  effectiveLastReadAnchorMessageId != null
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
                      bottom: composerHeight.value + 16,
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
                        top: topChromeHeight.value,
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
              // Floating header band: the pill's own gap, then any banner the
              // room is showing. Measured, so the timeline's padding tracks
              // the banners coming and going.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: MeasureHeight(
                  onHeight: (height) => topChromeHeight.value = height,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Transparent gap for the floating pill. The screen's
                      // own context only carries the status-bar inset — the
                      // scaffold injects its reserved app-bar band into the
                      // body subtree — so the pill's full band comes from
                      // [_roomHeaderBand], the same helper the non-overlay
                      // branches use. Ignored for pointers: the gap only
                      // clears the pill, so drags must fall through to the
                      // timeline behind it.
                      if (!isSelectionMode)
                        IgnorePointer(child: _roomHeaderBand(context)),
                      if (currentRoom != null &&
                          currentIdentity != null &&
                          currentRoom.type == 1 &&
                          currentIdentity.joinedAt != null &&
                          currentIdentity.confirmedAt == null)
                        _DirectMessageConfirmationBanner(
                          chatRoom: currentRoom,
                          identity: currentIdentity,
                          isBlocked: currentIdentity.leaveAt != null,
                          onBlocked: () async {
                            if (context.mounted) {
                              context.router.maybePop();
                            }
                          },
                        ),
                      if (pinnedPins.value.isNotEmpty)
                        PinnedMessagesBar(
                          pins: pinnedPins.value,
                          isCollapsed: isPinnedBarCollapsed.value,
                          onToggleCollapse: () {
                            isPinnedBarCollapsed.value =
                                !isPinnedBarCollapsed.value;
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
                          fetchMessageById: messagesNotifier.fetchMessageById,
                        ),
                    ],
                  ),
                ),
              ),
              // Floating composer band. It is measured for the same reason
              // the header is: the list pads its newest end by exactly this
              // height, so the latest message rests just above the composer
              // even as the composer grows with attachments or wraps to five
              // lines.
              // Bottom-only offset on purpose: it leaves the band's height
              // free, so the band shrink-wraps the composer. Filling the
              // Stack instead would hand the composer a tight height and
              // stretch it to the whole page.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MeasureHeight(
                  onHeight: (height) => composerHeight.value = height,
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: isSelectionMode
                          ? RoomSelectionMode(
                              key: const ValueKey('selection-bar'),
                              visible: true,
                              selectedCount: selectedMessageIds.length,
                              onClose: chatStateNotifier.exitSelectionMode,
                              onRedirect: openRedirectSheet,
                              onRedirectToCurrentChat: redirectToCurrentChat,
                            )
                          : chatRoom.when(
                              data: (room) => room != null
                                  ? KeyedSubtree(
                                      key: const ValueKey('chat-input'),
                                      child: Consumer(
                                        builder: (context, ref, _) {
                                          final inputState = ref.watch(
                                            chatRoomStateProvider(id).select(
                                              (state) => (
                                                attachments: state.attachments,
                                                attachmentProgress:
                                                    state.attachmentProgress,
                                                editingTo:
                                                    state.messageEditingTo,
                                                replyingTo:
                                                    state.messageReplyingTo,
                                                forwardingTo:
                                                    state.messageForwardingTo,
                                                embeds: state.embeds,
                                              ),
                                            ),
                                          );

                                          return ChatInput(
                                            key: inputKey,
                                            messageController: chatStateNotifier
                                                .messageController,
                                            chatRoom: room,
                                            onSend:
                                                chatStateNotifier.sendMessage,
                                            onClear: () {
                                              if (inputState.editingTo !=
                                                  null) {
                                                chatStateNotifier
                                                    .clearAttachmentsOnly();
                                              }
                                              chatStateNotifier.setEditingTo(
                                                null,
                                              );
                                              chatStateNotifier.setReplyingTo(
                                                null,
                                              );
                                              chatStateNotifier.setForwardingTo(
                                                null,
                                              );
                                              chatStateNotifier.clearInput();
                                            },
                                            messageEditingTo:
                                                inputState.editingTo,
                                            messageReplyingTo:
                                                inputState.replyingTo,
                                            messageForwardingTo:
                                                inputState.forwardingTo,
                                            embeds: inputState.embeds,
                                            onEmbedsChanged:
                                                chatStateNotifier.setEmbeds,
                                            onPickFile: (isPhoto) {
                                              if (isPhoto) {
                                                chatStateNotifier.pickPhotos();
                                              } else {
                                                chatStateNotifier.pickVideos();
                                              }
                                            },
                                            onPickAudio:
                                                chatStateNotifier.pickAudio,
                                            onPickGeneralFile:
                                                chatStateNotifier.pickFiles,
                                            onLinkAttachment: () =>
                                                chatStateNotifier
                                                    .linkAttachment(context),
                                            attachments: inputState.attachments,
                                            onUploadAttachment:
                                                uploadAttachment,
                                            onCancelUploadAttachment: (index) =>
                                                chatStateNotifier
                                                    .cancelAttachmentUpload(
                                                      index,
                                                    ),
                                            onDeleteAttachment: (index) async {
                                              final attachment =
                                                  inputState.attachments[index];
                                              // Stop the upload that is running for
                                              // this attachment, if any.
                                              chatStateNotifier
                                                  .cancelAttachmentUpload(
                                                    index,
                                                  );
                                              if (attachment.isOnCloud &&
                                                  !attachment.isLink) {
                                                final client = ref.read(
                                                  apiClientProvider,
                                                );
                                                await client.delete(
                                                  '/fs/files/${attachment.data.id}',
                                                );
                                              }
                                              final clone = List.of(
                                                inputState.attachments,
                                              );
                                              clone.removeAt(index);
                                              chatStateNotifier
                                                  .updateAttachments(clone);
                                            },
                                            onMoveAttachment: (idx, delta) {
                                              if (idx + delta < 0 ||
                                                  idx + delta >=
                                                      inputState
                                                          .attachments
                                                          .length) {
                                                return;
                                              }
                                              final clone = List.of(
                                                inputState.attachments,
                                              );
                                              clone.insert(
                                                idx + delta,
                                                clone.removeAt(idx),
                                              );
                                              chatStateNotifier
                                                  .updateAttachments(clone);
                                            },
                                            onAttachmentsChanged:
                                                chatStateNotifier
                                                    .updateAttachments,
                                            attachmentProgress:
                                                inputState.attachmentProgress,
                                          );
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('no-input'),
                                    ),
                              error: (_, _) => const SizedBox.shrink(
                                key: ValueKey('input-error'),
                              ),
                              loading: () => const SizedBox.shrink(
                                key: ValueKey('input-loading'),
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    final room = chatRoom.value;

    return ResponsiveSidebar(
      showSidebar: showThreadSidebar,
      mainContent: mainContent,
      sidebarContent: _buildThreadSidebar(
        openedThreadTarget.value,
        room,
        onJump,
      ),
      drawerBuilder: (sheetContext) {
        return SheetScaffold(
          showHeader: true,
          titleText: 'thread'.tr(),
          onClose: () => Navigator.of(sheetContext).pop(),
          child: _buildThreadSidebar(
            openedThreadTarget.value,
            room,
            onJump,
            hideHeader: true,
          ),
        );
      },
      sidebarWidth: 420,
    );
  }
}

/// Builds the thread sidebar panel widget. Extracted so both the wide-screen
/// sidebar and the narrow-screen bottom sheet can create a fresh instance from
/// the latest [openedThreadTarget] value at render time.
Widget _buildThreadSidebar(
  SnChatMessage? threadTarget,
  SnChatRoom? room,
  void Function(String) onJump, {
  VoidCallback? onClose,
  bool hideHeader = false,
}) {
  if (threadTarget == null || room == null) {
    return const SizedBox.shrink();
  }
  return ChatThreadPanel(
    roomId: room.id,
    chatRoom: room,
    root: threadTarget,
    onJump: onJump,
    onClose: onClose,
    hideHeader: hideHeader,
  );
}

/// Reserves the band the floating header paints into.
///
/// [PillAppBar] draws a capsule over the top of the page rather than taking a
/// solid row, so the scaffold is told to let content run under it and every
/// body starts with this gap instead. It is the status-bar inset plus the
/// bar's own height — exactly [PillAppBar.preferredSize], so the pill and the
/// content it clears can never disagree about where the bar ends.
Widget _roomHeaderBand(BuildContext context) =>
    SizedBox(height: MediaQuery.paddingOf(context).top + kPillAppBarHeight);

/// The room's floating header.
///
/// The pill carries the room identity and its two actions on the left, and
/// the room's status — online members, or a placeholder while the room is
/// loading — on the right. While work is in flight the pill's own border is
/// the spinner ([PillAppBar.loading]), so the room screen has no separate
/// progress chrome: the status line just says what is happening.
///
/// Presence, sync and summary updates are watched here rather than in the
/// screen, so a change in any of them repaints the bar alone. In busy rooms
/// the online count moves independently of the timeline, and rebuilding the
/// whole screen for it would do list work on every presence tick.
class _RoomPillAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String roomId;

  /// The room, when it has already loaded. Null renders the header skeleton:
  /// the same pill with the same height, so the page below is never re-laid
  /// out when the room arrives.
  final SnChatRoom? room;

  /// Opens the room's detail page. The pill only offers the action once it
  /// knows which room it is describing.
  final VoidCallback? onOpenDetail;

  /// Status-bar inset. Taken at the call site because the scaffold needs the
  /// bar's [preferredSize] before it can lay the bar out.
  final double statusTop;

  const _RoomPillAppBar({
    required this.roomId,
    required this.statusTop,
    this.room,
    this.onOpenDetail,
  });

  @override
  Size get preferredSize => Size.fromHeight(statusTop + kPillAppBarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineCount = ref.watch(chatOnlineCountProvider(roomId));
    final busy = watchRoomHeaderState(ref);
    final currentRoom = room;

    return PillAppBar(
      statusTop: statusTop,
      loading: busy.loading,
      child: Row(
        children: [
          const _ChatRoomLeading(),
          const Gap(SolSpace.sm),
          Expanded(
            child: currentRoom == null
                ? const SizedBox.shrink()
                : RoomAppBar(
                    room: currentRoom,
                    onlineStatus: onlineCount.value,
                    statusLine: busy.status,
                  ),
          ),
          if (currentRoom != null) ...[
            AudioCallButton(room: currentRoom),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: onOpenDetail,
            ),
          ],
        ],
      ),
    );
  }
}

class _RedirectRoomSelectorSheet extends HookConsumerWidget {
  final String currentRoomId;

  const _RedirectRoomSelectorSheet({required this.currentRoomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomJoinedProvider);
    final summaries = ref.watch(chatSummaryProvider);
    final filter = useState(ChatRoomPickerFilter.all);
    final query = useState('');

    return SheetScaffold(
      titleText: 'chatRedirectSelectRoom'.tr(),
      child: roomsAsync.when(
        data: (rooms) {
          final summariesData = summaries.whenData((data) => data).value ?? {};
          final filteredRooms = sortChatRoomsByActivity(rooms, summariesData)
              .where(
                (room) =>
                    room.encryptionMode == 0 &&
                    (filter.value == ChatRoomPickerFilter.all ||
                        (filter.value == ChatRoomPickerFilter.direct &&
                            room.type == 1) ||
                        (filter.value == ChatRoomPickerFilter.group &&
                            room.type != 1)) &&
                    chatRoomMatchesSearch(room, query.value),
              )
              .toList();

          if (rooms.where((room) => room.encryptionMode == 0).isEmpty) {
            return EmptyState(
              compact: true,
              icon: Icons.forum_outlined,
              title: 'noChatRoomsAvailable'.tr(),
            );
          }

          return ListView(
            children: [
              ChatRoomPickerSearchBar(
                onChanged: (value) => query.value = value,
              ),
              ChatRoomPickerFilterBar(
                selected: filter.value,
                onSelected: (value) => filter.value = value,
              ),
              if (filteredRooms.isEmpty)
                EmptyState(
                  compact: true,
                  icon: Icons.search_off_rounded,
                  title: 'noResultsFound'.tr(),
                )
              else
                _RedirectRoomGroup(
                  rooms: filteredRooms,
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
  final List<SnChatRoom> rooms;
  final String currentRoomId;

  const _RedirectRoomGroup({required this.rooms, required this.currentRoomId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final room in rooms)
          ChatRoomListTile(
            room: room,
            isDirect: room.type == 1,
            selected: room.id == currentRoomId,
            subtitle: room.id == currentRoomId
                ? Text(
                    'chatRedirectCurrentRoom'.tr(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
            // The room being read is not a destination: leave the row inert
            // instead of bouncing the reader back to where they started.
            onTap: room.id == currentRoomId
                ? null
                : () => Navigator.of(context).pop(room.id),
          ),
      ],
    );
  }
}

/// AppBar leading for this room: the router's own [AutoLeadingButton] when it
/// can pop (or has a drawer), falling back to a home button when there is
/// nothing to pop — e.g. the room was opened directly from a deep link.
class _ChatRoomLeading extends StatelessWidget {
  const _ChatRoomLeading();

  @override
  Widget build(BuildContext context) {
    return AutoLeadingButton.builder(
      builder: (context, leading) =>
          leading ??
          IconButton(
            onPressed: () {
              context.router.navigate(const ChatListRoute());
            },
            icon: const Icon(Symbols.home),
          ),
    );
  }
}
