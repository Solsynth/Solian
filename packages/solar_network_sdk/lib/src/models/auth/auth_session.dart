import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/auth/misc.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

@freezed
sealed class SnAuthSession with _$SnAuthSession {
  const factory SnAuthSession({
    required String id,
    String? label,
    required DateTime lastGrantedAt,
    DateTime? expiredAt,
    required List<dynamic> audiences,
    required List<dynamic> scopes,
    String? ipAddress,
    String? userAgent,
    GeoIpLocation? location,
    required int type,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnAuthSession;

  factory SnAuthSession.fromJson(Map<String, dynamic> json) =>
      _$SnAuthSessionFromJson(json);
}
