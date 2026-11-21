import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Media domains supported by Pulsar (`model.Domain*` in LightHouse).
abstract final class PulsarDomain {
  static const music = 'music';
  static const gaming = 'gaming';
  static const video = 'video';
  static const anime = 'anime';
  static const book = 'book';
  static const custom = 'custom';

  static const List<String> mediaDomains = [
    music,
    gaming,
    video,
    anime,
    book,
  ];

  static const List<String> all = [
    music,
    gaming,
    video,
    anime,
    book,
    custom,
  ];

  static IconData icon(String? domain) {
    return switch (domain) {
      music => Symbols.music_note,
      gaming => Symbols.sports_esports,
      video => Symbols.movie,
      anime => Symbols.live_tv,
      book => Symbols.menu_book,
      _ => Symbols.podcasts,
    };
  }

  static String label(String? domain) {
    return switch (domain) {
      music => 'pulsarDomainMusic'.tr(),
      gaming => 'pulsarDomainGaming'.tr(),
      video => 'pulsarDomainVideo'.tr(),
      anime => 'pulsarDomainAnime'.tr(),
      book => 'pulsarDomainBook'.tr(),
      custom => 'pulsarDomainCustom'.tr(),
      _ => domain ?? 'pulsarDomainCustom'.tr(),
    };
  }
}

/// Collection item statuses supported by Pulsar (`model.Status*` in LightHouse).
abstract final class PulsarWorkStatus {
  static const watching = 'watching';
  static const planToWatch = 'plan_to_watch';
  static const completed = 'completed';
  static const onHold = 'on_hold';
  static const dropped = 'dropped';

  static const List<String> all = [
    watching,
    planToWatch,
    completed,
    onHold,
    dropped,
  ];

  static IconData icon(String? status) {
    return switch (status) {
      watching => Symbols.play_circle,
      planToWatch => Symbols.bookmark_add,
      completed => Symbols.check_circle,
      onHold => Symbols.pause_circle,
      dropped => Symbols.cancel,
      _ => Symbols.radio_button_unchecked,
    };
  }

  static String label(String? status) {
    return switch (status) {
      watching => 'pulsarStatusWatching'.tr(),
      planToWatch => 'pulsarStatusPlanToWatch'.tr(),
      completed => 'pulsarStatusCompleted'.tr(),
      onHold => 'pulsarStatusOnHold'.tr(),
      dropped => 'pulsarStatusDropped'.tr(),
      _ => 'pulsarStatusNone'.tr(),
    };
  }

  static Color color(BuildContext context, String? status) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      watching => scheme.primary,
      planToWatch => scheme.secondary,
      completed => Colors.green,
      onHold => Colors.orange,
      dropped => scheme.error,
      _ => scheme.onSurfaceVariant,
    };
  }
}

/// Collection kinds in Pulsar (`model.Kind*` in LightHouse).
abstract final class PulsarCollectionKind {
  static const playlist = 'playlist';
  static const watchlist = 'watchlist';
  static const backlog = 'backlog';
  static const favorites = 'favorites';
  static const custom = 'custom';
}

/// Favourite entry kinds in Pulsar (`model.Favourite*` in LightHouse).
abstract final class PulsarFavoriteKind {
  static const track = 'track';
  static const album = 'album';
  static const playlist = 'playlist';

  static const List<String> all = [track, album, playlist];

  static String label(String? kind) {
    return switch (kind) {
      album => 'pulsarFavKindAlbum'.tr(),
      playlist => 'pulsarFavKindPlaylist'.tr(),
      _ => 'pulsarFavKindTrack'.tr(),
    };
  }
}

class PulsarCatalogItem {
  final String id;
  final String domain;
  final String? slug;
  final String? urn;
  final String provider;
  final String? providerKey;
  final String title;
  final String? subtitle;
  final String? caption;
  final String? description;
  final String? artworkUrl;
  final String? bannerUrl;
  final int durationSeconds;
  final String? releaseDate;

