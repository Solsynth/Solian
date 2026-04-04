import 'package:dio/dio.dart';

import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/wallets/wallet.dart';

/// API for wallet-related endpoints (/wallet).
///
/// Handles wallets, funds, transactions, subscriptions, and payments.
class WalletApi extends BaseApi {
  WalletApi(super.dio);

  /// Base path for all wallet endpoints.
  static const String _basePath = '/wallet';

  // ==========================================
  // Wallet endpoints
  // ==========================================

  /// Gets the current user's wallet.
  Future<SnWallet?> getWallet() async {
    try {
      final response = await get<Map<String, dynamic>>('$_basePath/wallets');
      return SnWallet.fromJson(response.data!);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Creates a new wallet.
  Future<SnWallet> createWallet() async {
    final response = await post<Map<String, dynamic>>('$_basePath/wallets');
    return SnWallet.fromJson(response.data!);
  }

  /// Gets wallet statistics.
  Future<SnWalletStats> getWalletStats() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/wallets/stats',
    );
    return SnWalletStats.fromJson(response.data!);
  }

  // ==========================================
  // Fund endpoints
  // ==========================================

  /// Gets all funds.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnWalletFund>> getFunds({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/wallets/funds',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnWalletFund.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific fund by ID.
  ///
  /// [fundId] - The fund ID.
  Future<SnWalletFund> getFund(String fundId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/wallets/funds/$fundId',
    );
    return SnWalletFund.fromJson(response.data!);
  }

  /// Creates a new fund.
  ///
  /// [name] - The fund name.
  /// [amount] - The amount.
  /// [recipients] - List of recipients with splits.
  Future<SnWalletFund> createFund({
    required String name,
    required double amount,
    required List<SnWalletFundRecipient> recipients,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/wallets/funds',
      data: {
        'name': name,
        'amount': amount,
        'recipients': recipients.map((r) => r.toJson()).toList(),
      },
    );
    return SnWalletFund.fromJson(response.data!);
  }

  /// Updates a fund.
  ///
  /// [fundId] - The fund ID.
  /// [data] - The data to update.
  Future<SnWalletFund> updateFund({
    required String fundId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/wallets/funds/$fundId',
      data: data,
    );
    return SnWalletFund.fromJson(response.data!);
  }

  /// Deletes a fund.
  ///
  /// [fundId] - The fund ID.
  Future<void> deleteFund(String fundId) async {
    await delete('$_basePath/wallets/funds/$fundId');
  }

  /// Transfers funds from one wallet to another.
  ///
  /// [toWalletId] - The recipient wallet ID.
  /// [amount] - The amount to transfer.
  /// [message] - Optional message.
  Future<void> transfer({
    required String toWalletId,
    required double amount,
    String? message,
  }) async {
    await post(
      '$_basePath/wallets/transfer',
      data: {'to_wallet_id': toWalletId, 'amount': amount, 'message': ?message},
    );
  }

  // ==========================================
  // Transaction endpoints
  // ==========================================

  /// Gets all transactions.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnTransaction>> getTransactions({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/wallets/transactions',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnTransaction.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific transaction by ID.
  ///
  /// [transactionId] - The transaction ID.
  Future<SnTransaction> getTransaction(String transactionId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/wallets/transactions/$transactionId',
    );
    return SnTransaction.fromJson(response.data!);
  }

  // ==========================================
  // Subscription endpoints
  // ==========================================

  /// Gets all subscriptions.
  Future<List<SnWalletSubscription>> getSubscriptions() async {
    final response = await get<List<dynamic>>(
      '$_basePath/wallets/subscriptions',
    );
    return parseList(response, SnWalletSubscription.fromJson);
  }

  /// Gets a specific subscription by ID.
  ///
  /// [subscriptionId] - The subscription ID.
  Future<SnWalletSubscription> getSubscription(String subscriptionId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/wallets/subscriptions/$subscriptionId',
    );
    return SnWalletSubscription.fromJson(response.data!);
  }

  /// Cancels a subscription.
  ///
  /// [subscriptionId] - The subscription ID.
  Future<void> cancelSubscription(String subscriptionId) async {
    await delete('$_basePath/wallets/subscriptions/$subscriptionId');
  }

  /// Gets subscription catalog.
  Future<List<SnSubscriptionCatalog>> getSubscriptionCatalog() async {
    final response = await get<List<dynamic>>(
      '$_basePath/wallets/subscriptions/catalog',
    );
    return parseList(response, SnSubscriptionCatalog.fromJson);
  }

  /// Gets active subscriptions.
  Future<List<SnActiveSubscription>> getActiveSubscriptions() async {
    final response = await get<List<dynamic>>(
      '$_basePath/wallets/subscriptions/active',
    );
    return parseList(response, SnActiveSubscription.fromJson);
  }

  // ==========================================
  // Order endpoints
  // ==========================================

  /// Creates a new order.
  ///
  /// [productId] - The product ID.
  /// [quantity] - The quantity.
  Future<SnWalletOrder> createOrder({
    required String productId,
    int quantity = 1,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/wallets/orders',
      data: {'product_id': productId, 'quantity': quantity},
    );
    return SnWalletOrder.fromJson(response.data!);
  }

  /// Gets order history.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnWalletOrder>> getOrders({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/wallets/orders',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnWalletOrder.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific order by ID.
  ///
  /// [orderId] - The order ID.
  Future<SnWalletOrder> getOrder(String orderId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/orders/$orderId',
    );
    return SnWalletOrder.fromJson(response.data!);
  }

  // ==========================================
  // Gift endpoints
  // ==========================================

  /// Sends a gift.
  ///
  /// [toWalletId] - The recipient wallet ID.
  /// [giftId] - The gift type ID.
  /// [message] - Optional message.
  Future<SnWalletGift> sendGift({
    required String toWalletId,
    required String giftId,
    String? message,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/gifts',
      data: {
        'to_wallet_id': toWalletId,
        'gift_id': giftId,
        'message': ?message,
      },
    );
    return SnWalletGift.fromJson(response.data!);
  }

  /// Gets gift history.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnWalletGift>> getGifts({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/gifts',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnWalletGift.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }
}
