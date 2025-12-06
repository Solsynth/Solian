// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnWallet _$SnWalletFromJson(Map<String, dynamic> json) => _SnWallet(
  id: json['id'] as String,
  pockets: (json['pockets'] as List<dynamic>)
      .map((e) => SnWalletPocket.fromJson(e as Map<String, dynamic>))
      .toList(),
  accountId: json['account_id'] as String,
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
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

_SnWalletStats _$SnWalletStatsFromJson(Map<String, dynamic> json) =>
    _SnWalletStats(
      periodBegin: DateTime.parse(json['period_begin'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      totalTransactions: (json['total_transactions'] as num).toInt(),
      totalOrders: (json['total_orders'] as num).toInt(),
      totalIncome: (json['total_income'] as num).toDouble(),
      totalOutgoing: (json['total_outgoing'] as num).toDouble(),
      sum: (json['sum'] as num).toDouble(),
      incomeCategories:
          (json['income_categories'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      outgoingCategories:
          (json['outgoing_categories'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
    );

Map<String, dynamic> _$SnWalletStatsToJson(_SnWalletStats instance) =>
    <String, dynamic>{
      'period_begin': instance.periodBegin.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
      'total_transactions': instance.totalTransactions,
      'total_orders': instance.totalOrders,
      'total_income': instance.totalIncome,
      'total_outgoing': instance.totalOutgoing,
      'sum': instance.sum,
      'income_categories': instance.incomeCategories,
      'outgoing_categories': instance.outgoingCategories,
    };

_SnWalletPocket _$SnWalletPocketFromJson(Map<String, dynamic> json) =>
    _SnWalletPocket(
      id: json['id'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      walletId: json['wallet_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
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
      payerWallet: json['payer_wallet'] == null
          ? null
          : SnWallet.fromJson(json['payer_wallet'] as Map<String, dynamic>),
      payeeWalletId: json['payee_wallet_id'] as String?,
      payeeWallet: json['payee_wallet'] == null
          ? null
          : SnWallet.fromJson(json['payee_wallet'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
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
  endedAt: json['ended_at'] == null
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
  renewalAt: json['renewal_at'] == null
      ? null
      : DateTime.parse(json['renewal_at'] as String),
  accountId: json['account_id'] as String,
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  isAvailable: json['is_available'] as bool? ?? true,
  finalPrice: (json['final_price'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
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

_SnWalletSubscriptionRef _$SnWalletSubscriptionRefFromJson(
  Map<String, dynamic> json,
) => _SnWalletSubscriptionRef(
  id: json['id'] as String,
  isActive: json['is_active'] as bool,
  accountId: json['account_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  identifier: json['identifier'] as String,
);

Map<String, dynamic> _$SnWalletSubscriptionRefToJson(
  _SnWalletSubscriptionRef instance,
) => <String, dynamic>{
  'id': instance.id,
  'is_active': instance.isActive,
  'account_id': instance.accountId,
  'created_at': instance.createdAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'identifier': instance.identifier,
};

_SnWalletOrder _$SnWalletOrderFromJson(Map<String, dynamic> json) =>
    _SnWalletOrder(
      id: json['id'] as String,
      status: (json['status'] as num).toInt(),
      currency: json['currency'] as String,
      remarks: json['remarks'] as String?,
      appIdentifier: json['app_identifier'] as String,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      amount: (json['amount'] as num).toInt(),
      expiredAt: DateTime.parse(json['expired_at'] as String),
      payeeWalletId: json['payee_wallet_id'] as String?,
      transactionId: json['transaction_id'] as String?,
      issuerAppId: json['issuer_app_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
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
      'transaction_id': instance.transactionId,
      'issuer_app_id': instance.issuerAppId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnWalletGift _$SnWalletGiftFromJson(Map<String, dynamic> json) =>
    _SnWalletGift(
      id: json['id'] as String,
      giftCode: json['gift_code'] as String,
      subscriptionIdentifier: json['subscription_identifier'] as String,
      recipientId: json['recipient_id'] as String?,
      recipient: json['recipient'] == null
          ? null
          : SnAccount.fromJson(json['recipient'] as Map<String, dynamic>),
      gifterId: json['gifter_id'] as String,
      gifter: json['gifter'] == null
          ? null
          : SnAccount.fromJson(json['gifter'] as Map<String, dynamic>),
      redeemerId: json['redeemer_id'] as String?,
      redeemer: json['redeemer'] == null
          ? null
          : SnAccount.fromJson(json['redeemer'] as Map<String, dynamic>),
      message: json['message'] as String?,
      status: (json['status'] as num).toInt(),
      redeemedAt: json['redeemed_at'] == null
          ? null
          : DateTime.parse(json['redeemed_at'] as String),
      expiredAt: json['expired_at'] == null
          ? null
          : DateTime.parse(json['expired_at'] as String),
      subscriptionId: json['subscription_id'] as String?,
      subscription: json['subscription'] == null
          ? null
          : SnWalletSubscription.fromJson(
              json['subscription'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnWalletGiftToJson(_SnWalletGift instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gift_code': instance.giftCode,
      'subscription_identifier': instance.subscriptionIdentifier,
      'recipient_id': instance.recipientId,
      'recipient': instance.recipient?.toJson(),
      'gifter_id': instance.gifterId,
      'gifter': instance.gifter?.toJson(),
      'redeemer_id': instance.redeemerId,
      'redeemer': instance.redeemer?.toJson(),
      'message': instance.message,
      'status': instance.status,
      'redeemed_at': instance.redeemedAt?.toIso8601String(),
      'expired_at': instance.expiredAt?.toIso8601String(),
      'subscription_id': instance.subscriptionId,
      'subscription': instance.subscription?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnWalletFund _$SnWalletFundFromJson(Map<String, dynamic> json) =>
    _SnWalletFund(
      id: json['id'] as String,
      currency: json['currency'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      amountOfSplits: (json['amount_of_splits'] as num).toInt(),
      splitType: (json['split_type'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      message: json['message'] as String?,
      creatorAccountId: json['creator_account_id'] as String,
      creatorAccount: json['creator_account'] == null
          ? null
          : SnAccount.fromJson(json['creator_account'] as Map<String, dynamic>),
      expiredAt: DateTime.parse(json['expired_at'] as String),
      recipients: (json['recipients'] as List<dynamic>)
          .map((e) => SnWalletFundRecipient.fromJson(e as Map<String, dynamic>))
          .toList(),
      isOpen: json['is_open'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnWalletFundToJson(_SnWalletFund instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currency': instance.currency,
      'total_amount': instance.totalAmount,
      'remaining_amount': instance.remainingAmount,
      'amount_of_splits': instance.amountOfSplits,
      'split_type': instance.splitType,
      'status': instance.status,
      'message': instance.message,
      'creator_account_id': instance.creatorAccountId,
      'creator_account': instance.creatorAccount?.toJson(),
      'expired_at': instance.expiredAt.toIso8601String(),
      'recipients': instance.recipients.map((e) => e.toJson()).toList(),
      'is_open': instance.isOpen,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnWalletFundRecipient _$SnWalletFundRecipientFromJson(
  Map<String, dynamic> json,
) => _SnWalletFundRecipient(
  id: json['id'] as String,
  fundId: json['fund_id'] as String,
  recipientAccountId: json['recipient_account_id'] as String,
  recipientAccount: json['recipient_account'] == null
      ? null
      : SnAccount.fromJson(json['recipient_account'] as Map<String, dynamic>),
  amount: (json['amount'] as num).toDouble(),
  isReceived: json['is_received'] as bool,
  receivedAt: json['received_at'] == null
      ? null
      : DateTime.parse(json['received_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnWalletFundRecipientToJson(
  _SnWalletFundRecipient instance,
) => <String, dynamic>{
  'id': instance.id,
  'fund_id': instance.fundId,
  'recipient_account_id': instance.recipientAccountId,
  'recipient_account': instance.recipientAccount?.toJson(),
  'amount': instance.amount,
  'is_received': instance.isReceived,
  'received_at': instance.receivedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SnLotteryTicket _$SnLotteryTicketFromJson(Map<String, dynamic> json) =>
    _SnLotteryTicket(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      regionOneNumbers: (json['region_one_numbers'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      regionTwoNumber: (json['region_two_number'] as num).toInt(),
      multiplier: (json['multiplier'] as num).toInt(),
      drawStatus: (json['draw_status'] as num).toInt(),
      drawDate: json['draw_date'] == null
          ? null
          : DateTime.parse(json['draw_date'] as String),
      matchedRegionOneNumbers:
          (json['matched_region_one_numbers'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      matchedRegionTwoNumber: (json['matched_region_two_number'] as num?)
          ?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnLotteryTicketToJson(_SnLotteryTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'region_one_numbers': instance.regionOneNumbers,
      'region_two_number': instance.regionTwoNumber,
      'multiplier': instance.multiplier,
      'draw_status': instance.drawStatus,
      'draw_date': instance.drawDate?.toIso8601String(),
      'matched_region_one_numbers': instance.matchedRegionOneNumbers,
      'matched_region_two_number': instance.matchedRegionTwoNumber,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnLotteryRecord _$SnLotteryRecordFromJson(
  Map<String, dynamic> json,
) => _SnLotteryRecord(
  id: json['id'] as String,
  drawDate: DateTime.parse(json['draw_date'] as String),
  winningRegionOneNumbers: (json['winning_region_one_numbers'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  winningRegionTwoNumber: (json['winning_region_two_number'] as num).toInt(),
  totalTickets: (json['total_tickets'] as num).toInt(),
  totalPrizesAwarded: (json['total_prizes_awarded'] as num).toInt(),
  totalPrizeAmount: (json['total_prize_amount'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnLotteryRecordToJson(_SnLotteryRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'draw_date': instance.drawDate.toIso8601String(),
      'winning_region_one_numbers': instance.winningRegionOneNumbers,
      'winning_region_two_number': instance.winningRegionTwoNumber,
      'total_tickets': instance.totalTickets,
      'total_prizes_awarded': instance.totalPrizesAwarded,
      'total_prize_amount': instance.totalPrizeAmount,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
