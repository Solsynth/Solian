// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_auth_app_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WebAuthAppInfo _$WebAuthAppInfoFromJson(Map<String, dynamic> json) =>
    _WebAuthAppInfo(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: (json['status'] as num).toInt(),
      picture: json['picture'] == null
          ? null
          : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
      background: json['background'] == null
          ? null
          : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
      verification: json['verification'] == null
          ? null
          : SnVerificationMark.fromJson(
              json['verification'] as Map<String, dynamic>,
            ),
      links: Map<String, String?>.from(json['links'] as Map),
      projectId: json['project_id'] as String,
      project: SnDevProject.fromJson(json['project'] as Map<String, dynamic>),
      resourceIdentifier: json['resource_identifier'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$WebAuthAppInfoToJson(_WebAuthAppInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'verification': instance.verification?.toJson(),
      'links': instance.links,
      'project_id': instance.projectId,
      'project': instance.project.toJson(),
      'resource_identifier': instance.resourceIdentifier,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
