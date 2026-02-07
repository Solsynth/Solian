// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SnAuthChallengeImpl _$$SnAuthChallengeImplFromJson(
  Map<String, dynamic> json,
) => _$SnAuthChallengeImpl(
  id: json['id'] as String,
  expiredAt: json['expiredAt'] == null
      ? null
      : DateTime.parse(json['expiredAt'] as String),
  stepRemain: (json['stepRemain'] as num).toInt(),
  stepTotal: (json['stepTotal'] as num).toInt(),
  failedAttempts: (json['failedAttempts'] as num).toInt(),
  blacklistFactors: (json['blacklistFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  audiences: json['audiences'] as List<dynamic>,
  scopes: json['scopes'] as List<dynamic>,
  ipAddress: json['ipAddress'] as String,
  userAgent: json['userAgent'] as String,
  nonce: json['nonce'] as String?,
  countryCode: json['countryCode'] as String?,
  country: json['country'] as String?,
  city: json['city'] as String?,
  accountId: json['accountId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$$SnAuthChallengeImplToJson(
  _$SnAuthChallengeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'expiredAt': instance.expiredAt?.toIso8601String(),
  'stepRemain': instance.stepRemain,
  'stepTotal': instance.stepTotal,
  'failedAttempts': instance.failedAttempts,
  'blacklistFactors': instance.blacklistFactors,
  'audiences': instance.audiences,
  'scopes': instance.scopes,
  'ipAddress': instance.ipAddress,
  'userAgent': instance.userAgent,
  'nonce': instance.nonce,
  'countryCode': instance.countryCode,
  'country': instance.country,
  'city': instance.city,
  'accountId': instance.accountId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};

_$SnAuthFactorImpl _$$SnAuthFactorImplFromJson(Map<String, dynamic> json) =>
    _$SnAuthFactorImpl(
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

Map<String, dynamic> _$$SnAuthFactorImplToJson(_$SnAuthFactorImpl instance) =>
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

_$SnAccountConnectionImpl _$$SnAccountConnectionImplFromJson(
  Map<String, dynamic> json,
) => _$SnAccountConnectionImpl(
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

Map<String, dynamic> _$$SnAccountConnectionImplToJson(
  _$SnAccountConnectionImpl instance,
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
