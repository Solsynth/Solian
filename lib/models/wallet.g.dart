// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnWallet _$SnWalletFromJson(Map<String, dynamic> json) => _SnWallet(
  id: json['id'] as String,
  pockets:
      (json['pockets'] as List<dynamic>)
          .map((e) => SnWalletPocket.fromJson(e as Map<String, dynamic>))
          .toList(),
  accountId: json['account_id'] as String,
  account:
      json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnWalletToJson(_SnWallet instance) => <String, dynamic>{
  'id': instance.id,
  'pockets': instance.pockets.map((e) => e.toJson()).toList(),
  'account_id': instance.accountId,
  'account': instance.account?.toJson(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SnWalletPocket _$SnWalletPocketFromJson(Map<String, dynamic> json) =>
    _SnWalletPocket(
      id: json['id'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      walletId: json['wallet_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnWalletPocketToJson(_SnWalletPocket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currency': instance.currency,
      'amount': instance.amount,
      'wallet_id': instance.walletId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
