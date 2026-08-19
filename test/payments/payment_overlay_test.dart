import 'package:flutter_test/flutter_test.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  test('parses the system app marker from snake_case responses', () {
    final info = PaymentOverlayOrderInfo.fromJson({
      'is_system_app': true,
      'app': {
        'id': '00000000-0000-0000-0000-000000000000',
        'slug': 'internal',
        'name': 'Solar Network',
        'description': 'Built-in platform services',
      },
    });

    expect(info.isSystemApp, isTrue);
    expect(info.app?.name, 'Solar Network');
    expect(info.developer, isNull);
  });

  test('keeps custom app responses non-system by default', () {
    final info = PaymentOverlayOrderInfo.fromJson({
      'app': {'id': 'app-id', 'slug': 'example-app', 'name': 'Example App'},
      'developer': {
        'id': 'developer-id',
        'publisher_id': 'publisher-id',
        'publisher_name': 'Example Publisher',
      },
    });

    expect(info.isSystemApp, isFalse);
    expect(info.app?.slug, 'example-app');
    expect(info.developer?.publisherName, 'Example Publisher');
  });

  test('treats wallet order zero dates as absent', () {
    final order = SnWalletOrder.fromJson({
      'id': 'order-123',
      'status': 0,
      'currency': 'points',
      'remarks': null,
      'app_identifier': 'internal',
      'amount': 500,
      'expired_at': '0001-01-01T00:00:00+00:00',
      'payer_wallet_id': null,
      'payee_wallet_id': null,
      'transaction_id': null,
      'issuer_app_id': null,
      'created_at': '2026-08-19T08:17:28.60535+00:00',
      'updated_at': '0001-01-01T00:00:00+00:00',
      'deleted_at': null,
    });

    expect(order.expiredAt, isNull);
    expect(order.updatedAt, isNull);
  });
}
