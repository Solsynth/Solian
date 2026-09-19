import 'package:material_ui/material_ui.dart';
import 'package:island/core/services/responsive.dart';

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
