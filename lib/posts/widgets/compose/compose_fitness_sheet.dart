import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final composeFitnessWorkoutsProvider = FutureProvider.autoDispose
    .family<List<_FitnessItem>, String>((ref, accountId) async {
      final client = ref.watch(solarNetworkClientProvider);
      final fitness = client.fitness;

      final workouts = await fitness.getWorkouts(skip: 0, take: 50);
      return workouts.items
          .where((w) => w.visibility == FitnessVisibility.public)
          .map(
            (w) => _FitnessItem(
              id: w.id,
              type: _FitnessItemType.workout,
              name: w.name,
              date: w.startTime,
              subtitle: w.caloriesBurned != null
                  ? '${w.caloriesBurned} kcal'
                  : null,
            ),
          )
          .toList();
    });

final composeFitnessMetricsProvider = FutureProvider.autoDispose
    .family<List<_FitnessItem>, String>((ref, accountId) async {
      final client = ref.watch(solarNetworkClientProvider);
      final fitness = client.fitness;

      final metrics = await fitness.getMetrics(skip: 0, take: 50);
      return metrics.items
          .where((m) => m.visibility == FitnessVisibility.public)
          .map(
            (m) => _FitnessItem(
              id: m.id,
              type: _FitnessItemType.metric,
              name: '${_getMetricTypeName(m.metricType)}: ${m.value} ${m.unit}',
              date: m.recordedAt,
              subtitle: _formatDate(m.recordedAt),
            ),
          )
          .toList();
    });

final composeFitnessGoalsProvider = FutureProvider.autoDispose
    .family<List<_FitnessItem>, String>((ref, accountId) async {
      final client = ref.watch(solarNetworkClientProvider);
      final fitness = client.fitness;

      final goals = await fitness.getGoals(skip: 0, take: 50);
      return goals.items
          .where((g) => g.visibility == FitnessVisibility.public)
          .map(
            (g) => _FitnessItem(
              id: g.id,
              type: _FitnessItemType.goal,
              name: g.title,
              date: g.startDate,
              subtitle: g.targetValue != null
                  ? '${g.currentValue?.toStringAsFixed(0) ?? 0} / ${g.targetValue!.toStringAsFixed(0)} ${g.unit ?? ''}'
                  : null,
            ),
          )
          .toList();
    });

enum _FitnessItemType { workout, metric, goal }

class _FitnessItem {
  final String id;
  final _FitnessItemType type;
  final String name;
  final DateTime date;
  final String? subtitle;

  _FitnessItem({
    required this.id,
    required this.type,
    required this.name,
    required this.date,
    this.subtitle,
  });

  String get reference => switch (type) {
    _FitnessItemType.workout => 'workout:$id',
    _FitnessItemType.metric => 'metric:$id',
    _FitnessItemType.goal => 'goal:$id',
  };

  IconData get icon => switch (type) {
    _FitnessItemType.workout => Symbols.fitness_center,
    _FitnessItemType.metric => Symbols.monitor_weight,
    _FitnessItemType.goal => Icons.flag,
  };
}

String _getMetricTypeName(FitnessMetricType type) {
  return switch (type) {
    FitnessMetricType.weight => 'Weight',
    FitnessMetricType.bodyFat => 'Body Fat',
    FitnessMetricType.steps => 'Steps',
    FitnessMetricType.heartRate => 'Heart Rate',
    FitnessMetricType.sleep => 'Sleep',
    FitnessMetricType.calories => 'Calories',
    FitnessMetricType.waterIntake => 'Water',
    FitnessMetricType.distance => 'Distance',
    FitnessMetricType.custom => 'Custom',
  };
}

String _formatDate(DateTime date) {
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

class ComposeFitnessSheet extends ConsumerWidget {
  final void Function(String reference) onSelected;

  const ComposeFitnessSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: SheetScaffold(
        heightFactor: 0.7,
        titleText: 'Fitness',
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Workouts'),
                Tab(text: 'Metrics'),
                Tab(text: 'Goals'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _WorkoutsTab(onSelected: onSelected),
                  _MetricsTab(onSelected: onSelected),
                  _GoalsTab(onSelected: onSelected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutsTab extends ConsumerWidget {
  final void Function(String reference) onSelected;

  const _WorkoutsTab({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(composeFitnessWorkoutsProvider('current'));

    return workoutsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No public workouts'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.name),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              onTap: () {
                onSelected(item.reference);
                Navigator.pop(context);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _MetricsTab extends ConsumerWidget {
  final void Function(String reference) onSelected;

  const _MetricsTab({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(composeFitnessMetricsProvider('current'));

    return metricsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No public metrics'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.name),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              onTap: () {
                onSelected(item.reference);
                Navigator.pop(context);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _GoalsTab extends ConsumerWidget {
  final void Function(String reference) onSelected;

  const _GoalsTab({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(composeFitnessGoalsProvider('current'));

    return goalsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No public goals'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.name),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              onTap: () {
                onSelected(item.reference);
                Navigator.pop(context);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
