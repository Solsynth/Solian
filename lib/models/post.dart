import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/account.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post_category.dart';
import 'package:island/models/post_tag.dart';
import 'package:island/models/publisher.dart';
import 'package:island/models/realm.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
sealed class SnPost with _$SnPost {
  const factory SnPost({
    required String id,
    String? title,
    String? description,
    String? language,
    DateTime? editedAt,
    @Default(null) DateTime? publishedAt,
    @Default(0) int visibility,
    String? content,
    String? slug,
    @Default(0) int type,
    Map<String, dynamic>? meta,
    SnPostEmbedView? embedView,
    @Default(0) int viewsUnique,
    @Default(0) int viewsTotal,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    @Default(0) int repliesCount,
    @Default(0) int awardedScore,
    int? pinMode,
    String? threadedPostId,
    SnPost? threadedPost,
    String? repliedPostId,
    SnPost? repliedPost,
    String? forwardedPostId,
    SnPost? forwardedPost,
    String? realmId,
    SnRealm? realm,
    @Default([]) List<SnCloudFile> attachments,
    required SnPublisher publisher,
    @Default({}) Map<String, int> reactionsCount,
    @Default({}) Map<String, bool> reactionsMade,
    @Default([]) List<dynamic> reactions,
    @Default([]) List<SnPostTag> tags,
    @Default([]) List<SnPostCategory> categories,
    @Default([]) List<dynamic> collections,
    @Default([]) List<SnPostFeaturedRecord> featuredRecords,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
    DateTime? deletedAt,
    @Default(false) bool repliedGone,
    @Default(false) bool forwardedGone,
    @Default(false) bool isTruncated,
  }) = _SnPost;

  factory SnPost.fromJson(Map<String, dynamic> json) => _$SnPostFromJson(json);
}

@freezed
sealed class SnPublisherStats with _$SnPublisherStats {
  const factory SnPublisherStats({
    required int postsCreated,
    required int stickerPacksCreated,
    required int stickersCreated,
    required int upvoteReceived,
    required int downvoteReceived,
  }) = _SnPublisherStats;

  factory SnPublisherStats.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherStatsFromJson(json);
}

@freezed
sealed class SnPublisherSubscription with _$SnPublisherSubscription {
  const factory SnPublisherSubscription({
    required String accountId,
    required String publisherId,
    required SnPublisher publisher,
  }) = _SnPublisherSubscription;

  factory SnPublisherSubscription.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherSubscriptionFromJson(json);
}

@freezed
sealed class ReactInfo with _$ReactInfo {
  const factory ReactInfo({required String icon, required int attitude}) =
      _ReactInfo;

  static String getTranslationKey(String templateKey) {
    final parts = templateKey.split('_');
    final camelCase = parts
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join();
    return 'reaction$camelCase';
  }
}

const Map<String, ReactInfo> kReactionTemplates = {
  'thumb_up': ReactInfo(icon: '👍', attitude: 0),
  'thumb_down': ReactInfo(icon: '👎', attitude: 2),
  'just_okay': ReactInfo(icon: '😅', attitude: 1),
  'cry': ReactInfo(icon: '😭', attitude: 1),
  'confuse': ReactInfo(icon: '🧐', attitude: 1),
  'clap': ReactInfo(icon: '👏', attitude: 0),
  'laugh': ReactInfo(icon: '😂', attitude: 0),
  'angry': ReactInfo(icon: '😡', attitude: 2),
  'party': ReactInfo(icon: '🎉', attitude: 0),
  'pray': ReactInfo(icon: '🙏', attitude: 0),
  'heart': ReactInfo(icon: '❤️', attitude: 0),
};

enum PostEmbedViewRenderer {
  @JsonValue(0)
  webView,
}

@freezed
sealed class SnPostEmbedView with _$SnPostEmbedView {
  const factory SnPostEmbedView({
    required String uri,
    double? aspectRatio,
    @Default(PostEmbedViewRenderer.webView) PostEmbedViewRenderer renderer,
  }) = _SnPostEmbedView;

  factory SnPostEmbedView.fromJson(Map<String, dynamic> json) =>
      _$SnPostEmbedViewFromJson(json);
}

@freezed
sealed class SnPostAward with _$SnPostAward {
  const factory SnPostAward({
    required String id,
    required double amount,
    required int attitude,
    String? message,
    required String postId,
    required String accountId,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _SnPostAward;

  factory SnPostAward.fromJson(Map<String, dynamic> json) =>
      _$SnPostAwardFromJson(json);
}

@freezed
sealed class SnPostReaction with _$SnPostReaction {
  const factory SnPostReaction({
    required String id,
    required String symbol,
    required int attitude,
    required String postId,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(null) SnAccount? account,
    DateTime? deletedAt,
  }) = _SnPostReaction;

  factory SnPostReaction.fromJson(Map<String, dynamic> json) =>
      _$SnPostReactionFromJson(json);
}

@freezed
sealed class SnPostFeaturedRecord with _$SnPostFeaturedRecord {
  const factory SnPostFeaturedRecord({
    required String id,
    required String postId,
    required DateTime? featuredAt,
    required int socialCredits,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnPostFeaturedRecord;

  factory SnPostFeaturedRecord.fromJson(Map<String, dynamic> json) =>
      _$SnPostFeaturedRecordFromJson(json);
}
