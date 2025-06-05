import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
sealed class AppToken with _$AppToken {
  const factory AppToken({required String token}) = _AppToken;

  factory AppToken.fromJson(Map<String, dynamic> json) =>
      _$AppTokenFromJson(json);
}

@freezed
sealed class SnAuthChallenge with _$SnAuthChallenge {
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
sealed class SnAuthFactor with _$SnAuthFactor {
  const factory SnAuthFactor({
    required String id,
    required int type,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required DateTime? expiredAt,
    required DateTime? enabledAt,
    required int trustworthy,
    required Map<String, dynamic>? createdResponse,
  }) = _SnAuthFactor;

  factory SnAuthFactor.fromJson(Map<String, dynamic> json) =>
      _$SnAuthFactorFromJson(json);
}
