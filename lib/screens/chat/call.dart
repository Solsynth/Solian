import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/chat/call.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/chat/call_button.dart';
import 'package:island/widgets/chat/call_overlay.dart';
import 'package:island/widgets/chat/call_participant_tile.dart';
import 'package:island/widgets/alert.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class CallScreen extends HookConsumerWidget {
  final String roomId;
  const CallScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ongoingCall = ref.watch(ongoingCallProvider(roomId));
    final callState = ref.watch(callNotifierProvider);
    final callNotifier = ref.watch(callNotifierProvider.notifier);

    useEffect(() {
      log('[Call] Joining the call...');
      callNotifier.joinRoom(roomId).catchError((_) {
        showConfirmAlert(
          'Seems there already has a call connected, do you want override it?',
          'Call already connected',
        ).then((value) {
          if (value != true) return;
          log('[Call] Joining the call... with overrides');
          callNotifier.disconnect();
          callNotifier.dispose();
          callNotifier.joinRoom(roomId);
        });
      });
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

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: PageBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              ongoingCall.value?.room.name ?? 'call'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              callState.isConnected
                  ? formatDuration(callState.duration)
                  : (switch (callNotifier.room?.connectionState) {
                    ConnectionState.connected => 'connected',
                    ConnectionState.connecting => 'connecting',
                    ConnectionState.reconnecting => 'reconnecting',
                    _ => 'disconnected',
                  }).tr(),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          if (!allAudioOnly)
            SingleChildScrollView(
              child: Row(
                spacing: 4,
                children: [
                  for (final live in callNotifier.participants)
                    SpeakingRippleAvatar(live: live, size: 30),
                  const Gap(8),
                ],
              ),
            ),
        ],
      ),
      body:
          callState.error != null
              ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    children: [
                      const Icon(Symbols.error_outline, size: 48),
                      const Gap(4),
                      Text(
                        callState.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF757575)),
                      ),
                      const Gap(8),
                      TextButton(
                        onPressed: () {
                          callNotifier.disconnect();
                          callNotifier.dispose();
                          callNotifier.joinRoom(roomId);
                        },
                        child: Text('retry').tr(),
                      ),
                    ],
                  ),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (!callState.isConnected) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (callNotifier.participants.isEmpty) {
                          return const Center(
                            child: Text('No participants in call'),
                          );
                        }

                        final participants = callNotifier.participants;
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

                        // Stage view: show main speaker(s) large, others in row
                        final mainSpeakers =
                            participants
                                .where(
                                  (p) => p
                                      .remoteParticipant
                                      .trackPublications
                                      .values
                                      .any(
                                        (pub) =>
                                            pub.track != null &&
                                            pub.kind == TrackType.VIDEO,
                                      ),
                                )
                                .toList();
                        if (mainSpeakers.isEmpty && participants.isNotEmpty) {
                          mainSpeakers.add(participants.first);
                        }
                        return Column(
                          children: [
                            for (final speaker in mainSpeakers)
                              Expanded(
                                child: CallParticipantTile(live: speaker),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  CallControlsBar(),
                  Gap(MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
    );
  }
}
