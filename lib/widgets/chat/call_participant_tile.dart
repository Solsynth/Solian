import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/chat/call.dart';
import 'package:island/screens/account/profile.dart';
import 'package:island/widgets/chat/call_participant_card.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class SpeakingRippleAvatar extends HookConsumerWidget {
  final CallParticipantLive live;
  final double size;

  const SpeakingRippleAvatar({super.key, required this.live, this.size = 96});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(live.participant.identity));

    final avatarRadius = size / 2;
    final clampedLevel = live.remoteParticipant.audioLevel.clamp(0.0, 1.0);
    final rippleRadius = avatarRadius + clampedLevel * (size * 0.333);
    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: avatarRadius,
          end: live.remoteParticipant.isSpeaking ? rippleRadius : avatarRadius,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        builder: (context, animatedRadius, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (live.remoteParticipant.isSpeaking)
                Container(
                  width: animatedRadius * 2,
                  height: animatedRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.75 + 0.25 * clampedLevel),
                  ),
                ),
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: account.when(
                  data:
                      (value) => CallParticipantGestureDetector(
                        participant: live,
                        child: ProfilePictureWidget(
                          file: value.profile.picture,
                          radius: size / 2,
                        ),
                      ),
                  error:
                      (_, _) => CircleAvatar(
                        radius: size / 2,
                        child: const Icon(Symbols.person_remove),
                      ),
                  loading:
                      () => CircleAvatar(
                        radius: size / 2,
                        child: CircularProgressIndicator(),
                      ),
                ),
              ),
              if (live.remoteParticipant.isMuted)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Icon(
                      Symbols.mic_off,
                      size: 14,
                      fill: 1,
                    ).padding(left: 1.5, top: 1.5),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class CallParticipantTile extends HookConsumerWidget {
  final CallParticipantLive live;

  const CallParticipantTile({super.key, required this.live});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasVideo =
        live.hasVideo &&
        live.remoteParticipant.trackPublications.values
            .where((pub) => pub.track != null && pub.kind == TrackType.VIDEO)
            .isNotEmpty;

    if (hasVideo) {
      return Stack(
        fit: StackFit.loose,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoTrackRenderer(
              live.remoteParticipant.trackPublications.values
                      .where((track) => track.kind == TrackType.VIDEO)
                      .first
                      .track
                  as VideoTrack,
              renderMode: VideoRenderMode.platformView,
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Text(
              '@${live.participant.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    spreadRadius: 8,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return SpeakingRippleAvatar(size: 84, live: live);
    }
  }
}
