import 'package:freezed_annotation/freezed_annotation.dart';

part 'news.freezed.dart';
part 'news.g.dart';

@freezed
abstract class SnNewsSource with _$SnNewsSource {
  const factory SnNewsSource({
    required String id,
    required String label,
    required String type,
    required String source,
    required int depth,
    required bool enabled,
  }) = _SnNewsSource;

  factory SnNewsSource.fromJson(Map<String, dynamic> json) =>
      _$SnNewsSourceFromJson(json);
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
    required DateTime? publishedAt,
  }) = _SnSubscriptionItem;

  factory SnSubscriptionItem.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionItemFromJson(json);
}
