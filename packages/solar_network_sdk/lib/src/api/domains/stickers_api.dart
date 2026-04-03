import 'package:solar_network_sdk/src/api/base_api.dart';

/// API for sticker-related endpoints (/sticker).
///
/// Handles stickers, sticker packs, and sticker marketplace.
class StickersApi extends BaseApi {
  StickersApi(super.dio);

  /// Base path for all sticker endpoints.
  static const String _basePath = '/sphere';

  // ==========================================
  // Sticker endpoints
  // ==========================================

  /// Gets all stickers.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getStickers({int offset = 0, int take = 50}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/stickers',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Gets a specific sticker by ID.
  ///
  /// [stickerId] - The sticker ID.
  Future<Map<String, dynamic>> getSticker(String stickerId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/stickers/$stickerId',
    );
    return response.data!;
  }

  /// Creates a new sticker.
  ///
  /// [name] - The sticker name.
  /// [packId] - The pack ID.
  /// [imageData] - The image data (base64 or URL).
  Future<Map<String, dynamic>> createSticker({
    required String name,
    required String packId,
    required String imageData,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/stickers',
      data: {'name': name, 'pack_id': packId, 'image_data': imageData},
    );
    return response.data!;
  }

  /// Deletes a sticker.
  ///
  /// [stickerId] - The sticker ID.
  Future<void> deleteSticker(String stickerId) async {
    await delete('$_basePath/stickers/$stickerId');
  }

  // ==========================================
  // Pack endpoints
  // ==========================================

  /// Gets all sticker packs.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getPacks({int offset = 0, int take = 20}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/packs',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Gets a specific sticker pack by ID.
  ///
  /// [packId] - The pack ID.
  Future<Map<String, dynamic>> getPack(String packId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/packs/$packId',
    );
    return response.data!;
  }

  /// Creates a new sticker pack.
  ///
  /// [name] - The pack name.
  /// [description] - Optional description.
  Future<Map<String, dynamic>> createPack({
    required String name,
    String? description,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/packs',
      data: {'name': name, 'description': ?description},
    );
    return response.data!;
  }

  /// Updates a sticker pack.
  ///
  /// [packId] - The pack ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updatePack({
    required String packId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/packs/$packId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes a sticker pack.
  ///
  /// [packId] - The pack ID.
  Future<void> deletePack(String packId) async {
    await delete('$_basePath/packs/$packId');
  }

  /// Gets stickers in a pack.
  ///
  /// [packId] - The pack ID.
  Future<List<dynamic>> getPackStickers(String packId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/packs/$packId/stickers',
    );
    return response.data ?? [];
  }

  // ==========================================
  // Marketplace endpoints
  // ==========================================

  /// Gets featured sticker packs.
  Future<List<dynamic>> getFeaturedPacks() async {
    final response = await get<List<dynamic>>(
      '$_basePath/marketplace/featured',
    );
    return response.data ?? [];
  }

  /// Gets trending sticker packs.
  ///
  /// [limit] - Number of packs to return.
  Future<List<dynamic>> getTrendingPacks({int limit = 10}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/marketplace/trending',
      queryParameters: {'limit': limit},
    );
    return response.data ?? [];
  }

  /// Searches sticker packs.
  ///
  /// [query] - The search query.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> searchPacks({
    required String query,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/marketplace/search',
      queryParameters: {'q': query, 'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Gets a pack's preview.
  ///
  /// [packId] - The pack ID.
  Future<Map<String, dynamic>> getPackPreview(String packId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/marketplace/packs/$packId/preview',
    );
    return response.data!;
  }

  // ==========================================
  // User sticker endpoints
  // ==========================================

  /// Gets user's sticker collection.
  Future<List<dynamic>> getUserStickers() async {
    final response = await get<List<dynamic>>('$_basePath/me/stickers');
    return response.data ?? [];
  }

  /// Gets user's sticker packs.
  Future<List<dynamic>> getUserPacks() async {
    final response = await get<List<dynamic>>('$_basePath/me/packs');
    return response.data ?? [];
  }

  /// Adds a pack to user's collection.
  ///
  /// [packId] - The pack ID.
  Future<void> addPackToCollection(String packId) async {
    await post('$_basePath/me/packs/$packId');
  }

  /// Removes a pack from user's collection.
  ///
  /// [packId] - The pack ID.
  Future<void> removePackFromCollection(String packId) async {
    await delete('$_basePath/me/packs/$packId');
  }

  /// Sets favorite stickers.
  ///
  /// [stickerIds] - List of sticker IDs.
  Future<void> setFavorites(List<String> stickerIds) async {
    await put('$_basePath/me/favorites', data: {'sticker_ids': stickerIds});
  }

  /// Gets favorite stickers.
  Future<List<dynamic>> getFavorites() async {
    final response = await get<List<dynamic>>('$_basePath/me/favorites');
    return response.data ?? [];
  }

  // ==========================================
  // Category endpoints
  // ==========================================

  /// Gets all sticker categories.
  Future<List<dynamic>> getCategories() async {
    final response = await get<List<dynamic>>('$_basePath/categories');
    return response.data ?? [];
  }

  /// Gets stickers by category.
  ///
  /// [categoryId] - The category ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getStickersByCategory({
    required String categoryId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/categories/$categoryId/stickers',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Reports a sticker.
  ///
  /// [stickerId] - The sticker ID.
  /// [reason] - The report reason.
  Future<void> reportSticker({
    required String stickerId,
    required String reason,
  }) async {
    await post(
      '$_basePath/stickers/$stickerId/report',
      data: {'reason': reason},
    );
  }
}
