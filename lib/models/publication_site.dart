import 'package:freezed_annotation/freezed_annotation.dart';

part 'publication_site.freezed.dart';
part 'publication_site.g.dart';

@freezed
sealed class SnPublicationSiteNavItems with _$SnPublicationSiteNavItems {
  const factory SnPublicationSiteNavItems({
    required String label,
    required String href,
  }) = _SnPublicationSiteNavItems;

  factory SnPublicationSiteNavItems.fromJson(Map<String, dynamic> json) =>
      _$SnPublicationSiteNavItemsFromJson(json);
}

@freezed
sealed class SnPublicationSiteConfig with _$SnPublicationSiteConfig {
  const factory SnPublicationSiteConfig({
    String? styleOverride,
    List<SnPublicationSiteNavItems>? navItems,
  }) = _SnPublicationSiteConfig;

  factory SnPublicationSiteConfig.fromJson(Map<String, dynamic> json) =>
      _$SnPublicationSiteConfigFromJson(json);
}

@freezed
sealed class SnPublicationSite with _$SnPublicationSite {
  const factory SnPublicationSite({
    required String id,
    required String slug,
    required String name,
    String? description,
    int? mode,
    required String publisherId,
    required String accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<SnPublicationPage> pages,
    required SnPublicationSiteConfig config,
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
