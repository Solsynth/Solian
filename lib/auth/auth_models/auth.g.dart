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

_GeoIpLocation _$GeoIpLocationFromJson(Map<String, dynamic> json) =>
    _GeoIpLocation(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      countryCode: json['country_code'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
    );

Map<String, dynamic> _$GeoIpLocationToJson(_GeoIpLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'country_code': instance.countryCode,
      'country': instance.country,
      'city': instance.city,
    };

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
      location: json['location'] == null
          ? null
          : GeoIpLocation.fromJson(json['location'] as Map<String, dynamic>),
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
      'location': instance.location?.toJson(),
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
      expiredAt: json['expired_at'] == null
          ? null
          : DateTime.parse(json['expired_at'] as String),
      audiences: json['audiences'] as List<dynamic>,
      scopes: json['scopes'] as List<dynamic>,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      location: json['location'] == null
          ? null
          : GeoIpLocation.fromJson(json['location'] as Map<String, dynamic>),
      type: (json['type'] as num).toInt(),
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAuthSessionToJson(_SnAuthSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'last_granted_at': instance.lastGrantedAt.toIso8601String(),
      'expired_at': instance.expiredAt?.toIso8601String(),
      'audiences': instance.audiences,
      'scopes': instance.scopes,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'location': instance.location?.toJson(),
      'type': instance.type,
      'account_id': instance.accountId,
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
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      expiredAt: json['expired_at'] == null
          ? null
          : DateTime.parse(json['expired_at'] as String),
      enabledAt: json['enabled_at'] == null
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

_SnAccountConnection _$SnAccountConnectionFromJson(Map<String, dynamic> json) =>
    _SnAccountConnection(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      provider: json['provider'] as String,
      providedIdentifier: json['provided_identifier'] as String,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      lastUsedAt: DateTime.parse(json['last_used_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAccountConnectionToJson(
  _SnAccountConnection instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'provider': instance.provider,
  'provided_identifier': instance.providedIdentifier,
  'meta': instance.meta,
  'last_used_at': instance.lastUsedAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
