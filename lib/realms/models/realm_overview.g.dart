// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RealmBoostStatus _$RealmBoostStatusFromJson(Map<String, dynamic> json) =>
    _RealmBoostStatus(
      boostPoints: (json['boost_points'] as num).toInt(),
      boostLevel: (json['boost_level'] as num).toInt(),
      labelCap: (json['label_cap'] as num).toInt(),
    );

Map<String, dynamic> _$RealmBoostStatusToJson(_RealmBoostStatus instance) =>
    <String, dynamic>{
      'boost_points': instance.boostPoints,
      'boost_level': instance.boostLevel,
      'label_cap': instance.labelCap,
    };

_RealmBoostLeaderboardEntry _$RealmBoostLeaderboardEntryFromJson(
  Map<String, dynamic> json,
) => _RealmBoostLeaderboardEntry(
  accountId: json['account_id'] as String,
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  amountPoints: (json['amount_points'] as num).toDouble(),
  shares: (json['shares'] as num).toDouble(),
  boosts: (json['boosts'] as num).toInt(),
);

Map<String, dynamic> _$RealmBoostLeaderboardEntryToJson(
  _RealmBoostLeaderboardEntry instance,
) => <String, dynamic>{
  'account_id': instance.accountId,
  'account': instance.account?.toJson(),
  'amount_points': instance.amountPoints,
  'shares': instance.shares,
  'boosts': instance.boosts,
};

_RealmLabel _$RealmLabelFromJson(Map<String, dynamic> json) => _RealmLabel(
  id: json['id'] as String,
  realmId: json['realm_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  color: json['color'] as String?,
  icon: json['icon'] as String?,
  createdByAccountId: json['created_by_account_id'] as String,
);

Map<String, dynamic> _$RealmLabelToJson(_RealmLabel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'realm_id': instance.realmId,
      'name': instance.name,
      'description': instance.description,
      'color': instance.color,
      'icon': instance.icon,
      'created_by_account_id': instance.createdByAccountId,
    };
