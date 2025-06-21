import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/call.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/chat/call_button.dart';
import 'package:island/widgets/chat/call_overlay.dart';
import 'package:island/widgets/chat/call_participant_tile.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class CallScreen extends HookConsumerWidget {
  final String roomId;
  const CallScreen({super.key, @PathParam('id') required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ongoingCall = ref.watch(ongoingCallProvider(roomId));
    final callState = ref.watch(callNotifierProvider);
    final callNotifier = ref.read(callNotifierProvider.notifier);

    useEffect(() {
      callNotifier.joinRoom(roomId);
      return null;
    }, []);

    final viewMode = useState<String>('grid');

    return AppScaffold(
      noBackground: false,
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
                  : 'Connecting',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Symbols.grid_view),
                tooltip: 'Grid View',
                onPressed: () => viewMode.value = 'grid',
                color:
                    viewMode.value == 'grid'
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
              IconButton(
                icon: Icon(Symbols.view_agenda),
                tooltip: 'Stage View',
                onPressed: () => viewMode.value = 'stage',
                color:
                    viewMode.value == 'stage'
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
            ],
          ),
          const Gap(8),
        ],
      ),
      body:
          callState.error != null
              ? Center(
                child: Text(
                  callState.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
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
                        final allAudioOnly = participants.every(
                          (p) =>
                              !(p.hasVideo &&
                                  p.remoteParticipant.trackPublications.values
                                      .any(
                                        (pub) =>
                                            pub.track != null &&
                                            pub.kind == TrackType.VIDEO,
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: SpeakingRippleAvatar(
                                        isSpeaking: live.isSpeaking,
                                        audioLevel:
                                            live.remoteParticipant.audioLevel,
                                        pictureId:
                                            live
                                                .participant
                                                .profile
                                                ?.account
                                                .profile
                                                .picture
                                                ?.id,
                                        size: 72,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (viewMode.value == 'stage') {
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
                          final others =
                              participants
                                  .where((p) => !mainSpeakers.contains(p))
                                  .toList();
                          return Column(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (final speaker in mainSpeakers)
                                      Expanded(
                                        child:
                                            AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: Card(
                                                margin: EdgeInsets.zero,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Column(
                                                    children: [
                                                      CallParticipantTile(
                                                        live: speaker,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ).center(),
                                      ),
                                  ],
                                ).padding(horizontal: 12),
                              ),
                              if (others.isNotEmpty)
                                SizedBox(
                                  height: 100,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      for (final other in others)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: CallParticipantTile(
                                            live: other,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }
                        // Default: grid view
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    isWidestScreen(context)
                                        ? 4
                                        : isWiderScreen(context)
                                        ? 3
                                        : 2,
                                childAspectRatio: 16 / 9,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: participants.length,
                          itemBuilder: (context, idx) {
                            final live = participants[idx];
                            return AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Column(
                                    children: [CallParticipantTile(live: live)],
                                  ),
                                ),
                              ),
                            ).center();
                          },
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
