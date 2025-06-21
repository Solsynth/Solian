// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPost _$SnPostFromJson(Map<String, dynamic> json) => _SnPost(
  id: json['id'] as String,
  title: json['title'] as String?,
  description: json['description'] as String?,
  language: json['language'] as String?,
  editedAt:
      json['edited_at'] == null
          ? null
          : DateTime.parse(json['edited_at'] as String),
  publishedAt: DateTime.parse(json['published_at'] as String),
  visibility: (json['visibility'] as num).toInt(),
  content: json['content'] as String?,
  type: (json['type'] as num).toInt(),
  meta: json['meta'] as Map<String, dynamic>?,
  viewsUnique: (json['views_unique'] as num).toInt(),
  viewsTotal: (json['views_total'] as num).toInt(),
  upvotes: (json['upvotes'] as num).toInt(),
  downvotes: (json['downvotes'] as num).toInt(),
  repliesCount: (json['replies_count'] as num).toInt(),
  threadedPostId: json['threaded_post_id'] as String?,
  threadedPost:
      json['threaded_post'] == null
          ? null
          : SnPost.fromJson(json['threaded_post'] as Map<String, dynamic>),
  repliedPostId: json['replied_post_id'] as String?,
  repliedPost:
      json['replied_post'] == null
          ? null
          : SnPost.fromJson(json['replied_post'] as Map<String, dynamic>),
  forwardedPostId: json['forwarded_post_id'] as String?,
  forwardedPost:
      json['forwarded_post'] == null
          ? null
          : SnPost.fromJson(json['forwarded_post'] as Map<String, dynamic>),
  attachments:
      (json['attachments'] as List<dynamic>)
          .map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
          .toList(),
  publisher: SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
  reactionsCount:
      (json['reactions_count'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  reactions: json['reactions'] as List<dynamic>,
  tags: json['tags'] as List<dynamic>,
  categories: json['categories'] as List<dynamic>,
  collections: json['collections'] as List<dynamic>,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
  isTruncated: json['is_truncated'] as bool? ?? false,
);

Map<String, dynamic> _$SnPostToJson(_SnPost instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'language': instance.language,
  'edited_at': instance.editedAt?.toIso8601String(),
  'published_at': instance.publishedAt.toIso8601String(),
  'visibility': instance.visibility,
  'content': instance.content,
  'type': instance.type,
  'meta': instance.meta,
  'views_unique': instance.viewsUnique,
  'views_total': instance.viewsTotal,
  'upvotes': instance.upvotes,
  'downvotes': instance.downvotes,
  'replies_count': instance.repliesCount,
  'threaded_post_id': instance.threadedPostId,
  'threaded_post': instance.threadedPost?.toJson(),
  'replied_post_id': instance.repliedPostId,
  'replied_post': instance.repliedPost?.toJson(),
  'forwarded_post_id': instance.forwardedPostId,
  'forwarded_post': instance.forwardedPost?.toJson(),
  'attachments': instance.attachments.map((e) => e.toJson()).toList(),
  'publisher': instance.publisher.toJson(),
  'reactions_count': instance.reactionsCount,
  'reactions': instance.reactions,
  'tags': instance.tags,
  'categories': instance.categories,
  'collections': instance.collections,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'is_truncated': instance.isTruncated,
};

_SnPublisher _$SnPublisherFromJson(Map<String, dynamic> json) => _SnPublisher(
  id: json['id'] as String,
  type: (json['type'] as num).toInt(),
  name: json['name'] as String,
  nick: json['nick'] as String,
  bio: json['bio'] as String? ?? '',
  picture:
      json['picture'] == null
          ? null
          : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background:
      json['background'] == null
          ? null
          : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  account:
      json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  accountId: json['account_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
  realmId: json['realm_id'] as String?,
  verification:
      json['verification'] == null
          ? null
          : SnVerificationMark.fromJson(
            json['verification'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$SnPublisherToJson(_SnPublisher instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'nick': instance.nick,
      'bio': instance.bio,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'account': instance.account?.toJson(),
      'account_id': instance.accountId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'realm_id': instance.realmId,
      'verification': instance.verification?.toJson(),
    };

_SnPublisherStats _$SnPublisherStatsFromJson(Map<String, dynamic> json) =>
    _SnPublisherStats(
      postsCreated: (json['posts_created'] as num).toInt(),
      stickerPacksCreated: (json['sticker_packs_created'] as num).toInt(),
      stickersCreated: (json['stickers_created'] as num).toInt(),
      upvoteReceived: (json['upvote_received'] as num).toInt(),
      downvoteReceived: (json['downvote_received'] as num).toInt(),
    );

Map<String, dynamic> _$SnPublisherStatsToJson(_SnPublisherStats instance) =>
    <String, dynamic>{
      'posts_created': instance.postsCreated,
      'sticker_packs_created': instance.stickerPacksCreated,
      'stickers_created': instance.stickersCreated,
      'upvote_received': instance.upvoteReceived,
      'downvote_received': instance.downvoteReceived,
    };

_SnSubscriptionStatus _$SnSubscriptionStatusFromJson(
  Map<String, dynamic> json,
) => _SnSubscriptionStatus(
  isSubscribed: json['is_subscribed'] as bool,
  publisherId: json['publisher_id'] as String,
  publisherName: json['publisher_name'] as String,
);

Map<String, dynamic> _$SnSubscriptionStatusToJson(
  _SnSubscriptionStatus instance,
) => <String, dynamic>{
  'is_subscribed': instance.isSubscribed,
  'publisher_id': instance.publisherId,
  'publisher_name': instance.publisherName,
};
