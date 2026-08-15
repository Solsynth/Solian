import 'package:flutter_test/flutter_test.dart';
import 'package:island/payments/payment_overlay.dart';

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
}
