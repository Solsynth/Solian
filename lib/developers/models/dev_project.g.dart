// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnDevProject _$SnDevProjectFromJson(Map<String, dynamic> json) =>
    _SnDevProject(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      developer: SnDeveloper.fromJson(
        json['developer'] as Map<String, dynamic>,
      ),
      developerId: json['developer_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnDevProjectToJson(_SnDevProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'developer': instance.developer.toJson(),
      'developer_id': instance.developerId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
