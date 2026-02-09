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
  editedAt: json['edited_at'] == null
      ? null
      : DateTime.parse(json['edited_at'] as String),
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  visibility: (json['visibility'] as num?)?.toInt() ?? 0,
  content: json['content'] as String?,
  slug: json['slug'] as String?,
  type: (json['type'] as num?)?.toInt() ?? 0,
  meta: json['meta'] as Map<String, dynamic>?,
  embedView: json['embed_view'] == null
      ? null
      : SnPostEmbedView.fromJson(json['embed_view'] as Map<String, dynamic>),
  viewsUnique: (json['views_unique'] as num?)?.toInt() ?? 0,
  viewsTotal: (json['views_total'] as num?)?.toInt() ?? 0,
  upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
  downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
  repliesCount: (json['replies_count'] as num?)?.toInt() ?? 0,
  awardedScore: (json['awarded_score'] as num?)?.toInt() ?? 0,
  pinMode: (json['pin_mode'] as num?)?.toInt(),
  threadedPostId: json['threaded_post_id'] as String?,
  threadedPost: json['threaded_post'] == null
      ? null
      : SnPost.fromJson(json['threaded_post'] as Map<String, dynamic>),
  repliedPostId: json['replied_post_id'] as String?,
  repliedPost: json['replied_post'] == null
      ? null
      : SnPost.fromJson(json['replied_post'] as Map<String, dynamic>),
  forwardedPostId: json['forwarded_post_id'] as String?,
  forwardedPost: json['forwarded_post'] == null
      ? null
      : SnPost.fromJson(json['forwarded_post'] as Map<String, dynamic>),
  realmId: json['realm_id'] as String?,
  realm: json['realm'] == null
      ? null
      : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
  publisherId: json['publisher_id'] as String?,
  publisher: json['publisher'] == null
      ? null
      : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
  actorid: json['actorid'] as String?,
  actor: json['actor'] == null
      ? null
      : SnActivityPubActor.fromJson(json['actor'] as Map<String, dynamic>),
  fediverseUri: json['fediverse_uri'] as String?,
  fediverseType: (json['fediverse_type'] as num?)?.toInt(),
  contentType: (json['content_type'] as num?)?.toInt() ?? 0,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  reactionsCount:
      (json['reactions_count'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  reactionsMade:
      (json['reactions_made'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  reactions: json['reactions'] as List<dynamic>? ?? const [],
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => SnPostTag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => SnPostCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  collections: json['collections'] as List<dynamic>? ?? const [],
  featuredRecords:
      (json['featured_records'] as List<dynamic>?)
          ?.map((e) => SnPostFeaturedRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  repliedGone: json['replied_gone'] as bool? ?? false,
  forwardedGone: json['forwarded_gone'] as bool? ?? false,
  isTruncated: json['is_truncated'] as bool? ?? false,
);

Map<String, dynamic> _$SnPostToJson(_SnPost instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'language': instance.language,
  'edited_at': instance.editedAt?.toIso8601String(),
  'published_at': instance.publishedAt?.toIso8601String(),
  'visibility': instance.visibility,
  'content': instance.content,
  'slug': instance.slug,
  'type': instance.type,
  'meta': instance.meta,
  'embed_view': instance.embedView?.toJson(),
  'views_unique': instance.viewsUnique,
  'views_total': instance.viewsTotal,
  'upvotes': instance.upvotes,
  'downvotes': instance.downvotes,
  'replies_count': instance.repliesCount,
  'awarded_score': instance.awardedScore,
  'pin_mode': instance.pinMode,
  'threaded_post_id': instance.threadedPostId,
  'threaded_post': instance.threadedPost?.toJson(),
  'replied_post_id': instance.repliedPostId,
  'replied_post': instance.repliedPost?.toJson(),
  'forwarded_post_id': instance.forwardedPostId,
  'forwarded_post': instance.forwardedPost?.toJson(),
  'realm_id': instance.realmId,
  'realm': instance.realm?.toJson(),
  'publisher_id': instance.publisherId,
  'publisher': instance.publisher?.toJson(),
  'actorid': instance.actorid,
  'actor': instance.actor?.toJson(),
  'fediverse_uri': instance.fediverseUri,
  'fediverse_type': instance.fediverseType,
  'content_type': instance.contentType,
  'attachments': instance.attachments.map((e) => e.toJson()).toList(),
  'reactions_count': instance.reactionsCount,
  'reactions_made': instance.reactionsMade,
  'reactions': instance.reactions,
  'tags': instance.tags.map((e) => e.toJson()).toList(),
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'collections': instance.collections,
  'featured_records': instance.featuredRecords.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'replied_gone': instance.repliedGone,
  'forwarded_gone': instance.forwardedGone,
  'is_truncated': instance.isTruncated,
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

_SnPublisherSubscription _$SnPublisherSubscriptionFromJson(
  Map<String, dynamic> json,
) => _SnPublisherSubscription(
  accountId: json['account_id'] as String,
  publisherId: json['publisher_id'] as String,
  publisher: SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SnPublisherSubscriptionToJson(
  _SnPublisherSubscription instance,
) => <String, dynamic>{
  'account_id': instance.accountId,
  'publisher_id': instance.publisherId,
  'publisher': instance.publisher.toJson(),
};

_SnPostEmbedView _$SnPostEmbedViewFromJson(Map<String, dynamic> json) =>
    _SnPostEmbedView(
      uri: json['uri'] as String,
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble(),
      renderer:
          $enumDecodeNullable(
            _$PostEmbedViewRendererEnumMap,
            json['renderer'],
          ) ??
          PostEmbedViewRenderer.webView,
    );

Map<String, dynamic> _$SnPostEmbedViewToJson(_SnPostEmbedView instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'aspect_ratio': instance.aspectRatio,
      'renderer': _$PostEmbedViewRendererEnumMap[instance.renderer]!,
    };

const _$PostEmbedViewRendererEnumMap = {PostEmbedViewRenderer.webView: 0};

_SnPostAward _$SnPostAwardFromJson(Map<String, dynamic> json) => _SnPostAward(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  attitude: (json['attitude'] as num).toInt(),
  message: json['message'] as String?,
  postId: json['post_id'] as String,
  accountId: json['account_id'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnPostAwardToJson(_SnPostAward instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'attitude': instance.attitude,
      'message': instance.message,
      'post_id': instance.postId,
      'account_id': instance.accountId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnPostReaction _$SnPostReactionFromJson(Map<String, dynamic> json) =>
    _SnPostReaction(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      attitude: (json['attitude'] as num).toInt(),
      postId: json['post_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      actorId: json['actor_id'] as String?,
      actor: json['actor'] == null
          ? null
          : SnActivityPubActor.fromJson(json['actor'] as Map<String, dynamic>),
      accountId: json['account_id'] as String?,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnPostReactionToJson(_SnPostReaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'attitude': instance.attitude,
      'post_id': instance.postId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'actor_id': instance.actorId,
      'actor': instance.actor?.toJson(),
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnPostFeaturedRecord _$SnPostFeaturedRecordFromJson(
  Map<String, dynamic> json,
) => _SnPostFeaturedRecord(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  featuredAt: json['featured_at'] == null
      ? null
      : DateTime.parse(json['featured_at'] as String),
  socialCredits: (json['social_credits'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnPostFeaturedRecordToJson(
  _SnPostFeaturedRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'post_id': instance.postId,
  'featured_at': instance.featuredAt?.toIso8601String(),
  'social_credits': instance.socialCredits,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
