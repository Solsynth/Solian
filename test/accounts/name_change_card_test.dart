import 'package:flutter_test/flutter_test.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  test('parses the order creation response', () {
    final order = SnNameChangeCardOrder.fromJson({
      'purchase_id': 'purchase-1',
      'order_id': 'order-123',
      'amount': 100,
    });

    expect(order.purchaseId, 'purchase-1');
    expect(order.orderId, 'order-123');
    expect(order.amount, 100.0);
  });

  test('parses an unfulfilled purchase row', () {
    final purchase = SnNameChangeCardPurchase.fromJson({
      'id': 'purchase-1',
      'account_id': 'account-9',
      'order_id': 'order-123',
      'amount': 100,
      'fulfilled_at': null,
      'consumed_at': null,
      'target_type': null,
      'target_id': null,
      'old_name': null,
      'new_name': null,
      'created_at': '2026-08-15T12:00:00Z',
      'updated_at': '2026-08-15T12:00:00Z',
    });

    expect(purchase.id, 'purchase-1');
    expect(purchase.accountId, 'account-9');
    expect(purchase.orderId, 'order-123');
    expect(purchase.amount, 100.0);
    expect(purchase.fulfilledAt, isNull);
    expect(purchase.consumedAt, isNull);
    expect(purchase.targetType, isNull);
    expect(purchase.oldName, isNull);
    expect(purchase.newName, isNull);
    expect(purchase.isFulfilled, isFalse);
    expect(purchase.isConsumed, isFalse);
  });

  test('parses a fulfilled and consumed purchase row', () {
    final purchase = SnNameChangeCardPurchase.fromJson({
      'id': 'purchase-2',
      'account_id': 'account-9',
      'order_id': 'order-456',
      'amount': 100,
      'fulfilled_at': '2026-08-15T12:01:00Z',
      'consumed_at': '2026-08-15T12:05:00Z',
      'target_type': 'account',
      'target_id': null,
      'old_name': 'alice',
      'new_name': 'alice_new',
      'created_at': '2026-08-15T12:00:00Z',
      'updated_at': '2026-08-15T12:05:00Z',
    });

    expect(purchase.isFulfilled, isTrue);
    expect(purchase.isConsumed, isTrue);
    expect(purchase.targetType, SnNameChangeCardTargetType.account);
    expect(purchase.oldName, 'alice');
    expect(purchase.newName, 'alice_new');
  });

  test('maps realm and publisher target types from their wire values', () {
    final realm = SnNameChangeCardPurchase.fromJson({
      'id': 'purchase-3',
      'account_id': 'account-9',
      'order_id': 'order-789',
      'amount': 100,
      'fulfilled_at': '2026-08-15T12:01:00Z',
      'consumed_at': '2026-08-15T12:05:00Z',
      'target_type': 'realm',
      'target_id': 'my-realm',
      'old_name': 'my-realm',
      'new_name': 'new-slug',
      'created_at': '2026-08-15T12:00:00Z',
      'updated_at': '2026-08-15T12:05:00Z',
    });
    expect(
      realm.targetType,
      SnNameChangeCardTargetType.realm,
    );
    expect(realm.targetId, 'my-realm');
    expect(realm.newName, 'new-slug');

    final publisher = SnNameChangeCardPurchase.fromJson({
      'id': 'purchase-4',
      'account_id': 'account-9',
      'order_id': 'order-1011',
      'amount': 100,
      'fulfilled_at': '2026-08-15T12:01:00Z',
      'consumed_at': '2026-08-15T12:05:00Z',
      'target_type': 'publisher',
      'target_id': 'pub-id-1',
      'old_name': 'old-pub',
      'new_name': 'new-pub-name',
      'created_at': '2026-08-15T12:00:00Z',
      'updated_at': '2026-08-15T12:05:00Z',
    });
    expect(
      publisher.targetType,
      SnNameChangeCardTargetType.publisher,
    );
    expect(publisher.targetId, 'pub-id-1');
    expect(publisher.newName, 'new-pub-name');
  });

  test('unknown target type degrades to null', () {
    expect(
      SnNameChangeCardTargetType.fromWire('unknown-kind'),
      isNull,
    );
  });
}
