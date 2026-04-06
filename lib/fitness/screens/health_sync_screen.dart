import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/fitness/pods/health_sync_providers.dart';
import 'package:island/fitness/services/health_sync_service.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class HealthSyncScreen extends ConsumerStatefulWidget {
  const HealthSyncScreen({super.key});

  @override
  ConsumerState<HealthSyncScreen> createState() => _HealthSyncScreenState();
}

class _HealthSyncScreenState extends ConsumerState<HealthSyncScreen> {
  final Set<String> _selectedUuids = {};
  final Set<HealthDataType> _selectedTypes = {};
  bool _isSyncing = false;
  FitnessVisibility _visibility = FitnessVisibility.private;

  Future<void> _requestPermissions() async {
    final syncService = ref.read(healthSyncServiceProvider);
    final granted = await syncService.requestPermissions();
    if (granted) {
      ref.invalidate(healthRecordsProvider);
    }
  }

  Future<void> _sync() async {
    if (_selectedUuids.isEmpty) {
      showSnackBar('Please select records to sync');
      return;
    }

    if (_selectedTypes.isEmpty) {
      showSnackBar('Please select at least one data type');
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final syncService = ref.read(healthSyncServiceProvider);
      final records = await ref.read(healthRecordsProvider.future);
      final selectedRecords = records
          .where((r) => _selectedUuids.contains(r.uuid))
          .toList();

      final result = await syncService.syncRecords(
        records: selectedRecords,
        selectedTypes: _selectedTypes,
        visibility: _visibility,
      );

      setState(() {
        _isSyncing = false;
        if (result.success) {
          _selectedUuids.clear();
          _selectedTypes.clear();
        }
      });

      if (mounted) {
        if (result.success) {
          showSnackBar('Synced ${result.uploaded} records');
        } else {
          showErrorAlert('Sync failed: ${result.error}');
        }
      }
    } catch (e) {
      setState(() => _isSyncing = false);
      if (mounted) {
        showErrorAlert('Sync failed: $e');
      }
    }
  }

  void _toggleRecord(String uuid) {
    setState(() {
      if (_selectedUuids.contains(uuid)) {
        _selectedUuids.remove(uuid);
      } else {
        _selectedUuids.add(uuid);
      }
    });
  }

