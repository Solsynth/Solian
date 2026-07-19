import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:island/core/widgets/content/file_action_button.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';

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
  final double bottomOffset;
  final bool isQualityLoading;

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
    this.bottomOffset = 0,
    this.isQualityLoading = false,
  });

  Widget _toolButton({
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
    bool selected = false,
    Widget? iconWidget,
  }) {
    final button = IconButton(
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      tooltip: tooltip,
      icon:
          iconWidget ??
          Icon(
            icon,
            size: 22,
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.92),
          ),
    );
    return button;
  }

  @override
  Widget build(BuildContext context) {
    final controlButtons = <Widget>[
      _toolButton(
        icon: Icons.remove,
        tooltip: 'Zoom out',
        onPressed: () {
          photoViewController.scale = (photoViewController.scale ?? 1) - 0.05;
        },
      ),
      _toolButton(
        icon: Icons.add,
        tooltip: 'Zoom in',
        onPressed: () {
          photoViewController.scale = (photoViewController.scale ?? 1) + 0.05;
        },
      ),
      const Gap(2),
      _toolButton(
        icon: Icons.rotate_left,
        tooltip: 'Rotate left',
        onPressed: () {
          rotation.value = (rotation.value - 1) % 4;
          photoViewController.rotation = rotation.value * -math.pi / 2;
        },
      ),
      _toolButton(
        icon: Icons.rotate_right,
        tooltip: 'Rotate right',
        onPressed: () {
          rotation.value = (rotation.value + 1) % 4;
          photoViewController.rotation = rotation.value * -math.pi / 2;
        },
      ),
      if (hasExifData) ...[
        const Gap(2),
        _toolButton(
          icon: showExifInfo ? Icons.info : Icons.info_outline,
          tooltip: showExifInfo ? 'Hide EXIF' : 'Show EXIF',
          selected: showExifInfo,
          onPressed: onToggleExif,
        ),
      ],
    ];

    final qualityButton = _toolButton(
      icon: showOriginal ? Symbols.hd : Symbols.sd,
      tooltip: isQualityLoading
          ? 'Loading…'
          : (showOriginal
                ? 'Original quality (HD)'
                : 'Compressed quality (SD)'),
      selected: showOriginal,
      onPressed: isQualityLoading ? null : onToggleQuality,
      iconWidget: isQualityLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : null,
    );

    final left = showExtraOnLeft
        ? <Widget>[...?extraButtons, if (extraButtons != null) const Gap(8)]
        : <Widget>[];
    final right = showExtraOnLeft
        ? <Widget>[]
        : <Widget>[
            qualityButton,
            if (extraButtons != null) ...[const Gap(4), ...extraButtons!],
          ];

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16 + bottomOffset,
      left: 16,
      right: 16,
      child: Row(
        children: [
          if (left.isNotEmpty) ...left,
          MediaChromeSurface(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(mainAxisSize: MainAxisSize.min, children: controlButtons),
          ),
          const Spacer(),
          if (right.isNotEmpty)
            MediaChromeSurface(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(mainAxisSize: MainAxisSize.min, children: right),
            ),
        ],
      ),
    );
  }
}
