import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/data/message_cache.dart';
import 'package:island/chat/e2ee_message_service.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/data/database.dart';
import 'package:island/data/message.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Repository for message data operations.
/// Abstracts database and API interactions.
class MessageRepository {
  final Ref _ref;
  final String _roomId;
  final _logger = Logger('MessageRepository');

  late final Dio _apiClient = _ref.read(apiClientProvider);
  late final AppDatabase _database = _ref.read(databaseProvider);

  final MessageCache _messageCache;

  MessageRepository(this._ref, this._roomId, this._messageCache);

  // ── Local Database Operations ───────────────────────────────────────────

  /// Gets messages from local database.
  Future<List<LocalChatMessage>> getLocalMessages({
    required int offset,
    required int limit,
  }) async {
    return _database.getMessagesForRoom(
      _roomId,
      offset: offset,
      limit: limit,
    );
  }

  /// Gets a single message from local database.
  Future<LocalChatMessage?> getLocalMessage(String messageId) async {
    // Check cache first
    final cached = _messageCache.get(messageId);
    if (cached != null) return cached;

    final message = await _database.getMessageById(messageId);
    if (message != null) {
      _messageCache.put(message);
    }
    return message;
  }

  /// Searches messages in local database.
  Future<List<LocalChatMessage>> searchMessages(
    String query, {
    bool? withAttachments,
    required Future<SnAccount?> Function(String) fetchAccount,
  }) async {
    return _database.searchMessages(
      _roomId,
      query,
      withAttachments: withAttachments,
      fetchAccount: fetchAccount,
    );
  }

  /// Saves a message to local database.
  Future<void> saveMessage(LocalChatMessage message) async {
    await _database.saveMessageWithSender(message);
    _messageCache.put(message);
  }

  /// Saves multiple messages in a batch.
  Future<void> saveMessages(List<LocalChatMessage> messages) async {
    if (messages.isEmpty) return;

    try {
      await _database.saveMessagesWithSenders(messages);
      _messageCache.putAll(messages);
      _logger.info('Batch saved ${messages.length} messages');
    } catch (e) {
      _logger.warning('Batch save failed, falling back to individual: $e');
      // Fallback to individual saves
      for (final message in messages) {
        try {
          await _database.saveMessageWithSender(message);
          _messageCache.put(message);
        } catch (e) {
          _logger.warning('Failed to save message ${message.id}: $e');
        }
      }
    }
  }

  /// Updates message status.
  Future<void> updateStatus(String messageId, MessageStatus status) async {
    await _database.updateMessageStatus(messageId, status);
    // Update cache if present
    final cached = _messageCache.get(messageId);
    if (cached != null) {
      _messageCache.put(cached..status = status);
    }
  }

  /// Deletes a message.
  Future<void> deleteMessage(String messageId) async {
    await _database.deleteMessage(messageId);
    _messageCache.remove(messageId);
  }

  /// Deletes all messages for this room.
  Future<void> deleteAllMessages() async {
    await _database.deleteMessagesForRoom(_roomId);
    // Clear only cached messages for this room
    final toRemove = _messageCache.values
        .where((m) => m.roomId == _roomId)
        .map((m) => m.id)
        .toList();
    for (final id in toRemove) {
      _messageCache.remove(id);
    }
  }

  /// Counts messages newer than a timestamp.
  Future<int> countMessagesNewerThan(DateTime timestamp) async {
    return _database.countMessagesNewerThan(_roomId, timestamp);
  }

  /// Gets total message count.
  Future<int> getTotalCount() async {
    return _database.getTotalMessagesForRoom(_roomId);
  }

  // ── Remote API Operations ───────────────────────────────────────────────

  /// Fetches messages from the API.
  Future<FetchMessagesResult> fetchRemoteMessages({
    required int offset,
    required int limit,
    E2eeMessageService? e2eeService,
  }) async {
    final response = await _apiClient.get(
      '/messager/chat/$_roomId/messages',
      queryParameters: {'offset': offset, 'take': limit},
    );

    final totalCount =
        int.parse(response.headers['x-total']?.firstOrNull ?? '0');

    if (offset >= totalCount) {
      return FetchMessagesResult(
        messages: [],
        totalCount: totalCount,
        hasMore: false,
      );
    }

    final data = response.data as List<dynamic>;
    final messages = <SnChatMessage>[];

    for (final json in data) {
      final message = _tryParseMessage(json);
      if (message != null) {
        messages.add(message);
      }
    }

    final hasMore = offset + messages.length < totalCount;

    return FetchMessagesResult(
      messages: messages,
      totalCount: totalCount,
      hasMore: hasMore,
    );
  }

  /// Fetches a single message from the API.
  Future<SnChatMessage?> fetchRemoteMessage(String messageId) async {
    try {
      final response = await _apiClient.get(
        '/messager/chat/$_roomId/messages/$messageId',
      );
      return _tryParseMessage(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Sends a new message.
  Future<SnChatMessage> sendMessage(
    Map<String, dynamic> payload, {
    Options? options,
  }) async {
    final response = await _apiClient.post(
      '/messager/chat/$_roomId/messages',
      data: payload,
      options: options,
    );
    final message = _tryParseMessage(response.data);
    if (message == null) {
      throw Exception('Invalid chat message response');
    }
    return message;
  }

  /// Edits an existing message.
  Future<SnChatMessage> editMessage(
    String messageId,
    Map<String, dynamic> payload, {
    Options? options,
  }) async {
    final response = await _apiClient.patch(
      '/messager/chat/$_roomId/messages/$messageId',
      data: payload,
      options: options,
    );
    final message = _tryParseMessage(response.data);
    if (message == null) {
      throw Exception('Invalid chat message response');
    }
    return message;
  }

  /// Deletes a message on the server.
  Future<SnChatMessage?> deleteRemoteMessage(
    String messageId, {
    Options? options,
  }) async {
    final response = await _apiClient.delete(
      '/messager/chat/$_roomId/messages/$messageId',
      options: options,
    );
    return _tryParseMessage(response.data);
  }

  // ── Utility Methods ─────────────────────────────────────────────────────

  SnChatMessage? _tryParseMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMessage.fromJson(
        E2eeMessageService.sanitizeChatMessageJson(data),
      );
    } catch (e) {
      _logger.warning('Failed to parse message: $e');
      return null;
    }
  }

  // ── Voice Media Prefetching ─────────────────────────────────────────────

  final _prefetchedVoiceUrls = <String>{};

  Future<void> prefetchVoiceMedia(
    String? mediaUrl, {
    String? authToken,
  }) async {
    if (mediaUrl == null || mediaUrl.isEmpty) return;
    if (!_prefetchedVoiceUrls.add(mediaUrl)) return;

    final headers = authToken == null
        ? null
        : <String, String>{'Authorization': 'Bearer $authToken'};

    final cache = DefaultCacheManager();
    try {
      final cached = await cache.getFileFromCache(mediaUrl);
      if (cached != null) return;
      unawaited(cache.downloadFile(mediaUrl, authHeaders: headers));
    } catch (e) {
      _prefetchedVoiceUrls.remove(mediaUrl);
      _logger.warning('Failed to prefetch voice media: $e');
    }
  }

  void clearVoicePrefetchCache() => _prefetchedVoiceUrls.clear();
}

/// Result of fetching messages from remote.
class FetchMessagesResult {
  final List<SnChatMessage> messages;
  final int totalCount;
  final bool hasMore;

  const FetchMessagesResult({
    required this.messages,
    required this.totalCount,
    required this.hasMore,
  });
}
