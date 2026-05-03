import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/data/message_cache.dart';
import 'package:island/chat/data/message_repository.dart';
import 'package:island/chat/e2ee_message_service.dart';
import 'package:island/chat/models/chat_view_state.dart';
import 'package:island/data/message.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Service responsible for message synchronization and pagination.
/// Handles the complex logic of loading, caching, and merging messages.
class MessageSyncService {
  final String _roomId;
  final MessageRepository _repository;
  final MessageCache _cache;
  final PendingMessageCache _pendingCache;
  final E2eeMessageService? _e2eeService;
  final _logger = Logger('MessageSyncService');

  // Pagination state
  int _lastApiOffset = 0;
  int? _totalRemoteCount;
  bool _allRemoteFetched = false;

  MessageSyncService(
    Ref _,
    this._roomId,
    this._repository,
    this._cache,
    this._pendingCache, {
    E2eeMessageService? e2eeService,
  }) : _e2eeService = e2eeService;

  // ── State Getters ────────────────────────────────────────────────────────

  bool get allRemoteFetched => _allRemoteFetched;
  int? get totalRemoteCount => _totalRemoteCount;
  int get lastApiOffset => _lastApiOffset;

  // ── Initial Load ─────────────────────────────────────────────────────────

  /// Loads initial messages with smart caching strategy.
  Future<List<LocalChatMessage>> loadInitial({
    required bool forceRemote,
    required MessageFilter filter,
  }) async {
    _logger.info('Loading initial messages (forceRemote: $forceRemote)');

    // Reset pagination state
    _lastApiOffset = 0;
    _allRemoteFetched = false;
    _totalRemoteCount = null;

    // Try cache first
    final cached = await _loadFromCache(
      offset: 0,
      limit: PaginationConfig.pageSize,
      filter: filter,
    );

    final shouldFetchRemote = forceRemote ||
        cached.isEmpty ||
        (cached.length < PaginationConfig.pageSize && !filter.hasSearch);

    if (!shouldFetchRemote) {
      _logger.info('Using cached messages (${cached.length})');
      return cached;
    }

    try {
      // Fetch from remote
      final remoteMessages = await _fetchAndCacheRemote(
        offset: 0,
        limit: PaginationConfig.initialFetchSize,
      );

      if (kIsWeb) {
        // On web, return remote directly without DB roundtrip
        return _applyFilters(remoteMessages, filter);
      }

      // Re-fetch from cache to get merged result
      final merged = await _loadFromCache(
        offset: 0,
        limit: PaginationConfig.pageSize,
        filter: filter,
      );

      _logger.info(
        'Initial load complete: ${merged.length} messages, hasMore: ${_computeHasMore(merged.length)}',
      );
      return merged;
    } catch (e) {
      _logger.warning('Remote fetch failed, using cache: $e');
      return cached;
    }
  }

  /// Eagerly prefetches more messages if the initial load is too short.
  Future<List<LocalChatMessage>> eagerPrefetchIfNeeded(
    List<LocalChatMessage> current, {
    required MessageFilter filter,
  }) async {
    if (current.length >= PaginationConfig.eagerPrefetchThreshold) {
      return current;
    }
    if (_allRemoteFetched) return current;

    var combined = List<LocalChatMessage>.from(current);
    var passes = 0;

    while (_computeHasMore(combined.length) &&
        combined.length < PaginationConfig.eagerPrefetchThreshold &&
        passes < PaginationConfig.maxEagerPrefetchPasses) {
      final remaining = PaginationConfig.eagerPrefetchThreshold - combined.length;
      final take = remaining.clamp(
        PaginationConfig.pageSize,
        PaginationConfig.batchSize,
      );

      _logger.info(
        'Eager prefetch pass $passes: loading $take more messages',
      );

      final more = await loadMore(
        currentCount: combined.length,
        take: take,
        filter: filter,
      );

      if (more.isEmpty) break;

      final beforeCount = combined.length;
      combined = _mergeAndDedupe([...combined, ...more]);

      // Stop if no new unique messages were added
      if (combined.length == beforeCount) {
        _allRemoteFetched = true;
        break;
      }

      passes++;
    }

    _logger.info('Eager prefetch complete: ${combined.length} messages');
    return combined;
  }

  // ── Pagination ───────────────────────────────────────────────────────────

