import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart' hide ConnectionState;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/native_call_bridge.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/chat/widgets/call_chrome.dart';
import 'package:island/chat/widgets/call_content.dart';
import 'package:island/chat/widgets/call_invite_sheet.dart';
import 'package:island/chat/widgets/call_overlay.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

String _normalizedCallIdentity(String? value) =>
    value?.trim().toLowerCase() ?? '';

bool _isMemberAlreadyInCall(
  SnChatMember member,
  Iterable<CallParticipantLive> participants,
) {
  final activeKeys = <String>{
    for (final live in participants) ...[
      _normalizedCallIdentity(live.participant.identity),
      _normalizedCallIdentity(live.participant.name),
    ],
  }..remove('');

  return activeKeys.contains(_normalizedCallIdentity(member.account.name)) ||
      activeKeys.contains(_normalizedCallIdentity(member.account.nick)) ||
      activeKeys.contains(_normalizedCallIdentity(member.nick));
}

@RoutePage()
class CallScreen extends HookConsumerWidget {
  final SnChatRoom room;
  final bool cameraEnabled;
  final bool microphoneEnabled;
  const CallScreen({
    super.key,
    required this.room,
    this.cameraEnabled = false,
    this.microphoneEnabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final ongoingCall = ref.watch(ongoingCallProvider(room.id));
    final roomState = ref.watch(chatRoomProvider(room.id));
    final callState = ref.watch(callProvider);
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    ref.watch(callProvider.select((state) => state.participantSyncVersion));
    final callNotifier = ref.read(callProvider.notifier);
    void restoreCallOverlay() {
      setCallScreenActive(false);
      final currentState = ref.read(callProvider);
      if (callNotifier.roomId == room.id &&
          (currentState.isConnected || currentState.isReconnecting)) {
        showCallOverlay(room);
      }
    }

    final controlsVisible = useState(true);
    // Both bands are derived from the chrome that paints into them
    // ([kCallHeaderBandHeight], [kCallControlsHeight]) rather than guessed, so
    // the stage clears the chrome exactly and nothing hides behind it at rest.
    final statusTop = mediaQuery.padding.top;
    final topOverlayInset = controlsVisible.value
        ? statusTop + kCallHeaderBandHeight
        : 0.0;
    final bottomOverlayInset = controlsVisible.value
        ? mediaQuery.padding.bottom + kCallControlsHeight
        : 0.0;
    final toolParticipants = callNotifier.participants
        .where(isToolCallParticipant)
        .toList();

    useEffect(() {
      // Mark CallScreen as active and hide overlay
      setCallScreenActive(true);
      hideCallOverlay();

      // Re-entering from the floating overlay: a session for this room may
      // already be live (connected, connecting or reconnecting). Attach to it
      // instead of negotiating a new join, which would surface a spurious
      // 'Call already connected' override prompt.
      final lkRoom = callNotifier.room;
      final alreadyAttached =
          callNotifier.roomId == room.id &&
          lkRoom != null &&
          !lkRoom.isDisposed &&
          lkRoom.connectionState != ConnectionState.disconnected;
      if (alreadyAttached) {
        Logger.root.info(
          '[Call] Session for ${room.id} is already active, attaching',
        );
        return restoreCallOverlay;
      }

      Logger.root.info('[Call] Joining the call...');
      callNotifier
          .joinRoom(
            room,
            cameraEnabled: cameraEnabled,
            microphoneEnabled: microphoneEnabled,
          )
          .catchError((_) {
            showConfirmAlert(
              'Seems there already has a call connected, do you want override it?',
              'Call already connected',
            ).then((value) {
              if (value != true) return;
              Logger.root.info('[Call] Joining the call... with overrides');
              callNotifier.disconnect();
              callNotifier.dispose();
              callNotifier.joinRoom(
                room,
                cameraEnabled: cameraEnabled,
                microphoneEnabled: microphoneEnabled,
              );
            });
          });
      return restoreCallOverlay;
    }, []);

    useEffect(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      return null;
    }, []);

    useEffect(() {
      if (!isNativeCallAvailable) return null;
      final sub = ref.listenManual(nativeCallBridgeProvider, (
        previous,
        current,
      ) {
        final nativeEnded =
            current.systemEndedAt != null &&
            current.systemEndedAt != previous?.systemEndedAt;
        if (!nativeEnded || !context.mounted) return;
        Logger.root.info('[Call] Native/system call ended, leaving CallScreen');
        unawaited(() async {
          await callNotifier.disconnect();
          if (context.mounted) await context.router.maybePop();
        }());
      });
      return sub.close;
    }, []);

    // Resolve room title: prefer explicit name, then other DM member's name
    final roomForTitle = roomState.value ?? room;
    final roomTitle =
        ongoingCall.value?.room.name ??
        roomForTitle.name ??
        (roomForTitle.members ?? [])
            .where((m) => m.accountId != currentUserId)
            .map((m) => m.nick ?? m.account.nick)
            .firstOrNull ??
        'call'.tr();
    // Prefer callState over livekit room state to avoid stale 'connecting'
    final statusText = callState.isConnected
        ? formatDuration(callState.duration)
        : callState.isReconnecting
        ? 'reconnecting'.tr()
        : callState.hasJoined
        ? formatDuration(callState.duration)
        : (switch (callNotifier.room?.connectionState) {
            ConnectionState.connected => 'connected',
            ConnectionState.connecting => 'connecting',
            ConnectionState.reconnecting => 'reconnecting',
            _ => 'disconnected',
          }).tr();
    final showReconnectBanner =
        callState.isReconnecting && callState.error == null;
    Future<void> inviteToCall() async {
      final currentRoom = roomState.value ?? room;
      var members = currentRoom.members ?? const <SnChatMember>[];

      // Fetch members if not available
      if (members.isEmpty) {
        showLoadingModal(context);
        try {
          final apiClient = ref.read(apiClientProvider);
          final resp = await apiClient.get(
            '/messager/chat/${room.id}/members',
            queryParameters: {'take': '100', 'withStatus': 'true'},
          );
          members = (resp.data as List)
              .map((e) => SnChatMember.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (err) {
          showErrorAlert(err);
        } finally {
          if (context.mounted) hideLoadingModal(context);
        }
      }

      final inviteCandidates = members.where((member) {
        if (member.joinedAt == null) return false;
        if (member.accountId == currentUserId) return false;
        return !_isMemberAlreadyInCall(member, callNotifier.participants);
      }).toList();

      if (inviteCandidates.isEmpty) {
        showErrorAlert('noMembersToInvite'.tr());
        return;
      }

      if (!context.mounted) return;
      final target = await showModalBottomSheet<SnChatMember>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (ctx) => CallInviteSheet(candidates: inviteCandidates),
      );
      if (target == null) return;

      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(
          '/messager/chat/realtime/${room.id}/invite/${target.accountId}',
        );
        showSnackBar(
          'inviteSentTo'.tr(args: [target.nick ?? target.account.nick]),
        );
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void retryJoin() {
      callNotifier.disconnect();
      callNotifier.dispose();
      callNotifier.joinRoom(
        room,
        cameraEnabled: cameraEnabled,
        microphoneEnabled: microphoneEnabled,
      );
    }

    final theme = Theme.of(context);
    final stageColor = theme.colorScheme.surface;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The status bar follows the stage it sits on, not a fixed light style:
      // the stage is the app's own surface, so it can be a light page.
      value: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: stageColor,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controlsVisible.value = !controlsVisible.value,
          child: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(
                    top: topOverlayInset,
                    bottom: bottomOverlayInset,
                  ),
                  child: callState.error != null
                      ? _CallErrorState(
                          error: callState.error!,
                          onRetry: retryJoin,
                        )
                      : CallContent(outerMaxHeight: mediaQuery.size.height),
                ),
              ),
              // Identity and call-level actions float over the stage as a
              // liquid glass capsule matching the app's pill header surface.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                top: controlsVisible.value
                    ? 0
                    : -(statusTop + kCallHeaderBandHeight),
                left: 0,
                right: 0,
                child: CallHeaderPill(
                  statusTop: statusTop,
                  title: roomTitle,
                  status: statusText,
                  onBack: () => context.router.maybePop(),
                  actions: [
                    IconButton(
                      onPressed: callNotifier.toggleViewMode,
                      tooltip: callState.viewMode == ViewMode.grid
                          ? 'Stage view'
                          : 'Grid view',
                      icon: Icon(
                        callState.viewMode == ViewMode.grid
                            ? Symbols.view_list
                            : Symbols.grid_view,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (toolParticipants.isNotEmpty)
                      IconButton(
                        onPressed: () => showToolParticipantsSheet(
                          context,
                          toolParticipants,
                        ),
                        tooltip: 'toolsInCall'.tr(),
                        icon: Badge.count(
                          count: toolParticipants.length,
                          child: const Icon(Symbols.terminal, size: 20),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    IconButton(
                      onPressed: inviteToCall,
                      tooltip: 'inviteToCall'.tr(),
                      icon: const Icon(Symbols.person_add, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              // Reconnection is a state of the session, not of the chrome: the
              // banner stays put while the controls are hidden so the reason
              // for the silence is always visible.
              Positioned(
                top: statusTop + kCallHeaderBandHeight + SolSpace.sm,
                left: kCallChromeGutter,
                right: kCallChromeGutter,
                child: IgnorePointer(
                  ignoring: !showReconnectBanner,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: showReconnectBanner ? 1 : 0,
                    child: Center(
                      child: CallStatusPill(
                        loading: true,
                        message: callState.reconnectAttempt > 0
                            ? 'Reconnecting... (${callState.reconnectAttempt}/${CallNotifier.maxReconnectAttempts})'
                            : 'Reconnecting...',
                      ),
                    ),
                  ),
                ),
              ),
              // The controls are not wrapped in a surface: they are the only
              // actions on the page and the tiles already carry their own
              // contrast, so a capsule around them would be a second frame
              // around the same row.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                bottom: controlsVisible.value
                    ? 0
                    : -(mediaQuery.padding.bottom + kCallControlsHeight),
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: kCallChromeGutter,
                    right: kCallChromeGutter,
                    top: SolSpace.md,
                    bottom: mediaQuery.padding.bottom + SolSpace.lg,
                  ),
                  child: const Center(
                    child: CallControlsBar(
                      popOnLeaves: true,
                      showViewToggle: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The call's failure placeholder.
///
/// Shown in the stage's own area, so the header pill keeps describing which
/// call failed and the retry stays the single next action.
class _CallErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _CallErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SolSpace.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.error_outline, size: 40, color: colorScheme.error),
              const Gap(SolSpace.md),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(SolSpace.lg),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Symbols.refresh),
                label: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
