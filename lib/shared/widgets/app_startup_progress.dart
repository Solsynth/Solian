import 'package:flutter/material.dart';
import 'package:island/core/services/responsive.dart';
import 'package:material_symbols_icons/symbols.dart';

class StartupProgressBar extends StatelessWidget {
  final double progress;
  final bool isErrored;
  final ColorScheme colorScheme;

  const StartupProgressBar({
    super.key,
    required this.progress,
    required this.isErrored,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    const barHeight = 3.0;
    final wide = isWideScreen(context);

    Widget buildBar({required bool reversed}) {
      return ClipRRect(
        borderRadius: BorderRadius.zero,
        child: SizedBox(
          height: barHeight,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              final bar = LinearProgressIndicator(
                value: value,
                borderRadius: BorderRadius.zero,
                stopIndicatorRadius: 0,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(
                  isErrored ? colorScheme.error : colorScheme.primary,
                ),
              );
              if (reversed) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0),
                  child: bar,
                );
              }
              return bar;
            },
          ),
        ),
      );
    }

    if (!wide) return buildBar(reversed: false);

    return Row(
      children: [
        Expanded(child: buildBar(reversed: false)),
        const SizedBox(width: 4),
        Expanded(child: buildBar(reversed: true)),
      ],
    );
  }
}

class StartupProgressIcon extends StatelessWidget {
  final bool isBusy;
  final bool isErrored;
  final bool isDismissable;
  final bool isWaitingForConnectivity;
  final ColorScheme colorScheme;

  const StartupProgressIcon({
    super.key,
    required this.isBusy,
    required this.isErrored,
    required this.isDismissable,
    required this.isWaitingForConnectivity,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    const iconSize = 72.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/icons/icon.webp',
              width: iconSize - 16,
              height: iconSize - 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isBusy
              ? const SizedBox(key: ValueKey('busy-placeholder'), height: 18)
              : isErrored && !isDismissable
              ? Icon(
                  isWaitingForConnectivity
                      ? Symbols.wifi_off_rounded
                      : Symbols.error_outline,
                  size: 18,
                  color: colorScheme.error,
                  fill: 1,
                  shadows: [
                    Shadow(
                      color: colorScheme.error.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : isErrored && isDismissable
              ? Icon(
                  Symbols.warning_amber_rounded,
                  size: 18,
                  color: colorScheme.error,
                  fill: 1,
                  shadows: [
                    Shadow(
                      color: colorScheme.error.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : Icon(
                  Symbols.check_circle_outline,
                  size: 18,
                  color: colorScheme.primary,
                  fill: 1,
                  shadows: [
                    Shadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
