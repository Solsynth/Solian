// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnScrappedLink _$SnScrappedLinkFromJson(Map<String, dynamic> json) =>
    _SnScrappedLink(
      type: json['type'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      faviconUrl: json['favicon_url'] as String?,
      siteName: json['site_name'] as String?,
      contentType: json['content_type'] as String?,
      author: json['author'] as String?,
      publishedDate: json['published_date'] == null
          ? null
          : DateTime.parse(json['published_date'] as String),
    );

Map<String, dynamic> _$SnScrappedLinkToJson(_SnScrappedLink instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
      'title': instance.title,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'favicon_url': instance.faviconUrl,
      'site_name': instance.siteName,
      'content_type': instance.contentType,
      'author': instance.author,
      'published_date': instance.publishedDate?.toIso8601String(),
    };
