import 'package:freezed_annotation/freezed_annotation.dart';

part 'embed.freezed.dart';
part 'embed.g.dart';

@freezed
sealed class SnEmbedLink with _$SnEmbedLink {
  const factory SnEmbedLink({
    @JsonKey(name: 'Type') required String type,
    @JsonKey(name: 'Url') required String url,
    @JsonKey(name: 'Title') required String title,
    @JsonKey(name: 'Description') required String description,
    @JsonKey(name: 'ImageUrl') required String imageUrl,
    @JsonKey(name: 'FaviconUrl') required String faviconUrl,
    @JsonKey(name: 'SiteName') required String siteName,
    @JsonKey(name: 'ContentType') required String contentType,
    @JsonKey(name: 'Author') required dynamic author,
    @JsonKey(name: 'PublishedDate') required dynamic publishedDate,
  }) = _SnEmbedLink;

  factory SnEmbedLink.fromJson(Map<String, dynamic> json) =>
      _$SnEmbedLinkFromJson(json);
}
