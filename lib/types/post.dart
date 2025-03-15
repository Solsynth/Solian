import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/types/poll.dart';
import 'package:surface/types/realm.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
abstract class SnPost with _$SnPost {
  const SnPost._();

  const factory SnPost({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String type,
    required Map<String, dynamic> body,
    required String language,
    required String? alias,
    required String? aliasPrefix,
    @Default([]) List<SnPostTag> tags,
    @Default([]) List<SnPostCategory> categories,
    required List<SnPost>? replies,
    required int? replyId,
    required int? repostId,
    required int? realmId,
    required SnPost? replyTo,
    required SnPost? repostTo,
    required List<int>? visibleUsersList,
    required List<int>? invisibleUsersList,
    required int visibility,
    required DateTime? editedAt,
    required DateTime? pinnedAt,
    required DateTime? lockedAt,
    required bool isDraft,
    required DateTime? publishedAt,
    required DateTime? publishedUntil,
    required int totalUpvote,
    required int totalDownvote,
    @Default(0) int totalViews,
    @Default(0) int totalAggregatedViews,
    required int publisherId,
    required int? pollId,
    required SnPublisher publisher,
    required SnMetric metric,
    SnPostPreload? preload,
  }) = _SnPost;

  factory SnPost.fromJson(Map<String, Object?> json) => _$SnPostFromJson(json);

  String get typePlural => switch (type) {
        'story' => 'stories',
        _ => '${type}s',
      };
}

@freezed
abstract class SnPostTag with _$SnPostTag {
  const factory SnPostTag({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required dynamic deletedAt,
    required String alias,
    required String name,
    required String description,
    required dynamic posts,
  }) = _SnPostTag;

  factory SnPostTag.fromJson(Map<String, Object?> json) =>
      _$SnPostTagFromJson(json);
}

@freezed
abstract class SnPostCategory with _$SnPostCategory {
  const factory SnPostCategory({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required dynamic deletedAt,
    required String alias,
    required String name,
    required String description,
    required dynamic posts,
  }) = _SnPostCategory;

  factory SnPostCategory.fromJson(Map<String, Object?> json) =>
      _$SnPostCategoryFromJson(json);
}

@freezed
abstract class SnPostPreload with _$SnPostPreload {
  const factory SnPostPreload({
    required SnAttachment? thumbnail,
    required List<SnAttachment?>? attachments,
    required SnAttachment? video,
    required SnPoll? poll,
    required SnRealm? realm,
  }) = _SnPostPreload;

  factory SnPostPreload.fromJson(Map<String, Object?> json) =>
      _$SnPostPreloadFromJson(json);
}

@freezed
abstract class SnBody with _$SnBody {
  const factory SnBody({
    required List<String> attachments,
    required String content,
    required dynamic location,
    required dynamic thumbnail,
    required dynamic title,
  }) = _SnBody;

  factory SnBody.fromJson(Map<String, Object?> json) => _$SnBodyFromJson(json);
}

@freezed
abstract class SnMetric with _$SnMetric {
  const factory SnMetric({
    required int replyCount,
    required int reactionCount,
    @Default({}) Map<String, int> reactionList,
  }) = _SnMetric;

  factory SnMetric.fromJson(Map<String, Object?> json) =>
      _$SnMetricFromJson(json);
}

@freezed
abstract class SnPublisher with _$SnPublisher {
  const factory SnPublisher({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required int type,
    required String name,
    required String nick,
    required String description,
    required String avatar,
    required String banner,
    required int totalUpvote,
    required int totalDownvote,
    required int? realmId,
    required int accountId,
  }) = _SnPublisher;

  factory SnPublisher.fromJson(Map<String, Object?> json) =>
      _$SnPublisherFromJson(json);
}

@freezed
abstract class SnSubscription with _$SnSubscription {
  const factory SnSubscription({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required int followerId,
    required int accountId,
  }) = _SnSubscription;

  factory SnSubscription.fromJson(Map<String, Object?> json) =>
      _$SnSubscriptionFromJson(json);
}

@freezed
abstract class SnFeedEntry with _$SnFeedEntry {
  const factory SnFeedEntry({
    required String type,
    required dynamic data,
    required DateTime createdAt,
  }) = _SnFeedEntry;

  factory SnFeedEntry.fromJson(Map<String, dynamic> json) =>
      _$SnFeedEntryFromJson(json);
}

@freezed
abstract class SnFediversePost with _$SnFediversePost {
  const factory SnFediversePost({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String identifier,
    required String origin,
    required String content,
    required String language,
    required List<String> images,
    required SnFediverseUser user,
    required int userId,
  }) = _SnFediversePost;

  factory SnFediversePost.fromJson(Map<String, Object?> json) =>
      _$SnFediversePostFromJson(json);
}

@freezed
abstract class SnFediverseUser with _$SnFediverseUser {
  const factory SnFediverseUser({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String identifier,
    required String origin,
    required String avatar,
    required String name,
    required String nick,
  }) = _SnFediverseUser;

  factory SnFediverseUser.fromJson(Map<String, dynamic> json) =>
      _$SnFediverseUserFromJson(json);
}
