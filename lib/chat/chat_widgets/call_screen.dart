import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/chat/chat_pod/call.dart';
import 'package:island/chat/chat_widgets/call_button.dart';
import 'package:island/chat/chat_widgets/call_content.dart';
import 'package:island/chat/chat_widgets/call_overlay.dart';
import 'package:island/chat/chat_widgets/call_participant_tile.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/talker.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/symbols.dart';

class CallScreen extends HookConsumerWidget {
  final SnChatRoom room;
  const CallScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ongoingCall = ref.watch(ongoingCallProvider(room.id));
    final callState = ref.watch(callProvider);
    final callNotifier = ref.watch(callProvider.notifier);

    useEffect(() {
      talker.info('[Call] Joining the call...');
      callNotifier.joinRoom(room).catchError((_) {
        showConfirmAlert(
          'Seems there already has a call connected, do you want override it?',
          'Call already connected',
        ).then((value) {
          if (value != true) return;
          talker.info('[Call] Joining the call... with overrides');
          callNotifier.disconnect();
          callNotifier.dispose();
          callNotifier.joinRoom(room);
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
      body: callState.error != null
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
                const SizedBox(width: double.infinity),
                Expanded(child: CallContent()),
                CallControlsBar(popOnLeaves: true),
                Gap(MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
    );
  }
}
