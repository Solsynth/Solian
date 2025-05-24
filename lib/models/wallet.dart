import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/user.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
sealed class SnWallet with _$SnWallet {
  const factory SnWallet({
    required String id,
    required List<SnWalletPocket> pockets,
    required String accountId,
    required SnAccount? account,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWallet;

  factory SnWallet.fromJson(Map<String, dynamic> json) =>
      _$SnWalletFromJson(json);
}

@freezed
sealed class SnWalletPocket with _$SnWalletPocket {
  const factory SnWalletPocket({
    required String id,
    required String currency,
    required double amount,
    required String walletId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnWalletPocket;

  factory SnWalletPocket.fromJson(Map<String, dynamic> json) =>
      _$SnWalletPocketFromJson(json);
}

@freezed
sealed class SnTransaction with _$SnTransaction {
  const factory SnTransaction({
    required String id,
    required String currency,
    required double amount,
    required String? remarks,
    required int type,
    required String? payerWalletId,
    required SnWallet? payerWallet,
    required String? payeeWalletId,
    required SnWallet? payeeWallet,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnTransaction;

  factory SnTransaction.fromJson(Map<String, dynamic> json) =>
      _$SnTransactionFromJson(json);
}
