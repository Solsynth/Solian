import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:island/models/auth.dart';
import 'package:island/models/wallet.dart';
import 'package:island/widgets/payment/payment_overlay.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
sealed class PaymentRequest with _$PaymentRequest {
  const factory PaymentRequest({
    required String orderId,
    required int amount,
    required String currency,
    String? remarks,
    String? payeeWalletId,
    String? pinCode,
    @Default(true) bool showOverlay,
    @Default(true) bool enableBiometric,
  }) = _PaymentRequest;

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);
}

@freezed
sealed class PaymentResult with _$PaymentResult {
  const factory PaymentResult({
    required bool success,
    SnWalletOrder? order,
    String? error,
    String? errorCode,
  }) = _PaymentResult;

  factory PaymentResult.fromJson(Map<String, dynamic> json) =>
      _$PaymentResultFromJson(json);
}

@freezed
sealed class CreateOrderRequest with _$CreateOrderRequest {
  const factory CreateOrderRequest({
    required int amount,
    required String currency,
    String? remarks,
    String? payeeWalletId,
    String? appIdentifier,
    @Default({}) Map<String, dynamic> meta,
  }) = _CreateOrderRequest;

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);
}

class PaymentAPI {
  static PaymentAPI? _instance;
  late Dio _dio;
  late String _serverUrl;
  String? _token;

  PaymentAPI._internal();

  static PaymentAPI get instance {
    _instance ??= PaymentAPI._internal();
    return _instance!;
  }

  Future<void> _initialize() async {
    if (_dio == null) {
      final prefs = await SharedPreferences.getInstance();
      _serverUrl =
          prefs.getString(kNetworkServerStoreKey) ?? kNetworkServerDefault;

      final tokenString = prefs.getString(kTokenPairStoreKey);
      if (tokenString != null) {
        final appToken = AppToken.fromJson(jsonDecode(tokenString!));
        _token = await getToken(appToken);
      }

      _dio = Dio(
        BaseOptions(
          baseUrl: _serverUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            if (_token != null) {
              options.headers['Authorization'] = 'AtField $_token';
            }
            return handler.next(options);
          },
        ),
      );
    }
  }

  Future<SnWalletOrder?> createOrder(CreateOrderRequest request) async {
    await _initialize();

    try {
      final response = await _dio.post('/pass/orders', data: request.toJson());

      return SnWalletOrder.fromJson(response.data);
    } catch (e) {
      throw _parsePaymentError(e);
    }
  }

  Future<SnWalletOrder?> processPayment({
    required String orderId,
    required String pinCode,
    bool enableBiometric = true,
  }) async {
    await _initialize();

    try {
      final response = await _dio.post(
        '/pass/orders/$orderId/pay',
        data: {'pin_code': pinCode},
      );

      return SnWalletOrder.fromJson(response.data);
    } catch (e) {
      throw _parsePaymentError(e);
    }
  }

  Future<PaymentResult> processPaymentWithOverlay({
    required BuildContext context,
    PaymentRequest? request,
    CreateOrderRequest? createOrderRequest,
    bool enableBiometric = true,
  }) async {
    try {
      await _initialize();

      SnWalletOrder order;

      if (request == null && createOrderRequest == null) {
        return PaymentResult(
          success: false,
          error: 'Either request or createOrderRequest must be provided',
        );
      }

      if (request != null) {
        order = (await createOrder(createOrderRequest!))!;
      } else {
        order = SnWalletOrder(
          id: request!.orderId,
          status: 0,
          currency: request!.currency,
          remarks: request!.remarks,
          appIdentifier: 'mini-app',
          meta: {},
          amount: request!.amount,
          expiredAt: DateTime.now().add(const Duration(hours: 1)),
          payeeWalletId: request!.payeeWalletId,
          transactionId: null,
          issuerAppId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deletedAt: null,
        );
      }

      final result = await PaymentOverlay.show(
        context: context,
        order: order,
        enableBiometric: enableBiometric,
      );

      if (result != null) {
        return PaymentResult(success: true, order: result);
      } else {
        return PaymentResult(
          success: false,
          error: 'Payment was cancelled by user',
        );
      }
    } catch (e) {
      final errorMessage = _parsePaymentError(e);
      return PaymentResult(
        success: false,
        error: errorMessage,
        errorCode: e is DioException
            ? (e as DioException).response?.statusCode.toString()
            : null,
      );
    }
  }

  Future<PaymentResult> processDirectPayment(PaymentRequest request) async {
    await _initialize();

    try {
      if (request.pinCode == null) {
        return PaymentResult(
          success: false,
          error: 'PIN code is required for direct payment processing',
        );
      }

      final result = await processPayment(
        orderId: request.orderId,
        pinCode: request.pinCode!,
        enableBiometric: request.enableBiometric,
      );

      if (result != null) {
        return PaymentResult(success: true, order: result);
      } else {
        return PaymentResult(success: false, error: 'Payment failed');
      }
    } catch (e) {
      final errorMessage = _parsePaymentError(e);
      return PaymentResult(
        success: false,
        error: errorMessage,
        errorCode: e is DioException
            ? (e as DioException).response?.statusCode.toString()
            : null,
      );
    }
  }

  String _parsePaymentError(dynamic error) {
    if (error is DioException) {
      final dioError = error as DioException;

      if (dioError.response?.statusCode == 403 ||
          dioError.response?.statusCode == 401) {
        return 'invalidPin'.tr();
      } else if (dioError.response?.statusCode == 400) {
        return dioError.response?.data?['error'] ?? 'paymentFailed'.tr();
      } else if (dioError.response?.statusCode == 503) {
        return 'serviceUnavailable'.tr();
      } else if (dioError.response?.statusCode == 404) {
        return 'orderNotFound'.tr();
      }

      return 'networkError'.tr();
    }

    return error.toString();
  }

  Future<void> updateServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl =
        prefs.getString(kNetworkServerStoreKey) ?? kNetworkServerDefault;
    _dio.options.baseUrl = _serverUrl;
  }

  Future<void> updateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenString = prefs.getString(kTokenPairStoreKey);
    if (tokenString != null) {
      final appToken = AppToken.fromJson(jsonDecode(tokenString!));
      _token = await getToken(appToken);
    } else {
      _token = null;
    }
  }

  void dispose() {
    _dio.close();
  }
}
