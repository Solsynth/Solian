import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:logging/logging.dart';

import 'package:solar_network_sdk/solar_network_sdk.dart';

final realtimePostsProvider = Provider<RealtimePostsHandler>((ref) {
  return RealtimePostsHandler(ref);
});

class RealtimePostsHandler {
  final Ref _ref;
  StreamSubscription? _subscription;
  final Set<String> _processedPostIds = {};

  RealtimePostsHandler(this._ref);

  void startListening() {
    final ws = _ref.read(websocketProvider);
    _subscription?.cancel();
    _subscription = ws.dataStream.listen(_handlePacket);
    Logger.root.info('[RealtimePosts] Started listening to WebSocket');
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    Logger.root.info('[RealtimePosts] Stopped listening to WebSocket');
  }

  void _handlePacket(WebSocketPacket packet) {
    if (packet.type == 'post.created') {
      _handlePostCreated(packet);
    } else if (packet.type == 'post.updated') {
      _handlePostUpdated(packet);
    } else if (packet.type == 'post.deleted') {
      _handlePostDeleted(packet);
    } else if (packet.type == 'post.reaction.added') {
      _handleReactionAdded(packet);
    } else if (packet.type == 'post.reaction.removed') {
      _handleReactionRemoved(packet);
    }
  }

  void _handlePostCreated(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final post = SnPost.fromJson(packet.data!);

      // A chained child never surfaces standalone: it attaches under its
      // chain head (flat chains point straight at the head). The head's card
      // already in lists carries stale data without children, so refetch the
      // head and push an update — the child then appears under it in place.
      if (post.chainedPostId != null) {
        Logger.root.info(
          '[RealtimePosts] Chained post created: ${post.id} under ${post.chainedPostId}',
        );
        unawaited(_refreshChainHead(post.chainedPostId!));
        return;
      }

      if (_processedPostIds.contains(post.id)) {
        Logger.root.info(
          '[RealtimePosts] Skipping duplicate post.created: ${post.id}',
        );
        return;
      }
      _processedPostIds.add(post.id);

      Logger.root.info(
        '[RealtimePosts] Post created: ${post.id} - ${post.title ?? "Untitled"}',
      );

      // Broadcast event for other parts of the app to handle
      eventBus.fire(PostCreatedEvent(post));

      // Invalidate post lists to fetch fresh data
      _ref.invalidate(postListProvider(const PostListQueryConfig(id: 'home')));
    } catch (e) {
      Logger.root.severe('[RealtimePosts] Failed to parse post.created: $e');
    }
  }

  /// Refetches a chain head after one of its children is created, so cards
  /// already in lists gain the new child (children are hydrated server-side
  /// on GET by id). The update is a no-op where the head is not listed.
  Future<void> _refreshChainHead(String headId) async {
    try {
      final client = _ref.read(solarNetworkClientProvider);
      final head = await client.sphere.getPost(headId);
      Logger.root.info(
        '[RealtimePosts] Chain head refreshed: $headId (${head.chainedCount} children)',
      );
      eventBus.fire(PostUpdateEvent(head));
    } catch (e) {
      Logger.root.warning(
        '[RealtimePosts] Failed to refresh chain head $headId: $e',
      );
    }
  }

  void _handlePostUpdated(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final post = SnPost.fromJson(packet.data!);

      Logger.root.info('[RealtimePosts] Post updated: ${post.id}');

      // Broadcast event for other parts of the app to handle
      eventBus.fire(PostUpdateEvent(post));

      // Invalidate post lists to fetch fresh data
      _ref.invalidate(postListProvider(const PostListQueryConfig(id: 'home')));
    } catch (e) {
      Logger.root.severe('[RealtimePosts] Failed to parse post.updated: $e');
    }
  }

  void _handlePostDeleted(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final post = SnPost.fromJson(packet.data!);

      Logger.root.info('[RealtimePosts] Post deleted: ${post.id}');

      // Broadcast event for other parts of the app to handle
      eventBus.fire(PostDeleteEvent(post.id));

      // Invalidate post lists to fetch fresh data
      _ref.invalidate(postListProvider(const PostListQueryConfig(id: 'home')));
    } catch (e) {
      Logger.root.severe('[RealtimePosts] Failed to parse post.deleted: $e');
    }
  }

  void _handleReactionAdded(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final reaction = SnPostReaction.fromJson(packet.data!);

      Logger.root.info(
        '[RealtimePosts] Reaction added: ${reaction.symbol} on post ${reaction.postId}',
      );

      // Broadcast event for other parts of the app to handle
      eventBus.fire(
        PostReactionUpdateEvent(
          reaction: reaction,
          action: ReactionAction.added,
        ),
      );
    } catch (e) {
      Logger.root.severe(
        '[RealtimePosts] Failed to parse post.reaction.added: $e',
      );
    }
  }

  void _handleReactionRemoved(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final reaction = SnPostReaction.fromJson(packet.data!);

      Logger.root.info(
        '[RealtimePosts] Reaction removed: ${reaction.symbol} from post ${reaction.postId}',
      );

      // Broadcast event for other parts of the app to handle
      eventBus.fire(
        PostReactionUpdateEvent(
          reaction: reaction,
          action: ReactionAction.removed,
        ),
      );
    } catch (e) {
      Logger.root.severe(
        '[RealtimePosts] Failed to parse post.reaction.removed: $e',
      );
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
