import 'package:island/modular/api/payment.dart';

class PaymentBridgePlugin {
  static final instance = PaymentBridgePlugin._internal();
  PaymentBridgePlugin._internal();

  Future<PaymentResult> createOrder({
    required int amount,
    required String currency,
    String? remarks,
    String? payeeWalletId,
    String? appIdentifier,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final request = CreateOrderRequest(
        amount: amount,
        currency: currency,
        remarks: remarks,
        payeeWalletId: payeeWalletId,
        appIdentifier: appIdentifier,
        meta: meta ?? {},
      );
      final order = await PaymentApi.instance.createOrder(request);
      if (order == null) {
        return PaymentResult(success: false, error: 'Failed to create order');
      }
      return PaymentResult(success: true, order: order);
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }

  Future<PaymentResult> processPayment({
    required String orderId,
    required String pinCode,
    bool enableBiometric = true,
  }) async {
    try {
      final order = await PaymentApi.instance.processPayment(
        orderId: orderId,
        pinCode: pinCode,
        enableBiometric: enableBiometric,
      );
      if (order == null) {
        return PaymentResult(
          success: false,
          error: 'Failed to process payment',
        );
      }
      return PaymentResult(success: true, order: order);
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }

  Future<PaymentResult> processDirectPayment({
    required String orderId,
    required int amount,
    required String currency,
    required String pinCode,
    String? remarks,
    String? payeeWalletId,
    bool enableBiometric = true,
  }) async {
    try {
      final request = PaymentRequest(
        orderId: orderId,
        amount: amount,
        currency: currency,
        remarks: remarks,
        payeeWalletId: payeeWalletId,
        pinCode: pinCode,
        showOverlay: false,
        enableBiometric: enableBiometric,
      );
      return await PaymentApi.instance.processDirectPayment(request);
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }
}
