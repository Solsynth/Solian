import 'package:freezed_annotation/freezed_annotation.dart';

part 'misc.freezed.dart';
part 'misc.g.dart';

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
    @Default(false) bool isPublic,
    @Default({}) Map<String, dynamic> meta,
    required DateTime lastUsedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAccountConnection;

  factory SnAccountConnection.fromJson(Map<String, dynamic> json) =>
      _$SnAccountConnectionFromJson(json);
}
