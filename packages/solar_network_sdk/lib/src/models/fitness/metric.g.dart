// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnFitnessMetric _$SnFitnessMetricFromJson(Map<String, dynamic> json) =>
    _SnFitnessMetric(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      metricType: $enumDecode(_$FitnessMetricTypeEnumMap, json['metric_type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      notes: json['notes'] as String?,
      source: json['source'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SnFitnessMetricToJson(_SnFitnessMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'metric_type': _$FitnessMetricTypeEnumMap[instance.metricType]!,
      'value': instance.value,
      'unit': instance.unit,
      'recorded_at': instance.recordedAt.toIso8601String(),
      'notes': instance.notes,
      'source': instance.source,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$FitnessMetricTypeEnumMap = {
  FitnessMetricType.weight: 0,
  FitnessMetricType.bodyFat: 1,
  FitnessMetricType.steps: 2,
  FitnessMetricType.heartRate: 3,
  FitnessMetricType.sleep: 4,
  FitnessMetricType.calories: 5,
  FitnessMetricType.waterIntake: 6,
  FitnessMetricType.distance: 9,
  FitnessMetricType.custom: 10,
};

_CreateMetricRequest _$CreateMetricRequestFromJson(Map<String, dynamic> json) =>
    _CreateMetricRequest(
      metricType: $enumDecode(_$FitnessMetricTypeEnumMap, json['metric_type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      recordedAt: const DateTimeConverter().fromJson(
        json['recorded_at'] as String,
      ),
      notes: json['notes'] as String?,
      source: json['source'] as String?,
      externalId: json['external_id'] as String?,
    );

Map<String, dynamic> _$CreateMetricRequestToJson(
  _CreateMetricRequest instance,
) => <String, dynamic>{
  'metric_type': _$FitnessMetricTypeEnumMap[instance.metricType]!,
  'value': instance.value,
  'unit': instance.unit,
  'recorded_at': const DateTimeConverter().toJson(instance.recordedAt),
  'notes': instance.notes,
  'source': instance.source,
  'external_id': instance.externalId,
};

_UpdateMetricRequest _$UpdateMetricRequestFromJson(Map<String, dynamic> json) =>
    _UpdateMetricRequest(
      metricType: $enumDecode(_$FitnessMetricTypeEnumMap, json['metric_type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      recordedAt: const DateTimeConverter().fromJson(
        json['recorded_at'] as String,
      ),
      notes: json['notes'] as String?,
      source: json['source'] as String?,
    );

Map<String, dynamic> _$UpdateMetricRequestToJson(
  _UpdateMetricRequest instance,
) => <String, dynamic>{
  'metric_type': _$FitnessMetricTypeEnumMap[instance.metricType]!,
  'value': instance.value,
  'unit': instance.unit,
  'recorded_at': const DateTimeConverter().toJson(instance.recordedAt),
  'notes': instance.notes,
  'source': instance.source,
};

_CreateMetricsBatchRequest _$CreateMetricsBatchRequestFromJson(
  Map<String, dynamic> json,
) => _CreateMetricsBatchRequest(
  metrics: (json['metrics'] as List<dynamic>)
      .map((e) => CreateMetricRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CreateMetricsBatchRequestToJson(
  _CreateMetricsBatchRequest instance,
) => <String, dynamic>{
  'metrics': instance.metrics.map((e) => e.toJson()).toList(),
};
