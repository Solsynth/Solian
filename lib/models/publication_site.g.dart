// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publication_site.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPublicationSite _$SnPublicationSiteFromJson(Map<String, dynamic> json) =>
    _SnPublicationSite(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      mode: (json['mode'] as num?)?.toInt(),
      publisherId: json['publisher_id'] as String,
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pages: (json['pages'] as List<dynamic>)
          .map((e) => SnPublicationPage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SnPublicationSiteToJson(_SnPublicationSite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'mode': instance.mode,
      'publisher_id': instance.publisherId,
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'pages': instance.pages.map((e) => e.toJson()).toList(),
    };

_SnPublicationPage _$SnPublicationPageFromJson(Map<String, dynamic> json) =>
    _SnPublicationPage(
      id: json['id'] as String,
      preset: json['preset'] as String?,
      path: json['path'] as String?,
      config: json['config'] as Map<String, dynamic>?,
      siteId: json['site_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SnPublicationPageToJson(_SnPublicationPage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'preset': instance.preset,
      'path': instance.path,
      'config': instance.config,
      'site_id': instance.siteId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
