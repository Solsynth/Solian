import 'package:freezed_annotation/freezed_annotation.dart';

part 'heatmap.freezed.dart';
part 'heatmap.g.dart';

@freezed
sealed class SnPublisherHeatmap with _$SnPublisherHeatmap {
  const factory SnPublisherHeatmap({
    required String unit,
    @JsonKey(name: 'period_start') required DateTime periodStart,
    @JsonKey(name: 'period_end') required DateTime periodEnd,
    required List<SnPublisherHeatmapItem> items,
  }) = _SnPublisherHeatmap;

  factory SnPublisherHeatmap.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherHeatmapFromJson(json);
}

@freezed
sealed class SnPublisherHeatmapItem with _$SnPublisherHeatmapItem {
  const factory SnPublisherHeatmapItem({
    required DateTime date,
    required int count,
  }) = _SnPublisherHeatmapItem;

  factory SnPublisherHeatmapItem.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherHeatmapItemFromJson(json);
}
