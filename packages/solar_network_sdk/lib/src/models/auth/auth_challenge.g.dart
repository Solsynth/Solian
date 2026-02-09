// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAuthChallenge _$SnAuthChallengeFromJson(Map<String, dynamic> json) =>
    _SnAuthChallenge(
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

Map<String, dynamic> _$SnAuthChallengeToJson(_SnAuthChallenge instance) =>
    <String, dynamic>{
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
