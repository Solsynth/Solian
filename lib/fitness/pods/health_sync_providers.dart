import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/fitness/services/health_sync_service.dart';

final healthProvider = Provider<Health>((ref) {
  return Health();
});

final healthSyncServiceProvider = Provider<HealthSyncService>((ref) {
  final health = ref.watch(healthProvider);
  final fitnessApi = ref.watch(solarNetworkClientProvider).fitness;
  final prefs = ref.watch(sharedPreferencesProvider);
  return HealthSyncService(
    health: health,
    fitnessApi: fitnessApi,
    prefs: prefs,
  );
});

final healthRecordsProvider = FutureProvider.autoDispose<List<HealthRecord>>((
  ref,
) async {
  final syncService = ref.watch(healthSyncServiceProvider);
  final health = ref.watch(healthProvider);
  final types = await syncService.getAvailableTypes();

  try {
    final hasPermission = await health.hasPermissions(types.toList());
    if (Platform.isIOS || (Platform.isAndroid && hasPermission == true)) {
      return syncService.fetchAllRecords();
    }
    return [];
  } catch (e) {
    return [];
  }
});

final selectedRecordUuidsProvider = Provider<Set<String>>((ref) => <String>{});

final selectedTypesForSyncProvider = Provider<Set<HealthDataType>>(
  (ref) => <HealthDataType>{},
);

final syncResultProvider = Provider<SyncResult?>((ref) => null);

final isSyncingProvider = Provider<bool>((ref) => false);

final groupedRecordsProvider =
    Provider.autoDispose<Map<HealthDataType, List<HealthRecord>>>((ref) {
      final records = ref.watch(healthRecordsProvider);

      return records.when(
        data: (allRecords) {
          final grouped = <HealthDataType, List<HealthRecord>>{};
          for (final record in allRecords) {
            grouped.putIfAbsent(record.type, () => []).add(record);
          }
          return grouped;
        },
        loading: () => {},
        error: (_, __) => {},
      );
    });

final recordCountByTypeProvider =
    Provider.autoDispose<Map<HealthDataType, int>>((ref) {
      final grouped = ref.watch(groupedRecordsProvider);
      return grouped.map((key, value) => MapEntry(key, value.length));
    });

final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  final syncService = ref.watch(healthSyncServiceProvider);
  final lastWorkouts = syncService.lastSyncWorkouts;
  final lastMetrics = syncService.lastSyncMetrics;

  if (lastWorkouts == null && lastMetrics == null) return null;
  if (lastWorkouts == null) return lastMetrics;
  if (lastMetrics == null) return lastWorkouts;

  return lastWorkouts.isAfter(lastMetrics) ? lastWorkouts : lastMetrics;
});

class SelectedRecordsNotifier {
  final Set<String> _selected = {};

  Set<String> get selected => _selected;

  void toggle(String uuid) {
    if (_selected.contains(uuid)) {
      _selected.remove(uuid);
    } else {
      _selected.add(uuid);
    }
  }

  void selectAll(List<String> uuids) {
    _selected.addAll(uuids);
  }

  void deselectAll() {
    _selected.clear();
  }

  bool isSelected(String uuid) => _selected.contains(uuid);
}

final selectedRecordsNotifierProvider = Provider<SelectedRecordsNotifier>(
  (ref) => SelectedRecordsNotifier(),
);

class SelectedTypesNotifier {
  final Set<HealthDataType> _selected = {};

  Set<HealthDataType> get selected => _selected;

  void toggle(HealthDataType type) {
    if (_selected.contains(type)) {
      _selected.remove(type);
    } else {
      _selected.add(type);
    }
  }

  void selectAll(Set<HealthDataType> types) {
    _selected.addAll(types);
  }

  void deselectAll() {
    _selected.clear();
  }

  bool isSelected(HealthDataType type) => _selected.contains(type);
}

final selectedTypesNotifierProvider = Provider<SelectedTypesNotifier>(
  (ref) => SelectedTypesNotifier(),
);
