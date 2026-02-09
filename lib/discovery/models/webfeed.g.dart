// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webfeed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnWebFeedConfig _$SnWebFeedConfigFromJson(Map<String, dynamic> json) =>
    _SnWebFeedConfig(scrapPage: json['scrap_page'] as bool? ?? false);

Map<String, dynamic> _$SnWebFeedConfigToJson(_SnWebFeedConfig instance) =>
    <String, dynamic>{'scrap_page': instance.scrapPage};

_SnWebFeed _$SnWebFeedFromJson(Map<String, dynamic> json) => _SnWebFeed(
  id: json['id'] as String,
  url: json['url'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  preview: json['preview'] == null
      ? null
      : SnScrappedLink.fromJson(json['preview'] as Map<String, dynamic>),
  config: json['config'] == null
      ? const SnWebFeedConfig()
      : SnWebFeedConfig.fromJson(json['config'] as Map<String, dynamic>),
  publisherId: json['publisher_id'] as String,
  articles:
      (json['articles'] as List<dynamic>?)
          ?.map((e) => SnWebArticle.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnWebFeedToJson(_SnWebFeed instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'description': instance.description,
      'preview': instance.preview?.toJson(),
      'config': instance.config.toJson(),
      'publisher_id': instance.publisherId,
      'articles': instance.articles.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnWebArticle _$SnWebArticleFromJson(Map<String, dynamic> json) =>
    _SnWebArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      author: json['author'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
      preview: json['preview'] == null
          ? null
          : SnScrappedLink.fromJson(json['preview'] as Map<String, dynamic>),
      feed: json['feed'] == null
          ? null
          : SnWebFeed.fromJson(json['feed'] as Map<String, dynamic>),
      content: json['content'] as String?,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      feedId: json['feed_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnWebArticleToJson(_SnWebArticle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'author': instance.author,
      'meta': instance.meta,
      'preview': instance.preview?.toJson(),
      'feed': instance.feed?.toJson(),
      'content': instance.content,
      'published_at': instance.publishedAt?.toIso8601String(),
      'feed_id': instance.feedId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
