// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAuthSession _$SnAuthSessionFromJson(Map<String, dynamic> json) =>
    _SnAuthSession(
      id: json['id'] as String,
      label: json['label'] as String?,
      lastGrantedAt: DateTime.parse(json['lastGrantedAt'] as String),
      expiredAt: json['expiredAt'] == null
          ? null
          : DateTime.parse(json['expiredAt'] as String),
      audiences: json['audiences'] as List<dynamic>,
      scopes: json['scopes'] as List<dynamic>,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      location: json['location'] == null
          ? null
          : GeoIpLocation.fromJson(json['location'] as Map<String, dynamic>),
      type: (json['type'] as num).toInt(),
      accountId: json['accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnAuthSessionToJson(_SnAuthSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'lastGrantedAt': instance.lastGrantedAt.toIso8601String(),
      'expiredAt': instance.expiredAt?.toIso8601String(),
      'audiences': instance.audiences,
      'scopes': instance.scopes,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'location': instance.location,
      'type': instance.type,
      'accountId': instance.accountId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
