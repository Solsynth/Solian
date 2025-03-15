import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
abstract class SnAuthResult with _$SnAuthResult {
  const factory SnAuthResult({
    required bool isFinished,
    required SnAuthTicket? ticket,
  }) = _SnAuthResult;

  factory SnAuthResult.fromJson(Map<String, Object?> json) =>
      _$SnAuthResultFromJson(json);
}

@freezed
abstract class SnAuthTicket with _$SnAuthTicket {
  const factory SnAuthTicket({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required int stepRemain,
    required String? grantToken,
    required String? accessToken,
    required String? refreshToken,
    required String ipAddress,
    required String? location,
    required double? coordinateX,
    required double? coordinateY,
    required String userAgent,
    required DateTime? expiredAt,
    required DateTime? lastGrantAt,
    required DateTime? availableAt,
    required String? nonce,
    required int? accountId,
    @Default([]) List<int> factorTrail,
  }) = _SnAuthTicket;

  factory SnAuthTicket.fromJson(Map<String, Object?> json) =>
      _$SnAuthTicketFromJson(json);
}

@freezed
abstract class SnAuthFactor with _$SnAuthFactor {
  const factory SnAuthFactor({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required int type,
    required Map<String, dynamic>? config,
    required int? accountId,
  }) = _SnAuthFactor;

  factory SnAuthFactor.fromJson(Map<String, Object?> json) =>
      _$SnAuthFactorFromJson(json);
}
