import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/fitness/utils/metric_unit_formatter.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

enum MetricTimeRange {
  week(7, '7 Days'),
  month(30, '30 Days'),
  threeMonths(90, '90 Days');

  final int days;
  final String label;

  const MetricTimeRange(this.days, this.label);
}

@RoutePage()
class MetricDetailScreen extends ConsumerStatefulWidget {
  final FitnessMetricType metricType;

  const MetricDetailScreen({super.key, required this.metricType});

  @override
  ConsumerState<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends ConsumerState<MetricDetailScreen> {
  MetricTimeRange _selectedRange = MetricTimeRange.week;

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(
      metricsProvider((
        type: widget.metricType,
        skip: 0,
        take: _selectedRange.days,
      )),
    );

    return AppScaffold(
      appBar: AppBar(title: Text(_getMetricName(widget.metricType))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimeRangeSelector(),
          Expanded(
            child: metricsAsync.when(
              data: (result) {
                if (result.items.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildContent(context, result.items);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SegmentedButton<MetricTimeRange>(
          segments: MetricTimeRange.values
              .map(
                (range) =>
                    ButtonSegment(value: range, label: Text(range.label)),
              )
              .toList(),
          selected: {_selectedRange},
          onSelectionChanged: (selection) {
            setState(() => _selectedRange = selection.first);
          },
        ),
      ),
    ).padding(bottom: 12);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getMetricIcon(widget.metricType),
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_getMetricName(widget.metricType).toLowerCase()} data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Import from Health to see your data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SnFitnessMetric> metrics) {
    final sortedMetrics = List<SnFitnessMetric>.from(metrics)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final stats = _calculateStats(sortedMetrics);
    final chartData = _prepareChartData(sortedMetrics);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(
          metricsProvider((
            type: widget.metricType,
            skip: 0,
            take: _selectedRange.days,
          )),
        );
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildStatsCards(context, stats),
          const SizedBox(height: 24),
          Text(
            'Trend',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildChart(context, chartData)),
          const SizedBox(height: 24),
          Text(
            'Recent Records',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildRecentRecords(context, sortedMetrics),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, _MetricStats stats) {
    final latestMetric = stats.latest;
    final unit = latestMetric?.unit ?? '';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Latest',
            value: latestMetric != null
                ? formatMetricValue(latestMetric.value, unit)
                : '--',
            icon: Icons.access_time,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Average',
            value: formatMetricValue(stats.average, unit),
            icon: Icons.analytics_outlined,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Min',
            value: formatMetricValue(stats.min, unit),
            icon: Icons.arrow_downward,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Max',
            value: formatMetricValue(stats.max, unit),
            icon: Icons.arrow_upward,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, List<_ChartPoint> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    final minY = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final maxY = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      return const Center(child: Text('Not enough data variation'));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (data.length / 5).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatChartDate(data[index].date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatChartValue(value),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY - padding,
        maxY: maxY + padding,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.spotIndex;
                final point = data[index];
                return LineTooltipItem(
                  '${formatMetricValue(point.value, '')}\n${_formatChartDate(point.date)}',
                  TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecords(
    BuildContext context,
    List<SnFitnessMetric> sortedMetrics,
  ) {
    final unit = sortedMetrics.isNotEmpty ? sortedMetrics.first.unit : '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedMetrics.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final metric = sortedMetrics[index];
          return ListTile(
            title: Text(
              formatMetricValue(metric.value, unit),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(_formatRecordDate(metric.recordedAt)),
            trailing: Text(
              formatSource(metric.source),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }

  _MetricStats _calculateStats(List<SnFitnessMetric> metrics) {
    if (metrics.isEmpty) {
      return _MetricStats(latest: null, average: 0, min: 0, max: 0);
    }

    final values = metrics.map((m) => m.value).toList();
    final sum = values.reduce((a, b) => a + b);
    final avg = sum / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return _MetricStats(latest: metrics.last, average: avg, min: min, max: max);
  }

  List<_ChartPoint> _prepareChartData(List<SnFitnessMetric> metrics) {
    return metrics.map((m) => _ChartPoint(m.recordedAt, m.value)).toList();
  }

  String _formatChartDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _formatRecordDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatChartValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  IconData _getMetricIcon(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => Symbols.monitor_weight,
      FitnessMetricType.bodyFat => Symbols.percent,
      FitnessMetricType.steps => Symbols.directions_walk,
      FitnessMetricType.heartRate => Symbols.monitor_heart,
      FitnessMetricType.sleep => Symbols.bedtime,
      FitnessMetricType.calories => Symbols.local_fire_department,
      FitnessMetricType.waterIntake => Symbols.water_drop,
      FitnessMetricType.distance => Symbols.directions_run,
      FitnessMetricType.custom => Symbols.show_chart,
    };
  }

  String _getMetricName(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => 'Weight',
      FitnessMetricType.bodyFat => 'Body Fat',
      FitnessMetricType.steps => 'Steps',
      FitnessMetricType.heartRate => 'Heart Rate',
      FitnessMetricType.sleep => 'Sleep',
      FitnessMetricType.calories => 'Calories',
      FitnessMetricType.waterIntake => 'Water Intake',
      FitnessMetricType.distance => 'Distance',
      FitnessMetricType.custom => 'Custom',
    };
  }
}

class _MetricStats {
  final SnFitnessMetric? latest;
  final double average;
  final double min;
  final double max;

  _MetricStats({
    required this.latest,
    required this.average,
    required this.min,
    required this.max,
  });
}

class _ChartPoint {
  final DateTime date;
  final double value;

  _ChartPoint(this.date, this.value);
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
