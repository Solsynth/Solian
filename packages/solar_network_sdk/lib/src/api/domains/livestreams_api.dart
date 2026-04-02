import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/live/livestream.dart';

/// API for livestream-related endpoints (/livestream).
///
/// Handles livestreams, viewers, and live streaming functionality.
class LivestreamsApi extends BaseApi {
  LivestreamsApi(super.dio);

  /// Base path for all livestream endpoints.
  static const String _basePath = '/livestream';

  // ==========================================
  // Livestream endpoints
  // ==========================================

  /// Gets all active livestreams.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnLiveStream>> getActiveLivestreams({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/streams',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnLiveStream.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific livestream by ID.
  ///
  /// [streamId] - The stream ID.
  Future<SnLiveStream> getLivestream(String streamId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/streams/$streamId',
    );
    return SnLiveStream.fromJson(response.data!);
  }

  /// Creates a new livestream.
  ///
  /// [title] - The stream title.
  /// [description] - Optional description.
  /// [category] - Optional category.
  Future<SnLiveStream> createLivestream({
    required String title,
    String? description,
    String? category,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/streams',
      data: {
        'title': title,
        'description': ?description,
        'category': ?category,
      },
    );
    return SnLiveStream.fromJson(response.data!);
  }

  /// Updates a livestream.
  ///
  /// [streamId] - The stream ID.
  /// [data] - The data to update.
  Future<SnLiveStream> updateLivestream({
    required String streamId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/streams/$streamId',
      data: data,
    );
    return SnLiveStream.fromJson(response.data!);
  }

  /// Deletes a livestream.
  ///
  /// [streamId] - The stream ID.
  Future<void> deleteLivestream(String streamId) async {
    await delete('$_basePath/streams/$streamId');
  }

  /// Starts a livestream.
  ///
  /// [streamId] - The stream ID.
  Future<SnLiveStream> startLivestream(String streamId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/streams/$streamId/start',
    );
    return SnLiveStream.fromJson(response.data!);
  }

  /// Ends a livestream.
  ///
  /// [streamId] - The stream ID.
  Future<SnLiveStream> endLivestream(String streamId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/streams/$streamId/end',
    );
    return SnLiveStream.fromJson(response.data!);
  }

  // ==========================================
  // Viewer endpoints
  // ==========================================

  /// Gets viewers of a livestream.
  ///
  /// [streamId] - The stream ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<dynamic>> getViewers({
    required String streamId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/streams/$streamId/viewers',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(items: response.data ?? [], totalCount: totalCount);
  }

  /// Joins a livestream as viewer.
  ///
  /// [streamId] - The stream ID.
  Future<void> joinLivestream(String streamId) async {
    await post('$_basePath/streams/$streamId/join');
  }

  /// Leaves a livestream.
  ///
  /// [streamId] - The stream ID.
  Future<void> leaveLivestream(String streamId) async {
    await post('$_basePath/streams/$streamId/leave');
  }

  /// Gets viewer count for a livestream.
  ///
  /// [streamId] - The stream ID.
  Future<int> getViewerCount(String streamId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/streams/$streamId/viewers/count',
    );
    return response.data!['count'] as int;
  }

  // ==========================================
  // Chat endpoints
  // ==========================================

  /// Gets chat messages for a livestream.
  ///
  /// [streamId] - The stream ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getChatMessages({
    required String streamId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/streams/$streamId/chat',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Sends a chat message to a livestream.
  ///
  /// [streamId] - The stream ID.
  /// [message] - The message content.
  Future<void> sendChatMessage({
    required String streamId,
    required String message,
  }) async {
    await post('$_basePath/streams/$streamId/chat', data: {'message': message});
  }

  /// Deletes a chat message.
  ///
  /// [streamId] - The stream ID.
  /// [messageId] - The message ID.
  Future<void> deleteChatMessage({
    required String streamId,
    required String messageId,
  }) async {
    await delete('$_basePath/streams/$streamId/chat/$messageId');
  }

  /// Bans a user from chat.
  ///
  /// [streamId] - The stream ID.
  /// [accountId] - The account ID to ban.
  Future<void> banFromChat({
    required String streamId,
    required String accountId,
  }) async {
    await post('$_basePath/streams/$streamId/chat/ban/$accountId');
  }

  /// Unbans a user from chat.
  ///
  /// [streamId] - The stream ID.
  /// [accountId] - The account ID to unban.
  Future<void> unbanFromChat({
    required String streamId,
    required String accountId,
  }) async {
    await delete('$_basePath/streams/$streamId/chat/ban/$accountId');
  }

  // ==========================================
  // Stream key endpoints
  // ==========================================

  /// Gets the stream key for a livestream.
  ///
  /// [streamId] - The stream ID.
  Future<Map<String, dynamic>> getStreamKey(String streamId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/streams/$streamId/key',
    );
    return response.data!;
  }

  /// Regenerates the stream key.
  ///
  /// [streamId] - The stream ID.
  Future<Map<String, dynamic>> regenerateStreamKey(String streamId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/streams/$streamId/key/regenerate',
    );
    return response.data!;
  }

  // ==========================================
  // Category endpoints
  // ==========================================

  /// Gets all livestream categories.
  Future<List<dynamic>> getCategories() async {
    final response = await get<List<dynamic>>('$_basePath/categories');
    return response.data ?? [];
  }

  /// Gets livestreams by category.
  ///
  /// [category] - The category name.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnLiveStream>> getLivestreamsByCategory({
    required String category,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/categories/$category/streams',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnLiveStream.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets followed livestreams.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnLiveStream>> getFollowedLivestreams({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/me/following',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnLiveStream.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Follows a streamer.
  ///
  /// [accountId] - The streamer's account ID.
  Future<void> followStreamer(String accountId) async {
    await post('$_basePath/me/following/$accountId');
  }

  /// Unfollows a streamer.
  ///
  /// [accountId] - The streamer's account ID.
  Future<void> unfollowStreamer(String accountId) async {
    await delete('$_basePath/me/following/$accountId');
  }

  // ==========================================
  // Highlight endpoints
  // ==========================================

  /// Gets highlights for a livestream.
  ///
  /// [streamId] - The stream ID.
  Future<List<dynamic>> getHighlights(String streamId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/streams/$streamId/highlights',
    );
    return response.data ?? [];
  }

  /// Creates a highlight.
  ///
  /// [streamId] - The stream ID.
  /// [startTime] - The start time in seconds.
  /// [duration] - The duration in seconds.
  /// [title] - The highlight title.
  Future<Map<String, dynamic>> createHighlight({
    required String streamId,
    required int startTime,
    required int duration,
    required String title,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/streams/$streamId/highlights',
      data: {'start_time': startTime, 'duration': duration, 'title': title},
    );
    return response.data!;
  }

  /// Deletes a highlight.
  ///
  /// [streamId] - The stream ID.
  /// [highlightId] - The highlight ID.
  Future<void> deleteHighlight({
    required String streamId,
    required String highlightId,
  }) async {
    await delete('$_basePath/streams/$streamId/highlights/$highlightId');
  }
}