  const PulsarCatalogItem({
    required this.id,
    required this.domain,
    this.slug,
    this.urn,
    required this.provider,
    this.providerKey,
    required this.title,
    this.subtitle,
    this.caption,
    this.description,
    this.artworkUrl,
    this.bannerUrl,
    this.durationSeconds = 0,
    this.releaseDate,
  });

  factory PulsarCatalogItem.fromJson(Map<String, dynamic> json) {
    return PulsarCatalogItem(
      id: json['id']?.toString() ?? '',
      domain: json['domain']?.toString() ?? PulsarDomain.music,
      slug: json['slug']?.toString(),
      urn: json['urn']?.toString(),
      provider: json['provider']?.toString() ?? '',
      providerKey: json['provider_key']?.toString(),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      caption: json['caption']?.toString(),
      description: json['description']?.toString(),
      artworkUrl: _nonEmpty(json['artwork_url']) ?? _nonEmpty(json['image_url']),
      bannerUrl: _nonEmpty(json['banner_url']),
      durationSeconds: _asInt(json['duration_seconds']) ?? 0,
      releaseDate: json['release_date']?.toString(),
    );
  }
}

class PulsarScrobble {
  final String id;
  final String accountId;
  final String? catalogId;
  final String domain;
  final String clientName;
  final String title;
  final String? subtitle;
  final String? caption;
  final String? artworkUrl;
  final int listenedSeconds;
  final int durationSeconds;
  final DateTime playedAt;
  final PulsarCatalogItem? catalogItem;

  const PulsarScrobble({
    required this.id,
    required this.accountId,
    this.catalogId,
    required this.domain,
    required this.clientName,
    required this.title,
    this.subtitle,
    this.caption,
    this.artworkUrl,
    this.listenedSeconds = 0,
    this.durationSeconds = 0,
    required this.playedAt,
    this.catalogItem,
  });

  String? get effectiveArtworkUrl => artworkUrl ?? catalogItem?.artworkUrl;

  factory PulsarScrobble.fromJson(Map<String, dynamic> json) {
    return PulsarScrobble(
      id: json['id']?.toString() ?? '',
      accountId: json['account_id']?.toString() ?? '',
      catalogId: json['catalog_id']?.toString(),
      domain: json['domain']?.toString() ?? PulsarDomain.music,
      clientName: json['client_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      caption: json['caption']?.toString(),
      artworkUrl: json['artwork_url']?.toString(),
      listenedSeconds: _asInt(json['listened_seconds']) ?? 0,
      durationSeconds: _asInt(json['duration_seconds']) ?? 0,
      playedAt: _asDate(json['played_at']) ?? DateTime.now().toUtc(),
      catalogItem: json['catalog_item'] is Map
          ? PulsarCatalogItem.fromJson(
              Map<String, dynamic>.from(json['catalog_item']),
            )
          : null,
    );
  }
}

class PulsarCollectionItem {
  final String id;
  final String collectionId;
  final String? catalogId;
  final int position;
  final String? note;
  final int? rating;
  final String? status;
  final String kind;
  final PulsarCatalogItem? catalogItem;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PulsarCollectionItem({
    required this.id,
    required this.collectionId,
    this.catalogId,
    this.position = 0,
    this.note,
    this.rating,
    this.status,
    this.kind = '',
    this.catalogItem,
    this.createdAt,
    this.updatedAt,
  });

  String get displayTitle => catalogItem?.title ?? 'Unknown';
  String? get displaySubtitle => catalogItem?.subtitle;
  String? get displayArtwork => catalogItem?.artworkUrl;
  String get displayDomain => catalogItem?.domain ?? PulsarDomain.custom;

