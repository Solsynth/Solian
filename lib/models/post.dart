import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';
import 'package:island/models/user.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
sealed class SnPost with _$SnPost {
  const factory SnPost({
    required String id,
    required String? title,
    required String? description,
    required String? language,
    required DateTime? editedAt,
    required DateTime publishedAt,
    required int visibility,
    required String? content,
    required int type,
    required Map<String, dynamic>? meta,
    required int viewsUnique,
    required int viewsTotal,
    required int upvotes,
    required int downvotes,
    required int repliesCount,
    required String? threadedPostId,
    required SnPost? threadedPost,
    required String? repliedPostId,
    required SnPost? repliedPost,
    required String? forwardedPostId,
    required SnPost? forwardedPost,
    required List<SnCloudFile> attachments,
    required SnPublisher publisher,
    @Default({}) Map<String, int> reactionsCount,
    required List<dynamic> reactions,
    required List<dynamic> tags,
    required List<dynamic> categories,
    required List<dynamic> collections,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    @Default(false) bool isTruncated,
  }) = _SnPost;

  factory SnPost.fromJson(Map<String, dynamic> json) => _$SnPostFromJson(json);
}

@freezed
sealed class SnPublisher with _$SnPublisher {
  const factory SnPublisher({
    required String id,
    required int type,
    required String name,
    required String nick,
    @Default('') String bio,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required SnAccount? account,
    required String? accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String? realmId,
    required SnVerificationMark? verification,
  }) = _SnPublisher;

  factory SnPublisher.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherFromJson(json);
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
