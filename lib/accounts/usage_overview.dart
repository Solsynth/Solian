import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/core/utils/format.dart';
import 'package:styled_widget/styled_widget.dart';

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
    final nonNullUsage = usage!;
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'All Uploads',
                    formatFileSize(nonNullUsage['total_usage_bytes'] as int),
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'All Files',
                    '${nonNullUsage['total_file_count']}',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Quota',
                    formatFileSize(
                      (nonNullUsage['total_quota'] as int) * 1024 * 1024,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Used Quota',
                    '${((nonNullUsage['used_quota'] as num) / (nonNullUsage['total_quota'] as num) * 100).toStringAsFixed(2)}%',
                    progress:
                        (nonNullUsage['used_quota'] as num) /
                        (nonNullUsage['total_quota'] as num),
                  ),
                ),
              ],
            ),
          ],
        ).padding(horizontal: 8),
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Pool Usage'),
                      SizedBox(
                        height: 200,
                        child: PieChart(_buildPoolChartData(nonNullUsage)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Verbose Quota'),
                      SizedBox(
                        height: 200,
                        child: PieChart(_buildQuotaChartData(quota)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ).padding(horizontal: 8),
      ],
    );
  }

  PieChartData _buildPoolChartData(Map<String, dynamic> usage) {
    final pools = usage['pool_usages'] as List<dynamic>;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    return PieChartData(
      sections:
          pools.asMap().entries.map((entry) {
            final pool = entry.value as Map<String, dynamic>;
            final title = pool['pool_name'] as String;
            final truncatedTitle =
                title.length > 8 ? '${title.substring(0, 8)}...' : title;
            return PieChartSectionData(
              value: (pool['usage_bytes'] as num).toDouble(),
              title: truncatedTitle,
              color: colors[entry.key % colors.length],
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
    );
  }

  PieChartData _buildQuotaChartData(Map<String, dynamic>? quota) {
    if (quota == null) return PieChartData(sections: []);
    return PieChartData(
      sections: [
        PieChartSectionData(
          value: (quota['based_quota'] as num).toDouble(),
          title: 'Base',
          color: Colors.green,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        PieChartSectionData(
          value: (quota['extra_quota'] as num).toDouble(),
          title: 'Extra',
          color: Colors.orange,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, {double? progress}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(value: progress),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
