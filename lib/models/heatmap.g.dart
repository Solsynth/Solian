// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnHeatmap _$SnHeatmapFromJson(Map<String, dynamic> json) => _SnHeatmap(
  unit: json['unit'] as String,
  periodStart: DateTime.parse(json['period_start'] as String),
  periodEnd: DateTime.parse(json['period_end'] as String),
  items: (json['items'] as List<dynamic>)
      .map((e) => SnHeatmapItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SnHeatmapToJson(_SnHeatmap instance) =>
    <String, dynamic>{
      'unit': instance.unit,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

_SnHeatmapItem _$SnHeatmapItemFromJson(Map<String, dynamic> json) =>
    _SnHeatmapItem(
      date: DateTime.parse(json['date'] as String),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$SnHeatmapItemToJson(_SnHeatmapItem instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'count': instance.count,
    };
