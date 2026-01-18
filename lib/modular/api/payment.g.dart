// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    _PaymentRequest(
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      remarks: json['remarks'] as String?,
      payeeWalletId: json['payee_wallet_id'] as String?,
      pinCode: json['pin_code'] as String?,
      showOverlay: json['show_overlay'] as bool? ?? true,
      enableBiometric: json['enable_biometric'] as bool? ?? true,
    );

Map<String, dynamic> _$PaymentRequestToJson(_PaymentRequest instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'remarks': instance.remarks,
      'payee_wallet_id': instance.payeeWalletId,
      'pin_code': instance.pinCode,
      'show_overlay': instance.showOverlay,
      'enable_biometric': instance.enableBiometric,
    };

_PaymentResult _$PaymentResultFromJson(Map<String, dynamic> json) =>
    _PaymentResult(
      success: json['success'] as bool,
      order: json['order'] == null
          ? null
          : SnWalletOrder.fromJson(json['order'] as Map<String, dynamic>),
      error: json['error'] as String?,
      errorCode: json['error_code'] as String?,
    );

Map<String, dynamic> _$PaymentResultToJson(_PaymentResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'order': instance.order?.toJson(),
      'error': instance.error,
      'error_code': instance.errorCode,
    };

_CreateOrderRequest _$CreateOrderRequestFromJson(Map<String, dynamic> json) =>
    _CreateOrderRequest(
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      remarks: json['remarks'] as String?,
      payeeWalletId: json['payee_wallet_id'] as String?,
      appIdentifier: json['app_identifier'] as String?,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CreateOrderRequestToJson(_CreateOrderRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'remarks': instance.remarks,
      'payee_wallet_id': instance.payeeWalletId,
      'app_identifier': instance.appIdentifier,
      'meta': instance.meta,
    };
