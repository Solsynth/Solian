// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher_leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPublisherLeaderboardEntry _$SnPublisherLeaderboardEntryFromJson(
  Map<String, dynamic> json,
) => _SnPublisherLeaderboardEntry(
  publisherId: json['publisher_id'] as String,
  name: json['name'] as String,
  nick: json['nick'] as String,
  picture: json['picture'] == null
      ? null
      : SnCloudFileReference.fromJson(json['picture'] as Map<String, dynamic>),
  rating: (json['rating'] as num).toDouble(),
  rank: (json['rank'] as num).toInt(),
  percentile: (json['percentile'] as num).toDouble(),
  grade: json['grade'] as String,
);

Map<String, dynamic> _$SnPublisherLeaderboardEntryToJson(
  _SnPublisherLeaderboardEntry instance,
) => <String, dynamic>{
  'publisher_id': instance.publisherId,
  'name': instance.name,
  'nick': instance.nick,
  'picture': instance.picture?.toJson(),
  'rating': instance.rating,
  'rank': instance.rank,
  'percentile': instance.percentile,
  'grade': instance.grade,
};

_SnPublisherRatingOverview _$SnPublisherRatingOverviewFromJson(
  Map<String, dynamic> json,
) => _SnPublisherRatingOverview(
  rating: (json['rating'] as num).toDouble(),
  rank: (json['rank'] as num).toInt(),
  totalPublishers: (json['total_publishers'] as num).toInt(),
  percentile: (json['percentile'] as num).toDouble(),
  grade: json['grade'] as String,
);

Map<String, dynamic> _$SnPublisherRatingOverviewToJson(
  _SnPublisherRatingOverview instance,
) => <String, dynamic>{
  'rating': instance.rating,
  'rank': instance.rank,
  'total_publishers': instance.totalPublishers,
  'percentile': instance.percentile,
  'grade': instance.grade,
};
