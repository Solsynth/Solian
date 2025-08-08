import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/publisher.dart';

part 'developer.freezed.dart';
part 'developer.g.dart';

@freezed
sealed class SnDeveloper with _$SnDeveloper {
  const factory SnDeveloper({
    required String id,
    required String publisherId,
    SnPublisher? publisher,
  }) = _SnDeveloper;

  factory SnDeveloper.fromJson(Map<String, dynamic> json) =>
      _$SnDeveloperFromJson(json);
}

@freezed
sealed class DeveloperStats with _$DeveloperStats {
  const factory DeveloperStats({@Default(0) int totalCustomApps}) =
      _DeveloperStats;

  factory DeveloperStats.fromJson(Map<String, dynamic> json) =>
      _$DeveloperStatsFromJson(json);
}
