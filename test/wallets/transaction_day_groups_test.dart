import 'package:flutter_test/flutter_test.dart';
import 'package:island/wallets/wallet.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnTransaction _tx({
  required String id,
  required String currency,
  required double amount,
  required DateTime createdAt,
  required String? payeeWalletId,
  required String? payerWalletId,
}) {
  return SnTransaction(
    id: id,
    currency: currency,
    amount: amount,
    remarks: null,
    type: 0,
    status: TransactionStatus.confirmed,
    payerWalletId: payerWalletId,
    payerWallet: null,
    payeeWalletId: payeeWalletId,
    payeeWallet: null,
    createdAt: createdAt,
    updatedAt: createdAt,
    deletedAt: null,
  );
}

void main() {
  final day1 = DateTime(2026, 8, 16, 10, 30);
  final day2 = DateTime(2026, 8, 15, 9, 0);

  test('groups consecutive same-day transactions under one header', () {
    final groups = groupTransactionsByDay([
      _tx(
        id: 'a',
        currency: 'golds',
        amount: 120,
        createdAt: day1,
        payeeWalletId: 'w',
        payerWalletId: 'other',
      ),
      _tx(
        id: 'b',
        currency: 'golds',
        amount: 45,
        createdAt: day1.add(const Duration(hours: 1)),
        payeeWalletId: 'other',
        payerWalletId: 'w',
      ),
    ], 'w');

    expect(groups.keys.toList(), [0]);
    final day = groups[0]!;
    expect(day.date, DateTime(2026, 8, 16));
    final golds = day.byCurrency['golds']!;
    expect(golds.inAmount, 120);
    expect(golds.outAmount, 45);
  });

  test('starts a new header when the day changes', () {
    final groups = groupTransactionsByDay([
      _tx(
        id: 'a',
        currency: 'points',
        amount: 10,
        createdAt: day1,
        payeeWalletId: 'w',
        payerWalletId: 'other',
      ),
      _tx(
        id: 'b',
        currency: 'points',
        amount: 20,
        createdAt: day2,
        payeeWalletId: 'other',
        payerWalletId: 'w',
      ),
    ], 'w');

    expect(groups.keys.toList(), [0, 1]);
    expect(groups[0]!.byCurrency['points']!.inAmount, 10);
    expect(groups[1]!.byCurrency['points']!.outAmount, 20);
  });

  test('keeps per-currency sums separate on mixed days', () {
    final groups = groupTransactionsByDay([
      _tx(
        id: 'a',
        currency: 'points',
        amount: 5,
        createdAt: day1,
        payeeWalletId: 'w',
        payerWalletId: 'other',
      ),
      _tx(
        id: 'b',
        currency: 'golds',
        amount: 99,
        createdAt: day1,
        payeeWalletId: 'other',
        payerWalletId: 'w',
      ),
    ], 'w');

    final day = groups[0]!;
    expect(day.byCurrency.keys.toList(), ['points', 'golds']);
    expect(day.byCurrency['points']!.inAmount, 5);
    expect(day.byCurrency['golds']!.outAmount, 99);
  });

  test('counts everything as outcome when no wallet is known', () {
    final groups = groupTransactionsByDay([
      _tx(
        id: 'a',
        currency: 'golds',
        amount: 7,
        createdAt: day1,
        payeeWalletId: 'w',
        payerWalletId: 'other',
      ),
    ], null);

    expect(groups[0]!.byCurrency['golds']!.inAmount, 0);
    expect(groups[0]!.byCurrency['golds']!.outAmount, 7);
  });

  test('returns an empty map for an empty list', () {
    expect(groupTransactionsByDay([], 'w'), isEmpty);
  });
}
