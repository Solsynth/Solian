import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:photo_view/photo_view.dart';
import 'package:material_symbols_icons/symbols.dart';

class ImageControlOverlay extends HookWidget {
  final PhotoViewController photoViewController;
  final ValueNotifier<int> rotation;
  final bool showOriginal;
  final VoidCallback onToggleQuality;
  final List<Widget>? extraButtons;
  final bool showExtraOnLeft;
  final bool showExifInfo;
  final VoidCallback onToggleExif;
  final bool hasExifData;

  const ImageControlOverlay({
    super.key,
    required this.photoViewController,
    required this.rotation,
    required this.showOriginal,
    required this.onToggleQuality,
    this.extraButtons,
    this.showExtraOnLeft = false,
    this.showExifInfo = false,
    required this.onToggleExif,
    this.hasExifData = true,
  });

  @override
  Widget build(BuildContext context) {
    final shadow = [
      Shadow(
        color: Colors.black54,
        blurRadius: 5.0,
        offset: const Offset(1.0, 1.0),
      ),
    ];

    final controlButtons = [
      IconButton(
        icon: Icon(Icons.remove, color: Colors.white, shadows: shadow),
        onPressed: () {
          photoViewController.scale = (photoViewController.scale ?? 1) - 0.05;
        },
      ),
      IconButton(
        icon: Icon(Icons.add, color: Colors.white, shadows: shadow),
        onPressed: () {
          photoViewController.scale = (photoViewController.scale ?? 1) + 0.05;
        },
      ),
      const Gap(8),
      IconButton(
        icon: Icon(Icons.rotate_left, color: Colors.white, shadows: shadow),
        onPressed: () {
          rotation.value = (rotation.value - 1) % 4;
          photoViewController.rotation = rotation.value * -math.pi / 2;
        },
      ),
      IconButton(
        icon: Icon(Icons.rotate_right, color: Colors.white, shadows: shadow),
        onPressed: () {
          rotation.value = (rotation.value + 1) % 4;
          photoViewController.rotation = rotation.value * -math.pi / 2;
        },
      ),
      if (hasExifData) ...[
        const Gap(8),
        IconButton(
          icon: Icon(
            showExifInfo ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
            shadows: shadow,
          ),
          onPressed: onToggleExif,
        ),
      ],
    ];

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 16,
      right: 16,
      child: Row(
        children: showExtraOnLeft
            ? [...?extraButtons, const Spacer(), ...controlButtons]
            : [
                ...controlButtons,
                const Spacer(),
                IconButton(
                  onPressed: onToggleQuality,
                  icon: Icon(
                    showOriginal ? Symbols.hd : Symbols.sd,
                    color: Colors.white,
                    shadows: shadow,
                  ),
                ),
                ...?extraButtons,
              ],
      ),
    );
  }
}
