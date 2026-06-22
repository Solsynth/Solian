import 'package:freezed_annotation/freezed_annotation.dart';

part 'verified_domain.freezed.dart';
part 'verified_domain.g.dart';

enum DomainVerificationStatus {
  @JsonValue(0)
  pending,
  @JsonValue(1)
  verified,
  @JsonValue(2)
  failed,
  @JsonValue(3)
  revoked,
}

@freezed
sealed class SnPublisherVerifiedDomain with _$SnPublisherVerifiedDomain {
  const factory SnPublisherVerifiedDomain({
    required String id,
    @JsonKey(name: 'publisher_id') required String publisherId,
    required String domain,
    @Default(DomainVerificationStatus.pending) DomainVerificationStatus status,
    @JsonKey(name: 'verified_at') @Default(null) DateTime? verifiedAt,
    @JsonKey(name: 'last_checked_at')
    @Default(null)
    DateTime? lastCheckedAt,
    @JsonKey(name: 'failed_attempts') @Default(0) int failedAttempts,
    @JsonKey(name: 'last_error') @Default(null) String? lastError,
    @JsonKey(name: 'created_at') @Default(null) DateTime? createdAt,
    @JsonKey(name: 'updated_at') @Default(null) DateTime? updatedAt,
  }) = _SnPublisherVerifiedDomain;

  factory SnPublisherVerifiedDomain.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherVerifiedDomainFromJson(json);
}
