import 'package:freezed_annotation/freezed_annotation.dart';

part 'publication_site.freezed.dart';
part 'publication_site.g.dart';

@freezed
sealed class SnPublicationSite with _$SnPublicationSite {
  const factory SnPublicationSite({
    required String id,
    required String slug,
    required String name,
    String? description,
    required String publisherId,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<SnPublicationPage> pages,
  }) = _SnPublicationSite;

  factory SnPublicationSite.fromJson(Map<String, dynamic> json) =>
      _$SnPublicationSiteFromJson(json);
}

@freezed
sealed class SnPublicationPage with _$SnPublicationPage {
  const factory SnPublicationPage({
    required String id,
    String? preset,
    String? path,
    Map<String, dynamic>? config,
    required String siteId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SnPublicationPage;

  factory SnPublicationPage.fromJson(Map<String, dynamic> json) =>
      _$SnPublicationPageFromJson(json);
}

enum PublicationPagePreset { landing, profile, posts, custom }
