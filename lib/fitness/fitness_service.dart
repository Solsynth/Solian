import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:island/talker.dart';
import 'package:island/fitness/fitness_data.dart';

final fitnessServiceProvider = Provider<FitnessService>((ref) {
  return FitnessService();
});

class FitnessService {
  final Health _health = Health();

  /// Check if the platform supports fitness data
  bool get isPlatformSupported {
    return !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  }

  /// Request permissions for fitness data
  Future<bool> requestPermissions() async {
    if (!isPlatformSupported) {
      talker.warning('[Fitness] Platform not supported for fitness data');
      return false;
    }

    try {
      final permissions = [
        HealthDataType.WORKOUT,
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_WALKING_RUNNING,
        HealthDataType.BASAL_ENERGY_BURNED,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ];

      final granted = await _health.requestAuthorization(permissions);
      talker.info('[Fitness] Permission request result: $granted');
      return granted;
    } catch (e) {
      talker.error('[Fitness] Error requesting permissions: $e');
      return false;
    }
  }

  /// Check if permissions are granted for fitness data
  Future<FitnessPermissionStatus> getPermissionStatus() async {
    if (!isPlatformSupported) {
      return FitnessPermissionStatus.notDetermined;
    }

    try {
      final permissions = [
        HealthDataType.WORKOUT,
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_WALKING_RUNNING,
        HealthDataType.BASAL_ENERGY_BURNED,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ];

      final granted = await _health.hasPermissions(permissions) ?? true;
      talker.info('[Fitness] Permission check result: $granted');

      if (granted) {
        return FitnessPermissionStatus.granted;
      } else {
        // Try to check if permissions are denied or restricted
        try {
          await _health.requestAuthorization(permissions);
          return FitnessPermissionStatus.notDetermined;
        } catch (e) {
          // If request fails, permissions are likely denied
          return FitnessPermissionStatus.denied;
        }
      }
    } catch (e) {
      talker.error('[Fitness] Error checking permissions: $e');
      return FitnessPermissionStatus.notDetermined;
    }
  }

