import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/native_call_bridge.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/chat/widgets/call_content.dart';
import 'package:island/chat/widgets/call_overlay.dart';
import 'package:island/chat/widgets/chat_member_list_tile.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
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
  const CallScreen({super.key, required this.room, this.cameraEnabled = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final ongoingCall = ref.watch(ongoingCallProvider(room.id));
    final roomState = ref.watch(chatRoomProvider(room.id));
    final callState = ref.watch(callProvider);
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    ref.watch(callProvider.select((state) => state.participantSyncVersion));
    final callNotifier = ref.read(callProvider.notifier);
    final controlsVisible = useState(true);

    useEffect(() {
      // Mark CallScreen as active and hide overlay
      setCallScreenActive(true);
      hideCallOverlay();

      Logger.root.info('[Call] Joining the call...');
      callNotifier.joinRoom(room, cameraEnabled: cameraEnabled).catchError((_) {
        showConfirmAlert(
          'Seems there already has a call connected, do you want override it?',
          'Call already connected',
        ).then((value) {
          if (value != true) return;
          Logger.root.info('[Call] Joining the call... with overrides');
          callNotifier.disconnect();
          callNotifier.dispose();
          callNotifier.joinRoom(room, cameraEnabled: cameraEnabled);
        });
      });
      return () {
        // Mark CallScreen as inactive when leaving
        setCallScreenActive(false);
      };
    }, []);

    useEffect(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      return null;
    }, []);

    useEffect(() {
      if (!isNativeCallAvailable) return null;
      final sub = ref.listenManual(nativeCallBridgeProvider, (previous, current) {
        final nativeEnded = current.systemEndedAt != null &&
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
        try {
          final apiClient = ref.read(apiClientProvider);
          final resp = await apiClient.get(
            '/messager/chat/${room.id}/members',
            queryParameters: {'take': '100', 'withStatus': 'true'},
          );
          members = (resp.data as List)
              .map((e) => SnChatMember.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (_) {}
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
        builder: (ctx) => SheetScaffold(
          titleText: 'inviteToCall'.tr(),
          heightFactor: 0.6,
          child: ListView.separated(
            itemCount: inviteCandidates.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final m = inviteCandidates[i];
              return ChatMemberListTile(
                member: m,
                trailing: IconButton(
                  icon: const Icon(Symbols.call),
                  tooltip: 'inviteToCall'.tr(),
                  onPressed: () => Navigator.pop(ctx, m),
                ),
                onTap: () => Navigator.pop(ctx, m),
              );
            },
          ),
        ),
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

    return Scaffold(
      backgroundColor: const Color(0xFF0E1117),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controlsVisible.value = !controlsVisible.value,
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: callState.error != null
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Symbols.error_outline,
                              size: 48,
                              color: Colors.white70,
                            ),
                            const Gap(8),
                            Text(
                              callState.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const Gap(10),
                            TextButton(
                              onPressed: () {
                                callNotifier.disconnect();
                                callNotifier.dispose();
                                callNotifier.joinRoom(room);
                              },
                              child: Text('retry').tr(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 6),
                        Expanded(
                          child: CallContent(
                            outerMaxHeight: MediaQuery.of(context).size.height,
                          ),
                        ),
                      ],
                    ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              top: controlsVisible.value ? 0 : -(mediaQuery.padding.top + 96),
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  10,
                  mediaQuery.padding.top + 6,
                  10,
                  10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.64),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.router.maybePop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            roomTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: callNotifier.toggleViewMode,
                      tooltip: callState.viewMode == ViewMode.grid
                          ? 'Stage view'
                          : 'Grid view',
                      icon: Icon(
                        callState.viewMode == ViewMode.grid
                            ? Symbols.view_list
                            : Symbols.grid_view,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    IconButton(
                      onPressed: inviteToCall,
                      tooltip: 'inviteToCall'.tr(),
                      icon: const Icon(
                        Symbols.person_add,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: mediaQuery.padding.top + 68,
              left: 16,
              right: 16,
              child: IgnorePointer(
                ignoring: !showReconnectBanner,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: showReconnectBanner ? 1 : 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            callState.reconnectAttempt > 0
                                ? 'Reconnecting... (${callState.reconnectAttempt}/${CallNotifier.maxReconnectAttempts})'
                                : 'Reconnecting...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              bottom: controlsVisible.value
                  ? 0
                  : -(mediaQuery.padding.bottom + 140),
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: mediaQuery.padding.bottom + 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.64),
                      Colors.transparent,
                    ],
                  ),
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
    );
  }
}
