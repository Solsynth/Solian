import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
abstract class SnWallet with _$SnWallet {
  const factory SnWallet({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String balance,
    required String goldenBalance,
    required String password,
    required int accountId,
  }) = _SnWallet;

  factory SnWallet.fromJson(Map<String, dynamic> json) => _$SnWalletFromJson(json);
}

@freezed
abstract class SnTransaction with _$SnTransaction {
  const factory SnTransaction({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String remark,
    required String amount,
    required String currency,
    required SnWallet? payer,
    required SnWallet? payee,
    required int? payerId,
    required int? payeeId,
  }) = _SnTransaction;

  factory SnTransaction.fromJson(Map<String, dynamic> json) => _$SnTransactionFromJson(json);
}
