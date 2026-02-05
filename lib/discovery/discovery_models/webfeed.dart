import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/posts/posts_models/embed.dart';

part 'webfeed.freezed.dart';
part 'webfeed.g.dart';

@freezed
sealed class SnWebFeedConfig with _$SnWebFeedConfig {
  const factory SnWebFeedConfig({@Default(false) bool scrapPage}) =
      _SnWebFeedConfig;

  factory SnWebFeedConfig.fromJson(Map<String, dynamic> json) =>
      _$SnWebFeedConfigFromJson(json);
}

@freezed
sealed class SnWebFeed with _$SnWebFeed {
  const factory SnWebFeed({
    required String id,
    required String url,
    required String title,
    String? description,
    SnScrappedLink? preview,
    @Default(SnWebFeedConfig()) SnWebFeedConfig config,
    required String publisherId,
    @Default([]) List<SnWebArticle> articles,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnWebFeed;

  factory SnWebFeed.fromJson(Map<String, dynamic> json) =>
      _$SnWebFeedFromJson(json);

  factory SnWebFeed.fromJsonString(String jsonString) =>
      SnWebFeed.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}

@freezed
sealed class SnWebArticle with _$SnWebArticle {
  const factory SnWebArticle({
    required String id,
    required String title,
    required String url,
    String? author,
    Map<String, dynamic>? meta,
    SnScrappedLink? preview,
    SnWebFeed? feed,
    String? content,
    DateTime? publishedAt,
    required String feedId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnWebArticle;

  factory SnWebArticle.fromJson(Map<String, dynamic> json) =>
      _$SnWebArticleFromJson(json);

  factory SnWebArticle.fromJsonString(String jsonString) =>
      SnWebArticle.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
