// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnEmbedLink _$SnEmbedLinkFromJson(Map<String, dynamic> json) => _SnEmbedLink(
  type: json['Type'] as String,
  url: json['Url'] as String,
  title: json['Title'] as String,
  description: json['Description'] as String?,
  imageUrl: json['ImageUrl'] as String?,
  faviconUrl: json['FaviconUrl'] as String,
  siteName: json['SiteName'] as String,
  contentType: json['ContentType'] as String?,
  author: json['Author'] as String?,
  publishedDate:
      json['PublishedDate'] == null
          ? null
          : DateTime.parse(json['PublishedDate'] as String),
);

Map<String, dynamic> _$SnEmbedLinkToJson(_SnEmbedLink instance) =>
    <String, dynamic>{
      'Type': instance.type,
      'Url': instance.url,
      'Title': instance.title,
      'Description': instance.description,
      'ImageUrl': instance.imageUrl,
      'FaviconUrl': instance.faviconUrl,
      'SiteName': instance.siteName,
      'ContentType': instance.contentType,
      'Author': instance.author,
      'PublishedDate': instance.publishedDate?.toIso8601String(),
    };

_SnScrappedLink _$SnScrappedLinkFromJson(Map<String, dynamic> json) =>
    _SnScrappedLink(
      type: json['type'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      faviconUrl: json['favicon_url'] as String,
      siteName: json['site_name'] as String,
      contentType: json['content_type'] as String?,
      author: json['author'] as String?,
      publishedDate:
          json['published_date'] == null
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
