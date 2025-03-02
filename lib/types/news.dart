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

  factory SnNewsSource.fromJson(Map<String, dynamic> json) => _$SnNewsSourceFromJson(json);
}

@freezed
abstract class SnNewsArticle with _$SnNewsArticle {
  const factory SnNewsArticle({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required dynamic deletedAt,
    required String thumbnail,
    required String title,
    required String description,
    required String content,
    required String url,
    required String hash,
    required String source,
    required DateTime? publishedAt,
  }) = _SnNewsArticle;

  factory SnNewsArticle.fromJson(Map<String, dynamic> json) => _$SnNewsArticleFromJson(json);
}