  factory PulsarCollectionItem.fromJson(Map<String, dynamic> json) {
    return PulsarCollectionItem(
      id: json['id']?.toString() ?? '',
      collectionId: json['collection_id']?.toString() ?? '',
      catalogId: json['catalog_id']?.toString(),
      position: _asInt(json['position']) ?? 0,
      note: json['note']?.toString(),
      rating: _asInt(json['rating']),
      status: json['status']?.toString(),
      kind: json['kind']?.toString() ?? '',
      catalogItem: json['catalog_item'] is Map
          ? PulsarCatalogItem.fromJson(
              Map<String, dynamic>.from(json['catalog_item']),
            )
          : null,
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }
}

class PulsarCollection {
  final String id;
  final String accountId;
  final String domain;
  final String kind;
  final String name;
  final String? description;
  final bool isPublic;
  final String? artworkUrl;
  final List<PulsarCollectionItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PulsarCollection({
    required this.id,
    required this.accountId,
    required this.domain,
    required this.kind,
    required this.name,
    this.description,
    this.isPublic = true,
    this.artworkUrl,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory PulsarCollection.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return PulsarCollection(
      id: json['id']?.toString() ?? '',
      accountId: json['account_id']?.toString() ?? '',
      domain: json['domain']?.toString() ?? PulsarDomain.music,
      kind: json['kind']?.toString() ?? PulsarCollectionKind.custom,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      isPublic: json['is_public'] as bool? ?? true,
      artworkUrl: json['artwork_url']?.toString(),
      items: rawItems is List
          ? [
              for (final item in rawItems)
                if (item is Map)
                  PulsarCollectionItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
            ]
          : const [],
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }
}

class PulsarTopEntity {
  final String name;
  final String? subtitle;
  final int count;
  final int seconds;

  const PulsarTopEntity({
    required this.name,
    this.subtitle,
    this.count = 0,
    this.seconds = 0,
  });

  factory PulsarTopEntity.fromJson(Map<String, dynamic> json) {
    return PulsarTopEntity(
      name: json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      count: _asInt(json['count']) ?? 0,
      seconds: _asInt(json['seconds']) ?? 0,
    );
  }
}

class PulsarMediaStats {
  final String accountId;
  final String? domain;
  final int totalScrobbles;
  final int totalSeconds;
  final List<PulsarTopEntity> topItems;
  final List<PulsarTopEntity> topCreators;
  final Map<String, int> domainBreakdown;
  final int daysActive;

  const PulsarMediaStats({
    required this.accountId,
    this.domain,
    this.totalScrobbles = 0,
    this.totalSeconds = 0,
    this.topItems = const [],
    this.topCreators = const [],
    this.domainBreakdown = const {},
    this.daysActive = 0,
  });

  factory PulsarMediaStats.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['domain_breakdown'];
    final breakdown = <String, int>{};
    if (rawBreakdown is Map) {
      for (final entry in rawBreakdown.entries) {
        final count = _asInt(entry.value);
        if (count != null && count > 0) {
          breakdown[entry.key.toString()] = count;
        }
      }
    }

    return PulsarMediaStats(
      accountId: json['account_id']?.toString() ?? '',
      domain: json['domain']?.toString(),
      totalScrobbles: _asInt(json['total_scrobbles']) ?? 0,
      totalSeconds: _asInt(json['total_seconds']) ?? 0,
      topItems: json['top_items'] is List
          ? [
              for (final item in json['top_items'] as List)
                if (item is Map)
                  PulsarTopEntity.fromJson(Map<String, dynamic>.from(item)),
            ]
          : const [],
      topCreators: json['top_creators'] is List
          ? [
              for (final item in json['top_creators'] as List)
                if (item is Map)
                  PulsarTopEntity.fromJson(Map<String, dynamic>.from(item)),
            ]
          : const [],
      domainBreakdown: breakdown,
      daysActive: _asInt(json['days_active']) ?? 0,
    );
  }
}

class PulsarReview {
  final String id;
  final String accountId;
  final String catalogId;
  final int? rating;
  final String? body;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PulsarReview({
    required this.id,
    required this.accountId,
    required this.catalogId,
    this.rating,
    this.body,
    this.createdAt,
    this.updatedAt,
  });

  factory PulsarReview.fromJson(Map<String, dynamic> json) {
    return PulsarReview(
      id: json['id']?.toString() ?? '',
      accountId: json['account_id']?.toString() ?? '',
      catalogId: json['catalog_id']?.toString() ?? '',
      rating: _asInt(json['rating']),
      body: json['body']?.toString(),
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _nonEmpty(dynamic value) {
  final str = value?.toString().trim();
  if (str == null || str.isEmpty) return null;
  return str;
}

DateTime? _asDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
