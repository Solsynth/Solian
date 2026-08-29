import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/workspaces/workspace_management.dart';
import 'package:island/drive/widgets/quota_sidebar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

/// Full-size storage panel, opened from the drive list.
///
/// Composed as an instrument rack in the same technical-drawing language as
/// [QuotaSidebarWidget]: the quota gauge (solid base, hatched purchased
/// extension) is the headline, and pool usage renders as a segmented tank
/// whose segments are sized by stored bytes — free space is the quiet track
/// remainder. The tank replaces the old pie charts, which truncated pool
/// names and forced a meaningless rainbow palette.
class UsageOverviewWidget extends StatelessWidget {
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;

  const UsageOverviewWidget({
    super.key,
    required this.usage,
    required this.quota,
  });

  @override
  Widget build(BuildContext context) {
    if (usage == null) return const SizedBox.shrink();

    final usageData = usage!;
    final totalMb = usageData['total_quota'] as int? ?? 0;
    final extraMb = (quota?['extra_quota'] as num?)?.toInt() ?? 0;
    final baseMb = totalMb - extraMb;
    final fileCount = usageData['total_file_count'] as int? ?? 0;
    final legacyUsedMb = (usageData['used_quota'] as num? ?? 0).toDouble();
    final usedBytes =
        (usageData['used_bytes'] as num?)?.toInt() ??
        (legacyUsedMb * 1024 * 1024).round();
    final usedMb = usedBytes / (1024 * 1024);
    final availableMb = baseMb + extraMb;
    final availableBytes =
        (usageData['limit_bytes'] as num?)?.toInt() ??
        (usageData['total_bytes'] as num?)?.toInt() ??
        availableMb * 1024 * 1024;
    final remainingBytes =
        (usageData['remaining_bytes'] as num?)?.toInt() ??
        (availableBytes - usedBytes).clamp(0, availableBytes).toInt();
    final ratio = availableBytes > 0
        ? (usedBytes / availableBytes).clamp(0.0, 1.0)
        : 0.0;
    final status = quotaUsageStatus(ratio);
    final metrics = quotaGaugeFractions(
      baseMb: baseMb,
      extraMb: extraMb,
      usedMb: usedMb,
    );
    final pools = (usageData['pool_usages'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((pool) => Map<String, dynamic>.from(pool))
        .toList(growable: false);
    final serviceUsages = (usageData['service_usages'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((service) => Map<String, dynamic>.from(service))
        .where((service) => (service['name'] as String?)?.isNotEmpty == true)
        .toList(growable: false);
    final calculatedAt = usageData['calculated_at']?.toString();
    final animate = !MediaQuery.of(context).disableAnimations;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReadout(
                  context,
                  usedBytes,
                  availableBytes,
                  ratio,
                  status,
                ),
                const Gap(16),
                _buildQuotaGauge(
                  context,
                  usedBytes,
                  availableBytes,
                  ratio,
                  metrics,
                  animate,
                ),
                const Gap(12),
                _buildQuotaLegend(context, baseMb, extraMb),
                const Gap(14),
                const Divider(height: 1),
                const Gap(12),
                _buildFilesRow(context, fileCount),
                const Gap(10),
                _buildRemainingRow(context, remainingBytes),
                if (calculatedAt != null && calculatedAt.isNotEmpty) ...[
                  const Gap(8),
                  _buildCalculatedAt(context, calculatedAt),
                ],
              ],
            ),
          ),
          if (pools.isNotEmpty) ...[
            const Gap(12),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    Symbols.folder_copy,
                    'poolUsage'.tr(),
                  ),
                  const Gap(12),
                  _buildPoolTank(context, pools, availableBytes, animate),
                  const Gap(14),
                  _buildPoolLegend(context, pools, availableBytes),
                ],
              ),
            ),
          ],
          if (serviceUsages.isNotEmpty) ...[
            const Gap(12),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    Symbols.apps,
                    'serviceUsage'.tr(),
                  ),
                  const Gap(12),
                  _buildServiceLegend(context, serviceUsages, availableBytes),
                ],
              ),
            ),
          ],
        ],
      ).padding(horizontal: 8),
    );
  }

  /// Headline readout: label + status chip, then the big used figure,
  /// the available total, and the fill percentage.
  Widget _buildReadout(
    BuildContext context,
    int usedBytes,
    int availableBytes,
    double ratio,
    ({Color color, String labelKey}) status,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Tooltip(
              message: 'quotaUsageTooltip'.tr(),
              child: Text(
                'used'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const Spacer(),
            _StatusChip(color: status.color, labelKey: status.labelKey),
          ],
        ),
        const Gap(4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                formatFileSize(usedBytes),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: status.color,
                ),
              ),
            ),
            const Gap(8),
            Text(
              '/ ${formatFileSize(availableBytes)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Gap(12),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: status.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// The shared quota instrument; the fill animates in from empty on entry.
  Widget _buildQuotaGauge(
    BuildContext context,
    int usedBytes,
    int availableBytes,
    double ratio,
    ({
      double span,
      double baseFraction,
      double usedFraction,
      double baseUsed,
      double extraUsed,
    })
    metrics,
    bool animate,
  ) {
    final scheme = Theme.of(context).colorScheme;
    Widget gauge(double t) => SizedBox(
      height: 14,
      width: double.infinity,
      child: CustomPaint(
        painter: QuotaGaugePainter(
          baseFraction: metrics.baseFraction,
          baseUsed: metrics.baseUsed * t,
          extraUsed: metrics.extraUsed * t,
          trackColor: scheme.surfaceContainerHighest,
          baseTint: scheme.primary.withValues(alpha: 0.08),
          baseFill: scheme.primary,
          extraTint: scheme.tertiary.withValues(alpha: 0.14),
          hatchColor: scheme.tertiary,
          tickColor: scheme.outlineVariant,
          boundaryColor: scheme.onSurfaceVariant,
        ),
      ),
    );
    return Semantics(
      label: [
        '${'used'.tr()} ${formatFileSize(usedBytes)}',
        'of ${formatFileSize(availableBytes)}',
      ].join(' '),
      value: '${(ratio * 100).toStringAsFixed(1)}%',
      child: animate
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) => gauge(t),
            )
          : gauge(1),
    );
  }

  /// Base solid / extra hatched legend, matching the sidebar's instrument.
  Widget _buildQuotaLegend(BuildContext context, int baseMb, int extraMb) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 20,
      runSpacing: 6,
      children: [
        _LegendItem(
          swatch: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          label: 'baseQuota'.tr(),
          value: formatFileSize(baseMb * 1024 * 1024),
        ),
        if (extraMb > 0)
          _LegendItem(
            swatch: ClipRect(
              child: CustomPaint(
                size: const Size(10, 10),
                painter: HatchSwatchPainter(
                  fill: scheme.tertiary.withValues(alpha: 0.35),
                  hatch: scheme.tertiary,
                ),
              ),
            ),
            label: 'quotaPurchaseExtraQuota'.tr(),
            value: formatFileSize(extraMb * 1024 * 1024),
          ),
      ],
    );
  }

  Widget _buildFilesRow(BuildContext context, int fileCount) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          Symbols.insert_drive_file,
          size: 18,
          color: scheme.onSurfaceVariant,
        ),
        const Gap(10),
        Text(
          'files'.tr(),
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          NumberFormat.decimalPattern().format(fileCount),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingRow(BuildContext context, int remainingBytes) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Symbols.storage, size: 18, color: scheme.onSurfaceVariant),
        const Gap(10),
        Text(
          'quotaRemaining'.tr(),
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          formatFileSize(remainingBytes),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatedAt(BuildContext context, String value) {
    final scheme = Theme.of(context).colorScheme;
    final date = DateTime.tryParse(value);
    final formatted = date == null
        ? value
        : DateFormat.yMMMd().add_jm().format(date.toLocal());
    return Row(
      children: [
        Icon(Symbols.schedule, size: 16, color: scheme.onSurfaceVariant),
        const Gap(10),
        Expanded(
          child: Text(
            'quotaCalculatedAt'.tr(args: [formatted]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceLegend(
    BuildContext context,
    List<Map<String, dynamic>> services,
    int availableBytes,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final colors = _poolSegmentColors(scheme, services.length);
    return Column(
      children: [
        for (var i = 0; i < services.length; i++) ...[
          if (i > 0) const Gap(8),
          _PoolLegendRow(
            swatchColor: colors[i],
            name: localizedWorkspaceServiceName(
              services[i]['name']?.toString() ?? 'unknown'.tr(),
            ),
            size: formatFileSize(
              (services[i]['used_bytes'] as num?)?.toInt() ?? 0,
            ),
            share: _percentOf(
              availableBytes > 0
                  ? ((services[i]['used_bytes'] as num?)?.toInt() ?? 0) /
                        availableBytes
                  : 0,
            ),
          ),
        ],
      ],
    );
  }

  /// The signature instrument: pools as tonal segments on the capacity
  /// span, free space as the quiet track remainder, a fill-level marker
  /// where the stored data ends.
  Widget _buildPoolTank(
    BuildContext context,
    List<Map<String, dynamic>> pools,
    int availableBytes,
    bool animate,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final fractions = [
      for (final pool in pools)
        availableBytes > 0
            ? (((pool['usage_bytes'] as num?)?.toInt() ?? 0) / availableBytes)
            : 0.0,
    ];
    final totalBytes = pools.fold<int>(
      0,
      (sum, pool) => sum + ((pool['usage_bytes'] as num?)?.toInt() ?? 0),
    );
    final freeBytes = (availableBytes - totalBytes).clamp(0, availableBytes);
    final summary = [
      for (final pool in pools)
        '${pool['pool_name']} ${formatFileSize(((pool['usage_bytes'] as num?)?.toInt() ?? 0))}',
      '${'freeSpace'.tr()} ${formatFileSize(freeBytes)}',
    ].join(', ');

    Widget tank(double t) => SizedBox(
      height: 16,
      width: double.infinity,
      child: CustomPaint(
        painter: _PoolTankPainter(
          fractions: fractions,
          segmentColors: _poolSegmentColors(scheme, pools.length),
          trackColor: scheme.surfaceContainerHighest,
          tickColor: scheme.onSurfaceVariant.withValues(alpha: 0.45),
          progress: t,
        ),
      ),
    );
    return Semantics(
      label: 'poolUsage'.tr(),
      value: summary,
      child: animate
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) => tank(t),
            )
          : tank(1),
    );
  }

  Widget _buildPoolLegend(
    BuildContext context,
    List<Map<String, dynamic>> pools,
    int availableBytes,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final colors = _poolSegmentColors(scheme, pools.length);
    final totalBytes = pools.fold<int>(
      0,
      (sum, pool) => sum + ((pool['usage_bytes'] as num?)?.toInt() ?? 0),
    );
    final freeBytes = (availableBytes - totalBytes).clamp(0, availableBytes);

    return Column(
      children: [
        for (var i = 0; i < pools.length; i++) ...[
          if (i > 0) const Gap(8),
          _PoolLegendRow(
            swatchColor: colors[i],
            name: pools[i]['pool_name'] as String? ?? 'unknown'.tr(),
            size: formatFileSize(
              ((pools[i]['usage_bytes'] as num?)?.toInt() ?? 0),
            ),
            share: _percentOf(
              availableBytes > 0
                  ? ((pools[i]['usage_bytes'] as num?)?.toInt() ?? 0) /
                        availableBytes
                  : 0,
            ),
          ),
        ],
        const Gap(8),
        _PoolLegendRow(
          swatchColor: scheme.surfaceContainerHighest,
          name: 'freeSpace'.tr(),
          size: formatFileSize(freeBytes),
          share: _percentOf(
            availableBytes > 0 ? freeBytes / availableBytes : 0,
          ),
          isFree: true,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String label,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const Gap(8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Tonal ramp from primary to tertiary across the pools, so the tank
  /// reads as one instrument rather than an assigned rainbow.
  List<Color> _poolSegmentColors(ColorScheme scheme, int count) {
    if (count <= 1) return [scheme.primary];
    return List.generate(
      count,
      (i) => Color.lerp(scheme.primary, scheme.tertiary, i / (count - 1))!,
    );
  }

  String _percentOf(double fraction) {
    final percent = fraction * 100;
    return '${percent.toStringAsFixed(percent >= 9.95 ? 0 : 1)}%';
  }
}

/// Hairline-bordered instrument panel, matching the sidebar's usage card.
class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Color color;
  final String labelKey;

  const _StatusChip({required this.color, required this.labelKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        labelKey.tr(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Widget swatch;
  final String label;
  final String value;

  const _LegendItem({
    required this.swatch,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const Gap(6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
        const Gap(4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PoolLegendRow extends StatelessWidget {
  final Color swatchColor;
  final String name;
  final String size;
  final String share;
  final bool isFree;

  const _PoolLegendRow({
    required this.swatchColor,
    required this.name,
    required this.size,
    required this.share,
    this.isFree = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: swatchColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isFree ? scheme.onSurfaceVariant : scheme.onSurface,
            ),
          ),
        ),
        const Gap(8),
        Text(
          size,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: isFree ? scheme.onSurfaceVariant : scheme.onSurface,
          ),
        ),
        const Gap(8),
        SizedBox(
          width: 48,
          child: Text(
            share,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws the pool tank: rounded track, tonal pool segments sized by bytes,
/// thin ticks where pools meet, and a taller marker where the stored data
/// ends (the start of free space). [progress] scales segment widths so the
/// tank can animate in from empty; ticks slide with the fill.
class _PoolTankPainter extends CustomPainter {
  final List<double> fractions;
  final List<Color> segmentColors;
  final Color trackColor;
  final Color tickColor;
  final double progress;

  const _PoolTankPainter({
    required this.fractions,
    required this.segmentColors,
    required this.trackColor,
    required this.tickColor,
    this.progress = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final trackRRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(999),
    );
    final width = size.width;

    canvas.save();
    canvas.clipRRect(trackRRect);
    canvas.drawRRect(trackRRect, Paint()..color = trackColor);

    var x = 0.0;
    for (var i = 0; i < fractions.length; i++) {
      final segmentWidth = width * fractions[i] * progress;
      if (segmentWidth <= 0) continue;
      canvas.drawRect(
        Rect.fromLTWH(x, 0, segmentWidth, size.height),
        Paint()..color = segmentColors[i % segmentColors.length],
      );
      x += segmentWidth;
    }
    canvas.restore();

    // Thin ticks where pools meet.
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1.2;
    var tickX = 0.0;
    for (var i = 0; i < fractions.length - 1; i++) {
      tickX += width * fractions[i] * progress;
      if (tickX <= 0 || tickX >= width) continue;
      canvas.drawLine(Offset(tickX, 0), Offset(tickX, size.height), tickPaint);
    }

    // Fill-level marker: where the stored data ends.
    final usedWidth = fractions.fold<double>(
      0,
      (sum, f) => sum + width * f * progress,
    );
    if (usedWidth > 0 && usedWidth < width) {
      final levelPaint = Paint()
        ..color = tickColor
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(usedWidth, -3),
        Offset(usedWidth, size.height + 3),
        levelPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_PoolTankPainter oldDelegate) {
    if (oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.tickColor != tickColor ||
        oldDelegate.fractions.length != fractions.length ||
        oldDelegate.segmentColors.length != segmentColors.length) {
      return true;
    }
    for (var i = 0; i < fractions.length; i++) {
      if (oldDelegate.fractions[i] != fractions[i]) return true;
    }
    for (var i = 0; i < segmentColors.length; i++) {
      if (oldDelegate.segmentColors[i] != segmentColors[i]) return true;
    }
    return false;
  }
}
