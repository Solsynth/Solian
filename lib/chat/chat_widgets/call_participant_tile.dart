import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account/profile.dart';
import 'package:island/chat/chat_pod/call.dart';
import 'package:island/chat/chat_widgets/call_participant_card.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class SpeakingRipple extends StatelessWidget {
  final double size;
  final double audioLevel;
  final bool isSpeaking;
  final Widget child;

  const SpeakingRipple({
    super.key,
    required this.size,
    required this.audioLevel,
    required this.isSpeaking,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final avatarRadius = size / 2;
    final clampedLevel = audioLevel.clamp(0.0, 1.0);
    final rippleRadius = avatarRadius + clampedLevel * (size * 0.333);

    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: avatarRadius,
          end: isSpeaking ? rippleRadius : avatarRadius,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        builder: (context, animatedRadius, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (isSpeaking)
                Container(
                  width: animatedRadius * 2,
                  height: animatedRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.75 + 0.25 * clampedLevel),
                  ),
                ),
              child!,
            ],
          );
        },
        child: SizedBox(width: size, height: size, child: child),
      ),
    );
  }
}

class SpeakingRippleAvatar extends HookConsumerWidget {
  final CallParticipantLive live;
  final double size;

  const SpeakingRippleAvatar({super.key, required this.live, this.size = 96});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(live.participant.identity));

    return SpeakingRipple(
      size: size,
      audioLevel: live.remoteParticipant.audioLevel,
      isSpeaking: live.remoteParticipant.isSpeaking,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: account.when(
              data: (value) => CallParticipantRegion(
                participant: live,
                child: ProfilePictureWidget(
                  file: value.profile.picture,
                  radius: size / 2,
                ),
              ),
              error: (_, _) => CircleAvatar(
                radius: size / 2,
                child: const Icon(Symbols.question_mark),
              ),
              loading: () => CircleAvatar(
                radius: size / 2,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          if (live.remoteParticipant.isMuted)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Symbols.mic_off,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CallParticipantTile extends HookConsumerWidget {
  final CallParticipantLive live;
  final bool allTiles;
  final double radius;

  const CallParticipantTile({
    super.key,
    required this.live,
    this.allTiles = false,
    this.radius = 48,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(accountProvider(live.participant.name));
    final account = ref.watch(accountProvider(live.participant.identity));

    final hasVideo =
        live.hasVideo &&
        live.remoteParticipant.trackPublications.values
            .where((pub) => pub.track != null && pub.kind == TrackType.VIDEO)
            .isNotEmpty;

    if (hasVideo || allTiles) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use the smaller dimension to determine the "size" for the ripple calculation
            // effectively making the ripple relative to the tile size.
            // However, for a rectangular video, we might want a different approach.
            // The user asked for "speaking ripple to the video as well".
            // If we use the extracted SpeakingRipple, it expects a size and assumes a circle.
            // We need to adapt it or create a rectangular version.
            // Given the "image" likely shows a rectangular video with rounded corners,
            // let's create a specific wrapper for the video tile that adds a border/glow when speaking.

            final isSpeaking = live.remoteParticipant.isSpeaking;
            final audioLevel = live.remoteParticipant.audioLevel;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSpeaking
                      ? Colors.green.withOpacity(
                          0.5 + 0.5 * audioLevel.clamp(0.0, 1.0),
                        )
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isSpeaking ? 4 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasVideo)
                        VideoTrackRenderer(
                          live.remoteParticipant.trackPublications.values
                                  .where(
                                    (track) => track.kind == TrackType.VIDEO,
                                  )
                                  .first
                                  .track
                              as VideoTrack,
                          renderMode: VideoRenderMode.platformView,
                        )
                      else
                        Center(
                          child: account.when(
                            data: (value) => CallParticipantRegion(
                              participant: live,
                              child: ProfilePictureWidget(
                                file: value.profile.picture,
                                radius: radius,
                              ),
                            ),
                            error: (_, _) => CircleAvatar(
                              radius: radius,
                              child: const Icon(Symbols.question_mark),
                            ),
                            loading: () => CircleAvatar(
                              radius: radius,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (live.remoteParticipant.isMuted)
                                const Icon(
                                  Symbols.mic_off,
                                  size: 14,
                                  color: Colors.redAccent,
                                ).padding(right: 4),
                              Text(
                                userInfo.value?.nick ?? live.participant.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return SpeakingRippleAvatar(size: 84, live: live);
    }
  }
}
