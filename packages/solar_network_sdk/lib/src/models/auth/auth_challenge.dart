import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_challenge.freezed.dart';
part 'auth_challenge.g.dart';

@freezed
sealed class SnAuthChallenge with _$SnAuthChallenge {
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
    String? deviceId,
    String? deviceName,
    int? platform,
    DateTime? approvedAt,
    DateTime? declinedAt,
    String? approvedBySessionId,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnAuthChallenge;

  factory SnAuthChallenge.fromJson(Map<String, dynamic> json) =>
      _$SnAuthChallengeFromJson(json);
}
