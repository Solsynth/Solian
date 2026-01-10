import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/chat.dart';
import 'package:island/widgets/chat/call_overlay.dart';
import 'package:styled_widget/styled_widget.dart';

class RoomOverlays extends ConsumerWidget {
  final AsyncValue<SnChatRoom?> roomAsync;
  final bool isSyncing;
  final bool showGradient;
  final double bottomGradientOpacity;
  final double inputHeight;

  const RoomOverlays({
    super.key,
    required this.roomAsync,
    required this.isSyncing,
    required this.showGradient,
    required this.bottomGradientOpacity,
    required this.inputHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: roomAsync.when(
            data: (data) => data != null
                ? CallOverlayBar(room: data).padding(horizontal: 8, top: 12)
                : const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ),
        if (isSyncing)
          Positioned(
            top: 8,
            right: 16,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                8,
                8,
                8,
                8 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Syncing...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
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
