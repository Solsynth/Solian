import 'package:freezed_annotation/freezed_annotation.dart';

part 'news.freezed.dart';
part 'news.g.dart';

@freezed
abstract class SnSubscriptionFeed with _$SnSubscriptionFeed {
  const factory SnSubscriptionFeed({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String url,
    required bool isEnabled,
    required bool isFullContent,
    required int pullInterval,
    required String adapter,
    required int? accountId,
    required DateTime? lastFetchedAt,
  }) = _SnSubscriptionFeed;

  factory SnSubscriptionFeed.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionFeedFromJson(json);
}

@freezed
abstract class SnSubscriptionItem with _$SnSubscriptionItem {
  const factory SnSubscriptionItem({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String thumbnail,
    required String title,
    required String description,
    required String content,
    required String url,
    required String hash,
    required int feedId,
    required SnSubscriptionFeed feed,
    required DateTime? publishedAt,
  }) = _SnSubscriptionItem;

  factory SnSubscriptionItem.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionItemFromJson(json);
}
