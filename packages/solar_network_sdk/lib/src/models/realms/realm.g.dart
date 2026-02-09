// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnRealm _$SnRealmFromJson(Map<String, dynamic> json) => _SnRealm(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  verifiedAs: json['verifiedAs'] as String?,
  verifiedAt: json['verifiedAt'] == null
      ? null
      : DateTime.parse(json['verifiedAt'] as String),
  isCommunity: json['isCommunity'] as bool,
  isPublic: json['isPublic'] as bool,
  picture: json['picture'] == null
      ? null
      : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background: json['background'] == null
      ? null
      : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  accountId: json['accountId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$SnRealmToJson(_SnRealm instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'description': instance.description,
  'verifiedAs': instance.verifiedAs,
  'verifiedAt': instance.verifiedAt?.toIso8601String(),
  'isCommunity': instance.isCommunity,
  'isPublic': instance.isPublic,
  'picture': instance.picture,
  'background': instance.background,
  'accountId': instance.accountId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};

_SnRealmMember _$SnRealmMemberFromJson(Map<String, dynamic> json) =>
    _SnRealmMember(
      realmId: json['realmId'] as String,
      realm: json['realm'] == null
          ? null
          : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
      accountId: json['accountId'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      role: (json['role'] as num).toInt(),
      joinedAt: json['joinedAt'] == null
          ? null
          : DateTime.parse(json['joinedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      status: json['status'] == null
          ? null
          : SnAccountStatus.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnRealmMemberToJson(_SnRealmMember instance) =>
    <String, dynamic>{
      'realmId': instance.realmId,
      'realm': instance.realm,
      'accountId': instance.accountId,
      'account': instance.account,
      'role': instance.role,
      'joinedAt': instance.joinedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'status': instance.status,
    };
