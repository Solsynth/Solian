import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/chat_pod/call.dart';
import 'package:island/chat/chat_widgets/call_participant_tile.dart';
import 'package:livekit_client/livekit_client.dart';

class CallStageView extends HookConsumerWidget {
  final List<CallParticipantLive> participants;
  final double? outerMaxHeight;

  const CallStageView({
    super.key,
    required this.participants,
    this.outerMaxHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedIndex = useState<int>(0);

    final focusedParticipant = participants[focusedIndex.value];
    final otherParticipants = participants
        .where((p) => p != focusedParticipant)
        .toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Focused participant (takes most space)
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate dynamic width based on available space
            final maxWidth = constraints.maxWidth * 0.8;
            final maxHeight = (outerMaxHeight ?? constraints.maxHeight) * 0.6;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CallParticipantTile(
                  live: focusedParticipant,
                  allTiles: true,
                ),
              ),
            );
          },
        ),
        // Horizontal list of other participants
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final participant in otherParticipants)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 180,
                    child: GestureDetector(
                      onTapDown: (_) {
                        final newIndex = participants.indexOf(participant);
                        focusedIndex.value = newIndex;
                      },
                      child: CallParticipantTile(
                        live: participant,
                        radius: 32,
                        allTiles: true,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CallContent extends HookConsumerWidget {
  final double? outerMaxHeight;
  const CallContent({super.key, this.outerMaxHeight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callProvider);
    final callNotifier = ref.watch(callProvider.notifier);

    if (!callState.isConnected) {
      return const Center(child: CircularProgressIndicator());
    }
    if (callNotifier.participants.isEmpty) {
      return const Center(child: Text('No participants in call'));
    }

    final participants = callNotifier.participants;
    final allAudioOnly = participants.every(
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

    if (allAudioOnly) {
      // Audio-only: show avatars in a compact row with animated containers
      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final live in participants)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SpeakingRippleAvatar(live: live, size: 72),
                ),
            ],
          ),
        ),
      );
    }

    if (callState.viewMode == ViewMode.stage) {
      // Stage: allow user to select a participant to focus, show others below
      return CallStageView(
        participants: participants,
        outerMaxHeight: outerMaxHeight,
      );
    } else {
      // Grid: show all participants in a responsive grid
      return LayoutBuilder(
        builder: (context, constraints) {
          // Calculate width for responsive 2-column layout
          final itemWidth = (constraints.maxWidth / 2) - 16;

          return SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final participant in participants)
                  SizedBox(
                    width: itemWidth,
                    child: CallParticipantTile(
                      live: participant,
                      allTiles: true,
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }
  }
}
