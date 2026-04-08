import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'leaderboard.freezed.dart';
part 'leaderboard.g.dart';

enum LeaderboardType {
  @JsonValue(0)
  calories,
  @JsonValue(1)
  workouts,
  @JsonValue(2)
  goals,
}

enum LeaderboardPeriod {
  @JsonValue(0)
  daily,
  @JsonValue(1)
  weekly,
  @JsonValue(2)
  monthly,
  @JsonValue(3)
  allTime,
}

@freezed
sealed class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required int rank,
    required String accountId,
    required double value,
    SnAccount? account,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

@freezed
sealed class LeaderboardResponse with _$LeaderboardResponse {
  const factory LeaderboardResponse({
    required List<LeaderboardEntry> entries,
    LeaderboardEntry? userEntry,
    required int totalCount,
  }) = _LeaderboardResponse;

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardResponseFromJson(json);
}
