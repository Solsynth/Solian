import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/call_overlay.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class RoomOverlays extends ConsumerWidget {
  final AsyncValue<SnChatRoom?> roomAsync;
  final bool showGradient;
  final double bottomGradientOpacity;
  final double inputHeight;

  const RoomOverlays({
    super.key,
    required this.roomAsync,
    required this.showGradient,
    required this.bottomGradientOpacity,
    required this.inputHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        roomAsync.when(
          data: (data) => data != null
              ? CallOverlayBar(room: data)
              : const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        ),
        if (showGradient)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: bottomGradientOpacity,
              child: Container(
                height: math.min(MediaQuery.of(context).size.height * 0.1, 128),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.surfaceContainer.withOpacity(0.8),
                      Theme.of(
                        context,
                      ).colorScheme.surfaceContainer.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
