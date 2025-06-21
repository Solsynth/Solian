// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnEmbedLink _$SnEmbedLinkFromJson(Map<String, dynamic> json) => _SnEmbedLink(
  type: json['Type'] as String,
  url: json['Url'] as String,
  title: json['Title'] as String,
  description: json['Description'] as String,
  imageUrl: json['ImageUrl'] as String,
  faviconUrl: json['FaviconUrl'] as String,
  siteName: json['SiteName'] as String,
  contentType: json['ContentType'] as String,
  author: json['Author'],
  publishedDate: json['PublishedDate'],
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
      'PublishedDate': instance.publishedDate,
    };
