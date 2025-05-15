import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
abstract class AppTokenPair with _$AppTokenPair {
  const factory AppTokenPair({
    required String accessToken,
    required String refreshToken,
  }) = _AppTokenPair;

  factory AppTokenPair.fromJson(Map<String, dynamic> json) =>
      _$AppTokenPairFromJson(json);
}

@freezed
abstract class SnAuthChallenge with _$SnAuthChallenge {
  const factory SnAuthChallenge({
    required String id,
    required DateTime expiredAt,
    required int stepRemain,
    required int stepTotal,
    required List<String> blacklistFactors,
    required List<String> audiences,
    required List<String> scopes,
    required String ipAddress,
    required String userAgent,
    required String? deviceId,
    required String? nonce,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAuthChallenge;

  factory SnAuthChallenge.fromJson(Map<String, dynamic> json) =>
      _$SnAuthChallengeFromJson(json);
}

@freezed
abstract class SnAuthFactor with _$SnAuthFactor {
  const factory SnAuthFactor({
    required String id,
    required int type,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAuthFactor;

  factory SnAuthFactor.fromJson(Map<String, dynamic> json) =>
      _$SnAuthFactorFromJson(json);
}
