import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_view_state.freezed.dart';

/// Unified loading phase for the chat view.
/// Replaces multiple boolean flags with a single source of truth.
enum ChatLoadingPhase {
  /// Initial state, nothing loaded yet
  idle,

  /// Loading initial messages
  initial,

  /// Initial load complete, ready for interaction
  ready,

  /// Loading more messages (pagination)
  loadingMore,

  /// Syncing with server in background
  syncing,

  /// Jumping to a specific message
  jumping,

  /// Error state
  error,
}

/// Represents the result of a message operation.
@freezed
class MessageOperationResult with _$MessageOperationResult {
  const factory MessageOperationResult.success() = _Success;
  const factory MessageOperationResult.failure(String error) = _Failure;
}

/// Filter options for message queries.
@freezed
abstract class MessageFilter with _$MessageFilter {
  const factory MessageFilter({
    String? searchQuery,
    bool? withLinks,
    bool? withAttachments,
  }) = _MessageFilter;

  const MessageFilter._();

  bool get isEmpty =>
      searchQuery?.isEmpty != false &&
      withLinks != true &&
      withAttachments != true;

  bool get hasSearch => searchQuery?.isNotEmpty == true;
}

/// Pagination state for the message list.
@freezed
abstract class PaginationState with _$PaginationState {
  const factory PaginationState({
    @Default(0) int loadedCount,
    @Default(true) bool hasMore,
    @Default(0) int totalCount,
    @Default(false) bool allRemoteFetched,
  }) = _PaginationState;
}

/// Represents a pending operation that can be awaited.
class PendingOperation<T> {
  final Future<T> future;
  final DateTime startedAt;

  PendingOperation(this.future) : startedAt = DateTime.now();

  bool get isStale =>
      DateTime.now().difference(startedAt) > const Duration(minutes: 2);
}

/// Configuration for pagination.
class PaginationConfig {
  static const int pageSize = 20;
  static const int initialFetchSize = 60;
  static const int batchSize = 100;
  static const int maxCacheSize = 100;
  static const int eagerPrefetchThreshold = 60;
  static const int maxEagerPrefetchPasses = 3;
}

/// Event types that affect message display.
class SystemEventTypes {
  static bool isSystemEvent(String type) {
    if (type.startsWith('system.')) return true;
    return switch (type) {
      'messages.update' ||
      'messages.sync.finalize' ||
      'messages.sync.links' ||
      'messages.delete' ||
      'messages.reaction.added' ||
      'messages.reaction.removed' =>
        true,
      _ => false,
    };
  }

  static bool isImportantEvent(String type) => switch (type) {
        'call.start' ||
        'call.ended' ||
        'messages.update' ||
        'messages.sync.finalize' ||
        'messages.sync.links' ||
        'messages.delete' ||
        'system.e2ee.enabled' ||
        'system.call.member.joined' ||
        'system.call.member.left' =>
          true,
        _ => false,
      };
}
