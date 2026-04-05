import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  bool _isConfigured = false;

  Future<void> initialize() async {
    if (_isConfigured) return;

    _health.configure();
    _isConfigured = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    await Permission.activityRecognition.request();
    if (Platform.isAndroid) {
      await Permission.location.request();
    }

    final types = _getDataTypes();
    final permissions = _getPermissions();

    return await _health.requestAuthorization(types, permissions: permissions);
  }

  Future<bool> isAuthorized() async {
    await initialize();
    final types = _getDataTypes();
    return await _health.hasPermissions(types) ?? false;
  }

  List<HealthDataType> _getDataTypes() {
    return Platform.isAndroid
        ? _dataTypesAndroid
        : Platform.isIOS
        ? _dataTypesIOS
        : [];
  }

  List<HealthDataAccess> _getPermissions() {
    final types = _getDataTypes();
    return types.map((type) {
      if (_readOnlyTypes.contains(type)) {
        return HealthDataAccess.READ;
      }
      return HealthDataAccess.READ_WRITE;
    }).toList();
  }

  static final List<HealthDataType> _dataTypesAndroid = [
    HealthDataType.WORKOUT,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
  ];

  static final List<HealthDataType> _dataTypesIOS = [
    HealthDataType.WORKOUT,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
  ];

  static final List<HealthDataType> _readOnlyTypes = [
    HealthDataType.GENDER,
    HealthDataType.BLOOD_TYPE,
    HealthDataType.BIRTH_DATE,
  ];

  Future<List<HealthDataPoint>> getWorkoutSamples({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await initialize();

    final types = [HealthDataType.WORKOUT];

    return _health.getHealthDataFromTypes(
      types: types,
      startTime: startDate,
      endTime: endDate,
    );
  }

  Future<List<HealthDataPoint>> getWeightSamples({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await initialize();

    final types = [HealthDataType.WEIGHT, HealthDataType.BODY_MASS_INDEX];

    return _health.getHealthDataFromTypes(
      types: types,
      startTime: startDate,
      endTime: endDate,
    );
  }

  Future<List<HealthDataPoint>> getStepsSamples({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await initialize();

    final types = [HealthDataType.STEPS];

    return _health.getHealthDataFromTypes(
      types: types,
      startTime: startDate,
      endTime: endDate,
    );
  }

  Future<List<HealthDataPoint>> getHeartRateSamples({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await initialize();

    final types = [HealthDataType.HEART_RATE];

    return _health.getHealthDataFromTypes(
      types: types,
      startTime: startDate,
      endTime: endDate,
    );
  }

  Future<List<HealthDataPoint>> getSleepSamples({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await initialize();

    final types = [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_AWAKE];

    return _health.getHealthDataFromTypes(
      types: types,
      startTime: startDate,
      endTime: endDate,
    );
  }

  Future<bool> saveWorkout({
    required DateTime start,
    required DateTime end,
    String? title,
    HealthWorkoutActivityType activityType = HealthWorkoutActivityType.OTHER,
  }) async {
    await initialize();

    return _health.writeWorkoutData(
      activityType: activityType,
      title: title,
      start: start,
      end: end,
    );
  }

  Future<bool> saveMetric({
    required HealthDataType type,
    required double value,
    required DateTime startTime,
    required DateTime endTime,
    HealthDataUnit? unit,
  }) async {
    await initialize();

    return _health.writeHealthData(
      value: value,
      type: type,
      startTime: startTime,
      endTime: endTime,
      unit: unit,
      recordingMethod: RecordingMethod.manual,
    );
  }

  HealthDataType mapMetricTypeToHealth(FitnessMetricType type) {
    switch (type) {
      case FitnessMetricType.weight:
        return HealthDataType.WEIGHT;
      case FitnessMetricType.bodyFat:
        return HealthDataType.BODY_FAT_PERCENTAGE;
      case FitnessMetricType.steps:
        return HealthDataType.STEPS;
      case FitnessMetricType.distance:
        return HealthDataType.DISTANCE_WALKING_RUNNING;
      case FitnessMetricType.heartRate:
        return HealthDataType.HEART_RATE;
      case FitnessMetricType.sleep:
        return HealthDataType.SLEEP_ASLEEP;
      case FitnessMetricType.custom:
        return HealthDataType.ACTIVE_ENERGY_BURNED;
    }
  }

  HealthWorkoutActivityType mapWorkoutTypeToHealth(WorkoutType type) {
    switch (type) {
      case WorkoutType.strength:
        return HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING;
      case WorkoutType.cardio:
        return HealthWorkoutActivityType.RUNNING;
      case WorkoutType.hiit:
        return HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING;
      case WorkoutType.yoga:
        return HealthWorkoutActivityType.YOGA;
      case WorkoutType.other:
        return HealthWorkoutActivityType.OTHER;
    }
  }
}

enum FitnessMetricType {
  weight,
  bodyFat,
  steps,
  distance,
  heartRate,
  sleep,
  custom,
}

enum WorkoutType { strength, cardio, hiit, yoga, other }