  /// Get workouts for a specific date range
  Future<List<FitnessWorkout>> getWorkouts({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (!isPlatformSupported) {
      throw Exception('Fitness data is only available on iOS and Android');
    }

    try {
      final healthData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.WORKOUT],
      );

      final workouts = <FitnessWorkout>[];

      for (final data in healthData) {
        if (data.value is WorkoutHealthValue) {
          final workoutValue = data.value as WorkoutHealthValue;

          final workout = FitnessWorkout(
            startTime: data.dateFrom,
            endTime: data.dateTo,
            workoutType: workoutValue.workoutActivityType,
            totalEnergyBurned: workoutValue.totalEnergyBurned?.toDouble(),
            totalEnergyBurnedUnit: workoutValue.totalEnergyBurnedUnit,
            totalDistance: workoutValue.totalDistance?.toDouble(),
            totalDistanceUnit: workoutValue.totalDistanceUnit,
            totalSteps: workoutValue.totalSteps?.toDouble(),
            totalStepsUnit: workoutValue.totalStepsUnit,
          );

          workouts.add(workout);
        }
      }

      // Sort by start time (newest first)
      workouts.sort((a, b) => b.startTime.compareTo(a.startTime));

      talker.info('[Fitness] Retrieved ${workouts.length} workouts');
      return workouts;
    } catch (e) {
      talker.error('[Fitness] Error retrieving workouts: $e');
      rethrow;
    }
  }

  /// Get workouts from the last 7 days
  Future<List<FitnessWorkout>> getWorkoutsLast7Days() async {
    final now = DateTime.now();
    final startTime = now.subtract(const Duration(days: 7));
    return getWorkouts(startTime: startTime, endTime: now);
  }

  /// Get workouts from the last 30 days
  Future<List<FitnessWorkout>> getWorkoutsLast30Days() async {
    final now = DateTime.now();
    final startTime = now.subtract(const Duration(days: 30));
    return getWorkouts(startTime: startTime, endTime: now);
  }

  /// Get workouts for today
  Future<List<FitnessWorkout>> getWorkoutsToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return getWorkouts(startTime: today, endTime: tomorrow);
  }

  /// Get workouts for this week (Monday to Sunday)
  Future<List<FitnessWorkout>> getWorkoutsThisWeek() async {
    final now = DateTime.now();
    // Calculate Monday of current week
    final daysSinceMonday = now.weekday - 1; // Monday is 1, Sunday is 7
    final monday = now.subtract(Duration(days: daysSinceMonday));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return getWorkouts(startTime: startOfWeek, endTime: endOfWeek);
  }

  /// Get workouts for this month
  Future<List<FitnessWorkout>> getWorkoutsThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = startOfMonth.add(const Duration(days: 32));
    final endOfMonth = DateTime(
      startOfNextMonth.year,
      startOfNextMonth.month,
      1,
    );
    return getWorkouts(startTime: startOfMonth, endTime: endOfMonth);
  }

  /// Get all available workout types from the device
  Future<Set<HealthWorkoutActivityType>> getAvailableWorkoutTypes({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!isPlatformSupported) {
      return {};
    }

    try {
      final workouts = await getWorkouts(
        startTime: startTime ?? DateTime(2020, 1, 1),
        endTime: endTime ?? DateTime.now(),
      );

      return workouts.map((w) => w.workoutType).toSet();
    } catch (e) {
      talker.error('[Fitness] Error getting available workout types: $e');
      return {};
    }
  }

  /// Get summary statistics for workouts
  Future<FitnessSummary> getWorkoutSummary({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final workouts = await getWorkouts(startTime: startTime, endTime: endTime);

    double totalCalories = 0;
    double totalDistance = 0;
    int totalSteps = 0;
    int totalWorkouts = workouts.length;
    Duration totalDuration = Duration.zero;

    for (final workout in workouts) {
      // Calculate total duration
      totalDuration += workout.endTime.difference(workout.startTime);

      // Add calories (prefer active energy, fallback to basal)
      if (workout.totalEnergyBurned != null) {
        totalCalories += workout.totalEnergyBurned!;
      }

      // Add distance
      if (workout.totalDistance != null) {
        totalDistance += workout.totalDistance!;
      }

      // Add steps
      if (workout.totalSteps != null) {
        totalSteps += workout.totalSteps!.toInt();
      }
    }

    return FitnessSummary(
      totalWorkouts: totalWorkouts,
      totalDuration: totalDuration,
      totalCalories: totalCalories,
      totalDistance: totalDistance,
      totalSteps: totalSteps,
      averageDuration: totalWorkouts > 0
          ? Duration(
              milliseconds: (totalDuration.inMilliseconds / totalWorkouts)
                  .round(),
            )
          : Duration.zero,
      averageCalories: totalWorkouts > 0 ? totalCalories / totalWorkouts : 0,
    );
  }

  /// Get summary for last 7 days
  Future<FitnessSummary> getWorkoutSummaryLast7Days() async {
    final now = DateTime.now();
    final startTime = now.subtract(const Duration(days: 7));
    return getWorkoutSummary(startTime: startTime, endTime: now);
  }

  /// Check if fitness data is available
  Future<bool> isDataAvailable() async {
    if (!isPlatformSupported) {
      return false;
    }

    try {
      final permissionStatus = await getPermissionStatus();
      if (permissionStatus != FitnessPermissionStatus.granted) {
        return false;
      }

      // Try to get a small sample of data to verify it's available
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final workouts = await getWorkouts(startTime: yesterday, endTime: now);

      return workouts.isNotEmpty;
    } catch (e) {
      talker.warning('[Fitness] Error checking data availability: $e');
      return false;
    }
  }
}

/// Summary statistics for fitness data
class FitnessSummary {
  final int totalWorkouts;
  final Duration totalDuration;
  final double totalCalories;
  final double totalDistance;
  final int totalSteps;
  final Duration averageDuration;
  final double averageCalories;

  FitnessSummary({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.totalCalories,
    required this.totalDistance,
    required this.totalSteps,
    required this.averageDuration,
    required this.averageCalories,
  });

  /// Get formatted total duration string
  String get totalDurationString {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    final seconds = totalDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Get formatted average duration string
  String get averageDurationString {
    final hours = averageDuration.inHours;
    final minutes = averageDuration.inMinutes.remainder(60);
    final seconds = averageDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Get formatted total calories string
  String get totalCaloriesString {
    return '${totalCalories.toStringAsFixed(0)} kcal';
  }

  /// Get formatted average calories string
  String get averageCaloriesString {
    return '${averageCalories.toStringAsFixed(0)} kcal';
  }

  /// Get formatted total distance string
  String get totalDistanceString {
    if (totalDistance >= 1000) {
      return '${(totalDistance / 1000).toStringAsFixed(2)} km';
    } else {
      return '${totalDistance.toStringAsFixed(0)} m';
    }
  }

  /// Get formatted total steps string
  String get totalStepsString {
    return totalSteps.toString();
  }
}
