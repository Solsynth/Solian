// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_permission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnFilePermissionStatus _$SnFilePermissionStatusFromJson(
  Map<String, dynamic> json,
) => _SnFilePermissionStatus(
  readable: json['readable'] as bool,
  writable: json['writable'] as bool,
  manageable: json['manageable'] as bool,
  visibility: json['visibility'] as String,
  inheritedFrom: json['inherited_from'] as String?,
);

Map<String, dynamic> _$SnFilePermissionStatusToJson(
  _SnFilePermissionStatus instance,
) => <String, dynamic>{
  'readable': instance.readable,
  'writable': instance.writable,
  'manageable': instance.manageable,
  'visibility': instance.visibility,
  'inherited_from': instance.inheritedFrom,
};

_SnFilePermission _$SnFilePermissionFromJson(Map<String, dynamic> json) =>
    _SnFilePermission(
      id: json['id'] as String?,
      fileId: json['file_id'] as String,
      subjectType: json['subject_type'] as String,
      subjectId: json['subject_id'] as String,
      permission: json['permission'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnFilePermissionToJson(_SnFilePermission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'file_id': instance.fileId,
      'subject_type': instance.subjectType,
      'subject_id': instance.subjectId,
      'permission': instance.permission,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
