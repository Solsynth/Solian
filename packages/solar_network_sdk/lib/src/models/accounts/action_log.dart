import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'action_log.g.dart';
part 'action_log.freezed.dart';

@freezed
sealed class SnActionLog with _$SnActionLog {
  const factory SnActionLog({
    required String id,
    required String action,
    required Map<String, dynamic> meta,
    required String userAgent,
    required String ipAddress,
    required GeoIpLocation? location,
    required String accountId,
    required String? sessionId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnActionLog;

  factory SnActionLog.fromJson(Map<String, dynamic> json) =>
      _$SnActionLogFromJson(json);
}
