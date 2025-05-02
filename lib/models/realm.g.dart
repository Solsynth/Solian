// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnRealm _$SnRealmFromJson(Map<String, dynamic> json) => _SnRealm(
  id: (json['id'] as num).toInt(),
  slug: json['slug'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  verifiedAs: json['verified_as'] as String?,
  verifiedAt:
      json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
  isCommunity: json['is_community'] as bool,
  isPublic: json['is_public'] as bool,
  picture:
      json['picture'] == null
          ? null
          : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background:
      json['background'] == null
          ? null
          : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  accountId: (json['account_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnRealmToJson(_SnRealm instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'description': instance.description,
  'verified_as': instance.verifiedAs,
  'verified_at': instance.verifiedAt?.toIso8601String(),
  'is_community': instance.isCommunity,
  'is_public': instance.isPublic,
  'picture': instance.picture?.toJson(),
  'background': instance.background?.toJson(),
  'account_id': instance.accountId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
