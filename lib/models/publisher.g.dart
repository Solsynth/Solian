// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPublisher _$SnPublisherFromJson(Map<String, dynamic> json) => _SnPublisher(
  id: json['id'] as String? ?? '',
  type: (json['type'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  nick: json['nick'] as String? ?? '',
  bio: json['bio'] as String? ?? '',
  picture: json['picture'] == null
      ? null
      : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background: json['background'] == null
      ? null
      : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  accountId: json['account_id'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  realmId: json['realm_id'] as String?,
  verification: json['verification'] == null
      ? null
      : SnVerificationMark.fromJson(
          json['verification'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SnPublisherToJson(_SnPublisher instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'nick': instance.nick,
      'bio': instance.bio,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'account': instance.account?.toJson(),
      'account_id': instance.accountId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'realm_id': instance.realmId,
      'verification': instance.verification?.toJson(),
    };

_SnPublisherMember _$SnPublisherMemberFromJson(Map<String, dynamic> json) =>
    _SnPublisherMember(
      publisherId: json['publisher_id'] as String,
      publisher: json['publisher'] == null
          ? null
          : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      role: (json['role'] as num).toInt(),
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnPublisherMemberToJson(_SnPublisherMember instance) =>
    <String, dynamic>{
      'publisher_id': instance.publisherId,
      'publisher': instance.publisher?.toJson(),
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'role': instance.role,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
