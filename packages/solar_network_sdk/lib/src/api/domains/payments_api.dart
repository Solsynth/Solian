import 'package:dio/dio.dart';

import 'package:solar_network_sdk/src/api/base_api.dart';

/// API for payment-related endpoints (/payment).
///
/// Handles payments, transactions, invoices, and payment methods.
class PaymentsApi extends BaseApi {
  PaymentsApi(super.dio);

  /// Base path for all payment endpoints.
  static const String _basePath = '/payment';

  // ==========================================
  // Payment endpoints
  // ==========================================

  /// Gets all payments.
  ///
  /// [status] - Optional status filter.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<dynamic>> getPayments({
    String? status,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/payments',
      queryParameters: {'status': ?status, 'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(items: response.data ?? [], totalCount: totalCount);
  }

  /// Gets a specific payment by ID.
  ///
  /// [paymentId] - The payment ID.
  Future<Map<String, dynamic>> getPayment(String paymentId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/payments/$paymentId',
    );
    return response.data!;
  }

  /// Creates a new payment.
  ///
  /// [amount] - The payment amount.
  /// [currency] - The currency code.
  /// [methodId] - The payment method ID.
  /// [description] - Optional description.
  /// [metadata] - Optional metadata.
  Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String currency,
    required String methodId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/payments',
      data: {
        'amount': amount,
        'currency': currency,
        'method_id': methodId,
        'description': ?description,
        'metadata': ?metadata,
      },
    );
    return response.data!;
  }

  /// Cancels a payment.
  ///
  /// [paymentId] - The payment ID.
  Future<Map<String, dynamic>> cancelPayment(String paymentId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/payments/$paymentId/cancel',
    );
    return response.data!;
  }

  /// Refunds a payment.
  ///
  /// [paymentId] - The payment ID.
  /// [amount] - The refund amount (optional, full refund if not specified).
  /// [reason] - Optional reason.
  Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/payments/$paymentId/refund',
      data: {'amount': ?amount, 'reason': ?reason},
    );
    return response.data!;
  }

  // ==========================================
  // Payment method endpoints
  // ==========================================

  /// Gets all payment methods for the current user.
  Future<List<dynamic>> getPaymentMethods() async {
    final response = await get<List<dynamic>>('$_basePath/methods');
    return response.data ?? [];
  }

  /// Gets a specific payment method by ID.
  ///
  /// [methodId] - The method ID.
  Future<Map<String, dynamic>> getPaymentMethod(String methodId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/methods/$methodId',
    );
    return response.data!;
  }

  /// Adds a new payment method.
  ///
  /// [type] - The payment method type (e.g., 'card', 'bank', 'wallet').
  /// [data] - The payment method data.
  /// [setAsDefault] - Whether to set as default.
  Future<Map<String, dynamic>> addPaymentMethod({
    required String type,
    required Map<String, dynamic> data,
    bool setAsDefault = false,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/methods',
      data: {'type': type, 'data': data, 'set_as_default': setAsDefault},
    );
    return response.data!;
  }

  /// Updates a payment method.
  ///
  /// [methodId] - The method ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updatePaymentMethod({
    required String methodId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/methods/$methodId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes a payment method.
  ///
  /// [methodId] - The method ID.
  Future<void> deletePaymentMethod(String methodId) async {
    await delete('$_basePath/methods/$methodId');
  }

  /// Sets a payment method as default.
  ///
  /// [methodId] - The method ID.
  Future<Map<String, dynamic>> setDefaultPaymentMethod(String methodId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/methods/$methodId/default',
    );
    return response.data!;
  }

  /// Gets the default payment method.
  Future<Map<String, dynamic>?> getDefaultPaymentMethod() async {
    try {
      final response = await get<Map<String, dynamic>>(
        '$_basePath/methods/default',
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // Invoice endpoints
  // ==========================================

  /// Gets all invoices.
  ///
  /// [status] - Optional status filter.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<dynamic>> getInvoices({
    String? status,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/invoices',
      queryParameters: {'status': ?status, 'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(items: response.data ?? [], totalCount: totalCount);
  }

  /// Gets a specific invoice by ID.
  ///
  /// [invoiceId] - The invoice ID.
  Future<Map<String, dynamic>> getInvoice(String invoiceId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/invoices/$invoiceId',
    );
    return response.data!;
  }

  /// Creates a new invoice.
  ///
  /// [items] - Invoice items.
  /// [customerInfo] - Customer information.
  /// [dueDate] - Due date.
  Future<Map<String, dynamic>> createInvoice({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> customerInfo,
    DateTime? dueDate,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/invoices',
      data: {
        'items': items,
        'customer_info': customerInfo,
        if (dueDate != null) 'due_date': dueDate.toIso8601String(),
      },
    );
    return response.data!;
  }

  /// Sends an invoice.
  ///
  /// [invoiceId] - The invoice ID.
  /// [email] - The recipient email.
  Future<Map<String, dynamic>> sendInvoice({
    required String invoiceId,
    required String email,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/invoices/$invoiceId/send',
      data: {'email': email},
    );
    return response.data!;
  }

  /// Downloads an invoice as PDF.
  ///
  /// [invoiceId] - The invoice ID.
  Future<Response> downloadInvoicePdf(String invoiceId) async {
    return await get<Response>(
      '$_basePath/invoices/$invoiceId/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  // ==========================================
  // Subscription endpoints
  // ==========================================

  /// Gets all subscriptions.
  Future<List<dynamic>> getSubscriptions() async {
    final response = await get<List<dynamic>>('$_basePath/subscriptions');
    return response.data ?? [];
  }

  /// Gets a specific subscription by ID.
  ///
  /// [subscriptionId] - The subscription ID.
  Future<Map<String, dynamic>> getSubscription(String subscriptionId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/subscriptions/$subscriptionId',
    );
    return response.data!;
  }

  /// Creates a new subscription.
  ///
  /// [planId] - The plan ID.
  /// [paymentMethodId] - The payment method ID.
  /// [metadata] - Optional metadata.
  Future<Map<String, dynamic>> createSubscription({
    required String planId,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/subscriptions',
      data: {
        'plan_id': planId,
        'payment_method_id': paymentMethodId,
        'metadata': ?metadata,
      },
    );
    return response.data!;
  }

  /// Cancels a subscription.
  ///
  /// [subscriptionId] - The subscription ID.
  /// [cancelAtPeriodEnd] - Whether to cancel at period end.
  Future<Map<String, dynamic>> cancelSubscription({
    required String subscriptionId,
    bool cancelAtPeriodEnd = true,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/subscriptions/$subscriptionId/cancel',
      data: {'cancel_at_period_end': cancelAtPeriodEnd},
    );
    return response.data!;
  }

  /// Updates a subscription.
  ///
  /// [subscriptionId] - The subscription ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updateSubscription({
    required String subscriptionId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/subscriptions/$subscriptionId',
      data: data,
    );
    return response.data!;
  }

  /// Changes subscription plan.
  ///
  /// [subscriptionId] - The subscription ID.
  /// [newPlanId] - The new plan ID.
  Future<Map<String, dynamic>> changeSubscriptionPlan({
    required String subscriptionId,
    required String newPlanId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/subscriptions/$subscriptionId/change-plan',
      data: {'new_plan_id': newPlanId},
    );
    return response.data!;
  }

  // ==========================================
  // Plan endpoints
  // ==========================================

  /// Gets all available plans.
  Future<List<dynamic>> getPlans() async {
    final response = await get<List<dynamic>>('$_basePath/plans');
    return response.data ?? [];
  }

  /// Gets a specific plan by ID.
  ///
  /// [planId] - The plan ID.
  Future<Map<String, dynamic>> getPlan(String planId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/plans/$planId',
    );
    return response.data!;
  }

  /// Gets plan pricing.
  ///
  /// [planId] - The plan ID.
  /// [currency] - The currency code.
  Future<Map<String, dynamic>> getPlanPricing({
    required String planId,
    String currency = 'USD',
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/plans/$planId/pricing',
      queryParameters: {'currency': currency},
    );
    return response.data!;
  }

  // ==========================================
  // Transaction endpoints
  // ==========================================

  /// Gets all transactions.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<dynamic>> getTransactions({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/transactions',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(items: response.data ?? [], totalCount: totalCount);
  }

  /// Gets a specific transaction by ID.
  ///
  /// [transactionId] - The transaction ID.
  Future<Map<String, dynamic>> getTransaction(String transactionId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/transactions/$transactionId',
    );
    return response.data!;
  }

  // ==========================================
  // Balance endpoints
  // ==========================================

  /// Gets the current user's balance.
  Future<Map<String, dynamic>> getBalance() async {
    final response = await get<Map<String, dynamic>>('$_basePath/balance');
    return response.data!;
  }

  /// Gets balance transactions.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getBalanceTransactions({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/balance/transactions',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Withdraws balance.
  ///
  /// [amount] - The amount to withdraw.
  /// [methodId] - The payment method ID.
  Future<Map<String, dynamic>> withdrawBalance({
    required double amount,
    required String methodId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/balance/withdraw',
      data: {'amount': amount, 'method_id': methodId},
    );
    return response.data!;
  }

  // ==========================================
  // Refund endpoints
  // ==========================================

  /// Gets all refunds.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<dynamic>> getRefunds({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/refunds',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(items: response.data ?? [], totalCount: totalCount);
  }

  /// Gets a specific refund by ID.
  ///
  /// [refundId] - The refund ID.
  Future<Map<String, dynamic>> getRefund(String refundId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/refunds/$refundId',
    );
    return response.data!;
  }
}
