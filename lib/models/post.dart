import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post_category.dart';
import 'package:island/models/post_tag.dart';
import 'package:island/models/publisher.dart';

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
    @Default(0) int type,
    Map<String, dynamic>? meta,
    @Default(0) int viewsUnique,
    @Default(0) int viewsTotal,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    @Default(0) int repliesCount,
    String? threadedPostId,
    SnPost? threadedPost,
    String? repliedPostId,
    SnPost? repliedPost,
    String? forwardedPostId,
    SnPost? forwardedPost,
    @Default([]) List<SnCloudFile> attachments,
    required SnPublisher publisher,
    @Default({}) Map<String, int> reactionsCount,
    @Default({}) Map<String, bool> reactionsMade,
    @Default([]) List<dynamic> reactions,
    @Default([]) List<PostTag> tags,
    @Default([]) List<PostCategory> categories,
    @Default([]) List<dynamic> collections,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
    DateTime? deletedAt,
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
sealed class SnSubscriptionStatus with _$SnSubscriptionStatus {
  const factory SnSubscriptionStatus({
    required bool isSubscribed,
    required String publisherId,
    required String publisherName,
  }) = _SnSubscriptionStatus;

  factory SnSubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionStatusFromJson(json);
}

@freezed
sealed class ReactInfo with _$ReactInfo {
  const factory ReactInfo({required String icon, required int attitude}) =
      _ReactInfo;

  static String getTranslationKey(String templateKey) {
    final parts = templateKey.split('_');
    final camelCase =
        parts.map((p) => p[0].toUpperCase() + p.substring(1)).join();
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
