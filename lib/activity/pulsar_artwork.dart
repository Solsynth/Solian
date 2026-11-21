import 'package:island/activity/pulsar_models.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Steam serves a portrait library capsule per app, but only for apps that
/// shipped library assets. Older titles fall back to the wide store header,
/// which crops inside a portrait card but still reads as the game.
const String _steamCdn = 'https://cdn.cloudflare.steamstatic.com/steam/apps';

/// `sha256:<hash>` artwork is a Stargate blob reference, not a URL.
const String _presenceArtworkPath = '/stargate/presence/artworks/';

/// One artwork location, in display priority order.
///
/// The first entry is what the card tries to load; later entries are fallbacks
/// for sources that only ship a wide image (Steam store headers) or for blobs
/// whose hash predates the server endpoint.
abstract final class PulsarArtwork {
  /// Normalizes a Steam app id. Steam's own ids are decimal; anything else is
  /// a malformed provider key and must not reach the CDN.
  static String? steamAppId(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(raw)) return null;
    return raw;
  }

  /// Steam's portrait capsule, then the landscape header, for one app id.
  static List<String> steamUrls(dynamic appId) {
    final id = steamAppId(appId);
    if (id == null) return const [];
    return ['$_steamCdn/$id/library_600x900.jpg', '$_steamCdn/$id/header.jpg'];
  }

  /// Resolves one raw artwork value: `sha256:` blobs, protocol-relative CDN
  /// paths, and plain http(s) URLs.
  ///
  /// `discord:` assets need the activity that owns them — the caller resolves
  /// those through the presence asset provider instead.
  static List<String> resolve(String? raw, {String? serverUrl}) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return const [];
    if (value.startsWith('discord:')) return const [];

    if (value.startsWith('sha256:')) {
      final server = _serverRoot(serverUrl);
      if (server == null) return const [];
      return ['$server$_presenceArtworkPath$value'];
    }

    if (value.startsWith('//')) return ['https:$value'];
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return [value];
    }
    return const [];
  }

  /// Now-playing artwork. Steam sessions carry the app id in metadata because
  /// the connector knows the game, not a cover URL.
  static List<String> presenceUrls(
    SnPresenceActivity activity, {
    String? serverUrl,
  }) {
    final meta = activity.meta;
    final gameId = meta?['game_id'] ?? meta?['app_id'];
    return _dedupe([
      if (activity.manualId == 'steam' || meta?['provider'] == 'steam')
        ...steamUrls(gameId),
      ...resolve(activity.largeImage, serverUrl: serverUrl),
      ...resolve(activity.smallImage, serverUrl: serverUrl),
    ]);
  }

  /// Scrobble artwork. History rows keep the provider key on the resolved
  /// catalog item, so an imported Steam game gets its cover back even though
  /// the row itself carries no image URL.
  static List<String> scrobbleUrls(
    PulsarScrobble scrobble, {
    String? serverUrl,
  }) {
    final meta = scrobble.meta;
    final catalog = scrobble.catalogItem;
    return _dedupe([
      ...steamUrls(
        meta?['game_id'] ??
            meta?['app_id'] ??
            (catalog?.provider == 'steam' ? catalog?.providerKey : null),
      ),
      ...resolve(scrobble.artworkUrl, serverUrl: serverUrl),
      ...catalogUrls(catalog, serverUrl: serverUrl),
    ]);
  }

  /// Catalog artwork. Gaming entries resolved through the Steam provider store
  /// the landscape store header, so the portrait capsule leads and the stored
  /// header follows.
  static List<String> catalogUrls(
    PulsarCatalogItem? item, {
    String? serverUrl,
  }) {
    if (item == null) return const [];
    return _dedupe([
      if (item.provider == 'steam') ...steamUrls(item.providerKey),
      ...resolve(item.artworkUrl, serverUrl: serverUrl),
      ...resolve(item.bannerUrl, serverUrl: serverUrl),
    ]);
  }

  /// Collection (favourites, watchlist) artwork. Rows carry no artwork of
  /// their own; the server resolves one catalog record per row and that record
  /// is where the picture lives.
  static List<String> collectionUrls(
    PulsarCollectionItem item, {
    String? serverUrl,
  }) {
    return catalogUrls(item.catalogItem, serverUrl: serverUrl);
  }

  /// Top-work artwork from media stats. Combines Steam app ids (from meta,
  /// provider key, or resolved catalog item), direct artwork URLs, and catalog
  /// artwork.
  static List<String> topEntityUrls(
    PulsarTopEntity entity, {
    String? serverUrl,
  }) {
    final meta = entity.meta;
    final catalog = entity.catalogItem;
    return _dedupe([
      ...steamUrls(
        meta?['game_id'] ??
            meta?['app_id'] ??
            (entity.provider == 'steam' ? entity.providerKey : null) ??
            (catalog?.provider == 'steam' ? catalog?.providerKey : null),
      ),
      ...resolve(entity.artworkUrl, serverUrl: serverUrl),
      ...catalogUrls(catalog, serverUrl: serverUrl),
    ]);
  }

  /// The one URL to persist when a scrobble is turned into a favourite or a
  /// tracked work.
  ///
  /// A Steam row has no `artwork_url` of its own; without this, the favourite
  /// it becomes is filed with no picture and shows a placeholder forever.
  static String? persistableScrobbleArtwork(
    PulsarScrobble scrobble, {
    String? serverUrl,
  }) {
    final urls = scrobbleUrls(scrobble, serverUrl: serverUrl);
    return urls.isEmpty ? null : urls.first;
  }

  /// Same for a collection row: the catalog cover, made concrete.
  static String? persistableCollectionArtwork(
    PulsarCollectionItem item, {
    String? serverUrl,
  }) {
    final urls = collectionUrls(item, serverUrl: serverUrl);
    return urls.isEmpty ? null : urls.first;
  }

  static String? _serverRoot(String? serverUrl) {
    final value = serverUrl?.trim();
    if (value == null || value.isEmpty) return null;
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static List<String> _dedupe(List<String> urls) {
    final seen = <String>{};
    final result = <String>[];
    for (final url in urls) {
      if (url.isEmpty || !seen.add(url)) continue;
      result.add(url);
    }
    return result;
  }
}
