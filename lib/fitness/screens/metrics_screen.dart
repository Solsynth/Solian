import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/fitness/screens/metric_record_screen.dart';
import 'package:island/fitness/utils/metric_unit_formatter.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class MetricsScreen extends ConsumerStatefulWidget {
  const MetricsScreen({super.key});

  @override
  ConsumerState<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends ConsumerState<MetricsScreen> {
  final Set<String> _selected = {};
  Map<FitnessMetricType, List<SnFitnessMetric>> _currentMetrics = {};
  bool isSelectionMode = false;

  void _enterSelectionMode() {
    setState(() {
      isSelectionMode = true;
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      if (_selected.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  void _selectAllMetrics() {
    setState(() {
      _selected.clear();
      for (final type in _currentMetrics.keys) {
        _selected.add(type.name);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selected.clear();
      isSelectionMode = false;
    });
  }

  Future<void> _updateSelectedVisibility(
    BuildContext context,
    WidgetRef ref,
    FitnessVisibility visibility,
  ) async {
    if (_selected.isEmpty) return;

    try {
      final count = await ref
          .read(metricNotifierProvider.notifier)
          .updateMetricsVisibility(
            metricIds: _selected.toList(),
            visibility: visibility,
          );
      if (context.mounted) {
        showSnackBar('Updated visibility for $count metrics');
        _clearSelection();
      }
    } catch (e) {
      showErrorAlert('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(
      metricsProvider((type: null, skip: 0, take: 100)),
    );
    final isSelectionMode = _selected.isNotEmpty;

    return AppScaffold(
      appBar: AppBar(
        title: isSelectionMode
            ? Text('${_selected.length} selected')
            : const Text('Metrics'),
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: [
          if (isSelectionMode) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.visibility),
              tooltip: 'Set Visibility',
              onSelected: (value) {
                if (value == 'selectAll') {
                  _selectAllMetrics();
                } else if (value == 'private' || value == 'public') {
                  _updateSelectedVisibility(
                    context,
                    ref,
                    value == 'private'
                        ? FitnessVisibility.private
                        : FitnessVisibility.public,
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'selectAll',
                  child: Row(
                    children: [
                      Icon(
                        Icons.select_all,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(width: 12),
                      Text('Select All'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'private',
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(width: 12),
                      Text('Set Private'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'public',
                  child: Row(
                    children: [
                      Icon(
                        Icons.public,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(width: 12),
                      Text('Set Public'),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: 'Select',
              onPressed: _enterSelectionMode,
            ),
          ],
          const Gap(8),
        ],
      ),
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _currentMetrics = grouped;
            });

            final types = grouped.keys.toList()
              ..sort((a, b) => a.index.compareTo(b.index));

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                final metrics = grouped[type]!;
                return _MetricCard(
                  type: type,
                  metrics: metrics,
                  isSelectionMode: isSelectionMode,
                  isSelected: _selected.contains(type.name),
                  onTap: isSelectionMode
                      ? () => _toggleSelection(type.name)
                      : null,
                  onLongPress: () => _toggleSelection(type.name),
                );
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

class _MetricCard extends ConsumerWidget {
  final FitnessMetricType type;
  final List<SnFitnessMetric> metrics;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _MetricCard({
    required this.type,
    required this.metrics,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        onTap: isSelectionMode
            ? onTap
            : () => context.router.push(MetricDetailRoute(metricType: type)),
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (isSelectionMode)
                Checkbox(value: isSelected, onChanged: (_) => onTap?.call()),
              if (isSelectionMode) const SizedBox(width: 8),
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
              PopupMenuButton<String>(
                onSelected: (value) => _handleAction(context, ref, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Symbols.delete,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Delete All',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) async {
    if (action == 'delete') {
      try {
        for (final metric in metrics) {
          await ref
              .read(metricNotifierProvider.notifier)
              .deleteMetric(metric.id);
        }
      } catch (e) {
        showErrorAlert('Error: $e');
      }
    }
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
