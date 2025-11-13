// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnCloudFolder _$SnCloudFolderFromJson(Map<String, dynamic> json) =>
    _SnCloudFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      parentFolderId: json['parent_folder_id'] as String?,
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SnCloudFolderToJson(_SnCloudFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parent_folder_id': instance.parentFolderId,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
