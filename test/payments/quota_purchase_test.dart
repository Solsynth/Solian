import 'package:flutter_test/flutter_test.dart';
import 'package:island/payments/quota_purchase_sheet.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  test('parses the purchase config from the billing API', () {
    final config = SnQuotaPurchaseConfig.fromJson({
      'price_per_gb': '0.05',
      'currency': 'golds',
      'min_gb': 1,
      'max_gb': 1024,
    });

    expect(config.pricePerGb, 0.05);
    expect(config.currency, 'golds');
    expect(config.minGb, 1);
    expect(config.maxGb, 1024);
  });

  test('parses the order creation response', () {
    final order = SnQuotaOrder.fromJson({
      'order_id': 'order-123',
      'amount': '0.5',
      'currency': 'golds',
      'quantity_gb': 10,
      'quota_mb': 10240,
    });

    expect(order.orderId, 'order-123');
    expect(order.amount, '0.5');
    expect(order.currency, 'golds');
    expect(order.quantityGb, 10);
    expect(order.quotaMb, 10240);
  });

  test('wallet order amount tolerates fractional golds', () {
    final order = SnWalletOrder.fromJson({
      'id': 'order-123',
      'status': 0,
      'currency': 'golds',
      'remarks': null,
      'app_identifier': 'dysonfs',
      'meta': <String, dynamic>{},
      'amount': 0.5,
      'expired_at': '2026-08-16T12:00:00Z',
      'payee_wallet_id': null,
      'transaction_id': null,
      'issuer_app_id': null,
      'created_at': '2026-08-15T12:00:00Z',
      'updated_at': '2026-08-15T12:00:00Z',
      'deleted_at': null,
    });

    expect(order.amount, 0.5);
  });

  test('parses quota purchase records with optional expiry', () {
    final expiring = QuotaPurchaseRecord.fromJson({
      'id': 'record-1',
      'name': '1 GB Extra Quota',
      'description': 'Extra storage purchased via Wallet order',
      'quota': 1024,
      'order_id': 'order-123',
      'expired_at': '2026-09-14T12:00:00Z',
    });

    expect(expiring.name, '1 GB Extra Quota');
    expect(expiring.description, 'Extra storage purchased via Wallet order');
    expect(expiring.quotaMb, 1024);
    expect(expiring.orderId, 'order-123');
    expect(expiring.expiredAt, isNotNull);

    final permanent = QuotaPurchaseRecord.fromJson({
      'id': 'record-2',
      'name': '荆州刺使',
      'description': '朝廷配给',
      'quota': 102400,
      'order_id': 'order-456',
    });
    expect(permanent.name, '荆州刺使');
    expect(permanent.description, '朝廷配给');
    expect(permanent.quotaMb, 102400);
    expect(permanent.expiredAt, isNull);
  });
}
