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
    required int failedAttempts,
    required int platform,
    required int type,
    required List<String> blacklistFactors,
    required List<dynamic> audiences,
    required List<dynamic> scopes,
    required String ipAddress,
    required String userAgent,
    required String deviceId,
    required String? nonce,
    required String? location,
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
    required DateTime expiredAt,
    required String accountId,
    required String challengeId,
    required SnAuthChallenge challenge,
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
sealed class SnAuthDevice with _$SnAuthDevice {
  const factory SnAuthDevice({
    required dynamic label,
    required String userAgent,
    required String deviceId,
    required int platform,
    required List<SnAuthSession> sessions,
    // Not from backend, used for UI
    @Default(false) bool isCurrent,
  }) = _SnAuthDevice;

  factory SnAuthDevice.fromJson(Map<String, dynamic> json) =>
      _$SnAuthDeviceFromJson(json);
}
