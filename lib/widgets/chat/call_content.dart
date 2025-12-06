import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/chat/call.dart';
import 'package:island/widgets/chat/call_participant_tile.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:styled_widget/styled_widget.dart';

class CallContent extends HookConsumerWidget {
  const CallContent({super.key});

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
      // Audio-only: show avatars in a compact row
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
                SpeakingRippleAvatar(
                  live: live,
                  size: 72,
                ).padding(horizontal: 4),
            ],
          ),
        ),
      );
    }

    // Show all participants in a responsive grid
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width for responsive 2-column layout
        final itemWidth = (constraints.maxWidth / 2) - 16;

        return Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final participant in participants)
              SizedBox(
                width: itemWidth,
                child: CallParticipantTile(live: participant),
              ),
          ],
        );
      },
    );
  }
}
