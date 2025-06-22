import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/user.dart';

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
sealed class SnWalletOrder with _$SnWalletOrder {
  const factory SnWalletOrder({
    required String id,
    required int status,
    required String currency,
    required dynamic remarks,
    required String appIdentifier,
    @Default({}) Map<String, dynamic> meta,
    required int amount,
    required DateTime expiredAt,
    required String? payeeWalletId,
    required SnWallet? payeeWallet,
    required String? transactionId,
    required SnTransaction? transaction,
    required String? issuerAppId,
    required dynamic issuerApp,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWalletOrder;

  factory SnWalletOrder.fromJson(Map<String, dynamic> json) =>
      _$SnWalletOrderFromJson(json);
}
