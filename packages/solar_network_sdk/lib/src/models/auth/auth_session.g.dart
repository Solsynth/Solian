// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
