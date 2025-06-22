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

_SnTransaction _$SnTransactionFromJson(Map<String, dynamic> json) =>
    _SnTransaction(
      id: json['id'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      remarks: json['remarks'] as String?,
      type: (json['type'] as num).toInt(),
      payerWalletId: json['payer_wallet_id'] as String?,
      payerWallet:
          json['payer_wallet'] == null
              ? null
              : SnWallet.fromJson(json['payer_wallet'] as Map<String, dynamic>),
      payeeWalletId: json['payee_wallet_id'] as String?,
      payeeWallet:
          json['payee_wallet'] == null
              ? null
              : SnWallet.fromJson(json['payee_wallet'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnTransactionToJson(_SnTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currency': instance.currency,
      'amount': instance.amount,
      'remarks': instance.remarks,
      'type': instance.type,
      'payer_wallet_id': instance.payerWalletId,
      'payer_wallet': instance.payerWallet?.toJson(),
      'payee_wallet_id': instance.payeeWalletId,
      'payee_wallet': instance.payeeWallet?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnWalletSubscription _$SnWalletSubscriptionFromJson(
  Map<String, dynamic> json,
) => _SnWalletSubscription(
  id: json['id'] as String,
  begunAt: DateTime.parse(json['begun_at'] as String),
  endedAt:
      json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
  identifier: json['identifier'] as String,
  isActive: json['is_active'] as bool? ?? true,
  isFreeTrial: json['is_free_trial'] as bool? ?? false,
  status: (json['status'] as num?)?.toInt() ?? 1,
  paymentMethod: json['payment_method'] as String?,
  paymentDetails: json['payment_details'] as Map<String, dynamic>?,
  basePrice: (json['base_price'] as num?)?.toDouble(),
  couponId: json['coupon_id'] as String?,
  coupon: json['coupon'],
  renewalAt:
      json['renewal_at'] == null
          ? null
          : DateTime.parse(json['renewal_at'] as String),
  accountId: json['account_id'] as String,
  account:
      json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  isAvailable: json['is_available'] as bool? ?? true,
  finalPrice: (json['final_price'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnWalletSubscriptionToJson(
  _SnWalletSubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'begun_at': instance.begunAt.toIso8601String(),
  'ended_at': instance.endedAt?.toIso8601String(),
  'identifier': instance.identifier,
  'is_active': instance.isActive,
  'is_free_trial': instance.isFreeTrial,
  'status': instance.status,
  'payment_method': instance.paymentMethod,
  'payment_details': instance.paymentDetails,
  'base_price': instance.basePrice,
  'coupon_id': instance.couponId,
  'coupon': instance.coupon,
  'renewal_at': instance.renewalAt?.toIso8601String(),
  'account_id': instance.accountId,
  'account': instance.account?.toJson(),
  'is_available': instance.isAvailable,
  'final_price': instance.finalPrice,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SnWalletOrder _$SnWalletOrderFromJson(Map<String, dynamic> json) =>
    _SnWalletOrder(
      id: json['id'] as String,
      status: (json['status'] as num).toInt(),
      currency: json['currency'] as String,
      remarks: json['remarks'],
      appIdentifier: json['app_identifier'] as String,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      amount: (json['amount'] as num).toInt(),
      expiredAt: DateTime.parse(json['expired_at'] as String),
      payeeWalletId: json['payee_wallet_id'] as String?,
      payeeWallet:
          json['payee_wallet'] == null
              ? null
              : SnWallet.fromJson(json['payee_wallet'] as Map<String, dynamic>),
      transactionId: json['transaction_id'] as String?,
      transaction:
          json['transaction'] == null
              ? null
              : SnTransaction.fromJson(
                json['transaction'] as Map<String, dynamic>,
              ),
      issuerAppId: json['issuer_app_id'] as String?,
      issuerApp: json['issuer_app'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnWalletOrderToJson(_SnWalletOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'currency': instance.currency,
      'remarks': instance.remarks,
      'app_identifier': instance.appIdentifier,
      'meta': instance.meta,
      'amount': instance.amount,
      'expired_at': instance.expiredAt.toIso8601String(),
      'payee_wallet_id': instance.payeeWalletId,
      'payee_wallet': instance.payeeWallet?.toJson(),
      'transaction_id': instance.transactionId,
      'transaction': instance.transaction?.toJson(),
      'issuer_app_id': instance.issuerAppId,
      'issuer_app': instance.issuerApp,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
