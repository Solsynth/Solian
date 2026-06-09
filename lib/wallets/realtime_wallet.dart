import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:island/wallets/wallet.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final realtimeWalletProvider = Provider<RealtimeWalletHandler>((ref) {
  return RealtimeWalletHandler(ref);
});

class RealtimeWalletHandler {
  final Ref _ref;
  StreamSubscription? _subscription;

  RealtimeWalletHandler(this._ref);

  void startListening() {
    final ws = _ref.read(websocketProvider);
    _subscription?.cancel();
    _subscription = ws.dataStream.listen(_handlePacket);
    Logger.root.info('[RealtimeWallet] Started listening to WebSocket');
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    Logger.root.info('[RealtimeWallet] Stopped listening to WebSocket');
  }

  void _handlePacket(WebSocketPacket packet) {
    switch (packet.type) {
      case 'wallet.transaction.created':
        _handleTransactionCreated(packet);
      case 'wallet.transaction.confirmed':
        _handleTransactionConfirmed(packet);
      case 'wallet.transaction.refunded':
        _handleTransactionRefunded(packet);
      case 'wallet.transaction.expired':
        _handleTransactionExpired(packet);
      case 'wallet.pocket.updated':
        _handlePocketUpdated(packet);
      case 'wallet.fund.contributed':
        _handleFundContributed(packet);
      case 'wallet.fund.completed':
        _handleFundCompleted(packet);
    }
  }

  void _handleTransactionCreated(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final transaction = SnTransaction.fromJson(packet.data!);

      Logger.root.info(
        '[RealtimeWallet] Transaction created: ${transaction.id} '
        '(${transaction.amount} ${transaction.currency}, status: ${transaction.status})',
      );

      // Fire event for UI to handle (e.g., show notification)
      eventBus.fire(WalletTransactionCreatedEvent(transaction));

      // Invalidate transaction list and wallet balance
      _ref.invalidate(transactionListProvider);
      _ref.invalidate(walletCurrentProvider);
      _ref.invalidate(walletListProvider);
    } catch (e) {
      Logger.root.severe(
        '[RealtimeWallet] Failed to parse transaction.created: $e',
      );
    }
  }

  void _handleTransactionConfirmed(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final transaction = SnTransaction.fromJson(packet.data!);

      Logger.root.info(
        '[RealtimeWallet] Transaction confirmed: ${transaction.id}',
      );

      eventBus.fire(WalletTransactionConfirmedEvent(transaction));

      // Invalidate providers to refresh UI
      _ref.invalidate(transactionListProvider);
      _ref.invalidate(walletCurrentProvider);
      _ref.invalidate(walletListProvider);
    } catch (e) {
      Logger.root.severe(
        '[RealtimeWallet] Failed to parse transaction.confirmed: $e',
      );
    }
  }

  void _handleTransactionRefunded(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final transaction = SnTransaction.fromJson(packet.data!);

      Logger.root.info(
        '[RealtimeWallet] Transaction refunded: ${transaction.id}',
      );

      eventBus.fire(WalletTransactionRefundedEvent(transaction));

      _ref.invalidate(transactionListProvider);
      _ref.invalidate(walletCurrentProvider);
      _ref.invalidate(walletListProvider);
    } catch (e) {
      Logger.root.severe(
        '[RealtimeWallet] Failed to parse transaction.refunded: $e',
      );
    }
  }

  void _handleTransactionExpired(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final transaction = SnTransaction.fromJson(packet.data!);

      Logger.root.info(
        '[RealtimeWallet] Transaction expired: ${transaction.id}',
      );

      eventBus.fire(WalletTransactionExpiredEvent(transaction));

      _ref.invalidate(transactionListProvider);
      _ref.invalidate(walletCurrentProvider);
      _ref.invalidate(walletListProvider);
    } catch (e) {
      Logger.root.severe(
        '[RealtimeWallet] Failed to parse transaction.expired: $e',
      );
    }
  }

  void _handlePocketUpdated(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final data = packet.data!;

      Logger.root.info(
        '[RealtimeWallet] Pocket updated: wallet=${data['wallet_id']}, '
        'currency=${data['currency']}, amount=${data['amount']}, '
        'held=${data['held_amount']}, available=${data['available_amount']}',
      );

      eventBus.fire(
        WalletPocketUpdatedEvent(
          walletId: data['wallet_id'] as String,
          currency: data['currency'] as String,
          amount: (data['amount'] as num).toDouble(),
          heldAmount: (data['held_amount'] as num?)?.toDouble() ?? 0,
          availableAmount: (data['available_amount'] as num?)?.toDouble() ?? 0,
        ),
      );

      // Invalidate wallet providers to refresh balance display
      _ref.invalidate(walletCurrentProvider);
      _ref.invalidate(walletListProvider);
      _ref.invalidate(walletStatsProvider);
    } catch (e) {
      Logger.root.severe(
        '[RealtimeWallet] Failed to parse pocket.updated: $e',
      );
    }
  }

  void _handleFundContributed(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final data = packet.data!;

      Logger.root.info(
        '[RealtimeWallet] Fund contributed: fund=${data['fund_id']}, '
        'amount=${data['amount']} ${data['currency']}, '
        'raised=${data['raised_amount']}/${data['target_amount']}',
      );

      eventBus.fire(
        WalletFundContributedEvent(
          fundId: data['fund_id'] as String,
          contributorAccountId: data['contributor_account_id'] as String,
          amount: (data['amount'] as num).toDouble(),
          currency: data['currency'] as String,
          raisedAmount: (data['raised_amount'] as num).toDouble(),
          targetAmount: (data['target_amount'] as num?)?.toDouble() ?? 0,
          status: (data['status'] as num?)?.toInt() ?? 0,
        ),
      );

      // Invalidate fund providers
      _ref.invalidate(walletFundsProvider);
      _ref.invalidate(walletCurrentProvider);
    } catch (e) {
      Logger.root.severe(
        '[RealtimeWallet] Failed to parse fund.contributed: $e',
      );
    }
  }

  void _handleFundCompleted(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final data = packet.data!;
      final fundId = data['fund_id'] as String;

      Logger.root.info('[RealtimeWallet] Fund completed: $fundId');

      eventBus.fire(WalletFundCompletedEvent(fundId));

      _ref.invalidate(walletFundsProvider);
      _ref.invalidate(walletCurrentProvider);
    } catch (e) {
      Logger.root.severe(
        '[RealtimeWallet] Failed to parse fund.completed: $e',
      );
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
