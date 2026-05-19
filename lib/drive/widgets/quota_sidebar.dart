import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A compact quota overview widget designed for sidebar display.
/// Shows essential storage metrics in a clean, space-efficient layout.
class QuotaSidebarWidget extends StatelessWidget {
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final List<SnFilePool>? pools;
  final SnFilePool? selectedPool;
  final ValueChanged<SnFilePool?>? onPoolSelected;
  final VoidCallback? onViewDetails;

  const QuotaSidebarWidget({
    super.key,
    required this.usage,
    required this.quota,
    this.pools,
    this.selectedPool,
    this.onPoolSelected,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (usage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final nonNullUsage = usage!;
    final usedBytes = nonNullUsage['total_usage_bytes'] as int? ?? 0;
    final fileCount = nonNullUsage['total_file_count'] as int? ?? 0;
    final totalQuota = nonNullUsage['total_quota'] as int? ?? 0;
    final usedQuota = nonNullUsage['used_quota'] as num? ?? 0;
    final poolUsages = nonNullUsage['pool_usages'] as List<dynamic>? ?? [];

    final usedQuotaBytes = (usedQuota * 1024 * 1024).round();
    final quotaBytes = totalQuota * 1024 * 1024;
    final usageRatio = totalQuota > 0 ? usedQuota / totalQuota : 0.0;

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

          // Usage Progress Card
          _buildUsageCard(context, usedQuotaBytes, quotaBytes, usageRatio),
          const Gap(16),

          // Quick Stats Row
          _buildStatsRow(context, fileCount, usedBytes, usedQuotaBytes),
          const Gap(24),

          // Pool Filter Section
          if (pools != null && pools!.isNotEmpty) ...[
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

          // View Details Button
          if (onViewDetails != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Symbols.bar_chart, size: 18),
                label: Text('viewDetails').tr(),
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
    int quotaBytes,
    double usageRatio,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final usageColor = _getUsageColor(usageRatio);

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Gap(2),
                    Text(
                      formatFileSize(usedQuotaBytes),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'total',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ).tr(),
                    const Gap(2),
                    Text(
                      formatFileSize(quotaBytes),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usageRatio.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(usageColor),
              ),
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(usageRatio * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: usageColor,
                  ),
                ),
                _buildUsageStatus(context, usageRatio),
              ],
            ),
          ],
        ),
      ),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

/// Extension for responsive sidebar to provide consistent width
class DriveQuotaSidebar extends StatelessWidget {
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final List<SnFilePool>? pools;
  final SnFilePool? selectedPool;
  final ValueChanged<SnFilePool?>? onPoolSelected;
  final VoidCallback? onViewDetails;

  const DriveQuotaSidebar({
    super.key,
    required this.usage,
    required this.quota,
    this.pools,
    this.selectedPool,
    this.onPoolSelected,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'storage'.tr(),
      heightFactor: 0.85,
      child: QuotaSidebarWidget(
        usage: usage,
        quota: quota,
        pools: pools,
        selectedPool: selectedPool,
        onPoolSelected: onPoolSelected,
        onViewDetails: onViewDetails,
      ),
    );
  }
}
