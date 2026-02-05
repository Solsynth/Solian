import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/accounts/accounts_models/account.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
sealed class SnWallet with _$SnWallet {
  const factory SnWallet({
    required String id,
    required List<SnWalletPocket> pockets,
    required String accountId,
    required SnAccount? account,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWallet;

  factory SnWallet.fromJson(Map<String, dynamic> json) =>
      _$SnWalletFromJson(json);
}

@freezed
sealed class SnWalletStats with _$SnWalletStats {
  const factory SnWalletStats({
    required DateTime periodBegin,
    required DateTime periodEnd,
    required int totalTransactions,
    required int totalOrders,
    required double totalIncome,
    required double totalOutgoing,
    required double sum,
    @Default({}) Map<String, double> incomeCategories,
    @Default({}) Map<String, double> outgoingCategories,
  }) = _SnWalletStats;

  factory SnWalletStats.fromJson(Map<String, dynamic> json) =>
      _$SnWalletStatsFromJson(json);
}

@freezed
sealed class SnWalletPocket with _$SnWalletPocket {
  const factory SnWalletPocket({
    required String id,
    required String currency,
    required double amount,
    required String walletId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWalletPocket;

  factory SnWalletPocket.fromJson(Map<String, dynamic> json) =>
      _$SnWalletPocketFromJson(json);
}

@freezed
sealed class SnTransaction with _$SnTransaction {
  const factory SnTransaction({
    required String id,
    required String currency,
    required double amount,
    required String? remarks,
    required int type,
    required String? payerWalletId,
    required SnWallet? payerWallet,
    required String? payeeWalletId,
    required SnWallet? payeeWallet,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnTransaction;

  factory SnTransaction.fromJson(Map<String, dynamic> json) =>
      _$SnTransactionFromJson(json);
}

@freezed
sealed class SnWalletSubscription with _$SnWalletSubscription {
  const factory SnWalletSubscription({
    required String id,
    required DateTime begunAt,
    required DateTime? endedAt,
    required String identifier,
    @Default(true) bool isActive,
    @Default(false) bool isFreeTrial,
    @Default(1) int status,
    required String? paymentMethod,
    required Map<String, dynamic>? paymentDetails,
    required double? basePrice,
    required String? couponId,
    required dynamic coupon,
    required DateTime? renewalAt,
    required String accountId,
    required SnAccount? account,
    @Default(true) bool isAvailable,
    required double? finalPrice,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWalletSubscription;

  factory SnWalletSubscription.fromJson(Map<String, dynamic> json) =>
      _$SnWalletSubscriptionFromJson(json);
}

@freezed
sealed class SnWalletSubscriptionRef with _$SnWalletSubscriptionRef {
  const factory SnWalletSubscriptionRef({
    required String id,
    required bool isActive,
    required String accountId,
    required DateTime createdAt,
    required DateTime? deletedAt,
    required DateTime updatedAt,
    required String identifier,
  }) = _SnWalletSubscriptionRef;

  factory SnWalletSubscriptionRef.fromJson(Map<String, dynamic> json) =>
      _$SnWalletSubscriptionRefFromJson(json);
}

@freezed
sealed class SnWalletOrder with _$SnWalletOrder {
  const factory SnWalletOrder({
    required String id,
    required int status,
    required String currency,
    required String? remarks,
    required String appIdentifier,
    @Default({}) Map<String, dynamic> meta,
    required int amount,
    required DateTime expiredAt,
    required String? payeeWalletId,
    required String? transactionId,
    required String? issuerAppId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWalletOrder;

  factory SnWalletOrder.fromJson(Map<String, dynamic> json) =>
      _$SnWalletOrderFromJson(json);
}

@freezed
sealed class SnWalletGift with _$SnWalletGift {
  const factory SnWalletGift({
    required String id,
    required String giftCode,
    required String subscriptionIdentifier,
    required String? recipientId,
    required SnAccount? recipient,
    required String gifterId,
    required SnAccount? gifter,
    required String? redeemerId,
    required SnAccount? redeemer,
    required String? message,
    required int status,
    required DateTime? redeemedAt,
    required DateTime? expiredAt,
    required String? subscriptionId,
    required SnWalletSubscription? subscription,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWalletGift;

  factory SnWalletGift.fromJson(Map<String, dynamic> json) =>
      _$SnWalletGiftFromJson(json);
}

@freezed
sealed class SnWalletFund with _$SnWalletFund {
  const factory SnWalletFund({
    required String id,
    required String currency,
    required double totalAmount,
    required double remainingAmount,
    required int amountOfSplits,
    required int splitType, // 0: even, 1: random
    required int
    status, // 0: created, 1: partially claimed, 2: fully claimed, 3: expired
    required String? message,
    required String creatorAccountId,
    required SnAccount? creatorAccount,
    required DateTime expiredAt,
    required List<SnWalletFundRecipient> recipients,
    required bool isOpen,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWalletFund;

  factory SnWalletFund.fromJson(Map<String, dynamic> json) =>
      _$SnWalletFundFromJson(json);
}

@freezed
sealed class SnWalletFundRecipient with _$SnWalletFundRecipient {
  const factory SnWalletFundRecipient({
    required String id,
    required String fundId,
    required String recipientAccountId,
    required SnAccount? recipientAccount,
    required double amount,
    required bool isReceived,
    required DateTime? receivedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWalletFundRecipient;

  factory SnWalletFundRecipient.fromJson(Map<String, dynamic> json) =>
      _$SnWalletFundRecipientFromJson(json);
}

@freezed
sealed class SnLotteryTicket with _$SnLotteryTicket {
  const factory SnLotteryTicket({
    required String id,
    required String accountId,
    required SnAccount? account,
    required List<int> regionOneNumbers,
    required int regionTwoNumber,
    required int multiplier,
    required int drawStatus,
    required DateTime? drawDate,
    required List<int>? matchedRegionOneNumbers,
    required int? matchedRegionTwoNumber,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnLotteryTicket;

  factory SnLotteryTicket.fromJson(Map<String, dynamic> json) =>
      _$SnLotteryTicketFromJson(json);
}

@freezed
sealed class SnLotteryRecord with _$SnLotteryRecord {
  const factory SnLotteryRecord({
    required String id,
    required DateTime drawDate,
    required List<int> winningRegionOneNumbers,
    required int winningRegionTwoNumber,
    required int totalTickets,
    required int totalPrizesAwarded,
    required double totalPrizeAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnLotteryRecord;

  factory SnLotteryRecord.fromJson(Map<String, dynamic> json) =>
      _$SnLotteryRecordFromJson(json);
}