  /// Loads more messages for pagination.
  Future<List<LocalChatMessage>> loadMore({
    required int currentCount,
    required int take,
    required MessageFilter filter,
  }) async {
    _logger.info('Loading more messages: offset=$currentCount, take=$take');

    // Try local cache first
    final localMessages = await _loadFromCache(
      offset: currentCount,
      limit: take,
      filter: filter,
    );

    // If we have enough local messages and no search filter, return them
    if (localMessages.length >= take || filter.hasSearch) {
      return localMessages;
    }

    // If all remote messages are fetched, return what we have
    if (_allRemoteFetched) {
      return localMessages;
    }

    // Fetch more from remote
    final remoteMessages = await _fetchAndCacheRemote(
      offset: _lastApiOffset,
      limit: PaginationConfig.batchSize,
    );

    if (remoteMessages.isEmpty) {
      return localMessages;
    }

    // Re-fetch from cache to get merged result
    return _loadFromCache(
      offset: currentCount,
      limit: take,
      filter: filter,
    );
  }

  // ── Jump to Message ──────────────────────────────────────────────────────

  /// Loads messages around a specific message for jump-to functionality.
  Future<JumpResult> loadAroundMessage(
    String messageId, {
    required int chunkSize,
  }) async {
    _logger.info('Loading messages around $messageId');

    // Try to find the message
    var message = await _repository.getLocalMessage(messageId);

    // If not in local DB, fetch from remote
    if (message == null) {
      final remoteMessage = await _repository.fetchRemoteMessage(messageId);
      if (remoteMessage == null) {
        return JumpResult.notFound();
      }

      // Decrypt if needed
      final decrypted = await _decryptIfNeeded(remoteMessage);
      if (decrypted == null) {
        return JumpResult.notFound();
      }

      message = LocalChatMessage.fromRemoteMessage(decrypted, MessageStatus.sent);
      await _repository.saveMessage(message);
    }

    // Calculate offset to center the target message
    final newerCount = await _repository.countMessagesNewerThan(message.createdAt);
    final offset = (newerCount - chunkSize ~/ 2).clamp(0, double.infinity).toInt();

    // Load messages around the target
    final surroundingMessages = await _loadFromCache(
      offset: offset,
      limit: chunkSize,
      filter: const MessageFilter(),
    );

    // Ensure target message is included
    final hasTarget = surroundingMessages.any((m) => m.id == messageId);
    final allMessages = hasTarget
        ? surroundingMessages
        : _mergeAndDedupe([message, ...surroundingMessages]);

    // Find the index of the target message in the result
    final targetIndex = allMessages.indexWhere((m) => m.id == messageId);

    return JumpResult(
      messages: allMessages,
      targetIndex: targetIndex,
      targetMessage: message,
    );
  }

  // ── Message Processing ───────────────────────────────────────────────────

  /// Processes incoming remote messages: decrypt, cache, save to DB.
  Future<List<LocalChatMessage>> processRemoteMessages(
    List<SnChatMessage> remoteMessages,
  ) async {
    final localMessages = <LocalChatMessage>[];
    final toBatchSave = <LocalChatMessage>[];

    for (final remote in remoteMessages) {
      // Check for existing
      final existing = await _repository.getLocalMessage(remote.id);
      if (existing != null &&
          existing.content?.isNotEmpty == true &&
          !_needsAttachmentRefresh(existing, remote)) {
        localMessages.add(existing);
        continue;
      }

      // Decrypt if needed
      final decrypted = await _decryptIfNeeded(remote);
      if (decrypted == null) continue;

      // Preserve plaintext for own messages
      final pending = _pendingCache.getByClientId(remote.clientMessageId);
      final withPlaintext = E2eeMessageService.preserveSenderPlaintext(
        decrypted,
        existingDbContent: existing?.content,
        pendingContent: pending?.content,
      );

      var local = LocalChatMessage.fromRemoteMessage(withPlaintext, MessageStatus.sent);

      // Merge with existing data if available
      if (existing != null) {
        local = _mergeMessageData(local, existing);
      }

      localMessages.add(local);
      toBatchSave.add(local);

      // Prefetch voice media
      if (remote.type == 'voice') {
        final voiceUrl = _resolveVoiceUrl(remote.meta);
        if (voiceUrl != null) {
          unawaited(_repository.prefetchVoiceMedia(voiceUrl));
        }
      }
    }

    // Batch save to database
    if (toBatchSave.isNotEmpty) {
      await _repository.saveMessages(toBatchSave);
    }

    // Remove processed pending messages
    for (final msg in remoteMessages) {
      if (msg.clientMessageId != null) {
        _pendingCache.removeByClientId(msg.clientMessageId);
      }
    }

    return localMessages;
  }

  // ── Private Helpers ──────────────────────────────────────────────────────

  Future<List<LocalChatMessage>> _loadFromCache({
    required int offset,
    required int limit,
    required MessageFilter filter,
  }) async {
    // Get from local DB
    var messages = await _repository.getLocalMessages(
      offset: offset,
      limit: limit,
    );
    _cache.putAll(messages);

    // Merge with pending messages if at the top
    if (offset == 0) {
      final pending = _pendingCache.forRoom(_roomId);
      messages = _mergeAndDedupe([...pending, ...messages]);
    }

    // Apply filters
    return _applyFilters(messages, filter);
  }

