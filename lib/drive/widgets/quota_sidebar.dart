import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/core/utils/format.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Gauge layout math. All quantities in MB; returns fractions of the total
/// span (base quota + purchased extra quota).
///
/// - [baseFraction] — where the base quota ends on the span.
/// - [usedFraction] — total fill level.
/// - [baseUsed] — fill consumed inside the base band (solid).
/// - [extraUsed] — fill consumed inside the extra band (hatched).
({
  double span,
  double baseFraction,
  double usedFraction,
  double baseUsed,
  double extraUsed,
})
quotaGaugeFractions({
  required int baseMb,
  required int extraMb,
  required double usedMb,
}) {
  final span = (baseMb + extraMb).toDouble();
  if (span <= 0) {
    return (
      span: 0,
      baseFraction: 0,
      usedFraction: 0,
      baseUsed: 0,
      extraUsed: 0,
    );
  }
  final used = usedMb.clamp(0.0, span).toDouble();
  return (
    span: span,
    baseFraction: baseMb / span,
    usedFraction: used / span,
    baseUsed: (used <= baseMb ? used : baseMb.toDouble()) / span,
    extraUsed: (used > baseMb ? used - baseMb : 0.0) / span,
  );
}

/// A compact quota overview widget designed for sidebar display.
///
/// The usage card is drawn as a measuring instrument: a tick-marked gauge
/// spanning base quota + purchased extra quota. Base quota renders as solid
/// fill; extra quota is a hatched extension band (the technical-drawing
/// convention for "additive"), so the structure survives monochrome and
/// colorblindness.
class QuotaSidebarWidget extends StatelessWidget {
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final List<SnFilePool>? pools;
  final SnFilePool? selectedPool;
  final ValueChanged<SnFilePool?>? onPoolSelected;
  final VoidCallback? onViewDetails;
  final VoidCallback? onBuyExtraQuota;
  final bool showPoolFilter;

