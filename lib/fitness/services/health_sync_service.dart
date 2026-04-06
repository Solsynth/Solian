import 'dart:async';
import 'dart:io' show Platform;

import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum SyncType { workouts, metrics }

class SyncResult {
  final bool success;
  final int uploaded;
  final int skipped;
  final String? error;
  final List<String> details;

  const SyncResult({
    required this.success,
    this.uploaded = 0,
    this.skipped = 0,
    this.error,
    this.details = const [],
  });

  factory SyncResult.success({
    int uploaded = 0,
    int skipped = 0,
    List<String> details = const [],
  }) {
    return SyncResult(
      success: true,
      uploaded: uploaded,
      skipped: skipped,
      details: details,
    );
  }

  factory SyncResult.failure(String error) {
    return SyncResult(success: false, error: error);
  }
}

class HealthRecord {
  final String uuid;
  final HealthDataType type;
  final DateTime startDate;
  final DateTime endDate;
  final dynamic value;
  final String unit;
  final HealthWorkoutActivityType? workoutType;
  final String source;
  final bool selected;

  const HealthRecord({
    required this.uuid,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.value,
    required this.unit,
    this.workoutType,
    required this.source,
    this.selected = false,
  });

  HealthRecord copyWith({
    bool? selected,
    HealthDataType? type,
    DateTime? startDate,
    DateTime? endDate,
    dynamic value,
    String? unit,
    HealthWorkoutActivityType? workoutType,
    String? source,
  }) {
    return HealthRecord(
      uuid: uuid,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      workoutType: workoutType ?? this.workoutType,
      source: source ?? this.source,
      selected: selected ?? this.selected,
    );
  }

