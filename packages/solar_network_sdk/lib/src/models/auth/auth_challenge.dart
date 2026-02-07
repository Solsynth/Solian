import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_challenge.freezed.dart';
part 'auth_challenge.g.dart';

@freezed
class SnAuthChallenge with _$SnAuthChallenge {
  const factory SnAuthChallenge({
    required String id,
    DateTime? expiredAt,
    required int stepRemain,
    required int stepTotal,
    required int failedAttempts,
    required List<String> blacklistFactors,
    required List<dynamic> audiences,
    required List<dynamic> scopes,
    required String ipAddress,
    required String userAgent,
    String? nonce,
    String? countryCode,
    String? country,
    String? city,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnAuthChallenge;

  factory SnAuthChallenge.fromJson(Map<String, dynamic> json) =>
      _$SnAuthChallengeFromJson(json);
}

@freezed
class SnAuthFactor with _$SnAuthFactor {
  const factory SnAuthFactor({
    required String id,
    required int type,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    DateTime? expiredAt,
    DateTime? enabledAt,
    required int trustworthy,
    Map<String, dynamic>? createdResponse,
  }) = _SnAuthFactor;

  factory SnAuthFactor.fromJson(Map<String, dynamic> json) =>
      _$SnAuthFactorFromJson(json);
}

@freezed
class SnAccountConnection with _$SnAccountConnection {
  const factory SnAccountConnection({
    required String id,
    required String accountId,
    required String provider,
    required String providedIdentifier,
    @Default({}) Map<String, dynamic> meta,
    required DateTime lastUsedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnAccountConnection;

  factory SnAccountConnection.fromJson(Map<String, dynamic> json) =>
      _$SnAccountConnectionFromJson(json);
}
