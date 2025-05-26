import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/call.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/chat/call_participant_tile.dart';
import 'package:styled_widget/styled_widget.dart';

class CallControlsBar extends HookConsumerWidget {
  const CallControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callNotifierProvider);
    final callNotifier = ref.read(callNotifierProvider.notifier);

    final userInfo = ref.watch(userInfoProvider);

    final actionButtonStyle = ButtonStyle(
      minimumSize: const MaterialStatePropertyAll(Size(24, 24)),
    );

    return Card(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    if (callNotifier.localParticipant == null) {
                      return CircularProgressIndicator().center();
                    }
                    return SizedBox(
                      width: 40,
                      height: 40,
                      child:
                          SpeakingRippleAvatar(
                            isSpeaking:
                                callNotifier.localParticipant!.isSpeaking,
                            audioLevel:
                                callNotifier.localParticipant!.audioLevel,
                            pictureId: userInfo.value?.profile.pictureId,
                            size: 36,
                          ).center(),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              callState.isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
            ),
            onPressed: () {
              callNotifier.toggleMicrophone();
            },
            style: actionButtonStyle,
          ),
          IconButton(
            icon: Icon(
              callState.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
            ),
            onPressed: () {
              callNotifier.toggleCamera();
            },
            style: actionButtonStyle,
          ),
          IconButton(
            icon: Icon(
              callState.isScreenSharing
                  ? Icons.stop_screen_share
                  : Icons.screen_share,
            ),
            onPressed: () {
              callNotifier.toggleScreenShare();
            },
            style: actionButtonStyle,
          ),
        ],
      ).padding(all: 16),
    );
  }
}

class CallOverlayBar extends HookConsumerWidget {
  const CallOverlayBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callNotifierProvider);
    final callNotifier = ref.read(callNotifierProvider.notifier);
    // Only show if connected and not on the call screen
    if (!callState.isConnected) return const SizedBox.shrink();

    final lastSpeaker =
        callNotifier.participants
                .where(
                  (element) => element.remoteParticipant.lastSpokeAt != null,
                )
                .isEmpty
            ? callNotifier.participants.first
            : callNotifier.participants
                .where(
                  (element) => element.remoteParticipant.lastSpokeAt != null,
                )
                .fold(
                  callNotifier.participants.first,
                  (value, element) =>
                      element.remoteParticipant.lastSpokeAt != null &&
                              (value.remoteParticipant.lastSpokeAt == null ||
                                  element.remoteParticipant.lastSpokeAt!
                                          .compareTo(
                                            value
                                                .remoteParticipant
                                                .lastSpokeAt!,
                                          ) >
                                      0)
                          ? element
                          : value,
                );

    final actionButtonStyle = ButtonStyle(
      minimumSize: const MaterialStatePropertyAll(Size(24, 24)),
    );

    return GestureDetector(
      child: Card(
        margin: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      if (callNotifier.localParticipant == null) {
                        return CircularProgressIndicator().center();
                      }
                      return SizedBox(
                        width: 40,
                        height: 40,
                        child:
                            SpeakingRippleAvatar(
                              isSpeaking: lastSpeaker.isSpeaking,
                              audioLevel:
                                  lastSpeaker.remoteParticipant.audioLevel,
                              pictureId:
                                  lastSpeaker
                                      .participant
                                      .profile
                                      ?.account
                                      .profile
                                      .pictureId,
                              size: 36,
                            ).center(),
                      );
                    },
                  ),
                  const Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastSpeaker.participant.profile?.account.nick ??
                            'unknown'.tr(),
                      ).bold(),
                      Text(
                        formatDuration(callState.duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                callState.isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
              ),
              onPressed: () {
                callNotifier.toggleMicrophone();
              },
              style: actionButtonStyle,
            ),
            IconButton(
              icon: Icon(
                callState.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              ),
              onPressed: () {
                callNotifier.toggleCamera();
              },
              style: actionButtonStyle,
            ),
            IconButton(
              icon: Icon(
                callState.isScreenSharing
                    ? Icons.stop_screen_share
                    : Icons.screen_share,
              ),
              onPressed: () {
                callNotifier.toggleScreenShare();
              },
              style: actionButtonStyle,
            ),
          ],
        ).padding(all: 16),
      ),
      onTap: () {
        context.router.push(CallRoute(roomId: callNotifier.roomId!));
      },
    );
  }
}
