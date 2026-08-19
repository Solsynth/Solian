import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

DateTime? _parseNullableWalletOrderDate(dynamic value) {
  if (value == null) return null;

  final date = value is DateTime ? value : DateTime.parse(value.toString());
  if (date.year == 1 &&
      date.month == 1 &&
      date.day == 1 &&
      date.hour == 0 &&
      date.minute == 0 &&
      date.second == 0 &&
      date.millisecond == 0 &&
      date.microsecond == 0) {
    return null;
  }
  return date;
}

@freezed
sealed class SnWallet with _$SnWallet {
  const factory SnWallet({
    required String id,
    required List<SnWalletPocket> pockets,
    String? accountId,
    String? realmId,
    required String name,
    @Default(false) bool isPrimary,
    String? publicId,
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
sealed class SnWalletExchangeOption with _$SnWalletExchangeOption {
  const factory SnWalletExchangeOption({
    required String sourceCurrency,
    required double sourceAmount,
    required String targetCurrency,
    required double targetAmount,
  }) = _SnWalletExchangeOption;

  factory SnWalletExchangeOption.fromJson(Map<String, dynamic> json) =>
      _$SnWalletExchangeOptionFromJson(json);
}

@freezed
sealed class SnWalletExchangeResponse with _$SnWalletExchangeResponse {
  const factory SnWalletExchangeResponse({
    required String walletId,
    required String sourceCurrency,
    required double sourceAmount,
    required String targetCurrency,
    required double targetAmount,
    required SnTransaction debitTransaction,
    required SnTransaction creditTransaction,
  }) = _SnWalletExchangeResponse;

  factory SnWalletExchangeResponse.fromJson(Map<String, dynamic> json) =>
      _$SnWalletExchangeResponseFromJson(json);
}

@freezed
sealed class SnWalletPocket with _$SnWalletPocket {
  const factory SnWalletPocket({
    required String id,
    required String currency,
    required double amount,
    @Default(0) double heldAmount,
    required String walletId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWalletPocket;

  factory SnWalletPocket.fromJson(Map<String, dynamic> json) =>
      _$SnWalletPocketFromJson(json);
}

extension SnWalletPocketX on SnWalletPocket {
  double get availableAmount => amount - heldAmount;
}

@freezed
sealed class SnTransaction with _$SnTransaction {
  const factory SnTransaction({
    required String id,
    required String currency,
    required double amount,
    required String? remarks,
    required int type,
    @Default(2)
    int
    status, // 0: Pending, 1: Frozen, 2: Confirmed, 3: Refunded, 4: Cancelled
    @Default(false) bool isFrozen,
    @Default(false) bool requireConfirmation,
    DateTime? frozenAt,
    DateTime? expiresAt,
    DateTime? confirmedAt,
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

/// Transaction status enum matching the server.
abstract class TransactionStatus {
  static const int pending = 0;
  static const int frozen = 1;
  static const int confirmed = 2;
  static const int refunded = 3;
  static const int cancelled = 4;
}

@freezed
sealed class SnWalletSubscription with _$SnWalletSubscription {
  const factory SnWalletSubscription({
    required String id,
    required DateTime begunAt,
    required DateTime? endedAt,
    required String identifier,
    String? groupIdentifier,
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
    @Default(false) bool isPendingActivation,
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
    Map<String, dynamic>? app,
    required double amount,
    @JsonKey(fromJson: _parseNullableWalletOrderDate)
    required DateTime? expiredAt,
    required String? payerWalletId,
    required String? payeeWalletId,
    required String? transactionId,
    required String? issuerAppId,
    required DateTime createdAt,
    @JsonKey(fromJson: _parseNullableWalletOrderDate)
    required DateTime? updatedAt,
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
    status, // 0: created, 1: partially claimed, 2: fully claimed, 3: expired, 4: refunded
    required String? message,
    required String creatorAccountId,
    required SnAccount? creatorAccount,
    // Raising mode fields
    @Default(false) bool isRaising,
    @Default(0) double targetAmount,
    @Default(0) int contributionType, // 0: Free, 1: Fixed
    @Default(0) double contributionAmount,
    DateTime? deadlineAt,
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

extension SnWalletFundX on SnWalletFund {
  double get raisedAmount => isRaising
      ? recipients.where((r) => r.isReceived).fold(0.0, (s, r) => s + r.amount)
      : 0;
}

/// Contribution type enum matching the server.
abstract class ContributionType {
  static const int free = 0;
  static const int fixed = 1;
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
sealed class SnSubscriptionCatalog with _$SnSubscriptionCatalog {
  const factory SnSubscriptionCatalog({
    required String identifier,
    required String groupIdentifier,
    required String displayName,
    required String currency,
    required int basePrice,
    required int perkLevel,
    required int minimumAccountLevel,
    required double experienceMultiplier,
    required int goldenPointReward,
    required SnSubscriptionDisplayConfig? displayConfig,
    required List<String> allowedPaymentMethods,
    required SnProductProviderMappings providerMappings,
  }) = _SnSubscriptionCatalog;

  factory SnSubscriptionCatalog.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionCatalogFromJson(json);
}

@freezed
sealed class SnSubscriptionDisplayConfig with _$SnSubscriptionDisplayConfig {
  const factory SnSubscriptionDisplayConfig({
    required String color,
    required dynamic backgroundColor,
    required dynamic badgeText,
  }) = _SnSubscriptionDisplayConfig;

  factory SnSubscriptionDisplayConfig.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionDisplayConfigFromJson(json);
}

@freezed
sealed class SnProductProviderMappings with _$SnProductProviderMappings {
  const factory SnProductProviderMappings({
    required List<String> afdian,
    required List<String> paddle,
    required List<String> appleStore,
  }) = _SnProductProviderMappings;

  factory SnProductProviderMappings.fromJson(Map<String, dynamic> json) =>
      _$SnProductProviderMappingsFromJson(json);
}

@freezed
sealed class SnSubscriptionGroup with _$SnSubscriptionGroup {
  const factory SnSubscriptionGroup({
    required String groupIdentifier,
    required SnSubscriptionGroupCatalog catalog,
    SnActiveSubscription? current,
    SnActiveSubscription? next,
    required List<SnActiveSubscription> subscriptions,
  }) = _SnSubscriptionGroup;

  factory SnSubscriptionGroup.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionGroupFromJson(json);
}

@freezed
sealed class SnSubscriptionGroupCatalog with _$SnSubscriptionGroupCatalog {
  const factory SnSubscriptionGroupCatalog({
    required String groupIdentifier,
    required String displayName,
    required int maxPerkLevel,
    required SnSubscriptionDisplayConfig? displayConfig,
    required List<SnSubscriptionCatalog> items,
  }) = _SnSubscriptionGroupCatalog;

  factory SnSubscriptionGroupCatalog.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionGroupCatalogFromJson(json);
}

@freezed
sealed class SnActiveSubscription with _$SnActiveSubscription {
  const factory SnActiveSubscription({
    required SnWalletSubscription subscription,
    required SnSubscriptionCatalog definition,
  }) = _SnActiveSubscription;

  factory SnActiveSubscription.fromJson(Map<String, dynamic> json) =>
      _$SnActiveSubscriptionFromJson(json);
}

class SnWalletBillingRecord {
  final String id;
  final String provider;
  final String externalId;
  final String? correlationId;
  final String? providerReferenceId;
  final String? productIdentifier;
  final DateTime begunAt;
  final bool isTesting;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SnWalletBillingOrder> orders;
  final List<SnWalletBillingSubscription> subscriptions;

  const SnWalletBillingRecord({
    required this.id,
    required this.provider,
    required this.externalId,
    required this.correlationId,
    required this.providerReferenceId,
    required this.productIdentifier,
    required this.begunAt,
    required this.isTesting,
    required this.createdAt,
    required this.updatedAt,
    required this.orders,
    required this.subscriptions,
  });

  factory SnWalletBillingRecord.fromJson(Map<String, dynamic> json) {
    return SnWalletBillingRecord(
      id: json['id'].toString(),
      provider: json['provider']?.toString() ?? 'unknown',
      externalId: json['external_id']?.toString() ?? '',
      correlationId: json['correlation_id']?.toString(),
      providerReferenceId: json['provider_reference_id']?.toString(),
      productIdentifier: json['product_identifier']?.toString(),
      begunAt: _parseBillingDate(json['begun_at']),
      isTesting: json['is_testing'] as bool? ?? false,
      createdAt: _parseBillingDate(json['created_at']),
      updatedAt: _parseBillingDate(json['updated_at']),
      orders: (json['orders'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SnWalletBillingOrder.fromJson)
          .toList(growable: false),
      subscriptions: (json['subscriptions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SnWalletBillingSubscription.fromJson)
          .toList(growable: false),
    );
  }
}

class SnWalletBillingOrder {
  final String id;
  final int status;
  final String currency;
  final String? remarks;
  final String? appIdentifier;
  final String? productIdentifier;
  final double amount;
  final DateTime expiredAt;
  final String? payeeWalletId;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SnWalletBillingOrder({
    required this.id,
    required this.status,
    required this.currency,
    required this.remarks,
    required this.appIdentifier,
    required this.productIdentifier,
    required this.amount,
    required this.expiredAt,
    required this.payeeWalletId,
    required this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SnWalletBillingOrder.fromJson(Map<String, dynamic> json) {
    return SnWalletBillingOrder(
      id: json['id'].toString(),
      status: _parseBillingInt(json['status']),
      currency: json['currency']?.toString() ?? '',
      remarks: json['remarks']?.toString(),
      appIdentifier: json['app_identifier']?.toString(),
      productIdentifier: json['product_identifier']?.toString(),
      amount: _parseBillingDouble(json['amount']),
      expiredAt: _parseBillingDate(json['expired_at']),
      payeeWalletId: json['payee_wallet_id']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      createdAt: _parseBillingDate(json['created_at']),
      updatedAt: _parseBillingDate(json['updated_at']),
    );
  }
}

class SnWalletBillingSubscription {
  final String id;
  final DateTime begunAt;
  final DateTime? endedAt;
  final String identifier;
  final String? groupIdentifier;
  final bool isActive;
  final bool isFreeTrial;
  final int status;
  final String? paymentMethod;
  final double? basePrice;
  final DateTime? renewalAt;
  final bool isTesting;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SnWalletBillingSubscription({
    required this.id,
    required this.begunAt,
    required this.endedAt,
    required this.identifier,
    required this.groupIdentifier,
    required this.isActive,
    required this.isFreeTrial,
    required this.status,
    required this.paymentMethod,
    required this.basePrice,
    required this.renewalAt,
    required this.isTesting,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SnWalletBillingSubscription.fromJson(Map<String, dynamic> json) {
    return SnWalletBillingSubscription(
      id: json['id'].toString(),
      begunAt: _parseBillingDate(json['begun_at']),
      endedAt: _parseBillingNullableDate(json['ended_at']),
      identifier: json['identifier']?.toString() ?? '',
      groupIdentifier: json['group_identifier']?.toString(),
      isActive: json['is_active'] as bool? ?? false,
      isFreeTrial: json['is_free_trial'] as bool? ?? false,
      status: _parseBillingInt(json['status']),
      paymentMethod: json['payment_method']?.toString(),
      basePrice: _parseBillingNullableDouble(json['base_price']),
      renewalAt: _parseBillingNullableDate(json['renewal_at']),
      isTesting: json['is_testing'] as bool? ?? false,
      createdAt: _parseBillingDate(json['created_at']),
      updatedAt: _parseBillingDate(json['updated_at']),
    );
  }
}

DateTime _parseBillingDate(dynamic value) =>
    DateTime.parse(value.toString()).toLocal();

DateTime? _parseBillingNullableDate(dynamic value) =>
    value == null ? null : _parseBillingDate(value);

int _parseBillingInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;

double _parseBillingDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0;

double? _parseBillingNullableDouble(dynamic value) =>
    value == null ? null : _parseBillingDouble(value);
