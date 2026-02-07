import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

@freezed
class SnAuthSession with _$SnAuthSession {
  const factory SnAuthSession({
    required String id,
    String? label,
    required DateTime lastGrantedAt,
    DateTime? expiredAt,
    required List<dynamic> audiences,
    required List<dynamic> scopes,
    String? ipAddress,
    String? userAgent,
    String? location,
    required int type,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnAuthSession;

  factory SnAuthSession.fromJson(Map<String, dynamic> json) =>
      _$SnAuthSessionFromJson(json);
}
