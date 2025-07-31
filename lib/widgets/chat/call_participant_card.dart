import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/call.dart';
import 'package:island/widgets/account/account_nameplate.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';

class CallParticipantCard extends HookConsumerWidget {
  final CallParticipantLive live;
  const CallParticipantCard({super.key, required this.live});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width =
        math.min(MediaQuery.of(context).size.width - 80, 360).toDouble();
    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Symbols.wifi, size: 16),
                    const Gap(8),
                    Text(switch (live.remoteParticipant.connectionQuality) {
                      ConnectionQuality.excellent => 'Excellent',
                      ConnectionQuality.good => 'Good',
                      ConnectionQuality.poor => 'Bad',
                      ConnectionQuality.lost => 'Lost',
                      _ => 'Connecting',
                    }),
                  ],
                ),
              ],
            ).padding(horizontal: 20, top: 16),
            AccountNameplate(
              name: live.participant.identity,
              isOutlined: false,
            ),
          ],
        ),
      ),
    );
  }
}

class CallParticipantGestureDetector extends StatelessWidget {
  final CallParticipantLive participant;
  final Widget child;
  const CallParticipantGestureDetector({
    super.key,
    required this.participant,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTapDown: (details) {
        showCallParticipantCard(
          context,
          participant,
          offset: details.localPosition,
        );
      },
    );
  }
}

Future<void> showCallParticipantCard(
  BuildContext context,
  CallParticipantLive participant, {
  Offset? offset,
}) async {
  await showPopupCard<void>(
    offset: offset ?? Offset.zero,
    context: context,
    builder: (context) => CallParticipantCard(live: participant),
    alignment: Alignment.center,
    dimBackground: true,
  );
}
