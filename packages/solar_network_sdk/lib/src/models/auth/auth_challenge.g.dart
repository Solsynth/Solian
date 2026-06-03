// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAuthChallenge _$SnAuthChallengeFromJson(Map<String, dynamic> json) =>
    _SnAuthChallenge(
      id: json['id'] as String,
      expiredAt: json['expired_at'] == null
          ? null
          : DateTime.parse(json['expired_at'] as String),
      stepRemain: (json['step_remain'] as num).toInt(),
      stepTotal: (json['step_total'] as num).toInt(),
      failedAttempts: (json['failed_attempts'] as num).toInt(),
      blacklistFactors: (json['blacklist_factors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      audiences: json['audiences'] as List<dynamic>,
      scopes: json['scopes'] as List<dynamic>,
      ipAddress: json['ip_address'] as String,
      userAgent: json['user_agent'] as String,
      nonce: json['nonce'] as String?,
      countryCode: json['country_code'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      deviceId: json['device_id'] as String?,
      deviceName: json['device_name'] as String?,
      platform: (json['platform'] as num?)?.toInt(),
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      declinedAt: json['declined_at'] == null
          ? null
          : DateTime.parse(json['declined_at'] as String),
      approvedBySessionId: json['approved_by_session_id'] as String?,
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAuthChallengeToJson(_SnAuthChallenge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expired_at': instance.expiredAt?.toIso8601String(),
      'step_remain': instance.stepRemain,
      'step_total': instance.stepTotal,
      'failed_attempts': instance.failedAttempts,
      'blacklist_factors': instance.blacklistFactors,
      'audiences': instance.audiences,
      'scopes': instance.scopes,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'nonce': instance.nonce,
      'country_code': instance.countryCode,
      'country': instance.country,
      'city': instance.city,
      'device_id': instance.deviceId,
      'device_name': instance.deviceName,
      'platform': instance.platform,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'declined_at': instance.declinedAt?.toIso8601String(),
      'approved_by_session_id': instance.approvedBySessionId,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
