// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnActionLog _$SnActionLogFromJson(Map<String, dynamic> json) => _SnActionLog(
  id: json['id'] as String,
  action: json['action'] as String,
  meta: json['meta'] as Map<String, dynamic>,
  userAgent: json['user_agent'] as String,
  ipAddress: json['ip_address'] as String,
  location: json['location'] == null
      ? null
      : GeoIpLocation.fromJson(json['location'] as Map<String, dynamic>),
  accountId: json['account_id'] as String,
  sessionId: json['session_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnActionLogToJson(_SnActionLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'meta': instance.meta,
      'user_agent': instance.userAgent,
      'ip_address': instance.ipAddress,
      'location': instance.location?.toJson(),
      'account_id': instance.accountId,
      'session_id': instance.sessionId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
