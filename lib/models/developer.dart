import 'package:freezed_annotation/freezed_annotation.dart';

part 'developer.freezed.dart';
part 'developer.g.dart';

@freezed
sealed class DeveloperStats with _$DeveloperStats {
  const factory DeveloperStats({
    @Default(0) int totalCustomApps,
  }) = _DeveloperStats;

  factory DeveloperStats.fromJson(Map<String, dynamic> json) =>
      _$DeveloperStatsFromJson(json);
}