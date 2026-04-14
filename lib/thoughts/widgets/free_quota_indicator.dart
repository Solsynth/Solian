import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/thoughts/screens/think.dart';

// NOTE: thoughtQuotaProvider is defined in lib/thoughts/screens/think.dart
// and is invalidated automatically when AI response completes

class FreeQuotaIndicator extends ConsumerWidget {
  final Color? forcegroundColor;
  const FreeQuotaIndicator({super.key, required this.forcegroundColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double kSize = 30;

    return ref
        .watch(thoughtQuotaProvider)
        .when(
          data: (quota) {
            final enabled = quota['enabled'] as bool? ?? false;
            final remaining = quota['free_remaining'] as int? ?? 0;
            final used = quota['free_used'] as int? ?? 0;
            final total = quota['free_total'] as int? ?? 0;

            if (!enabled || total == 0) {
              return const SizedBox.shrink();
            }

            final progress = used / total;
            final isLow = remaining < total * 0.2;
            final percentage = ((1 - progress) * 100).round();

            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              child: Tooltip(
                message: '$remaining / $total tokens remaining',
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: kSize,
                      height: kSize,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2.5,
                        trackGap: 0,
                        backgroundColor:
                            forcegroundColor?.withOpacity(0.3) ??
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation(
                          isLow
                              ? Theme.of(context).colorScheme.error
                              : forcegroundColor ??
                                    Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isLow
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox(
            width: kSize,
            height: kSize,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          error: (_, _) => const SizedBox.shrink(),
        );
  }
}
