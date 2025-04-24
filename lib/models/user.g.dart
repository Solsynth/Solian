// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAccount _$SnAccountFromJson(Map<String, dynamic> json) => _SnAccount(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  nick: json['nick'] as String,
  language: json['language'] as String,
  isSuperuser: json['is_superuser'] as bool,
  profile: SnAccountProfile.fromJson(json['profile'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnAccountToJson(_SnAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nick': instance.nick,
      'language': instance.language,
      'is_superuser': instance.isSuperuser,
      'profile': instance.profile.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnAccountProfile _$SnAccountProfileFromJson(Map<String, dynamic> json) =>
    _SnAccountProfile(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      bio: json['bio'] as String?,
      picture:
          json['picture'] == null
              ? null
              : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
      background:
          json['background'] == null
              ? null
              : SnCloudFile.fromJson(
                json['background'] as Map<String, dynamic>,
              ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnAccountProfileToJson(_SnAccountProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'middle_name': instance.middleName,
      'last_name': instance.lastName,
      'bio': instance.bio,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
