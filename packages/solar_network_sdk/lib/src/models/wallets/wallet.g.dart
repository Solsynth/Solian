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
  accountId: json['accountId'] as String,
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$SnWalletToJson(_SnWallet instance) => <String, dynamic>{
  'id': instance.id,
  'pockets': instance.pockets,
  'accountId': instance.accountId,
  'account': instance.account,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};

_SnWalletStats _$SnWalletStatsFromJson(Map<String, dynamic> json) =>
    _SnWalletStats(
      periodBegin: DateTime.parse(json['periodBegin'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      totalOrders: (json['totalOrders'] as num).toInt(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalOutgoing: (json['totalOutgoing'] as num).toDouble(),
      sum: (json['sum'] as num).toDouble(),
      incomeCategories:
          (json['incomeCategories'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      outgoingCategories:
          (json['outgoingCategories'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
    );

Map<String, dynamic> _$SnWalletStatsToJson(_SnWalletStats instance) =>
    <String, dynamic>{
      'periodBegin': instance.periodBegin.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'totalTransactions': instance.totalTransactions,
      'totalOrders': instance.totalOrders,
      'totalIncome': instance.totalIncome,
      'totalOutgoing': instance.totalOutgoing,
      'sum': instance.sum,
      'incomeCategories': instance.incomeCategories,
      'outgoingCategories': instance.outgoingCategories,
    };

_SnWalletPocket _$SnWalletPocketFromJson(Map<String, dynamic> json) =>
    _SnWalletPocket(
      id: json['id'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      walletId: json['walletId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnWalletPocketToJson(_SnWalletPocket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currency': instance.currency,
      'amount': instance.amount,
      'walletId': instance.walletId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnTransaction _$SnTransactionFromJson(Map<String, dynamic> json) =>
    _SnTransaction(
      id: json['id'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      remarks: json['remarks'] as String?,
      type: (json['type'] as num).toInt(),
      payerWalletId: json['payerWalletId'] as String?,
      payerWallet: json['payerWallet'] == null
          ? null
          : SnWallet.fromJson(json['payerWallet'] as Map<String, dynamic>),
      payeeWalletId: json['payeeWalletId'] as String?,
      payeeWallet: json['payeeWallet'] == null
          ? null
          : SnWallet.fromJson(json['payeeWallet'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnTransactionToJson(_SnTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currency': instance.currency,
      'amount': instance.amount,
      'remarks': instance.remarks,
      'type': instance.type,
      'payerWalletId': instance.payerWalletId,
      'payerWallet': instance.payerWallet,
      'payeeWalletId': instance.payeeWalletId,
      'payeeWallet': instance.payeeWallet,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnWalletSubscription _$SnWalletSubscriptionFromJson(
  Map<String, dynamic> json,
) => _SnWalletSubscription(
  id: json['id'] as String,
  begunAt: DateTime.parse(json['begunAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  identifier: json['identifier'] as String,
  isActive: json['isActive'] as bool? ?? true,
  isFreeTrial: json['isFreeTrial'] as bool? ?? false,
  status: (json['status'] as num?)?.toInt() ?? 1,
  paymentMethod: json['paymentMethod'] as String?,
  paymentDetails: json['paymentDetails'] as Map<String, dynamic>?,
  basePrice: (json['basePrice'] as num?)?.toDouble(),
  couponId: json['couponId'] as String?,
  coupon: json['coupon'],
  renewalAt: json['renewalAt'] == null
      ? null
      : DateTime.parse(json['renewalAt'] as String),
  accountId: json['accountId'] as String,
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  isAvailable: json['isAvailable'] as bool? ?? true,
  finalPrice: (json['finalPrice'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$SnWalletSubscriptionToJson(
  _SnWalletSubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'begunAt': instance.begunAt.toIso8601String(),
  'endedAt': instance.endedAt?.toIso8601String(),
  'identifier': instance.identifier,
  'isActive': instance.isActive,
  'isFreeTrial': instance.isFreeTrial,
  'status': instance.status,
  'paymentMethod': instance.paymentMethod,
  'paymentDetails': instance.paymentDetails,
  'basePrice': instance.basePrice,
  'couponId': instance.couponId,
  'coupon': instance.coupon,
  'renewalAt': instance.renewalAt?.toIso8601String(),
  'accountId': instance.accountId,
  'account': instance.account,
  'isAvailable': instance.isAvailable,
  'finalPrice': instance.finalPrice,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};

_SnWalletSubscriptionRef _$SnWalletSubscriptionRefFromJson(
  Map<String, dynamic> json,
) => _SnWalletSubscriptionRef(
  id: json['id'] as String,
  isActive: json['isActive'] as bool,
  accountId: json['accountId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  identifier: json['identifier'] as String,
);

Map<String, dynamic> _$SnWalletSubscriptionRefToJson(
  _SnWalletSubscriptionRef instance,
) => <String, dynamic>{
  'id': instance.id,
  'isActive': instance.isActive,
  'accountId': instance.accountId,
  'createdAt': instance.createdAt.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'identifier': instance.identifier,
};

_SnWalletOrder _$SnWalletOrderFromJson(Map<String, dynamic> json) =>
    _SnWalletOrder(
      id: json['id'] as String,
      status: (json['status'] as num).toInt(),
      currency: json['currency'] as String,
      remarks: json['remarks'] as String?,
      appIdentifier: json['appIdentifier'] as String,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      amount: (json['amount'] as num).toInt(),
      expiredAt: DateTime.parse(json['expiredAt'] as String),
      payeeWalletId: json['payeeWalletId'] as String?,
      transactionId: json['transactionId'] as String?,
      issuerAppId: json['issuerAppId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnWalletOrderToJson(_SnWalletOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'currency': instance.currency,
      'remarks': instance.remarks,
      'appIdentifier': instance.appIdentifier,
      'meta': instance.meta,
      'amount': instance.amount,
      'expiredAt': instance.expiredAt.toIso8601String(),
      'payeeWalletId': instance.payeeWalletId,
      'transactionId': instance.transactionId,
      'issuerAppId': instance.issuerAppId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnWalletGift _$SnWalletGiftFromJson(Map<String, dynamic> json) =>
    _SnWalletGift(
      id: json['id'] as String,
      giftCode: json['giftCode'] as String,
      subscriptionIdentifier: json['subscriptionIdentifier'] as String,
      recipientId: json['recipientId'] as String?,
      recipient: json['recipient'] == null
          ? null
          : SnAccount.fromJson(json['recipient'] as Map<String, dynamic>),
      gifterId: json['gifterId'] as String,
      gifter: json['gifter'] == null
          ? null
          : SnAccount.fromJson(json['gifter'] as Map<String, dynamic>),
      redeemerId: json['redeemerId'] as String?,
      redeemer: json['redeemer'] == null
          ? null
          : SnAccount.fromJson(json['redeemer'] as Map<String, dynamic>),
      message: json['message'] as String?,
      status: (json['status'] as num).toInt(),
      redeemedAt: json['redeemedAt'] == null
          ? null
          : DateTime.parse(json['redeemedAt'] as String),
      expiredAt: json['expiredAt'] == null
          ? null
          : DateTime.parse(json['expiredAt'] as String),
      subscriptionId: json['subscriptionId'] as String?,
      subscription: json['subscription'] == null
          ? null
          : SnWalletSubscription.fromJson(
              json['subscription'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnWalletGiftToJson(_SnWalletGift instance) =>
    <String, dynamic>{
      'id': instance.id,
      'giftCode': instance.giftCode,
      'subscriptionIdentifier': instance.subscriptionIdentifier,
      'recipientId': instance.recipientId,
      'recipient': instance.recipient,
      'gifterId': instance.gifterId,
      'gifter': instance.gifter,
      'redeemerId': instance.redeemerId,
      'redeemer': instance.redeemer,
      'message': instance.message,
      'status': instance.status,
      'redeemedAt': instance.redeemedAt?.toIso8601String(),
      'expiredAt': instance.expiredAt?.toIso8601String(),
      'subscriptionId': instance.subscriptionId,
      'subscription': instance.subscription,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnWalletFund _$SnWalletFundFromJson(Map<String, dynamic> json) =>
    _SnWalletFund(
      id: json['id'] as String,
      currency: json['currency'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      amountOfSplits: (json['amountOfSplits'] as num).toInt(),
      splitType: (json['splitType'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      message: json['message'] as String?,
      creatorAccountId: json['creatorAccountId'] as String,
      creatorAccount: json['creatorAccount'] == null
          ? null
          : SnAccount.fromJson(json['creatorAccount'] as Map<String, dynamic>),
      expiredAt: DateTime.parse(json['expiredAt'] as String),
      recipients: (json['recipients'] as List<dynamic>)
          .map((e) => SnWalletFundRecipient.fromJson(e as Map<String, dynamic>))
          .toList(),
      isOpen: json['isOpen'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnWalletFundToJson(_SnWalletFund instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currency': instance.currency,
      'totalAmount': instance.totalAmount,
      'remainingAmount': instance.remainingAmount,
      'amountOfSplits': instance.amountOfSplits,
      'splitType': instance.splitType,
      'status': instance.status,
      'message': instance.message,
      'creatorAccountId': instance.creatorAccountId,
      'creatorAccount': instance.creatorAccount,
      'expiredAt': instance.expiredAt.toIso8601String(),
      'recipients': instance.recipients,
      'isOpen': instance.isOpen,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnWalletFundRecipient _$SnWalletFundRecipientFromJson(
  Map<String, dynamic> json,
) => _SnWalletFundRecipient(
  id: json['id'] as String,
  fundId: json['fundId'] as String,
  recipientAccountId: json['recipientAccountId'] as String,
  recipientAccount: json['recipientAccount'] == null
      ? null
      : SnAccount.fromJson(json['recipientAccount'] as Map<String, dynamic>),
  amount: (json['amount'] as num).toDouble(),
  isReceived: json['isReceived'] as bool,
  receivedAt: json['receivedAt'] == null
      ? null
      : DateTime.parse(json['receivedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$SnWalletFundRecipientToJson(
  _SnWalletFundRecipient instance,
) => <String, dynamic>{
  'id': instance.id,
  'fundId': instance.fundId,
  'recipientAccountId': instance.recipientAccountId,
  'recipientAccount': instance.recipientAccount,
  'amount': instance.amount,
  'isReceived': instance.isReceived,
  'receivedAt': instance.receivedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};

_SnLotteryTicket _$SnLotteryTicketFromJson(Map<String, dynamic> json) =>
    _SnLotteryTicket(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      regionOneNumbers: (json['regionOneNumbers'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      regionTwoNumber: (json['regionTwoNumber'] as num).toInt(),
      multiplier: (json['multiplier'] as num).toInt(),
      drawStatus: (json['drawStatus'] as num).toInt(),
      drawDate: json['drawDate'] == null
          ? null
          : DateTime.parse(json['drawDate'] as String),
      matchedRegionOneNumbers:
          (json['matchedRegionOneNumbers'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      matchedRegionTwoNumber: (json['matchedRegionTwoNumber'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnLotteryTicketToJson(_SnLotteryTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'account': instance.account,
      'regionOneNumbers': instance.regionOneNumbers,
      'regionTwoNumber': instance.regionTwoNumber,
      'multiplier': instance.multiplier,
      'drawStatus': instance.drawStatus,
      'drawDate': instance.drawDate?.toIso8601String(),
      'matchedRegionOneNumbers': instance.matchedRegionOneNumbers,
      'matchedRegionTwoNumber': instance.matchedRegionTwoNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

_SnLotteryRecord _$SnLotteryRecordFromJson(Map<String, dynamic> json) =>
    _SnLotteryRecord(
      id: json['id'] as String,
      drawDate: DateTime.parse(json['drawDate'] as String),
      winningRegionOneNumbers:
          (json['winningRegionOneNumbers'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      winningRegionTwoNumber: (json['winningRegionTwoNumber'] as num).toInt(),
      totalTickets: (json['totalTickets'] as num).toInt(),
      totalPrizesAwarded: (json['totalPrizesAwarded'] as num).toInt(),
      totalPrizeAmount: (json['totalPrizeAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnLotteryRecordToJson(_SnLotteryRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drawDate': instance.drawDate.toIso8601String(),
      'winningRegionOneNumbers': instance.winningRegionOneNumbers,
      'winningRegionTwoNumber': instance.winningRegionTwoNumber,
      'totalTickets': instance.totalTickets,
      'totalPrizesAwarded': instance.totalPrizesAwarded,
      'totalPrizeAmount': instance.totalPrizeAmount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
