// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livestream_leaderboard_sheet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LivestreamAwardLeaderboardEntry _$LivestreamAwardLeaderboardEntryFromJson(
  Map<String, dynamic> json,
) => _LivestreamAwardLeaderboardEntry(
  rank: (json['rank'] as num?)?.toInt() ?? 0,
  accountId: json['account_id'] as String? ?? '',
  senderName: json['sender_name'] as String? ?? 'Unknown',
  totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
  awardCount: (json['award_count'] as num?)?.toInt() ?? 0,
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LivestreamAwardLeaderboardEntryToJson(
  _LivestreamAwardLeaderboardEntry instance,
) => <String, dynamic>{
  'rank': instance.rank,
  'account_id': instance.accountId,
  'sender_name': instance.senderName,
  'total_amount': instance.totalAmount,
  'award_count': instance.awardCount,
  'account': instance.account?.toJson(),
};
