// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPost _$SnPostFromJson(Map<String, dynamic> json) => _SnPost(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  language: json['language'],
  editedAt: json['edited_at'],
  publishedAt: DateTime.parse(json['published_at'] as String),
  visibility: (json['visibility'] as num).toInt(),
  content: json['content'] as String,
  type: (json['type'] as num).toInt(),
  meta: json['meta'],
  viewsUnique: (json['views_unique'] as num).toInt(),
  viewsTotal: (json['views_total'] as num).toInt(),
  upvotes: (json['upvotes'] as num).toInt(),
  downvotes: (json['downvotes'] as num).toInt(),
  threadedPostId: json['threaded_post_id'],
  threadedPost: json['threaded_post'],
  repliedPostId: json['replied_post_id'],
  repliedPost: json['replied_post'],
  forwardedPostId: json['forwarded_post_id'],
  forwardedPost: json['forwarded_post'],
  attachments:
      (json['attachments'] as List<dynamic>)
          .map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
          .toList(),
  publisher: SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
  reactions: json['reactions'] as List<dynamic>,
  tags: json['tags'] as List<dynamic>,
  categories: json['categories'] as List<dynamic>,
  collections: json['collections'] as List<dynamic>,
  empty: json['empty'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'],
);

Map<String, dynamic> _$SnPostToJson(_SnPost instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'language': instance.language,
  'edited_at': instance.editedAt,
  'published_at': instance.publishedAt.toIso8601String(),
  'visibility': instance.visibility,
  'content': instance.content,
  'type': instance.type,
  'meta': instance.meta,
  'views_unique': instance.viewsUnique,
  'views_total': instance.viewsTotal,
  'upvotes': instance.upvotes,
  'downvotes': instance.downvotes,
  'threaded_post_id': instance.threadedPostId,
  'threaded_post': instance.threadedPost,
  'replied_post_id': instance.repliedPostId,
  'replied_post': instance.repliedPost,
  'forwarded_post_id': instance.forwardedPostId,
  'forwarded_post': instance.forwardedPost,
  'attachments': instance.attachments.map((e) => e.toJson()).toList(),
  'publisher': instance.publisher.toJson(),
  'reactions': instance.reactions,
  'tags': instance.tags,
  'categories': instance.categories,
  'collections': instance.collections,
  'empty': instance.empty,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt,
};

_SnPublisher _$SnPublisherFromJson(Map<String, dynamic> json) => _SnPublisher(
  id: (json['id'] as num).toInt(),
  publisherType: (json['publisher_type'] as num).toInt(),
  name: json['name'] as String,
  nick: json['nick'] as String,
  bio: json['bio'] as String,
  picture: SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background: SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  accountId: (json['account_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnPublisherToJson(_SnPublisher instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publisher_type': instance.publisherType,
      'name': instance.name,
      'nick': instance.nick,
      'bio': instance.bio,
      'picture': instance.picture.toJson(),
      'background': instance.background.toJson(),
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