  const QuotaSidebarWidget({
    super.key,
    required this.usage,
    required this.quota,
    this.pools,
    this.selectedPool,
    this.onPoolSelected,
    this.onViewDetails,
    this.onBuyExtraQuota,
    this.showPoolFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    if (usage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final nonNullUsage = usage!;
    final usedBytes = nonNullUsage['total_usage_bytes'] as int? ?? 0;
    final fileCount = nonNullUsage['total_file_count'] as int? ?? 0;
    final baseMb = nonNullUsage['total_quota'] as int? ?? 0;
    final usedMb = (nonNullUsage['used_quota'] as num? ?? 0).toDouble();
    final extraMb = (quota?['extra_quota'] as num?)?.toInt() ?? 0;
    final poolUsages = nonNullUsage['pool_usages'] as List<dynamic>? ?? [];

    final availableMb = baseMb + extraMb;
    final availableBytes = availableMb * 1024 * 1024;
    final usedQuotaBytes = (usedMb * 1024 * 1024).round();
    final usageRatio = availableMb > 0 ? usedMb / availableMb : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Symbols.storage,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(8),
              Text(
                'storageOverview',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ).tr(),
            ],
          ),
          const Gap(16),

          // Usage instrument
          _buildUsageCard(
            context,
            usedQuotaBytes,
            availableBytes,
            usedMb,
            baseMb,
            extraMb,
            usageRatio,
          ),
          const Gap(16),

          // Quick Stats Row
          _buildStatsRow(context, fileCount, usedBytes, usedQuotaBytes),
          const Gap(24),

          // Pool Filter Section
          if (showPoolFilter && pools != null && pools!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Symbols.filter_list,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const Gap(8),
                Text(
                  'filterByPool',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ).tr(),
              ],
            ),
            const Gap(12),
            _buildPoolFilter(context, pools!, selectedPool),
            const Gap(24),
          ],

          // Pool Breakdown
          if (poolUsages.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Symbols.folder_copy,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const Gap(8),
                Text(
                  'poolUsage',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ).tr(),
              ],
            ),
            const Gap(12),
            _buildPoolList(context, poolUsages),
            const Gap(16),
          ],

          // Actions
          if (onBuyExtraQuota != null) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onBuyExtraQuota,
                icon: const Icon(Symbols.add_card, size: 18),
                label: Text('quotaPurchase'.tr()),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const Gap(8),
          ],
          if (onViewDetails != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Symbols.bar_chart, size: 18),
                label: Text('viewDetails'.tr()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(
    BuildContext context,
    int usedQuotaBytes,
    int availableBytes,
    double usedMb,
    int baseMb,
    int extraMb,
    double usageRatio,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final usageColor = _getUsageColor(usageRatio);
    final metrics = quotaGaugeFractions(
      baseMb: baseMb,
      extraMb: extraMb,
      usedMb: usedMb,
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Tooltip(
                  message: 'quotaUsageTooltip'.tr(),
                  child: Text(
                    'used',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ).tr(),
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    formatFileSize(usedQuotaBytes),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: usageColor,
                    ),
                  ),
                ),
                const Gap(8),
                Text(
                  '/ ${formatFileSize(availableBytes)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Gap(10),
                Text(
                  '${(usageRatio * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: usageColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const Gap(14),
            _buildGauge(context, metrics),
            const Gap(12),
            _buildQuotaLegend(context, baseMb, extraMb),
            const Gap(12),
            _buildUsageStatus(context, usageRatio),
          ],
        ),
      ),
    );
  }

  /// The instrument: track spans base + extra; solid fill inside base,
  /// hatched fill inside extra; a taller boundary tick marks where the
  /// purchased band begins; quarter ticks give it a ruled feel.
  Widget _buildGauge(
    BuildContext context,
    ({
      double span,
      double baseFraction,
      double usedFraction,
      double baseUsed,
      double extraUsed,
    })
    metrics,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: [
        '${'used'.tr()} ${formatFileSize((metrics.usedFraction * metrics.span * 1024 * 1024).round())}',
        'of ${formatFileSize((metrics.span * 1024 * 1024).round())}',
      ].join(' '),
      value: '${(metrics.usedFraction * 100).toStringAsFixed(1)}%',
      child: SizedBox(
        height: 14,
        width: double.infinity,
        child: CustomPaint(
          painter: _QuotaGaugePainter(
            baseFraction: metrics.baseFraction,
            baseUsed: metrics.baseUsed,
            extraUsed: metrics.extraUsed,
            trackColor: colorScheme.surfaceContainerHighest,
            baseTint: colorScheme.primary.withValues(alpha: 0.08),
            baseFill: colorScheme.primary,
            extraTint: colorScheme.tertiary.withValues(alpha: 0.14),
            hatchColor: colorScheme.tertiary,
            tickColor: colorScheme.outlineVariant,
            boundaryColor: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaLegend(BuildContext context, int baseMb, int extraMb) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        _buildLegendItem(
          context,
          swatch: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          label: 'baseQuota'.tr(),
          value: formatFileSize(baseMb * 1024 * 1024),
        ),
        if (extraMb > 0)
          _buildLegendItem(
            context,
            swatch: CustomPaint(
              size: const Size(10, 10),
              painter: _HatchSwatchPainter(
                fill: colorScheme.tertiary.withValues(alpha: 0.35),
                hatch: colorScheme.tertiary,
              ),
            ),
            label: 'quotaPurchaseExtraQuota'.tr(),
            value: formatFileSize(extraMb * 1024 * 1024),
          ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Widget swatch,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const Gap(6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ).tr(),
        const Gap(4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageStatus(BuildContext context, double ratio) {
    String statusKey;
    Color statusColor;

    if (ratio < 0.5) {
      statusKey = 'healthy';
      statusColor = Colors.green;
    } else if (ratio < 0.8) {
      statusKey = 'moderate';
      statusColor = Colors.orange;
    } else {
      statusKey = 'critical';
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusKey,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: statusColor,
        ),
      ).tr(),
    );
  }

  Color _getUsageColor(double ratio) {
    if (ratio < 0.5) return Colors.green;
    if (ratio < 0.8) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatsRow(
    BuildContext context,
    int fileCount,
    int usedBytes,
    int usedQuotaBytes,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            Symbols.data_usage,
            formatFileSize(usedBytes),
            'totalSize',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            Symbols.pie_chart,
            formatFileSize(usedQuotaBytes),
            'usedQuota',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            Symbols.insert_drive_file,
            fileCount.toString(),
            'files',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const Gap(4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ).tr(),
      ],
    );
  }

  Widget _buildPoolFilter(
    BuildContext context,
    List<SnFilePool> pools,
    SnFilePool? selected,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // "All Files" option
          _buildPoolTile(
            context,
            null,
            'allFiles'.tr(),
            Symbols.database,
            selected == null,
          ),
          Divider(height: 1, indent: 48, endIndent: 16),
          // Pool options
          ...pools.map((pool) {
            return _buildPoolTile(
              context,
              pool,
              pool.name,
              Symbols.storage,
              selected?.id == pool.id,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPoolTile(
    BuildContext context,
    SnFilePool? pool,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => onPoolSelected?.call(pool),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Symbols.check_circle,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolList(BuildContext context, List<dynamic> pools) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Column(
      children: pools.asMap().entries.map((entry) {
        final pool = entry.value as Map<String, dynamic>;
        final name = pool['pool_name'] as String? ?? 'Unknown';
        final bytes = pool['usage_bytes'] as int? ?? 0;
        final color = colors[entry.key % colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formatFileSize(bytes),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Draws the quota instrument: track, base/extra bands, used fill (solid in
/// base, hatched in extra), a taller boundary tick and quarter scale ticks.
class _QuotaGaugePainter extends CustomPainter {
  final double baseFraction;
  final double baseUsed;
  final double extraUsed;
  final Color trackColor;
  final Color baseTint;
  final Color baseFill;
  final Color extraTint;
  final Color hatchColor;
  final Color tickColor;
  final Color boundaryColor;

  const _QuotaGaugePainter({
    required this.baseFraction,
    required this.baseUsed,
    required this.extraUsed,
    required this.trackColor,
    required this.baseTint,
    required this.baseFill,
    required this.extraTint,
    required this.hatchColor,
    required this.tickColor,
    required this.boundaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final trackRRect = RRect.fromRectAndRadius(
      barRect,
      const Radius.circular(999),
    );

    canvas.save();
    canvas.clipRRect(trackRRect);

    canvas.drawRRect(trackRRect, Paint()..color = trackColor);

    final width = size.width;
    final height = size.height;

    // Base band tint (solid region of the instrument).
    if (baseFraction > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width * baseFraction, height),
        Paint()..color = baseTint,
      );
    }
    // Extra band tint (purchased headroom).
    if (baseFraction < 1) {
      canvas.drawRect(
        Rect.fromLTWH(
          width * baseFraction,
          0,
          width * (1 - baseFraction),
          height,
        ),
        Paint()..color = extraTint,
      );
    }
    // Used fill inside the base band.
    if (baseUsed > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width * baseUsed, height),
        Paint()..color = baseFill,
      );
    }
    // Used fill inside the extra band — hatched.
    if (extraUsed > 0) {
      _drawHatch(
        canvas,
        Rect.fromLTWH(width * baseFraction, 0, width * extraUsed, height),
      );
    }

    canvas.restore();

    // Scale ticks: quarter marks.
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1;
    for (final f in const [0.25, 0.5, 0.75]) {
      final x = width * f;
      canvas.drawLine(Offset(x, 0), Offset(x, height), tickPaint);
    }

    // Boundary tick: where the purchased band begins.
    if (baseFraction > 0 && baseFraction < 1) {
      final boundaryPaint = Paint()
        ..color = boundaryColor
        ..strokeWidth = 2;
      final x = width * baseFraction;
      canvas.drawLine(Offset(x, -3), Offset(x, height + 3), boundaryPaint);
    }
  }

  void _drawHatch(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = hatchColor
      ..strokeWidth = 1.4;
    const spacing = 5.0;
    var x = -rect.height;
    while (x < rect.width + rect.height) {
      canvas.drawLine(
        Offset(rect.left + x, rect.bottom),
        Offset(rect.left + x + rect.height, rect.top),
        paint,
      );
      x += spacing;
    }
  }

  @override
  bool shouldRepaint(_QuotaGaugePainter oldDelegate) {
    return oldDelegate.baseFraction != baseFraction ||
        oldDelegate.baseUsed != baseUsed ||
        oldDelegate.extraUsed != extraUsed ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.baseTint != baseTint ||
        oldDelegate.baseFill != baseFill ||
        oldDelegate.extraTint != extraTint ||
        oldDelegate.hatchColor != hatchColor ||
        oldDelegate.tickColor != tickColor ||
        oldDelegate.boundaryColor != boundaryColor;
  }
}

/// Tiny hatched swatch for the legend, matching the gauge's extra band.
class _HatchSwatchPainter extends CustomPainter {
  final Color fill;
  final Color hatch;

  const _HatchSwatchPainter({required this.fill, required this.hatch});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = fill);
    final paint = Paint()
      ..color = hatch
      ..strokeWidth = 1.1;
    var x = -size.height;
    while (x < size.width + size.height) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
      x += 3.5;
    }
  }

  @override
  bool shouldRepaint(_HatchSwatchPainter oldDelegate) {
    return oldDelegate.fill != fill || oldDelegate.hatch != hatch;
  }
}
