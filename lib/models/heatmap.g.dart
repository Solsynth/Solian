// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPublisherHeatmap _$SnPublisherHeatmapFromJson(Map<String, dynamic> json) =>
    _SnPublisherHeatmap(
      unit: json['unit'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      items:
          (json['items'] as List<dynamic>)
              .map((e) => SnHeatmapItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$SnPublisherHeatmapToJson(_SnPublisherHeatmap instance) =>
    <String, dynamic>{
      'unit': instance.unit,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

_SnPublisherHeatmapItem _$SnPublisherHeatmapItemFromJson(
  Map<String, dynamic> json,
) => _SnPublisherHeatmapItem(
  date: DateTime.parse(json['date'] as String),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$SnPublisherHeatmapItemToJson(
  _SnPublisherHeatmapItem instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'count': instance.count,
};
