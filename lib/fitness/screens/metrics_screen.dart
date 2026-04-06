import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/fitness/screens/metric_record_screen.dart';
import 'package:island/fitness/utils/metric_unit_formatter.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class MetricsScreen extends ConsumerStatefulWidget {
  const MetricsScreen({super.key});

  @override
  ConsumerState<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends ConsumerState<MetricsScreen> {
  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(
      metricsProvider((type: null, skip: 0, take: 100)),
    );

    return AppScaffold(
      appBar: AppBar(title: const Text('Metrics')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(metricsProvider((type: null, skip: 0, take: 100)));
        },
        child: metricsAsync.when(
          data: (result) {
            if (result.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No metrics yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showRecordMetricSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Record Metric'),
                    ),
                  ],
                ),
              );
            }

            final grouped = <FitnessMetricType, List<SnFitnessMetric>>{};
            for (final metric in result.items) {
              grouped.putIfAbsent(metric.metricType, () => []).add(metric);
            }

            final types = grouped.keys.toList()
              ..sort((a, b) => a.index.compareTo(b.index));

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                final metrics = grouped[type]!;
                return _MetricCard(type: type, metrics: metrics);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordMetricSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Record Metric'),
      ),
    );
  }

  void _showRecordMetricSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const MetricRecordScreen(),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final FitnessMetricType type;
  final List<SnFitnessMetric> metrics;

  const _MetricCard({required this.type, required this.metrics});

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    final latestMetric = metrics.first;
    final avgValue = metrics.isNotEmpty
        ? metrics.map((m) => m.value).reduce((a, b) => a + b) / metrics.length
        : 0.0;

    final displayValue = formatMetricValue(
      latestMetric.value,
      latestMetric.unit,
    );
    final avgDisplay = '${formatMetricValue(avgValue, latestMetric.unit)} avg';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.router.push(MetricDetailRoute(metricType: type)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  _getMetricIcon(type),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMetricName(type),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      displayValue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$avgDisplay • ${metrics.length} records',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ).alignment(Alignment.centerRight),
            ],
          ),
        ),
      ),
    );
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
