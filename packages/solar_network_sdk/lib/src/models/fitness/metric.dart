import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters.dart';
import 'workout.dart';

part 'metric.freezed.dart';
part 'metric.g.dart';

enum FitnessMetricType {
  @JsonValue(0)
  weight,
  @JsonValue(1)
  bodyFat,
  @JsonValue(2)
  steps,
  @JsonValue(3)
  heartRate,
  @JsonValue(4)
  sleep,
  @JsonValue(5)
  calories,
  @JsonValue(6)
  waterIntake,
  @JsonValue(9)
  distance,
  @JsonValue(10)
  custom,
}

@freezed
sealed class SnFitnessMetric with _$SnFitnessMetric {
  const factory SnFitnessMetric({
    required String id,
    required String accountId,
    required FitnessMetricType metricType,
    required double value,
    required String unit,
    required DateTime recordedAt,
    String? notes,
    String? source,
    @Default(FitnessVisibility.private) FitnessVisibility visibility,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SnFitnessMetric;

  factory SnFitnessMetric.fromJson(Map<String, dynamic> json) =>
      _$SnFitnessMetricFromJson(json);
}

@freezed
sealed class CreateMetricRequest with _$CreateMetricRequest {
  const factory CreateMetricRequest({
    required FitnessMetricType metricType,
    required double value,
    required String unit,
    @DateTimeConverter() required DateTime recordedAt,
    String? notes,
    String? source,
    String? externalId,
    @Default(FitnessVisibility.private) FitnessVisibility visibility,
  }) = _CreateMetricRequest;

  factory CreateMetricRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMetricRequestFromJson(json);
}

@freezed
sealed class UpdateMetricRequest with _$UpdateMetricRequest {
  const factory UpdateMetricRequest({
    required FitnessMetricType metricType,
    required double value,
    required String unit,
    @DateTimeConverter() required DateTime recordedAt,
    String? notes,
    String? source,
    FitnessVisibility? visibility,
  }) = _UpdateMetricRequest;

  factory UpdateMetricRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMetricRequestFromJson(json);
}

@freezed
sealed class CreateMetricsBatchRequest with _$CreateMetricsBatchRequest {
  const factory CreateMetricsBatchRequest({
    required List<CreateMetricRequest> metrics,
  }) = _CreateMetricsBatchRequest;

  factory CreateMetricsBatchRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMetricsBatchRequestFromJson(json);
}
