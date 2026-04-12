import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final thoughtQuotaProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.thoughts.getQuota();
});

class FreeQuotaIndicator extends ConsumerWidget {
  const FreeQuotaIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLow
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLow ? Symbols.warning : Symbols.bolt,
                    size: 16,
                    color: isLow
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$remaining free tokens',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLow
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Gap(2),
                      SizedBox(
                        width: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: isLow
                                ? Theme.of(context).colorScheme.onErrorContainer
                                      .withOpacity(0.2)
                                : Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation(
                              isLow
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(
            width: 80,
            height: 24,
            child: LinearProgressIndicator(),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
  }
}
