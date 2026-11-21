import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/activity/pulsar_activity.dart';
import 'package:island/activity/pulsar_models.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PulsarClient {
  final Dio _dio;

  PulsarClient(this._dio);

  Future<List<SnPresenceActivity>> getUserNowPlaying(String identifier) async {
    try {
      final resp = await _dio.get(
        '/pulsar/users/${Uri.encodeComponent(identifier)}/now-playing',
      );
      return pulsarActivitiesFromJson(resp.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  }

  Future<PulsarMediaStats?> getUserStats(
    String identifier, {
    String? domain,
  }) async {
    try {
      final resp = await _dio.get(
        '/pulsar/users/${Uri.encodeComponent(identifier)}/stats',
        queryParameters: {
          if (domain != null && domain.isNotEmpty) 'domain': domain,
        },
      );
      if (resp.data is! Map) return null;
      return PulsarMediaStats.fromJson(Map<String, dynamic>.from(resp.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<PulsarScrobble>> getUserHistory(
    String identifier, {
    String? domain,
    int offset = 0,
    int take = 20,
  }) async {
    try {
      final resp = await _dio.get(
        '/pulsar/users/${Uri.encodeComponent(identifier)}/history',
        queryParameters: {
          if (domain != null && domain.isNotEmpty) 'domain': domain,
          'offset': offset,
          'take': take,
        },
      );
      if (resp.data is! List) return const [];
      return [
        for (final item in resp.data as List)
          if (item is Map)
            PulsarScrobble.fromJson(Map<String, dynamic>.from(item)),
      ];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  }

  Future<List<PulsarCollectionItem>> getFavourites({
    String domain = PulsarDomain.music,
  }) async {
    try {
      final resp = await _dio.get(
        '/pulsar/collections/favourites',
        queryParameters: {'domain': domain},
      );
      if (resp.data is! Map) return const [];
      final items = resp.data['items'];
      if (items is! List) return const [];
      return [
        for (final item in items)
          if (item is Map)
            PulsarCollectionItem.fromJson(Map<String, dynamic>.from(item)),
      ];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  }

  Future<PulsarCollectionItem> setFavourite({
    String domain = PulsarDomain.music,
    String? catalogId,
    String? title,
    String? subtitle,
    String? artworkUrl,
    String kind = 'track',
  }) async {
    final resp = await _dio.put(
      '/pulsar/collections/favourites',
      queryParameters: {'domain': domain},
      data: {
        if (catalogId != null && catalogId.isNotEmpty) 'catalog_id': catalogId,
        if (title != null && title.isNotEmpty) 'title': title,
        if (subtitle != null && subtitle.isNotEmpty) 'subtitle': subtitle,
        if (artworkUrl != null && artworkUrl.isNotEmpty)
          'artwork_url': artworkUrl,
        if (kind.isNotEmpty) 'kind': kind,
      },
    );
    return PulsarCollectionItem.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<void> unsetFavourite(
    String catalogId, {
    String domain = PulsarDomain.music,
  }) async {
    await _dio.delete(
      '/pulsar/collections/favourites/${Uri.encodeComponent(catalogId)}',
      queryParameters: {'domain': domain},
    );
  }

  Future<List<PulsarCollection>> listMyCollections({
    String? domain,
    String? kind,
    int offset = 0,
    int take = 50,
  }) async {
    final resp = await _dio.get(
      '/pulsar/collections',
      queryParameters: {
        if (domain != null && domain.isNotEmpty) 'domain': domain,
        if (kind != null && kind.isNotEmpty) 'kind': kind,
        'offset': offset,
        'take': take,
      },
    );
    if (resp.data is! List) return const [];
    return [
      for (final item in resp.data as List)
        if (item is Map)
          PulsarCollection.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<PulsarCollection> getCollection(String id) async {
    final resp = await _dio.get(
      '/pulsar/collections/${Uri.encodeComponent(id)}',
    );
    return PulsarCollection.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<PulsarCollection> createCollection({
    required String name,
    required String domain,
    String kind = PulsarCollectionKind.watchlist,
    String? description,
    bool isPublic = true,
  }) async {
    final resp = await _dio.post(
      '/pulsar/collections',
      data: {
        'name': name,
        'domain': domain,
        'kind': kind,
        if (description != null && description.isNotEmpty)
          'description': description,
        'is_public': isPublic,
      },
    );
    return PulsarCollection.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<PulsarCollectionItem> addCollectionItem(
    String collectionId, {
    String? catalogId,
    String? title,
    String? subtitle,
    String? artworkUrl,
    String? status,
    int? rating,
    String? note,
    int? progress,
    int? volumeProgress,
  }) async {
    final resp = await _dio.post(
      '/pulsar/collections/${Uri.encodeComponent(collectionId)}/items',
      data: {
        if (catalogId != null && catalogId.isNotEmpty) 'catalog_id': catalogId,
        if (title != null && title.isNotEmpty) 'title': title,
        if (subtitle != null && subtitle.isNotEmpty) 'subtitle': subtitle,
        if (artworkUrl != null && artworkUrl.isNotEmpty)
          'artwork_url': artworkUrl,
        if (status != null && status.isNotEmpty) 'status': status,
        'rating': ?rating,
        if (note != null && note.isNotEmpty) 'note': note,
        'progress': ?progress,
        'volume_progress': ?volumeProgress,
      },
    );
    return PulsarCollectionItem.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<PulsarCollectionItem> updateCollectionItem(
    String collectionId,
    String itemId, {
    String? status,
    int? rating,
    String? note,
    int? progress,
    int? volumeProgress,
  }) async {
    final resp = await _dio.patch(
      '/pulsar/collections/${Uri.encodeComponent(collectionId)}/items/${Uri.encodeComponent(itemId)}',
      data: {
        'status': ?status,
        'rating': ?rating,
        'note': ?note,
        'progress': ?progress,
        'volume_progress': ?volumeProgress,
      },
    );
    return PulsarCollectionItem.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<List<PulsarCatalogItem>> searchCatalog(
    String query, {
    String? domain,
    int take = 20,
  }) async {
    final resp = await _dio.get(
      '/pulsar/catalog',
      queryParameters: {
        'q': query,
        if (domain != null && domain.isNotEmpty) 'domain': domain,
        'take': take,
      },
    );
    if (resp.data is! List) return const [];
    return [
      for (final item in resp.data as List)
        if (item is Map)
          PulsarCatalogItem.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<PulsarReview?> getMyReview(String catalogId) async {
    try {
      final resp = await _dio.get(
        '/pulsar/reviews/me',
        queryParameters: {'catalog_id': catalogId},
      );
      if (resp.data is! Map) return null;
      return PulsarReview.fromJson(Map<String, dynamic>.from(resp.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<PulsarReview> setReview(
    String catalogId, {
    int? rating,
    String? body,
  }) async {
    final resp = await _dio.put(
      '/pulsar/reviews',
      data: {
        'catalog_id': catalogId,
        'rating': ?rating,
        if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
      },
    );
    return PulsarReview.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<void> deleteReview(String reviewId) async {
    await _dio.delete('/pulsar/reviews/${Uri.encodeComponent(reviewId)}');
  }

  Future<PulsarBangumiConnection> getBangumiConnection() async {
    final resp = await _dio.get('/pulsar/bangumi/connection');
    return PulsarBangumiConnection.fromJson(
      Map<String, dynamic>.from(resp.data),
    );
  }

  Future<PulsarBangumiConnection> updateBangumiConnection({
    bool? syncEnabled,
    String? conflictPolicy,
  }) async {
    final resp = await _dio.patch(
      '/pulsar/bangumi/connection',
      data: {'sync_enabled': ?syncEnabled, 'conflict_policy': ?conflictPolicy},
    );
    return PulsarBangumiConnection.fromJson(
      Map<String, dynamic>.from(resp.data),
    );
  }

  Future<PulsarBangumiSyncResult> syncBangumiNow() async {
    final resp = await _dio.post(
      '/pulsar/bangumi/sync',
      options: Options(receiveTimeout: const Duration(minutes: 3)),
    );
    return PulsarBangumiSyncResult.fromJson(
      Map<String, dynamic>.from(resp.data),
    );
  }

  Future<List<PulsarCatalogItem>> searchMetadata(
    String query, {
    String? domain,
  }) async {
    final effectiveDomain =
        domain != null && domain.isNotEmpty && domain != PulsarDomain.custom
        ? domain
        : null;
    try {
      final resp = await _dio.get(
        '/pulsar/metadata/search',
        queryParameters: {'q': query, 'domain': ?effectiveDomain},
        options: Options(receiveTimeout: const Duration(seconds: 20)),
      );
      if (resp.data is List && (resp.data as List).isNotEmpty) {
        return [
          for (final item in resp.data as List)
            if (item is Map)
              PulsarCatalogItem.fromJson(Map<String, dynamic>.from(item)),
        ];
      }
    } on DioException {
      // Fall back to local catalog search if metadata search fails/times out.
    }

    return searchCatalog(query, domain: effectiveDomain);
  }

  Future<void> submitScrobble({
    required String domain,
    required String title,
    String? subtitle,
    String? caption,
    String? artworkUrl,
    String? catalogId,
    String? urn,
    int listenedSeconds = 0,
    int durationSeconds = 0,
    String clientName = 'Solian',
  }) async {
    const zeroUuid = '00000000-0000-0000-0000-000000000000';
    await _dio.post(
      '/pulsar/scrobbles',
      data: {
        'scrobbles': [
          {
            'domain': domain,
            'client_name': clientName,
            'title': title,
            if (subtitle != null && subtitle.isNotEmpty) 'subtitle': subtitle,
            if (caption != null && caption.isNotEmpty) 'caption': caption,
            if (artworkUrl != null && artworkUrl.isNotEmpty)
              'artwork_url': artworkUrl,
            if (catalogId != null &&
                catalogId.isNotEmpty &&
                catalogId != zeroUuid)
              'catalog_id': catalogId,
            if (urn != null && urn.isNotEmpty) 'urn': urn,
            'listened_seconds': listenedSeconds,
            'duration_seconds': durationSeconds,
          },
        ],
      },
    );
  }
}

final pulsarClientProvider = Provider<PulsarClient>((ref) {
  return PulsarClient(ref.watch(apiClientProvider));
});

final pulsarBangumiConnectionProvider =
    FutureProvider.autoDispose<PulsarBangumiConnection>((ref) async {
      return ref.watch(pulsarClientProvider).getBangumiConnection();
    });

final pulsarUserNowPlayingProvider = FutureProvider.autoDispose
    .family<List<SnPresenceActivity>, String>((ref, uname) async {
      return ref.watch(pulsarClientProvider).getUserNowPlaying(uname);
    });

final pulsarUserStatsProvider = FutureProvider.autoDispose
    .family<PulsarMediaStats?, String>((ref, uname) async {
      return ref.watch(pulsarClientProvider).getUserStats(uname);
    });

final pulsarUserHistoryProvider = FutureProvider.autoDispose
    .family<List<PulsarScrobble>, ({String uname, String? domain, int take})>((
      ref,
      arg,
    ) async {
      return ref
          .watch(pulsarClientProvider)
          .getUserHistory(arg.uname, domain: arg.domain, take: arg.take);
    });

final pulsarFavouritesProvider = FutureProvider.autoDispose
    .family<List<PulsarCollectionItem>, String>((ref, domain) async {
      return ref.watch(pulsarClientProvider).getFavourites(domain: domain);
    });

/// Loads the current user's non-favourites collections together with their items
/// so work statuses (`watching`, `plan_to_watch`, `completed`, `on_hold`,
/// `dropped`) can be viewed and edited in place.
final pulsarMyWorkCollectionsProvider =
    FutureProvider.autoDispose<List<PulsarCollection>>((ref) async {
      final client = ref.watch(pulsarClientProvider);
      final summaries = await client.listMyCollections(take: 50);
      final nonFav = summaries
          .where((c) => c.kind != PulsarCollectionKind.favorites)
          .toList();
      if (nonFav.isEmpty) return const [];
      return Future.wait(nonFav.map((c) => client.getCollection(c.id)));
    });
