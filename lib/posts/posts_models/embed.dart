import 'package:freezed_annotation/freezed_annotation.dart';

part 'embed.freezed.dart';
part 'embed.g.dart';

@freezed
sealed class SnScrappedLink with _$SnScrappedLink {
  const factory SnScrappedLink({
    required String type,
    required String url,
    required String? title,
    required String? description,
    required String? imageUrl,
    required String? faviconUrl,
    required String? siteName,
    required String? contentType,
    required String? author,
    required DateTime? publishedDate,
  }) = _SnScrappedLink;

  factory SnScrappedLink.fromJson(Map<String, dynamic> json) =>
      _$SnScrappedLinkFromJson(json);
}
