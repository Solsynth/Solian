// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppTokenPair _$AppTokenPairFromJson(Map<String, dynamic> json) =>
    _AppTokenPair(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$AppTokenPairToJson(_AppTokenPair instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };

_SnAuthChallenge _$SnAuthChallengeFromJson(Map<String, dynamic> json) =>
    _SnAuthChallenge(
      id: json['id'] as String,
      expiredAt: DateTime.parse(json['expired_at'] as String),
      stepRemain: (json['step_remain'] as num).toInt(),
      stepTotal: (json['step_total'] as num).toInt(),
      blacklistFactors:
          (json['blacklist_factors'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      audiences:
          (json['audiences'] as List<dynamic>).map((e) => e as String).toList(),
      scopes:
          (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
      ipAddress: json['ip_address'] as String,
      userAgent: json['user_agent'] as String,
      deviceId: json['device_id'] as String?,
      nonce: json['nonce'] as String?,
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
      'blacklist_factors': instance.blacklistFactors,
      'audiences': instance.audiences,
      'scopes': instance.scopes,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'device_id': instance.deviceId,
      'nonce': instance.nonce,
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
    );

Map<String, dynamic> _$SnAuthFactorToJson(_SnAuthFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
