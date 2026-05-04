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

  /// Gets the current user default wallet.
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

  /// Gets all personal wallets for the current user.
  Future<List<SnWallet>> getWallets() async {
    final response = await get<List<dynamic>>('$_basePath/wallets/all');
    return parseList(response, SnWallet.fromJson);
  }

  /// Gets a specific wallet by ID.
  Future<SnWallet> getWalletById(String id) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/wallets/$id',
    );
    return SnWallet.fromJson(response.data!);
  }

  /// Creates a new wallet.
  Future<SnWallet> createWallet({String? name, String? realmId}) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/wallets',
      data: {
        if (name != null) 'name': name,
        if (realmId != null) 'realm_id': realmId,
      },
    );
    return SnWallet.fromJson(response.data!);
  }

  /// Sets a wallet as the default for the current user.
  Future<void> setDefaultWallet(String id) async {
    await post('$_basePath/wallets/$id/default');
  }

  /// Enables the public ID for a wallet.
  Future<SnWallet> enablePublicId(String id) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/wallets/$id/public-id/enable',
    );
    return SnWallet.fromJson(response.data!);
  }

  /// Disables the public ID for a wallet.
  Future<SnWallet> disablePublicId(String id) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/wallets/$id/public-id/disable',
    );
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
  /// [amount] - The amount to transfer.
  /// [currency] - The currency.
  /// [pinCode] - The PIN code for verification.
  /// [payerWalletId] - Optional source wallet ID.
  /// [payeeWalletId] - Optional target wallet ID.
  /// [payeeAccountId] - Optional target account ID (resolves to default wallet).
  /// [payeePublicId] - Optional target public wallet ID.
  /// [remark] - Optional message.
  Future<void> transfer({
    required double amount,
    required String currency,
    required String pinCode,
    String? payerWalletId,
    String? payeeWalletId,
    String? payeeAccountId,
    String? payeePublicId,
    String? remark,
  }) async {
    await post(
      '$_basePath/wallets/transfer',
      data: {
        'amount': amount,
        'currency': currency,
        'pin_code': pinCode,
        if (payerWalletId != null) 'payer_wallet_id': payerWalletId,
        if (payeeWalletId != null) 'payee_wallet_id': payeeWalletId,
        if (payeeAccountId != null) 'payee_account_id': payeeAccountId,
        if (payeePublicId != null) 'payee_public_id': payeePublicId,
        if (remark != null) 'remark': remark,
      },
    );
  }

  // ==========================================
  // Transaction endpoints
  // ==========================================

  /// Gets all transactions.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  /// [wallet] - Filter by wallet ID.
  /// [direction] - Filter by direction (income/outcome).
  /// [type] - Filter by transaction type.
  Future<PaginatedResult<SnTransaction>> getTransactions({
    int offset = 0,
    int take = 20,
    String? wallet,
    String? direction,
    String? type,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/wallets/transactions',
      queryParameters: {
        'offset': offset,
        'take': take,
        if (wallet != null) 'wallet': wallet,
        if (direction != null) 'direction': direction,
        if (type != null) 'type': type,
      },
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
  /// [wallet] - Filter by wallet ID.
  /// [status] - Filter by order status.
  /// [direction] - Filter by direction (income/outcome).
  /// [type] - Filter by order type.
  Future<PaginatedResult<SnWalletOrder>> getOrders({
    int offset = 0,
    int take = 20,
    String? wallet,
    String? status,
    String? direction,
    String? type,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/wallets/orders',
      queryParameters: {
        'offset': offset,
        'take': take,
        if (wallet != null) 'wallet': wallet,
        if (status != null) 'status': status,
        if (direction != null) 'direction': direction,
        if (type != null) 'type': type,
      },
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
