// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'punishment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAccountPunishment _$SnAccountPunishmentFromJson(Map<String, dynamic> json) =>
    _SnAccountPunishment(
      id: json['id'] as String,
      reason: json['reason'] as String,
      expiredAt: json['expired_at'] == null
          ? null
          : DateTime.parse(json['expired_at'] as String),
      type: const PunishmentTypeConverter().fromJson(
        (json['type'] as num).toInt(),
      ),
      blockedPermissions: (json['blocked_permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      creatorId: json['creator_id'] as String?,
      creator: json['creator'] == null
          ? null
          : SnAccount.fromJson(json['creator'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAccountPunishmentToJson(
  _SnAccountPunishment instance,
) => <String, dynamic>{
  'id': instance.id,
  'reason': instance.reason,
  'expired_at': instance.expiredAt?.toIso8601String(),
  'type': const PunishmentTypeConverter().toJson(instance.type),
  'blocked_permissions': instance.blockedPermissions,
  'account_id': instance.accountId,
  'account': instance.account?.toJson(),
  'creator_id': instance.creatorId,
  'creator': instance.creator?.toJson(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
