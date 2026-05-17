import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/drive/file.dart';

part 'publisher_leaderboard.freezed.dart';
part 'publisher_leaderboard.g.dart';

/// Represents a leaderboard entry for publisher ratings.
@freezed
sealed class SnPublisherLeaderboardEntry with _$SnPublisherLeaderboardEntry {
  const factory SnPublisherLeaderboardEntry({
    @JsonKey(name: 'publisher_id') required String publisherId,
    required String name,
    required String nick,
    SnCloudFileReference? picture,
    required double rating,
    required int rank,
    required double percentile,
    required String grade,
  }) = _SnPublisherLeaderboardEntry;

  factory SnPublisherLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherLeaderboardEntryFromJson(json);
}

/// Represents a publisher's rating overview with percentile and grade.
@freezed
sealed class SnPublisherRatingOverview with _$SnPublisherRatingOverview {
  const factory SnPublisherRatingOverview({
    required double rating,
    required int rank,
    @JsonKey(name: 'total_publishers') required int totalPublishers,
    required double percentile,
    required String grade,
  }) = _SnPublisherRatingOverview;

  factory SnPublisherRatingOverview.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherRatingOverviewFromJson(json);
}
