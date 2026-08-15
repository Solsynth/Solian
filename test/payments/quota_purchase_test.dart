import 'package:flutter_test/flutter_test.dart';
import 'package:island/payments/quota_purchase_sheet.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  test('parses purchasable quota products from the billing API', () {
    final products = [
      SnQuotaProduct.fromJson({
        'product_identifier': 'dysonfs.quota.10gb',
        'display_name': '10 GB Extra Quota',
        'description': 'One-time extra storage, +10 GB for 30 days',
        'quota_mb': 10240,
        'price': '120',
        'currency': 'golds',
        'expires_in': '720h',
      }),
      // Permanent pack: expires_in omitted, numeric price tolerated.
      SnQuotaProduct.fromJson({
        'product_identifier': 'dysonfs.quota.50gb',
        'display_name': '50 GB Extra Quota',
        'quota_mb': 51200,
        'price': 500,
        'currency': 'golds',
      }),
    ];

    expect(products[0].productIdentifier, 'dysonfs.quota.10gb');
    expect(products[0].displayName, '10 GB Extra Quota');
    expect(products[0].quotaMb, 10240);
    expect(products[0].price, '120');
    expect(products[0].currency, 'golds');
    expect(products[0].expiresIn, '720h');

    expect(products[1].expiresIn, isNull);
    expect(products[1].price, '500');
  });

  test('parses the order creation response', () {
    final order = SnQuotaOrder.fromJson({
      'order_id': 'order-123',
      'amount': '120',
      'currency': 'golds',
    });

    expect(order.orderId, 'order-123');
    expect(order.amount, '120');
    expect(order.currency, 'golds');
  });

  test('parses quota purchase records with optional expiry', () {
    final expiring = QuotaPurchaseRecord.fromJson({
      'id': 'record-1',
      'product_identifier': 'dysonfs.quota.10gb',
      'quota_mb': 10240,
      'order_id': 'order-123',
      'expired_at': '2026-09-14T12:00:00Z',
    });

    expect(expiring.quotaMb, 10240);
    expect(expiring.orderId, 'order-123');
    expect(expiring.expiredAt, isNotNull);

    final permanent = QuotaPurchaseRecord.fromJson({
      'id': 'record-2',
      'quota_mb': 10240,
      'order_id': 'order-456',
    });
    expect(permanent.expiredAt, isNull);
  });
}
