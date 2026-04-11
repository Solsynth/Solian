import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/chat/widgets/call_content.dart';
import 'package:island/chat/widgets/call_overlay.dart';
import 'package:island/chat/widgets/call_participant_tile.dart';
import 'package:island/shared/widgets/alert.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class CallScreen extends HookConsumerWidget {
  final SnChatRoom room;
  const CallScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ongoingCall = ref.watch(ongoingCallProvider(room.id));
    final callState = ref.watch(callProvider);
    ref.watch(callProvider.select((state) => state.participantSyncVersion));
    final callNotifier = ref.read(callProvider.notifier);
    final controlsVisible = useState(true);

    useEffect(() {
      Logger.root.info('[Call] Joining the call...');
      callNotifier.joinRoom(room).catchError((_) {
        showConfirmAlert(
          'Seems there already has a call connected, do you want override it?',
          'Call already connected',
        ).then((value) {
          if (value != true) return;
          Logger.root.info('[Call] Joining the call... with overrides');
          callNotifier.disconnect();
          callNotifier.dispose();
          callNotifier.joinRoom(room);
        });
      });
      return null;
    }, []);

    useEffect(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      return null;
    }, []);

    final allAudioOnly = callNotifier.participants.every(
      (p) =>
          !(p.hasVideo &&
              p.remoteParticipant.trackPublications.values.any(
                (pub) =>
                    pub.track != null &&
                    pub.kind == TrackType.VIDEO &&
                    !pub.muted &&
                    !pub.isDisposed,
              )),
    );

    final roomTitle = ongoingCall.value?.room.name ?? room.name ?? 'call'.tr();
    final statusText = callState.isConnected
        ? formatDuration(callState.duration)
        : (switch (callNotifier.room?.connectionState) {
            ConnectionState.connected => 'connected',
            ConnectionState.connecting => 'connecting',
            ConnectionState.reconnecting => 'reconnecting',
            _ => 'disconnected',
          }).tr();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1117),
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controlsVisible.value = !controlsVisible.value,
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
              : Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 6),
                        Expanded(
                          child: CallContent(
                            outerMaxHeight: MediaQuery.of(context).size.height,
                          ),
                        ),
                      ],
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      top: controlsVisible.value ? 0 : -96,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
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
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
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
                            if (!allAudioOnly)
                              SizedBox(
                                height: 34,
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    for (final live
                                        in callNotifier.participants)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: SpeakingRippleAvatar(
                                          live: live,
                                          size: 28,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      bottom: controlsVisible.value
                          ? MediaQuery.of(context).padding.bottom + 8
                          : -(MediaQuery.of(context).padding.bottom + 140),
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                          child: CallControlsBar(popOnLeaves: true),
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
