import 'package:island/data/message.dart';
import 'package:logging/logging.dart';

/// LRU in-memory cache for frequently accessed messages.
/// Thread-safe for single-threaded Dart environment.
class MessageCache {
  final _logger = Logger('MessageCache');

  final int maxSize;
  final _cache = <String, LocalChatMessage>{};
  final _pendingFetches = <String, Future<LocalChatMessage?>>{};

  MessageCache({this.maxSize = 100});

  /// Gets a message from cache if present.
  LocalChatMessage? get(String messageId) {
    final message = _cache.remove(messageId);
    if (message != null) {
      // Move to end (most recently used)
      _cache[messageId] = message;
    }
    return message;
  }

  /// Puts a message into the cache.
  void put(LocalChatMessage message) {
    if (_cache.containsKey(message.id)) {
      _cache.remove(message.id);
    } else if (_cache.length >= maxSize) {
      // Remove oldest (first entry)
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
      _logger.fine('Evicted message $oldestKey from cache');
    }
    _cache[message.id] = message;
  }

  /// Puts multiple messages into the cache.
  void putAll(Iterable<LocalChatMessage> messages) {
    for (final message in messages) {
      put(message);
    }
  }

  /// Removes a message from cache.
  void remove(String messageId) {
    _cache.remove(messageId);
  }

  /// Clears the entire cache.
  void clear() {
    _cache.clear();
    _logger.info('Cache cleared');
  }

  /// Checks if a message is in the cache.
  bool contains(String messageId) => _cache.containsKey(messageId);

  /// Gets the current cache size.
  int get size => _cache.length;

  /// Gets all cached message IDs.
  Set<String> get keys => Set.unmodifiable(_cache.keys);

  /// Gets all cached messages.
  List<LocalChatMessage> get values => List.unmodifiable(_cache.values);

  // ── Pending Fetch Management ────────────────────────────────────────────

  /// Checks if there's a pending fetch for this message.
  bool hasPendingFetch(String messageId) =>
      _pendingFetches.containsKey(messageId);

  /// Gets the pending fetch future for this message.
  Future<LocalChatMessage?>? getPendingFetch(String messageId) =>
      _pendingFetches[messageId];

  /// Registers a pending fetch.
  void registerPendingFetch(
    String messageId,
    Future<LocalChatMessage?> future,
  ) {
    _pendingFetches[messageId] = future;
    future.whenComplete(() => _pendingFetches.remove(messageId));
  }

  /// Clears all pending fetches.
  void clearPendingFetches() => _pendingFetches.clear();
}

/// Cache for pending messages (outgoing messages waiting for server confirmation).
class PendingMessageCache {
  final _pending = <String, LocalChatMessage>{};
  final _uploadProgress = <String, Map<int, double?>>{};

  /// Adds a pending message.
  void add(LocalChatMessage message) {
    _pending[message.id] = message;
    _uploadProgress[message.id] = {};
  }

  /// Gets a pending message by ID.
  LocalChatMessage? get(String messageId) => _pending[messageId];

  /// Gets a pending message by client message ID.
  LocalChatMessage? getByClientId(String? clientMessageId) {
    if (clientMessageId == null) return null;
    return _pending.values
        .where((m) => m.clientMessageId == clientMessageId)
        .firstOrNull;
  }

  /// Removes a pending message.
  void remove(String messageId) {
    _pending.remove(messageId);
    _uploadProgress.remove(messageId);
  }

  /// Removes a pending message by client message ID.
  void removeByClientId(String? clientMessageId) {
    if (clientMessageId == null) return;
    final toRemove = _pending.entries
        .where((e) => e.value.clientMessageId == clientMessageId)
        .map((e) => e.key)
        .toList();
    for (final key in toRemove) {
      remove(key);
    }
  }

  /// Updates upload progress for a pending message.
  void updateProgress(String messageId, int attachmentIndex, double? progress) {
    _uploadProgress[messageId]?[attachmentIndex] = progress;
  }

  /// Gets upload progress for a pending message.
  Map<int, double?>? getProgress(String messageId) =>
      _uploadProgress[messageId];

  /// Gets all pending messages for a room.
  List<LocalChatMessage> forRoom(String roomId) =>
      _pending.values.where((m) => m.roomId == roomId).toList();

  /// Marks a pending message as failed.
  void markFailed(String messageId) {
    final message = _pending[messageId];
    if (message != null) {
      _pending[messageId] = message..status = MessageStatus.failed;
    }
  }

  /// Gets all pending message IDs.
  Set<String> get keys => Set.unmodifiable(_pending.keys);

  /// Clears all pending messages.
  void clear() {
    _pending.clear();
    _uploadProgress.clear();
  }
}
