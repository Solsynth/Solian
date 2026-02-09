// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abuse_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAbuseReport _$SnAbuseReportFromJson(Map<String, dynamic> json) =>
    _SnAbuseReport(
      id: json['id'] as String,
      resourceIdentifier: json['resourceIdentifier'] as String,
      type: (json['type'] as num).toInt(),
      reason: json['reason'] as String,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolution: json['resolution'] as String?,
      accountId: json['accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$SnAbuseReportToJson(_SnAbuseReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resourceIdentifier': instance.resourceIdentifier,
      'type': instance.type,
      'reason': instance.reason,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolution': instance.resolution,
      'accountId': instance.accountId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
