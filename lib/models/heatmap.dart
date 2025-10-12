import 'package:freezed_annotation/freezed_annotation.dart';

part 'heatmap.freezed.dart';
part 'heatmap.g.dart';

@freezed
sealed class SnHeatmap with _$SnHeatmap {
  const factory SnHeatmap({
    required String unit,
    @JsonKey(name: 'period_start') required DateTime periodStart,
    @JsonKey(name: 'period_end') required DateTime periodEnd,
    required List<SnHeatmapItem> items,
  }) = _SnHeatmap;

  factory SnHeatmap.fromJson(Map<String, dynamic> json) =>
      _$SnHeatmapFromJson(json);
}

@freezed
sealed class SnHeatmapItem with _$SnHeatmapItem {
  const factory SnHeatmapItem({required DateTime date, required int count}) =
      _SnHeatmapItem;

  factory SnHeatmapItem.fromJson(Map<String, dynamic> json) =>
      _$SnHeatmapItemFromJson(json);
}
