import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/embed.dart';

part 'webfeed.freezed.dart';
part 'webfeed.g.dart';

@freezed
sealed class WebFeedConfig with _$WebFeedConfig {
  const factory WebFeedConfig({@Default(false) bool scrapPage}) =
      _WebFeedConfig;

  factory WebFeedConfig.fromJson(Map<String, dynamic> json) =>
      _$WebFeedConfigFromJson(json);
}

@freezed
sealed class WebFeed with _$WebFeed {
  const factory WebFeed({
    required String id,
    required String url,
    required String title,
    String? description,
    SnScrappedLink? preview,
    @Default(WebFeedConfig()) WebFeedConfig config,
    required String publisherId,
    @Default([]) List<WebArticle> articles,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _WebFeed;

  factory WebFeed.fromJson(Map<String, dynamic> json) =>
      _$WebFeedFromJson(json);

  factory WebFeed.fromJsonString(String jsonString) =>
      WebFeed.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}

@freezed
sealed class WebArticle with _$WebArticle {
  const factory WebArticle({
    required String id,
    required String title,
    required String url,
    String? author,
    Map<String, dynamic>? meta,
    SnScrappedLink? preview,
    String? content,
    DateTime? publishedAt,
    required String feedId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _WebArticle;

  factory WebArticle.fromJson(Map<String, dynamic> json) =>
      _$WebArticleFromJson(json);

  factory WebArticle.fromJsonString(String jsonString) =>
      WebArticle.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
