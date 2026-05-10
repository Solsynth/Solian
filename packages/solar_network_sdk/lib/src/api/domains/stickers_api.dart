import 'package:dio/dio.dart';
import 'package:solar_network_sdk/src/api/base_api.dart';

/// API for sticker-related endpoints.
///
/// Handles stickers, sticker packs, and sticker ownership.
class StickersApi extends BaseApi {
  StickersApi(super.dio);

  /// Base path for all sticker endpoints.
  static const String _basePath = '/sphere/stickers';

  // ==========================================
  // Sticker Pack endpoints
  // ==========================================

  /// List sticker packs with pagination and filtering.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  /// [pubName] - Filter by publisher name.
  /// [order] - Ordering: 'usage' or default (created_at).
  /// [query] - Search query for pack name/description.
  Future<Response<List<dynamic>>> listStickerPacks({
    int offset = 0,
    int take = 20,
    String? pubName,
    String? order,
    String? query,
  }) async {
    return get<List<dynamic>>(
      _basePath,
      queryParameters: {
        'offset': offset,
        'take': take,
        'pub': ?pubName,
        'order': ?order,
        'query': ?query,
      },
    );
  }

  /// Get sticker packs owned by current user.
  Future<Response<List<dynamic>>> listOwnedStickerPacks() async {
    return get<List<dynamic>>('$_basePath/me');
  }

  /// Reorder owned sticker packs.
  Future<void> reorderOwnedStickerPacks({
    required List<Map<String, dynamic>> items,
  }) async {
    await patch<void>('$_basePath/me/order', data: {'items': items});
  }

  /// Get a specific sticker pack by ID.
  Future<Response<Map<String, dynamic>>> getStickerPack(String packId) async {
    return get<Map<String, dynamic>>('$_basePath/$packId');
  }

  /// Create a new sticker pack.
  ///
  /// [publisherName] - Publisher name to create the pack under.
  Future<Response<Map<String, dynamic>>> createStickerPack({
    required String publisherName,
    String? iconId,
    required String name,
    String? description,
    required String prefix,
  }) async {
    return post<Map<String, dynamic>>(
      _basePath,
      queryParameters: {'pub': publisherName},
      data: {
        'icon_id': ?iconId,
        'name': name,
        'description': ?description,
        'prefix': prefix,
      },
    );
  }

  /// Update an existing sticker pack.
  Future<Response<Map<String, dynamic>>> updateStickerPack(
    String packId, {
    String? iconId,
    String? name,
    String? description,
    String? prefix,
  }) async {
    return patch<Map<String, dynamic>>(
      '$_basePath/$packId',
      data: {
        'icon_id': ?iconId,
        'name': ?name,
        'description': ?description,
        'prefix': ?prefix,
      },
    );
  }

  /// Delete a sticker pack.
  Future<Response<void>> deleteStickerPack(String packId) async {
    return delete('$_basePath/$packId');
  }

  // ==========================================
  // Sticker endpoints
  // ==========================================

  /// List all stickers in a pack.
  Future<Response<List<dynamic>>> listStickers(String packId) async {
    return get<List<dynamic>>('$_basePath/$packId/content');
  }

  /// Lookup sticker by identifier (prefix+slug).
  Future<Response<Map<String, dynamic>>> getStickerByIdentifier(
    String identifier,
  ) async {
    return get<Map<String, dynamic>>('$_basePath/lookup/$identifier');
  }

  /// Get direct redirect URL for sticker image.
  Future<Response<Map<String, dynamic>>> openStickerByIdentifier(
    String identifier,
  ) async {
    return get<Map<String, dynamic>>('$_basePath/lookup/$identifier/open');
  }

  /// Search stickers by prefix+slug.
  Future<Response<List<dynamic>>> searchStickers({
    required String query,
    int take = 10,
    int offset = 0,
  }) async {
    return get<List<dynamic>>(
      '$_basePath/search',
      queryParameters: {'query': query, 'take': take, 'offset': offset},
    );
  }

  /// Get a specific sticker from a pack.
  Future<Response<Map<String, dynamic>>> getSticker(
    String packId,
    String stickerId,
  ) async {
    return get<Map<String, dynamic>>('$_basePath/$packId/content/$stickerId');
  }

  /// Create a new sticker in a pack.
  Future<Response<Map<String, dynamic>>> createSticker(
    String packId, {
    required String slug,
    required String imageId,
  }) async {
    return post<Map<String, dynamic>>(
      '$_basePath/$packId/content',
      data: {'slug': slug, 'image_id': imageId},
    );
  }

  /// Update an existing sticker.
  Future<Response<Map<String, dynamic>>> updateSticker(
    String packId,
    String stickerId, {
    String? slug,
    String? imageId,
  }) async {
    return patch<Map<String, dynamic>>(
      '$_basePath/$packId/content/$stickerId',
      data: {'slug': ?slug, 'image_id': ?imageId},
    );
  }

  /// Delete a sticker from a pack.
  Future<Response<void>> deleteSticker(String packId, String stickerId) async {
    return delete('$_basePath/$packId/content/$stickerId');
  }

  /// Reorder stickers within a pack.
  Future<void> reorderPackStickers({
    required String packId,
    required List<Map<String, dynamic>> items,
  }) async {
    await patch<void>(
      '$_basePath/$packId/content/order',
      data: {'items': items},
    );
  }

  // ==========================================
  // Ownership endpoints
  // ==========================================

  /// Get ownership status for a sticker pack.
  Future<Response<Map<String, dynamic>>> getStickerPackOwnership(
    String packId,
  ) async {
    return get<Map<String, dynamic>>('$_basePath/$packId/own');
  }

  /// Acquire (add to collection) a sticker pack.
  Future<Response<Map<String, dynamic>>> acquireStickerPack(
    String packId,
  ) async {
    return post<Map<String, dynamic>>('$_basePath/$packId/own');
  }

  /// Release (remove from collection) a sticker pack.
  Future<Response<void>> releaseStickerPack(String packId) async {
    return delete('$_basePath/$packId/own');
  }

  // ==========================================
  // Backward compatibility aliases
  // ==========================================

  /// @deprecated Use [listStickers] instead
  Future<List<dynamic>> getPackStickers(String packId) async {
    final response = await listStickers(packId);
    return response.data ?? [];
  }

  /// @deprecated Use [acquireStickerPack] instead
  Future<void> addPackToCollection(String packId) async {
    await acquireStickerPack(packId);
  }

  /// @deprecated Use [releaseStickerPack] instead
  Future<void> removePackFromCollection(String packId) async {
    await releaseStickerPack(packId);
  }

  /// @deprecated Use [listOwnedStickerPacks] instead
  Future<List<dynamic>> getUserPacks() async {
    final response = await listOwnedStickerPacks();
    return response.data ?? [];
  }
}
