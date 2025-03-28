import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ParticipantInfoWidget extends StatelessWidget {
  final String? title;
  final bool audioAvailable;
  final ConnectionQuality connectionQuality;
  final bool isScreenShare;
  final bool isList;

  const ParticipantInfoWidget({
    super.key,
    this.title,
    this.audioAvailable = true,
    this.connectionQuality = ConnectionQuality.unknown,
    this.isScreenShare = false,
    this.isList = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isList) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ).padding(left: 2),
          Row(
            children: [
              isScreenShare
                  ? const Icon(
                      Symbols.monitor,
                      color: Colors.white,
                      size: 16,
                    )
                  : Icon(
                      audioAvailable ? Symbols.mic : Symbols.mic_off,
                      color: audioAvailable ? Colors.white : Colors.red,
                      size: 16,
                    ),
              const Gap(3),
              if (connectionQuality != ConnectionQuality.unknown)
                Icon(
                  {
                    ConnectionQuality.excellent: Symbols.signal_cellular_alt,
                    ConnectionQuality.good: Symbols.signal_cellular_alt_2_bar,
                    ConnectionQuality.poor: Symbols.signal_cellular_alt_1_bar,
                  }[connectionQuality],
                  color: {
                    ConnectionQuality.excellent: Colors.green,
                    ConnectionQuality.good: Colors.orange,
                    ConnectionQuality.poor: Colors.red,
                  }[connectionQuality],
                  size: 16,
                )
              else
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ).padding(all: 3),
            ],
          )
        ],
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
      padding: const EdgeInsets.symmetric(
        vertical: 7,
        horizontal: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title != null)
            Flexible(
              child: Text(
                title!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          const Gap(5),
          isScreenShare
              ? const Icon(
                  Symbols.monitor,
                  color: Colors.white,
                  size: 16,
                )
              : Icon(
                  audioAvailable ? Symbols.mic : Symbols.mic_off,
                  color: audioAvailable ? Colors.white : Colors.red,
                  size: 16,
                ),
          const Gap(3),
          if (connectionQuality != ConnectionQuality.unknown)
            Icon(
              {
                ConnectionQuality.excellent: Symbols.signal_cellular_alt,
                ConnectionQuality.good: Symbols.signal_cellular_alt_2_bar,
                ConnectionQuality.poor: Symbols.signal_cellular_alt_1_bar,
              }[connectionQuality],
              color: {
                ConnectionQuality.excellent: Colors.green,
                ConnectionQuality.good: Colors.orange,
                ConnectionQuality.poor: Colors.red,
              }[connectionQuality],
              size: 16,
            )
          else
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ).padding(all: 3),
        ],
      ),
    );
  }
}
