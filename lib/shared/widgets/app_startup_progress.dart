import 'package:flutter/material.dart';
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

    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: SizedBox(
        height: barHeight,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              borderRadius: BorderRadius.zero,
              stopIndicatorRadius: 0,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                isErrored ? colorScheme.error : colorScheme.primary,
              ),
            );
          },
        ),
      ),
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
                )
              : isErrored && isDismissable
              ? Icon(
                  Symbols.warning_amber_rounded,
                  size: 18,
                  color: colorScheme.error,
                  fill: 1,
                )
              : Icon(
                  Symbols.check_circle_outline,
                  size: 18,
                  color: colorScheme.primary,
                  fill: 1,
                ),
        ),
      ],
    );
  }
}
