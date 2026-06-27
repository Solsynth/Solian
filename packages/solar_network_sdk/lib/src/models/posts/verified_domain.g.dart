// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verified_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPublisherVerifiedDomain _$SnPublisherVerifiedDomainFromJson(
  Map<String, dynamic> json,
) => _SnPublisherVerifiedDomain(
  id: json['id'] as String,
  publisherId: json['publisher_id'] as String,
  domain: json['domain'] as String,
  status:
      $enumDecodeNullable(_$DomainVerificationStatusEnumMap, json['status']) ??
      DomainVerificationStatus.pending,
  verifiedAt: json['verified_at'] == null
      ? null
      : DateTime.parse(json['verified_at'] as String),
  lastCheckedAt: json['last_checked_at'] == null
      ? null
      : DateTime.parse(json['last_checked_at'] as String),
  failedAttempts: (json['failed_attempts'] as num?)?.toInt() ?? 0,
  lastError: json['last_error'] as String? ?? null,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SnPublisherVerifiedDomainToJson(
  _SnPublisherVerifiedDomain instance,
) => <String, dynamic>{
  'id': instance.id,
  'publisher_id': instance.publisherId,
  'domain': instance.domain,
  'status': _$DomainVerificationStatusEnumMap[instance.status]!,
  'verified_at': instance.verifiedAt?.toIso8601String(),
  'last_checked_at': instance.lastCheckedAt?.toIso8601String(),
  'failed_attempts': instance.failedAttempts,
  'last_error': instance.lastError,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$DomainVerificationStatusEnumMap = {
  DomainVerificationStatus.pending: 0,
  DomainVerificationStatus.verified: 1,
  DomainVerificationStatus.failed: 2,
  DomainVerificationStatus.revoked: 3,
};