  String get displayName {
    switch (type) {
      case HealthDataType.WORKOUT:
        return 'Workout (${workoutType?.name ?? 'Unknown'})';
      case HealthDataType.STEPS:
        return 'Steps';
      case HealthDataType.WEIGHT:
        return 'Weight';
      case HealthDataType.HEIGHT:
        return 'Height';
      case HealthDataType.BODY_MASS_INDEX:
        return 'BMI';
      case HealthDataType.HEART_RATE:
        return 'Heart Rate';
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return 'Calories Burned';
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

  String get valueDisplay {
    if (type == HealthDataType.WORKOUT) {
      final duration = endDate.difference(startDate);
      return '${duration.inMinutes} min';
    }
    if (type == HealthDataType.SLEEP_ASLEEP ||
        type == HealthDataType.SLEEP_AWAKE) {
      final duration = endDate.difference(startDate);
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '$value $unit';
  }
}

class HealthSyncService {
  final Health _health;
  final FitnessApi _fitnessApi;
  final SharedPreferences _prefs;

  static const _keyLastSyncWorkouts = 'health_sync_last_workouts';
  static const _keyLastSyncMetrics = 'health_sync_last_metrics';
  static const _keySyncEnabled = 'health_sync_enabled';

  HealthSyncService({
    required Health health,
    required FitnessApi fitnessApi,
    required SharedPreferences prefs,
  }) : _health = health,
       _fitnessApi = fitnessApi,
       _prefs = prefs;

  DateTime? get lastSyncWorkouts {
    final str = _prefs.getString(_keyLastSyncWorkouts);
    return str != null ? DateTime.tryParse(str) : null;
  }

  DateTime? get lastSyncMetrics {
    final str = _prefs.getString(_keyLastSyncMetrics);
    return str != null ? DateTime.tryParse(str) : null;
  }

  bool get syncEnabled => _prefs.getBool(_keySyncEnabled) ?? false;

  Future<void> setSyncEnabled(bool value) async {
    await _prefs.setBool(_keySyncEnabled, value);
  }

  Future<bool> requestPermissions() async {
    await _health.configure();
    final types = await getAvailableTypes();
    return await _health.requestAuthorization(types.toList());
  }

  Future<void> updateLastSync(SyncType type) async {
    final now = DateTime.now().toIso8601String();
    switch (type) {
      case SyncType.workouts:
        await _prefs.setString(_keyLastSyncWorkouts, now);
      case SyncType.metrics:
        await _prefs.setString(_keyLastSyncMetrics, now);
    }
  }

  Future<bool> hasNewDataSince(DateTime since) async {
    final now = DateTime.now();

    if (since.isAfter(now.subtract(const Duration(hours: 1)))) {
      return false;
    }

    final aggregateTypes = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.HEART_RATE,
      HealthDataType.DISTANCE_WALKING_RUNNING,
    ];

    final individualTypes = [
      HealthDataType.WORKOUT,
      HealthDataType.SLEEP_ASLEEP,
    ];

    final latestPerDayTypes = [
      HealthDataType.WEIGHT,
      HealthDataType.BODY_MASS_INDEX,
    ];

    for (final type in [
      ...individualTypes,
      ...latestPerDayTypes,
      ...aggregateTypes,
    ]) {
      try {
        final data = await _health.getHealthDataFromTypes(
          types: [type],
          startTime: since,
          endTime: now,
        );

        if (data.isNotEmpty) {
          return true;
        }
      } catch (_) {
        // Skip types that fail
      }
    }

    return false;
  }

  Future<List<HealthRecord>> fetchAllRecords({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final records = <HealthRecord>[];
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final aggregateTypes = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.HEART_RATE,
      HealthDataType.DISTANCE_WALKING_RUNNING,
    ];

    final individualTypes = [
      HealthDataType.WORKOUT,
      HealthDataType.SLEEP_ASLEEP,
    ];

    final latestPerDayTypes = [
      HealthDataType.WEIGHT,
      HealthDataType.BODY_MASS_INDEX,
    ];

    for (final type in [
      ...individualTypes,
      ...latestPerDayTypes,
      ...aggregateTypes,
    ]) {
      try {
        final data = await _health.getHealthDataFromTypes(
          types: [type],
          startTime: start,
          endTime: end,
        );

        if (data.isEmpty) continue;

        List<HealthRecord> processedRecords;

        if (aggregateTypes.contains(type)) {
          processedRecords = _aggregateByDay(data, type);
        } else if (latestPerDayTypes.contains(type)) {
          processedRecords = _latestPerDay(data);
        } else {
          processedRecords = data.map((p) => _pointToRecord(p)).toList();
        }

        records.addAll(processedRecords);
      } catch (e) {
        // Skip types that fail
      }
    }

    records.sort((a, b) => b.startDate.compareTo(a.startDate));
    return records;
  }

  HealthRecord _pointToRecord(HealthDataPoint point) {
    final value = point.value;
    HealthWorkoutActivityType? workoutType;

    if (value is WorkoutHealthValue) {
      workoutType = value.workoutActivityType;
    }

    return HealthRecord(
      uuid: point.uuid,
      type: point.type,
      startDate: point.dateFrom,
      endDate: point.dateTo,
      value: _extractValue(point),
      unit: point.unitString,
      source: point.sourceName,
      workoutType: workoutType,
    );
  }

  List<HealthRecord> _aggregateByDay(
    List<HealthDataPoint> data,
    HealthDataType type,
  ) {
    final byDay = <String, List<HealthDataPoint>>{};

    for (final point in data) {
      final key = _dateKey(point.dateFrom);
      byDay.putIfAbsent(key, () => []).add(point);
    }

    final aggregated = <HealthRecord>[];

    for (final entry in byDay.entries) {
      final dayPoints = entry.value;
      if (dayPoints.isEmpty) continue;

      final first = dayPoints.first;
      final values = dayPoints
          .map((p) => (p.value as NumericHealthValue).numericValue)
          .toList();

      double aggValue;
      if (type == HealthDataType.HEART_RATE) {
        aggValue = values.reduce((a, b) => a + b).toDouble() / values.length;
      } else {
        aggValue = values.reduce((a, b) => a + b).toDouble();
      }

      aggregated.add(
        HealthRecord(
          uuid: '${type.name}_${entry.key}_agg',
          type: type,
          startDate: first.dateFrom,
          endDate: first.dateTo,
          value: aggValue,
          unit: first.unitString,
          source: first.sourceName,
        ),
      );
    }

    return aggregated;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<HealthRecord> _latestPerDay(List<HealthDataPoint> data) {
    final byDay = <String, HealthDataPoint>{};

    for (final point in data) {
      final key = _dateKey(point.dateFrom);
      if (!byDay.containsKey(key)) {
        byDay[key] = point;
      }
    }

    return byDay.values.map((p) => _pointToRecord(p)).toList();
  }

  dynamic _extractValue(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue;
    }
    if (value is WorkoutHealthValue) {
      return value;
    }
    return value.toString();
  }

  Future<SyncResult> syncRecords({
    required List<HealthRecord> records,
    required Set<HealthDataType> selectedTypes,
    FitnessVisibility visibility = FitnessVisibility.private,
  }) async {
    if (records.isEmpty) {
      return SyncResult.success(details: ['No records to sync']);
    }

    final workoutRecords = <HealthRecord>[];
    final metricRecords = <HealthRecord>[];

    for (final record in records) {
      if (!selectedTypes.contains(record.type)) {
        continue;
      }

      if (record.type == HealthDataType.WORKOUT) {
        workoutRecords.add(record);
      } else {
        metricRecords.add(record);
      }
    }

    try {
      if (workoutRecords.isNotEmpty) {
        final workouts = workoutRecords
            .map((r) => _buildWorkoutRequest(r, visibility))
            .toList();
        await _fitnessApi.createWorkoutsBatch(
          CreateWorkoutsBatchRequest(workouts: workouts),
        );
      }

      if (metricRecords.isNotEmpty) {
        final metrics = metricRecords
            .map((r) => _buildMetricRequest(r, visibility))
            .toList();
        await _fitnessApi.createMetricsBatch(
          CreateMetricsBatchRequest(metrics: metrics),
        );
      }

      await updateLastSync(SyncType.workouts);
      await updateLastSync(SyncType.metrics);

      return SyncResult.success(
        uploaded: workoutRecords.length + metricRecords.length,
        details: [
          'Uploaded ${workoutRecords.length} workouts and ${metricRecords.length} metrics',
        ],
      );
    } catch (e) {
      return SyncResult.failure('Sync failed: $e');
    }
  }

  CreateWorkoutRequest _buildWorkoutRequest(
    HealthRecord record,
    FitnessVisibility visibility,
  ) {
    final workoutValue = record.value as WorkoutHealthValue;
    final activityType = workoutValue.workoutActivityType;

    final source = Platform.isIOS ? 'healthkit' : 'googlefit';

    return CreateWorkoutRequest(
      name: _formatWorkoutName(activityType),
      description: 'Synced from $source',
      type: _mapWorkoutType(activityType),
      startTime: record.startDate,
      endTime: record.endDate,
      externalId: record.uuid,
      caloriesBurned: workoutValue.totalEnergyBurned?.toInt(),
      notes: 'Synced from $source',
      visibility: visibility,
    );
  }

  CreateMetricRequest _buildMetricRequest(
    HealthRecord record,
    FitnessVisibility visibility,
  ) {
    final metricType = _mapMetricType(record.type);
    double value = 0;
    if (record.value is double) {
      value = record.value as double;
    } else if (record.value is num) {
      value = (record.value as num).toDouble();
    }

    final source = Platform.isIOS ? 'healthkit' : 'googlefit';

    return CreateMetricRequest(
      metricType: metricType!,
      value: value,
      unit: record.unit,
      recordedAt: record.startDate,
      source: source,
      externalId: record.uuid,
      visibility: visibility,
    );
  }

  String _formatWorkoutName(HealthWorkoutActivityType? type) {
    if (type == null) return 'Workout';
    final name = type.name;
    // Convert SNAKE_CASE to Title Case
    return name
        .split('_')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  FitnessMetricType? _mapMetricType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return FitnessMetricType.steps;
      case HealthDataType.WEIGHT:
        return FitnessMetricType.weight;
      case HealthDataType.BODY_MASS_INDEX:
        return FitnessMetricType.bodyFat;
      case HealthDataType.HEART_RATE:
        return FitnessMetricType.heartRate;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return FitnessMetricType.calories;
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_AWAKE:
        return FitnessMetricType.sleep;
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return FitnessMetricType.distance;
      default:
        return null;
    }
  }

  WorkoutType _mapWorkoutType(HealthWorkoutActivityType? type) {
    if (type == null) return WorkoutType.other;

    switch (type) {
      case HealthWorkoutActivityType.RUNNING:
      case HealthWorkoutActivityType.WALKING:
      case HealthWorkoutActivityType.BIKING:
      case HealthWorkoutActivityType.SWIMMING:
      case HealthWorkoutActivityType.ROWING:
      case HealthWorkoutActivityType.ELLIPTICAL:
      case HealthWorkoutActivityType.STAIR_CLIMBING:
      case HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE:
      case HealthWorkoutActivityType.WALKING_TREADMILL:
      case HealthWorkoutActivityType.RUNNING_TREADMILL:
        return WorkoutType.cardio;

      case HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
      case HealthWorkoutActivityType.CROSS_TRAINING:
      case HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING:
      case HealthWorkoutActivityType.CALISTHENICS:
      case HealthWorkoutActivityType.MIXED_CARDIO:
      case HealthWorkoutActivityType.CROSS_COUNTRY_SKIING:
        return WorkoutType.hiit;

      case HealthWorkoutActivityType.YOGA:
      case HealthWorkoutActivityType.PILATES:
      case HealthWorkoutActivityType.BARRE:
      case HealthWorkoutActivityType.FLEXIBILITY:
      case HealthWorkoutActivityType.TAI_CHI:
      case HealthWorkoutActivityType.MIND_AND_BODY:
      case HealthWorkoutActivityType.GUIDED_BREATHING:
        return WorkoutType.yoga;

      case HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING:
      case HealthWorkoutActivityType.STRENGTH_TRAINING:
      case HealthWorkoutActivityType.CORE_TRAINING:
      case HealthWorkoutActivityType.BOWLING:
      case HealthWorkoutActivityType.FENCING:
      case HealthWorkoutActivityType.GYMNASTICS:
      case HealthWorkoutActivityType.HANDBALL:
      case HealthWorkoutActivityType.JUMP_ROPE:
      case HealthWorkoutActivityType.KICKBOXING:
      case HealthWorkoutActivityType.MARTIAL_ARTS:
      case HealthWorkoutActivityType.SQUASH:
      case HealthWorkoutActivityType.BOXING:
      case HealthWorkoutActivityType.RUGBY:
      case HealthWorkoutActivityType.SOCCER:
      case HealthWorkoutActivityType.BASKETBALL:
      case HealthWorkoutActivityType.BASEBALL:
      case HealthWorkoutActivityType.HOCKEY:
      case HealthWorkoutActivityType.TENNIS:
      case HealthWorkoutActivityType.BADMINTON:
      case HealthWorkoutActivityType.CRICKET:
      case HealthWorkoutActivityType.GOLF:
      case HealthWorkoutActivityType.VOLLEYBALL:
      case HealthWorkoutActivityType.PLAY:
      case HealthWorkoutActivityType.SKATING:
      case HealthWorkoutActivityType.SNOWBOARDING:
      case HealthWorkoutActivityType.SKIING:
      case HealthWorkoutActivityType.SURFING:
      case HealthWorkoutActivityType.WATER_SPORTS:
      case HealthWorkoutActivityType.DANCING:
      case HealthWorkoutActivityType.CARDIO_DANCE:
      case HealthWorkoutActivityType.SOCIAL_DANCE:
      case HealthWorkoutActivityType.ARCHERY:
      case HealthWorkoutActivityType.AUSTRALIAN_FOOTBALL:
      case HealthWorkoutActivityType.AMERICAN_FOOTBALL:
      case HealthWorkoutActivityType.DISC_SPORTS:
      case HealthWorkoutActivityType.HAND_CYCLING:
      case HealthWorkoutActivityType.LACROSSE:
      case HealthWorkoutActivityType.PADDLE_SPORTS:
      case HealthWorkoutActivityType.PICKLEBALL:
      case HealthWorkoutActivityType.RACQUETBALL:
      case HealthWorkoutActivityType.ROWING_MACHINE:
      case HealthWorkoutActivityType.ROCK_CLIMBING:
      case HealthWorkoutActivityType.SCUBA_DIVING:
      case HealthWorkoutActivityType.STEP_TRAINING:
      case HealthWorkoutActivityType.TABLE_TENNIS:
      case HealthWorkoutActivityType.UNDERWATER_DIVING:
      case HealthWorkoutActivityType.WHEELCHAIR_RUN_PACE:
      case HealthWorkoutActivityType.WHEELCHAIR_WALK_PACE:
      case HealthWorkoutActivityType.WRESTLING:
      case HealthWorkoutActivityType.BIKING_STATIONARY:
      case HealthWorkoutActivityType.WEIGHTLIFTING:
      case HealthWorkoutActivityType.FRISBEE_DISC:
      case HealthWorkoutActivityType.ICE_SKATING:
      case HealthWorkoutActivityType.PARAGLIDING:
      case HealthWorkoutActivityType.SNOWSHOEING:
      case HealthWorkoutActivityType.SWIMMING_OPEN_WATER:
      case HealthWorkoutActivityType.SWIMMING_POOL:
        return WorkoutType.strength;

      case HealthWorkoutActivityType.OTHER:
      case HealthWorkoutActivityType.COOLDOWN:
      case HealthWorkoutActivityType.PREPARATION_AND_RECOVERY:
      case HealthWorkoutActivityType.STAIRS:
      case HealthWorkoutActivityType.SNOW_SPORTS:
      case HealthWorkoutActivityType.EQUESTRIAN_SPORTS:
      case HealthWorkoutActivityType.FISHING:
      case HealthWorkoutActivityType.FITNESS_GAMING:
      case HealthWorkoutActivityType.HUNTING:
      case HealthWorkoutActivityType.TRACK_AND_FIELD:
      case HealthWorkoutActivityType.WATER_FITNESS:
      default:
        return WorkoutType.other;
    }
  }

  Future<Map<HealthDataType, List<HealthRecord>>> groupRecordsByType(
    List<HealthRecord> records,
  ) async {
    final grouped = <HealthDataType, List<HealthRecord>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.type, () => []).add(record);
    }
    return grouped;
  }

  Future<Set<HealthDataType>> getAvailableTypes() async {
    return {
      HealthDataType.WORKOUT,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.HEART_RATE,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.DISTANCE_WALKING_RUNNING,
    };
  }
}
