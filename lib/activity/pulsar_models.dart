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

  static const List<String> mediaDomains = [music, gaming, video, anime, book];

  static const List<String> all = [music, gaming, video, anime, book, custom];

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
      artworkUrl:
          _nonEmpty(json['artwork_url']) ?? _nonEmpty(json['image_url']),
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

  /// Provider metadata the client that scrobbled the row sent — for gaming
  /// that is `game_id`/`provider`, which is the only handle Steam artwork can
  /// be built from.
  final Map<String, dynamic>? meta;
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
    this.meta,
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
      meta: json['meta'] is Map
          ? Map<String, dynamic>.from(json['meta'])
          : null,
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
  final int? progress;
  final int? volumeProgress;
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
    this.progress,
    this.volumeProgress,
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
      progress: _asInt(json['progress']),
      volumeProgress: _asInt(json['volume_progress']),
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

class PulsarBangumiCollection {
  final String domain;
  final String collectionId;
  final String name;
  final String scope;
  final int items;

  const PulsarBangumiCollection({
    required this.domain,
    required this.collectionId,
    this.name = '',
    this.scope = '',
    this.items = 0,
  });

  factory PulsarBangumiCollection.fromJson(Map<String, dynamic> json) {
    return PulsarBangumiCollection(
      domain: json['domain']?.toString() ?? PulsarDomain.custom,
      collectionId: json['collection_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      scope: json['scope']?.toString() ?? '',
      items: _asInt(json['items']) ?? 0,
    );
  }
}

/// The account's Bangumi link state. Token values never reach the client; the
/// fields here are the profile and sync switches the settings card needs.
class PulsarBangumiConnection {
  final bool linked;
  final bool configured;
  final String provider;
  final String remoteUserId;
  final String remoteUsername;
  final String nickname;
  final String avatarUrl;
  final bool syncEnabled;
  final String conflictPolicy;
  final DateTime? tokenExpiresAt;
  final DateTime? lastSyncedAt;
  final String lastError;
  final DateTime? linkedAt;
  final List<PulsarBangumiCollection> collections;

  const PulsarBangumiConnection({
    this.linked = false,
    this.configured = false,
    this.provider = 'bangumi',
    this.remoteUserId = '',
    this.remoteUsername = '',
    this.nickname = '',
    this.avatarUrl = '',
    this.syncEnabled = true,
    this.conflictPolicy = 'remote',
    this.tokenExpiresAt,
    this.lastSyncedAt,
    this.lastError = '',
    this.linkedAt,
    this.collections = const [],
  });

  factory PulsarBangumiConnection.fromJson(Map<String, dynamic> json) {
    final rawCollections = json['collections'];
    return PulsarBangumiConnection(
      linked: json['linked'] as bool? ?? false,
      configured: json['configured'] as bool? ?? false,
      provider: json['provider']?.toString() ?? 'bangumi',
      remoteUserId: json['remote_user_id']?.toString() ?? '',
      remoteUsername: json['remote_username']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      syncEnabled: json['sync_enabled'] as bool? ?? true,
      conflictPolicy: json['conflict_policy']?.toString() ?? 'remote',
      tokenExpiresAt: _asDate(json['token_expires_at']),
      lastSyncedAt: _asDate(json['last_synced_at']),
      lastError: json['last_error']?.toString() ?? '',
      linkedAt: _asDate(json['linked_at']),
      collections: rawCollections is List
          ? [
              for (final item in rawCollections)
                if (item is Map)
                  PulsarBangumiCollection.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
            ]
          : const [],
    );
  }
}

class PulsarBangumiSyncResult {
  final int pulled;
  final int pushed;
  final int removed;
  final int conflicts;
  final int skipped;
  final int failed;

  const PulsarBangumiSyncResult({
    this.pulled = 0,
    this.pushed = 0,
    this.removed = 0,
    this.conflicts = 0,
    this.skipped = 0,
    this.failed = 0,
  });

  factory PulsarBangumiSyncResult.fromJson(Map<String, dynamic> json) {
    return PulsarBangumiSyncResult(
      pulled: _asInt(json['pulled']) ?? 0,
      pushed: _asInt(json['pushed']) ?? 0,
      removed: _asInt(json['removed']) ?? 0,
      conflicts: _asInt(json['conflicts']) ?? 0,
      skipped: _asInt(json['skipped']) ?? 0,
      failed: _asInt(json['failed']) ?? 0,
    );
  }
}

class PulsarTopEntity {
  final String name;
  final String? subtitle;
  final int count;
  final int seconds;

  /// Cover of the row the aggregate picked for this group. Empty when every
  /// play in the group came from a client that sent no picture.
  final String? artworkUrl;

  const PulsarTopEntity({
    required this.name,
    this.subtitle,
    this.count = 0,
    this.seconds = 0,
    this.artworkUrl,
  });

  factory PulsarTopEntity.fromJson(Map<String, dynamic> json) {
    return PulsarTopEntity(
      name: json['name']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      count: _asInt(json['count']) ?? 0,
      seconds: _asInt(json['seconds']) ?? 0,
      artworkUrl: _nonEmpty(json['artwork_url']),
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
