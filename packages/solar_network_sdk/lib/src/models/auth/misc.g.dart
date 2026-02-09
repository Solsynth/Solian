// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misc.dart';

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
      countryCode: json['countryCode'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
    );

Map<String, dynamic> _$GeoIpLocationToJson(_GeoIpLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'countryCode': instance.countryCode,
      'country': instance.country,
      'city': instance.city,
    };

_SnAuthFactor _$SnAuthFactorFromJson(Map<String, dynamic> json) =>
    _SnAuthFactor(
      id: json['id'] as String,
      type: (json['type'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      expiredAt: json['expiredAt'] == null
          ? null
          : DateTime.parse(json['expiredAt'] as String),
      enabledAt: json['enabledAt'] == null
          ? null
          : DateTime.parse(json['enabledAt'] as String),
      trustworthy: (json['trustworthy'] as num).toInt(),
      createdResponse: json['createdResponse'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SnAuthFactorToJson(_SnAuthFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'expiredAt': instance.expiredAt?.toIso8601String(),
      'enabledAt': instance.enabledAt?.toIso8601String(),
      'trustworthy': instance.trustworthy,
      'createdResponse': instance.createdResponse,
    };

_SnAccountConnection _$SnAccountConnectionFromJson(Map<String, dynamic> json) =>
    _SnAccountConnection(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      provider: json['provider'] as String,
      providedIdentifier: json['providedIdentifier'] as String,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnAccountConnectionToJson(
  _SnAccountConnection instance,
) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'provider': instance.provider,
  'providedIdentifier': instance.providedIdentifier,
  'meta': instance.meta,
  'lastUsedAt': instance.lastUsedAt.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};
