import 'package:freezed_annotation/freezed_annotation.dart';

part 'keypair.freezed.dart';
part 'keypair.g.dart';

@freezed
abstract class SnKeyPair with _$SnKeyPair {
  const factory SnKeyPair({
    required String id,
    required int accountId,
    required String publicKey,
    bool? isActive,
    String? privateKey,
  }) = _SnKeyPair;

  factory SnKeyPair.fromJson(Map<String, Object?> json) =>
      _$SnKeyPairFromJson(json);
}
