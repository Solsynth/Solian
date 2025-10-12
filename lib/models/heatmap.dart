import 'package:freezed_annotation/freezed_annotation.dart';

part 'heatmap.freezed.dart';
part 'heatmap.g.dart';

@freezed
sealed class SnHeatmap with _$SnPublisherHeatmap {
  const factory SnHeatmap({
    required String unit,
    @JsonKey(name: 'period_start') required DateTime periodStart,
    @JsonKey(name: 'period_end') required DateTime periodEnd,
    required List<SnHeatmapItem> items,
  }) = _SnPublisherHeatmap;

  factory SnHeatmap.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherHeatmapFromJson(json);
}

@freezed
sealed class SnHeatmapItem with _$SnPublisherHeatmapItem {
  const factory SnHeatmapItem({required DateTime date, required int count}) =
      _SnPublisherHeatmapItem;

  factory SnHeatmapItem.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherHeatmapItemFromJson(json);
}
