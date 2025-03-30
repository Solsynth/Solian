// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPost _$SnPostFromJson(Map<String, dynamic> json) => _SnPost(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      type: json['type'] as String,
      body: json['body'] as Map<String, dynamic>,
      language: json['language'] as String,
      alias: json['alias'] as String?,
      aliasPrefix: json['alias_prefix'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => SnPostTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => SnPostCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => SnPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      replyId: (json['reply_id'] as num?)?.toInt(),
      repostId: (json['repost_id'] as num?)?.toInt(),
      realmId: (json['realm_id'] as num?)?.toInt(),
      realm: json['realm'] == null
          ? null
          : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
      replyTo: json['reply_to'] == null
          ? null
          : SnPost.fromJson(json['reply_to'] as Map<String, dynamic>),
      repostTo: json['repost_to'] == null
          ? null
          : SnPost.fromJson(json['repost_to'] as Map<String, dynamic>),
      visibleUsersList: (json['visible_users_list'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      invisibleUsersList: (json['invisible_users_list'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      visibility: (json['visibility'] as num).toInt(),
      editedAt: json['edited_at'] == null
          ? null
          : DateTime.parse(json['edited_at'] as String),
      pinnedAt: json['pinned_at'] == null
          ? null
          : DateTime.parse(json['pinned_at'] as String),
      lockedAt: json['locked_at'] == null
          ? null
          : DateTime.parse(json['locked_at'] as String),
      isDraft: json['is_draft'] as bool,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      publishedUntil: json['published_until'] == null
          ? null
          : DateTime.parse(json['published_until'] as String),
      totalUpvote: (json['total_upvote'] as num).toInt(),
      totalDownvote: (json['total_downvote'] as num).toInt(),
      totalViews: (json['total_views'] as num?)?.toInt() ?? 0,
      totalAggregatedViews:
          (json['total_aggregated_views'] as num?)?.toInt() ?? 0,
      publisherId: (json['publisher_id'] as num).toInt(),
      pollId: (json['poll_id'] as num?)?.toInt(),
      poll: json['poll'] == null
          ? null
          : SnPoll.fromJson(json['poll'] as Map<String, dynamic>),
      publisher:
          SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
      metric: SnMetric.fromJson(json['metric'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnPostToJson(_SnPost instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'type': instance.type,
      'body': instance.body,
      'language': instance.language,
      'alias': instance.alias,
      'alias_prefix': instance.aliasPrefix,
      'tags': instance.tags.map((e) => e.toJson()).toList(),
      'categories': instance.categories.map((e) => e.toJson()).toList(),
      'replies': instance.replies?.map((e) => e.toJson()).toList(),
      'reply_id': instance.replyId,
      'repost_id': instance.repostId,
      'realm_id': instance.realmId,
      'realm': instance.realm?.toJson(),
      'reply_to': instance.replyTo?.toJson(),
      'repost_to': instance.repostTo?.toJson(),
      'visible_users_list': instance.visibleUsersList,
      'invisible_users_list': instance.invisibleUsersList,
      'visibility': instance.visibility,
      'edited_at': instance.editedAt?.toIso8601String(),
      'pinned_at': instance.pinnedAt?.toIso8601String(),
      'locked_at': instance.lockedAt?.toIso8601String(),
      'is_draft': instance.isDraft,
      'published_at': instance.publishedAt?.toIso8601String(),
      'published_until': instance.publishedUntil?.toIso8601String(),
      'total_upvote': instance.totalUpvote,
      'total_downvote': instance.totalDownvote,
      'total_views': instance.totalViews,
      'total_aggregated_views': instance.totalAggregatedViews,
      'publisher_id': instance.publisherId,
      'poll_id': instance.pollId,
      'poll': instance.poll?.toJson(),
      'publisher': instance.publisher.toJson(),
      'metric': instance.metric.toJson(),
    };

_SnPostTag _$SnPostTagFromJson(Map<String, dynamic> json) => _SnPostTag(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'],
      alias: json['alias'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      posts: json['posts'],
    );

Map<String, dynamic> _$SnPostTagToJson(_SnPostTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt,
      'alias': instance.alias,
      'name': instance.name,
      'description': instance.description,
      'posts': instance.posts,
    };

_SnPostCategory _$SnPostCategoryFromJson(Map<String, dynamic> json) =>
    _SnPostCategory(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'],
      alias: json['alias'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      posts: json['posts'],
    );

Map<String, dynamic> _$SnPostCategoryToJson(_SnPostCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt,
      'alias': instance.alias,
      'name': instance.name,
      'description': instance.description,
      'posts': instance.posts,
    };

_SnPostPreload _$SnPostPreloadFromJson(Map<String, dynamic> json) =>
    _SnPostPreload(
      thumbnail: json['thumbnail'] == null
          ? null
          : SnAttachment.fromJson(json['thumbnail'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : SnAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      video: json['video'] == null
          ? null
          : SnAttachment.fromJson(json['video'] as Map<String, dynamic>),
      poll: json['poll'] == null
          ? null
          : SnPoll.fromJson(json['poll'] as Map<String, dynamic>),
      realm: json['realm'] == null
          ? null
          : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnPostPreloadToJson(_SnPostPreload instance) =>
    <String, dynamic>{
      'thumbnail': instance.thumbnail?.toJson(),
      'attachments': instance.attachments?.map((e) => e?.toJson()).toList(),
      'video': instance.video?.toJson(),
      'poll': instance.poll?.toJson(),
      'realm': instance.realm?.toJson(),
    };

_SnBody _$SnBodyFromJson(Map<String, dynamic> json) => _SnBody(
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      content: json['content'] as String,
      location: json['location'],
      thumbnail: json['thumbnail'],
      title: json['title'],
    );

Map<String, dynamic> _$SnBodyToJson(_SnBody instance) => <String, dynamic>{
      'attachments': instance.attachments,
      'content': instance.content,
      'location': instance.location,
      'thumbnail': instance.thumbnail,
      'title': instance.title,
    };

_SnMetric _$SnMetricFromJson(Map<String, dynamic> json) => _SnMetric(
      replyCount: (json['reply_count'] as num).toInt(),
      reactionCount: (json['reaction_count'] as num).toInt(),
      reactionList: (json['reaction_list'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$SnMetricToJson(_SnMetric instance) => <String, dynamic>{
      'reply_count': instance.replyCount,
      'reaction_count': instance.reactionCount,
      'reaction_list': instance.reactionList,
    };

_SnPublisher _$SnPublisherFromJson(Map<String, dynamic> json) => _SnPublisher(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      type: (json['type'] as num).toInt(),
      name: json['name'] as String,
      nick: json['nick'] as String,
      description: json['description'] as String,
      avatar: json['avatar'] as String,
      banner: json['banner'] as String,
      totalUpvote: (json['total_upvote'] as num).toInt(),
      totalDownvote: (json['total_downvote'] as num).toInt(),
      realmId: (json['realm_id'] as num?)?.toInt(),
      accountId: (json['account_id'] as num).toInt(),
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnPublisherToJson(_SnPublisher instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'type': instance.type,
      'name': instance.name,
      'nick': instance.nick,
      'description': instance.description,
      'avatar': instance.avatar,
      'banner': instance.banner,
      'total_upvote': instance.totalUpvote,
      'total_downvote': instance.totalDownvote,
      'realm_id': instance.realmId,
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
    };

_SnSubscription _$SnSubscriptionFromJson(Map<String, dynamic> json) =>
    _SnSubscription(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      followerId: (json['follower_id'] as num).toInt(),
      accountId: (json['account_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnSubscriptionToJson(_SnSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'follower_id': instance.followerId,
      'account_id': instance.accountId,
    };

_SnFeedEntry _$SnFeedEntryFromJson(Map<String, dynamic> json) => _SnFeedEntry(
      type: json['type'] as String,
      data: json['data'],
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SnFeedEntryToJson(_SnFeedEntry instance) =>
    <String, dynamic>{
      'type': instance.type,
      'data': instance.data,
      'created_at': instance.createdAt.toIso8601String(),
    };

_SnFediversePost _$SnFediversePostFromJson(Map<String, dynamic> json) =>
    _SnFediversePost(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      identifier: json['identifier'] as String,
      origin: json['origin'] as String,
      content: json['content'] as String,
      language: json['language'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      user: SnFediverseUser.fromJson(json['user'] as Map<String, dynamic>),
      userId: (json['user_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnFediversePostToJson(_SnFediversePost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'identifier': instance.identifier,
      'origin': instance.origin,
      'content': instance.content,
      'language': instance.language,
      'images': instance.images,
      'user': instance.user.toJson(),
      'user_id': instance.userId,
    };

_SnFediverseUser _$SnFediverseUserFromJson(Map<String, dynamic> json) =>
    _SnFediverseUser(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      identifier: json['identifier'] as String,
      origin: json['origin'] as String,
      avatar: json['avatar'] as String,
      name: json['name'] as String,
      nick: json['nick'] as String,
    );

Map<String, dynamic> _$SnFediverseUserToJson(_SnFediverseUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'identifier': instance.identifier,
      'origin': instance.origin,
      'avatar': instance.avatar,
      'name': instance.name,
      'nick': instance.nick,
    };