  Future<List<LocalChatMessage>> _fetchAndCacheRemote({
    required int offset,
    required int limit,
  }) async {
    final result = await _repository.fetchRemoteMessages(
      offset: offset,
      limit: limit,
      e2eeService: _e2eeService,
    );

    _totalRemoteCount = result.totalCount;
    _allRemoteFetched = !result.hasMore;
    _lastApiOffset = offset + result.messages.length;

    // Process and cache messages
    return processRemoteMessages(result.messages);
  }

  List<LocalChatMessage> _applyFilters(
    List<LocalChatMessage> messages,
    MessageFilter filter,
  ) {
    var result = messages;

    // Apply search filter
    if (filter.searchQuery?.isNotEmpty == true) {
      // Search is handled by repository for local DB
      // This is for in-memory filtering
    }

    // Apply link filter
    if (filter.withLinks == true) {
      result = result.where(_hasLink).toList();
    }

    // Apply attachment filter
    if (filter.withAttachments == true) {
      result = result.where((m) => m.attachments.isNotEmpty).toList();
    }

    return result;
  }

  List<LocalChatMessage> _mergeAndDedupe(List<LocalChatMessage> messages) {
    // Sort by createdAt descending
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Remove duplicates (keep first occurrence)
    final seen = <String>{};
    return messages.where((m) => seen.add(m.id)).toList();
  }

  LocalChatMessage _mergeMessageData(
    LocalChatMessage incoming,
    LocalChatMessage existing,
  ) {
    // Preserve certain fields from existing message
    final mergedData = Map<String, dynamic>.from(incoming.data);
    for (final key in const ['sender', 'reactions_count', 'reactions_made']) {
      if (!mergedData.containsKey(key) && existing.data.containsKey(key)) {
        mergedData[key] = existing.data[key];
      }
    }

    // Rebuild with merged data
    return LocalChatMessage(
      id: incoming.id,
      roomId: incoming.roomId,
      senderId: incoming.senderId,
      sender: incoming.sender ?? existing.sender,
      data: mergedData,
      createdAt: incoming.createdAt,
      status: incoming.status,
      clientMessageId: incoming.clientMessageId,
      nonce: incoming.nonce,
      content: incoming.content ?? existing.content,
      isDeleted: incoming.isDeleted ?? existing.isDeleted,
      updatedAt: incoming.updatedAt ?? existing.updatedAt,
      deletedAt: incoming.deletedAt ?? existing.deletedAt,
      type: incoming.type,
      meta: incoming.meta,
      membersMentioned: incoming.membersMentioned,
      editedAt: incoming.editedAt ?? existing.editedAt,
      attachments: incoming.attachments.isEmpty && existing.attachments.isNotEmpty
          ? existing.attachments
          : incoming.attachments,
      reactions: incoming.reactions,
      repliedMessageId: incoming.repliedMessageId,
      forwardedMessageId: incoming.forwardedMessageId,
      localAttachments: incoming.localAttachments ?? existing.localAttachments,
    );
  }

  Future<SnChatMessage?> _decryptIfNeeded(SnChatMessage message) async {
    return message;
  }

  bool _needsAttachmentRefresh(LocalChatMessage existing, SnChatMessage remote) {
    return existing.attachments.isEmpty && remote.attachments.isNotEmpty;
  }

  bool _hasLink(LocalChatMessage message) {
    final content = message.content;
    if (content == null) return false;
    return RegExp(r'https?://[^\s/$.?#].[^\s]*').hasMatch(content);
  }

  String? _resolveVoiceUrl(Map<String, dynamic> meta) {
    final rawUrl = meta['voice_url']?.toString();
    if (rawUrl == null || rawUrl.isEmpty) return null;
    if (rawUrl.startsWith('http')) return rawUrl;
    // Relative URL - would need server URL from ref
    return null;
  }

  bool _computeHasMore(int loadedCount) {
    if (_allRemoteFetched) return false;
    if (_totalRemoteCount != null) {
      return loadedCount < _totalRemoteCount!;
    }
    return true;
  }
}

/// Result of a jump-to-message operation.
class JumpResult {
  final List<LocalChatMessage> messages;
  final int targetIndex;
  final LocalChatMessage? targetMessage;
  final bool found;

  const JumpResult({
    required this.messages,
    required this.targetIndex,
    this.targetMessage,
    this.found = true,
  });

  factory JumpResult.notFound() => const JumpResult(
        messages: [],
        targetIndex: -1,
        found: false,
      );
}
