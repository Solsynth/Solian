import 'package:freezed_annotation/freezed_annotation.dart';

part 'embed.freezed.dart';
part 'embed.g.dart';

@freezed
sealed class SnEmbedLink with _$SnEmbedLink {
  const factory SnEmbedLink({
    @JsonKey(name: 'Type') required String type,
    @JsonKey(name: 'Url') required String url,
    @JsonKey(name: 'Title') required String title,
    @JsonKey(name: 'Description') required String? description,
    @JsonKey(name: 'ImageUrl') required String? imageUrl,
    @JsonKey(name: 'FaviconUrl') required String faviconUrl,
    @JsonKey(name: 'SiteName') required String siteName,
    @JsonKey(name: 'ContentType') required String? contentType,
    @JsonKey(name: 'Author') required String? author,
    @JsonKey(name: 'PublishedDate') required DateTime? publishedDate,
  }) = _SnEmbedLink;

  factory SnEmbedLink.fromJson(Map<String, dynamic> json) =>
      _$SnEmbedLinkFromJson(json);
}

@freezed
sealed class SnScrappedLink with _$SnScrappedLink {
  const factory SnScrappedLink({
    required String type,
    required String url,
    required String title,
    required String? description,
    required String? imageUrl,
    required String faviconUrl,
    required String siteName,
    required String? contentType,
    required String? author,
    required DateTime? publishedDate,
  }) = _SnScrappedLink;

  factory SnScrappedLink.fromJson(Map<String, dynamic> json) =>
      _$SnScrappedLinkFromJson(json);
}