  void _toggleType(HealthDataType type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  void _selectAllOfType(List<HealthRecord> records) {
    for (final record in records) {
      _selectedUuids.add(record.uuid);
    }
    setState(() {});
  }

  void _deselectAllOfType(List<HealthRecord> records) {
    for (final record in records) {
      _selectedUuids.remove(record.uuid);
    }
    setState(() {});
  }

  void _selectAll() {
    _selectedTypes.addAll(_getAvailableTypes());
    final records = ref.read(healthRecordsProvider).value ?? [];
    for (final record in records) {
      _selectedUuids.add(record.uuid);
    }
    setState(() {});
  }

  void _deselectAll() {
    _selectedTypes.clear();
    _selectedUuids.clear();
    setState(() {});
  }

  Set<HealthDataType> _getAvailableTypes() {
    final records = ref.read(healthRecordsProvider).value ?? [];
    return records.map((r) => r.type).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(healthRecordsProvider);
    final lastSync = ref.watch(lastSyncTimeProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('healthSync').tr(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(healthRecordsProvider),
          ),
          if (_selectedUuids.isNotEmpty || _selectedTypes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
              onPressed: _deselectAll,
            ),
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: 'Select All',
            onPressed: _selectAll,
          ),
          const Gap(8),
        ],
      ),
      body: recordsAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return _buildPermissionRequest();
          }
          return _buildContent(recordsAsync, lastSync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(healthRecordsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _selectedUuids.isNotEmpty && _selectedTypes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isSyncing ? null : _sync,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Symbols.cloud_upload),
              label: Text(
                _isSyncing
                    ? 'Syncing...'
                    : 'Sync ${_selectedUuids.length} records',
              ),
            )
          : null,
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.fitness_center, size: 64),
            const SizedBox(height: 16),
            Text(
              'healthPermissionRequired',
              style: Theme.of(context).textTheme.headlineSmall,
            ).tr(),
            const SizedBox(height: 8),
            Text(
              'healthPermissionDescription',
              textAlign: TextAlign.center,
            ).tr(),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _requestPermissions,
              icon: const Icon(Symbols.health_and_safety),
              label: const Text('grantPermission').tr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<List<HealthRecord>> recordsAsync,
    DateTime? lastSync,
  ) {
    return recordsAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return _buildEmptyState();
        }

        final grouped = <HealthDataType, List<HealthRecord>>{};
        for (final record in records) {
          grouped.putIfAbsent(record.type, () => []).add(record);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTypeSelector(grouped),
            if (lastSync != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Row(
                  spacing: 8,
                  children: [
                    const Icon(Symbols.sync, size: 20),
                    Text(
                      'Last sync: ${_formatDate(lastSync)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final type = grouped.keys.elementAt(index);
                  final typeRecords = grouped[type]!;
                  return _buildTypeSection(type, typeRecords);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTypeSelector(Map<HealthDataType, List<HealthRecord>> grouped) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Data Types',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton(
                onPressed: () {
                  final allTypes = grouped.keys.toSet();
                  if (_selectedTypes.containsAll(allTypes)) {
                    _selectedTypes.clear();
                  } else {
                    _selectedTypes.addAll(allTypes);
                  }
                  setState(() {});
                },
                child: Text(
                  _selectedTypes.length == grouped.length
                      ? 'Deselect All'
                      : 'Select All',
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: grouped.keys.map((type) {
              final isSelected = _selectedTypes.contains(type);
              final count = grouped[type]!.length;
              return FilterChip(
                label: Text('${_getTypeName(type)} ($count)'),
                selected: isSelected,
                onSelected: (_) => _toggleType(type),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Visibility:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 16),
              SegmentedButton<FitnessVisibility>(
                segments: const [
                  ButtonSegment(
                    value: FitnessVisibility.private,
                    label: Text('Private'),
                  ),
                  ButtonSegment(
                    value: FitnessVisibility.public,
                    label: Text('Public'),
                  ),
                ],
                selected: {_visibility},
                onSelectionChanged: (selection) {
                  setState(() {
                    _visibility = selection.first;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection(HealthDataType type, List<HealthRecord> records) {
    final typeSelected = _selectedTypes.contains(type);
    final typeRecordsSelected = records
        .where((r) => _selectedUuids.contains(r.uuid))
        .length;

    return ExpansionTile(
      title: Row(
        children: [
          Icon(_getTypeIcon(type), size: 20),
          const SizedBox(width: 8),
          Text(_getTypeName(type)),
          const Spacer(),
          Text(
            '$typeRecordsSelected / ${records.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      initiallyExpanded: false,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => _selectAllOfType(records),
              child: const Text('Select All'),
            ),
            TextButton(
              onPressed: () => _deselectAllOfType(records),
              child: const Text('Deselect All'),
            ),
          ],
        ),
        ...records.map((record) => _buildRecordTile(record, typeSelected)),
      ],
    );
  }

  Widget _buildRecordTile(HealthRecord record, bool typeSelected) {
    final isSelected = _selectedUuids.contains(record.uuid);

    return ListTile(
      leading: typeSelected
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleRecord(record.uuid),
            )
          : Icon(_getTypeIcon(record.type), size: 20),
      title: Text(record.displayName),
      subtitle: Text(
        '${_formatDate(record.startDate)} - ${record.valueDisplay}',
      ),
      trailing: Text(
        record.source,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: typeSelected ? () => _toggleRecord(record.uuid) : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.inbox, size: 64),
            const SizedBox(height: 16),
            Text(
              'No health data found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your fitness with Apple Health or Google Fit to see your data here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeName(HealthDataType type) {
    switch (type) {
      case HealthDataType.WORKOUT:
        return 'Workouts';
      case HealthDataType.STEPS:
        return 'Steps';
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return 'Calories';
      case HealthDataType.HEART_RATE:
        return 'Heart Rate';
      case HealthDataType.WEIGHT:
        return 'Weight';
      case HealthDataType.HEIGHT:
        return 'Height';
      case HealthDataType.BODY_MASS_INDEX:
        return 'BMI';
      case HealthDataType.SLEEP_ASLEEP:
        return 'Sleep (Asleep)';
      case HealthDataType.SLEEP_AWAKE:
        return 'Sleep (Awake)';
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return 'Distance';
      default:
        return type.name;
    }
  }

  IconData _getTypeIcon(HealthDataType type) {
    switch (type) {
      case HealthDataType.WORKOUT:
        return Symbols.fitness_center;
      case HealthDataType.STEPS:
        return Symbols.directions_walk;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return Symbols.local_fire_department;
      case HealthDataType.HEART_RATE:
        return Symbols.monitor_heart;
      case HealthDataType.WEIGHT:
        return Symbols.monitor_weight;
      case HealthDataType.HEIGHT:
        return Symbols.height;
      case HealthDataType.BODY_MASS_INDEX:
        return Symbols.percent;
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_AWAKE:
        return Symbols.bedtime;
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return Symbols.directions_run;
      default:
        return Symbols.show_chart;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
