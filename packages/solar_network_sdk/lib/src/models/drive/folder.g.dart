// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnCloudFolder _$SnCloudFolderFromJson(Map<String, dynamic> json) =>
    _SnCloudFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      parentFolderId: json['parentFolderId'] as String?,
      accountId: json['accountId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SnCloudFolderToJson(_SnCloudFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentFolderId': instance.parentFolderId,
      'accountId': instance.accountId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
