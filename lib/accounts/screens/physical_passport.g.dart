// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physical_passport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPhysicalPassport _$SnPhysicalPassportFromJson(Map<String, dynamic> json) =>
    _SnPhysicalPassport(
      id: json['id'] as String,
      label: json['label'] as String?,
      isActive: json['is_active'] as bool,
      isLocked: json['is_locked'] as bool,
      isEncrypted: json['is_encrypted'] as bool,
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      uid: json['uid'] as String?,
    );

Map<String, dynamic> _$SnPhysicalPassportToJson(_SnPhysicalPassport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'is_active': instance.isActive,
      'is_locked': instance.isLocked,
      'is_encrypted': instance.isEncrypted,
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'uid': instance.uid,
    };

_SnScanResult _$SnScanResultFromJson(Map<String, dynamic> json) =>
    _SnScanResult(
      user: SnAccount.fromJson(json['user'] as Map<String, dynamic>),
      isFriend: json['is_friend'] as bool? ?? false,
      isClaimed: json['is_claimed'] as bool? ?? false,
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SnScanResultToJson(_SnScanResult instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'is_friend': instance.isFriend,
      'is_claimed': instance.isClaimed,
      'actions': instance.actions,
    };
