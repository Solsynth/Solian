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
sealed class GeoIpLocation with _$GeoIpLocation {
  const factory GeoIpLocation({
    required double? latitude,
    required double? longitude,
    required String? countryCode,
    required String? country,
    required String? city,
  }) = _GeoIpLocation;

  factory GeoIpLocation.fromJson(Map<String, dynamic> json) =>
      _$GeoIpLocationFromJson(json);
}

@freezed
sealed class SnAuthChallenge with _$SnAuthChallenge {
  const factory SnAuthChallenge({
    required String id,
    required DateTime? expiredAt,
    required int stepRemain,
    required int stepTotal,
    required int failedAttempts,
    required List<String> blacklistFactors,
    required List<dynamic> audiences,
    required List<dynamic> scopes,
    required String ipAddress,
    required String userAgent,
    required String? nonce,
    required GeoIpLocation? location,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAuthChallenge;

  factory SnAuthChallenge.fromJson(Map<String, dynamic> json) =>
      _$SnAuthChallengeFromJson(json);
}

@freezed
sealed class SnAuthSession with _$SnAuthSession {
  const factory SnAuthSession({
    required String id,
    required String? label,
    required DateTime lastGrantedAt,
    required DateTime? expiredAt,
    required List<dynamic> audiences,
    required List<dynamic> scopes,
    required String? ipAddress,
    required String? userAgent,
    required GeoIpLocation? location,
    required int type,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAuthSession;

  factory SnAuthSession.fromJson(Map<String, dynamic> json) =>
      _$SnAuthSessionFromJson(json);
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

@freezed
sealed class SnAccountConnection with _$SnAccountConnection {
  const factory SnAccountConnection({
    required String id,
    required String accountId,
    required String provider,
    required String providedIdentifier,
    @Default({}) Map<String, dynamic> meta,
    required DateTime lastUsedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccountConnection;

  factory SnAccountConnection.fromJson(Map<String, dynamic> json) =>
      _$SnAccountConnectionFromJson(json);
}
