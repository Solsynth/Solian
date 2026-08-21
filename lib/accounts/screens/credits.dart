import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'credits.g.dart';

@riverpod
Future<double> socialCredits(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getSocialCredits();
}

final socialCreditHistoryNotifierProvider = AsyncNotifierProvider.autoDispose(
  SocialCreditHistoryNotifier.new,
);

class SocialCreditHistoryNotifier
    extends AsyncNotifier<PaginationState<SnSocialCreditRecord>>
    with AsyncPaginationController<SnSocialCreditRecord> {
  static const int pageSize = 20;

  @override
  FutureOr<PaginationState<SnSocialCreditRecord>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnSocialCreditRecord>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final result = await client.accounts.getSocialCreditHistory(
      offset: fetchedCount,
      take: pageSize,
    );

    totalCount = result.totalCount;
    return result.items;
  }
}

class SocialCreditsTab extends HookConsumerWidget {
  const SocialCreditsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final socialCredits = ref.watch(socialCreditsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: socialCredits.when(
            data: (credits) {
              final tierColor = credits < 100
                  ? colorScheme.error
                  : credits < 150
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.primary;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        credits < 100
                            ? 'socialCreditsLevelPoor'.tr()
                            : credits < 150
                            ? 'socialCreditsLevelNormal'.tr()
                            : credits < 200
                            ? 'socialCreditsLevelGood'.tr()
                            : 'socialCreditsLevelExcellent'.tr(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: tierColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SheetScaffold(
                              titleText: 'socialCredits'.tr(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Text(
                                  'socialCreditsDescription'.tr(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          );
                        },
                        visualDensity: VisualDensity.compact,
                        color: colorScheme.onSurfaceVariant,
                        icon: const Icon(Symbols.info, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        credits.toStringAsFixed(1),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ 200',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 10,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _CreditScalePainter(
                        value: credits,
                        fillColor: tierColor,
                        trackColor: colorScheme.surfaceContainerHighest,
                        tickColor: colorScheme.onSurfaceVariant.withOpacity(
                          0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${credits.toStringAsFixed(2)} pts',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        '${((credits / 200) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 3,
              child: LinearProgressIndicator(minHeight: 3),
            ),
            error: (_, _) => Text(
              'somethingWentWrong'.tr(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Expanded(
          child: PaginationList(
            padding: EdgeInsets.zero,
            provider: socialCreditHistoryNotifierProvider,
            notifier: socialCreditHistoryNotifierProvider.notifier,
            itemBuilder: (context, idx, record) {
              final isExpired =
                  record.expiredAt != null &&
                  record.expiredAt!.isBefore(DateTime.now());
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  record.reason,
                  style: isExpired
                      ? TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        )
                      : null,
                ),
                subtitle: Row(
                  spacing: 4,
                  children: [
                    Flexible(
                      child: Text(
                        record.createdAt.formatSystem(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('to'),
                    if (record.expiredAt != null)
                      Flexible(
                        child: Text(
                          record.expiredAt!.formatSystem(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                trailing: Text(
                  record.delta > 0 ? '+${record.delta}' : '${record.delta}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontFeatures: [const FontFeature.tabularFigures()],
                    color: record.delta > 0
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A 0–200 scale for social credits with a tick marking the base score of 100.
class _CreditScalePainter extends CustomPainter {
  final double value;
  final Color fillColor;
  final Color trackColor;
  final Color tickColor;

  const _CreditScalePainter({
    required this.value,
    required this.fillColor,
    required this.trackColor,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barTop = size.height / 2 - 1.5;
    final radius = const Radius.circular(2);
    final paint = Paint();

    // Track.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, barTop, size.width, 3),
        radius,
      ),
      paint..color = trackColor,
    );

    // Fill up to the current value (0–200).
    final fraction = (value / 200).clamp(0.0, 1.0);
    if (fraction > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, barTop, (size.width * fraction).clamp(3, size.width), 3),
          radius,
        ),
        paint..color = fillColor,
      );
    }

    // Base-score tick at the midpoint (100).
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 1, 0, 2, size.height),
      paint..color = tickColor,
    );
  }

  @override
  bool shouldRepaint(covariant _CreditScalePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.tickColor != tickColor;
}
