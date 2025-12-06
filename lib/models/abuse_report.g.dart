// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abuse_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAbuseReport _$SnAbuseReportFromJson(Map<String, dynamic> json) =>
    _SnAbuseReport(
      id: json['id'] as String,
      resourceIdentifier: json['resource_identifier'] as String,
      type: (json['type'] as num).toInt(),
      reason: json['reason'] as String,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      resolution: json['resolution'] as String?,
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAbuseReportToJson(_SnAbuseReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resource_identifier': instance.resourceIdentifier,
      'type': instance.type,
      'reason': instance.reason,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'resolution': instance.resolution,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
