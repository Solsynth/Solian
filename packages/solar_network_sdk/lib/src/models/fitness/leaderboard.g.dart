// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    _LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      accountId: json['account_id'] as String,
      value: (json['value'] as num).toDouble(),
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'account_id': instance.accountId,
      'value': instance.value,
      'account': instance.account?.toJson(),
    };

_LeaderboardResponse _$LeaderboardResponseFromJson(Map<String, dynamic> json) =>
    _LeaderboardResponse(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      userEntry: json['user_entry'] == null
          ? null
          : LeaderboardEntry.fromJson(
              json['user_entry'] as Map<String, dynamic>,
            ),
      totalCount: (json['total_count'] as num).toInt(),
    );

Map<String, dynamic> _$LeaderboardResponseToJson(
  _LeaderboardResponse instance,
) => <String, dynamic>{
  'entries': instance.entries.map((e) => e.toJson()).toList(),
  'user_entry': instance.userEntry?.toJson(),
  'total_count': instance.totalCount,
};
