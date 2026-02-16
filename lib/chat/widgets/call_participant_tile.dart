import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/profile.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/widgets/call_participant_card.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  final bool tightPadding;
  final bool forceLarge;
  final double? tileHeight;

  const CallParticipantTile({
    super.key,
    required this.live,
    this.allTiles = false,
    this.radius = 48,
    this.tightPadding = false,
    this.forceLarge = false,
    this.tileHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(live.participant.identity));

    final hasVideoTrack =
        live.hasVideo &&
        live.remoteParticipant.trackPublications.values
            .where(
              (pub) =>
                  pub.track != null &&
                  pub.kind == TrackType.VIDEO &&
                  !pub.isDisposed,
            )
            .isNotEmpty;

    if (!hasVideoTrack && !allTiles) {
      return SpeakingRippleAvatar(size: 84, live: live);
    }

    final isSpeaking = live.remoteParticipant.isSpeaking;
    final audioLevel = live.remoteParticipant.audioLevel.clamp(0.0, 1.0);
    final tileRadius = forceLarge ? 18.0 : 14.0;
    final participantName =
        account.value?.nick ??
        (live.participant.name.isNotEmpty
            ? live.participant.name
            : live.participant.identity);

    Widget tile = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: const Color(0xFF171A1F),
        borderRadius: BorderRadius.circular(tileRadius),
        border: Border.all(
          color: isSpeaking
              ? Color.lerp(
                  const Color(0xFF3FCF8E),
                  const Color(0xFF9DFFCB),
                  audioLevel,
                )!
              : Colors.white12,
          width: isSpeaking ? 2.4 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tileRadius - 2),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasVideoTrack)
                RepaintBoundary(
                  child: VideoTrackRenderer(
                    live.remoteParticipant.trackPublications.values
                            .where((track) => track.kind == TrackType.VIDEO)
                            .first
                            .track
                        as VideoTrack,
                    renderMode: VideoRenderMode.auto,
                  ),
                )
              else
                DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF222831), Color(0xFF151A20)],
                    ),
                  ),
                  child: Center(
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
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.62),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: account.value == null
                            ? Text(participantName)
                            : AccountName(
                                account: account.value!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      if (live.remoteParticipant.isMuted)
                        const Icon(
                          Symbols.mic_off,
                          size: 14,
                          color: Colors.redAccent,
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

    if (tileHeight != null) {
      tile = SizedBox(height: tileHeight, child: tile);
    }

    if (!tightPadding) {
      tile = Padding(padding: const EdgeInsets.all(8), child: tile);
    }

    return tile;
  }
}
