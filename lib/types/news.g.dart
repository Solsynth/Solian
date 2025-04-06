// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnSubscriptionFeed _$SnSubscriptionFeedFromJson(Map<String, dynamic> json) =>
    _SnSubscriptionFeed(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      url: json['url'] as String,
      isEnabled: json['is_enabled'] as bool,
      isFullContent: json['is_full_content'] as bool,
      pullInterval: (json['pull_interval'] as num).toInt(),
      adapter: json['adapter'] as String,
      accountId: (json['account_id'] as num?)?.toInt(),
      lastFetchedAt: json['last_fetched_at'] == null
          ? null
          : DateTime.parse(json['last_fetched_at'] as String),
    );

Map<String, dynamic> _$SnSubscriptionFeedToJson(_SnSubscriptionFeed instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'url': instance.url,
      'is_enabled': instance.isEnabled,
      'is_full_content': instance.isFullContent,
      'pull_interval': instance.pullInterval,
      'adapter': instance.adapter,
      'account_id': instance.accountId,
      'last_fetched_at': instance.lastFetchedAt?.toIso8601String(),
    };

_SnSubscriptionItem _$SnSubscriptionItemFromJson(Map<String, dynamic> json) =>
    _SnSubscriptionItem(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      thumbnail: json['thumbnail'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      url: json['url'] as String,
      hash: json['hash'] as String,
      feedId: (json['feed_id'] as num).toInt(),
      feed: SnSubscriptionFeed.fromJson(json['feed'] as Map<String, dynamic>),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
    );

Map<String, dynamic> _$SnSubscriptionItemToJson(_SnSubscriptionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'thumbnail': instance.thumbnail,
      'title': instance.title,
      'description': instance.description,
      'content': instance.content,
      'url': instance.url,
      'hash': instance.hash,
      'feed_id': instance.feedId,
      'feed': instance.feed.toJson(),
      'published_at': instance.publishedAt?.toIso8601String(),
    };
