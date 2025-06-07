// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppToken _$AppTokenFromJson(Map<String, dynamic> json) =>
    _AppToken(token: json['token'] as String);

Map<String, dynamic> _$AppTokenToJson(_AppToken instance) => <String, dynamic>{
  'token': instance.token,
};

_SnAuthChallenge _$SnAuthChallengeFromJson(Map<String, dynamic> json) =>
    _SnAuthChallenge(
      id: json['id'] as String,
      expiredAt: DateTime.parse(json['expired_at'] as String),
      stepRemain: (json['step_remain'] as num).toInt(),
      stepTotal: (json['step_total'] as num).toInt(),
      failedAttempts: (json['failed_attempts'] as num).toInt(),
      platform: (json['platform'] as num).toInt(),
      type: (json['type'] as num).toInt(),
      blacklistFactors:
          (json['blacklist_factors'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      audiences: json['audiences'] as List<dynamic>,
      scopes: json['scopes'] as List<dynamic>,
      ipAddress: json['ip_address'] as String,
      userAgent: json['user_agent'] as String,
      deviceId: json['device_id'] as String,
      nonce: json['nonce'] as String?,
      location: json['location'] as String?,
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAuthChallengeToJson(_SnAuthChallenge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expired_at': instance.expiredAt.toIso8601String(),
      'step_remain': instance.stepRemain,
      'step_total': instance.stepTotal,
      'failed_attempts': instance.failedAttempts,
      'platform': instance.platform,
      'type': instance.type,
      'blacklist_factors': instance.blacklistFactors,
      'audiences': instance.audiences,
      'scopes': instance.scopes,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'device_id': instance.deviceId,
      'nonce': instance.nonce,
      'location': instance.location,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnAuthSession _$SnAuthSessionFromJson(Map<String, dynamic> json) =>
    _SnAuthSession(
      id: json['id'] as String,
      label: json['label'] as String?,
      lastGrantedAt: DateTime.parse(json['last_granted_at'] as String),
      expiredAt: DateTime.parse(json['expired_at'] as String),
      accountId: json['account_id'] as String,
      challengeId: json['challenge_id'] as String,
      challenge: SnAuthChallenge.fromJson(
        json['challenge'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAuthSessionToJson(_SnAuthSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'last_granted_at': instance.lastGrantedAt.toIso8601String(),
      'expired_at': instance.expiredAt.toIso8601String(),
      'account_id': instance.accountId,
      'challenge_id': instance.challengeId,
      'challenge': instance.challenge.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnAuthFactor _$SnAuthFactorFromJson(Map<String, dynamic> json) =>
    _SnAuthFactor(
      id: json['id'] as String,
      type: (json['type'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
      expiredAt:
          json['expired_at'] == null
              ? null
              : DateTime.parse(json['expired_at'] as String),
      enabledAt:
          json['enabled_at'] == null
              ? null
              : DateTime.parse(json['enabled_at'] as String),
      trustworthy: (json['trustworthy'] as num).toInt(),
      createdResponse: json['created_response'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SnAuthFactorToJson(_SnAuthFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'expired_at': instance.expiredAt?.toIso8601String(),
      'enabled_at': instance.enabledAt?.toIso8601String(),
      'trustworthy': instance.trustworthy,
      'created_response': instance.createdResponse,
    };

_SnAuthDevice _$SnAuthDeviceFromJson(Map<String, dynamic> json) =>
    _SnAuthDevice(
      label: json['label'],
      userAgent: json['user_agent'] as String,
      deviceId: json['device_id'] as String,
      platform: (json['platform'] as num).toInt(),
      sessions:
          (json['sessions'] as List<dynamic>)
              .map((e) => SnAuthSession.fromJson(e as Map<String, dynamic>))
              .toList(),
      isCurrent: json['is_current'] as bool? ?? false,
    );

Map<String, dynamic> _$SnAuthDeviceToJson(_SnAuthDevice instance) =>
    <String, dynamic>{
      'label': instance.label,
      'user_agent': instance.userAgent,
      'device_id': instance.deviceId,
      'platform': instance.platform,
      'sessions': instance.sessions.map((e) => e.toJson()).toList(),
      'is_current': instance.isCurrent,
    };
