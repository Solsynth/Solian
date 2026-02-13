import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:island/talker.dart';
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
    talker.info('[RealtimePosts] Started listening to WebSocket');
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    talker.info('[RealtimePosts] Stopped listening to WebSocket');
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

      if (_processedPostIds.contains(post.id)) {
        talker.info(
          '[RealtimePosts] Skipping duplicate post.created: ${post.id}',
        );
        return;
      }
      _processedPostIds.add(post.id);

      talker.info(
        '[RealtimePosts] Post created: ${post.id} - ${post.title ?? "Untitled"}',
      );

      _addPostToTimeline(post);
      _addPostToPostLists(post);
    } catch (e) {
      talker.error('[RealtimePosts] Failed to parse post.created: $e');
    }
  }

  void _handlePostUpdated(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final post = SnPost.fromJson(packet.data!);

      talker.info('[RealtimePosts] Post updated: ${post.id}');

      _updatePostInTimeline(post);
      _updatePostInPostLists(post);
    } catch (e) {
      talker.error('[RealtimePosts] Failed to parse post.updated: $e');
    }
  }

  void _handlePostDeleted(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final post = SnPost.fromJson(packet.data!);

      talker.info('[RealtimePosts] Post deleted: ${post.id}');

      _removePostFromTimeline(post.id);
      _removePostFromPostLists(post.id);
    } catch (e) {
      talker.error('[RealtimePosts] Failed to parse post.deleted: $e');
    }
  }

  void _handleReactionAdded(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final reaction = SnPostReaction.fromJson(packet.data!);

      talker.info(
        '[RealtimePosts] Reaction added: ${reaction.symbol} on post ${reaction.postId}',
      );

      _updateReactionInTimeline(reaction.postId, reaction.symbol, 1);
      _updateReactionInPostLists(reaction.postId, reaction.symbol, 1);
    } catch (e) {
      talker.error('[RealtimePosts] Failed to parse post.reaction.added: $e');
    }
  }

  void _handleReactionRemoved(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final reaction = SnPostReaction.fromJson(packet.data!);

      talker.info(
        '[RealtimePosts] Reaction removed: ${reaction.symbol} from post ${reaction.postId}',
      );

      _updateReactionInTimeline(reaction.postId, reaction.symbol, -1);
      _updateReactionInPostLists(reaction.postId, reaction.symbol, -1);
    } catch (e) {
      talker.error('[RealtimePosts] Failed to parse post.reaction.removed: $e');
    }
  }

  void _addPostToTimeline(SnPost post) {
    try {
      _ref.read(activityListProvider.notifier).addPost(post);
    } catch (e) {
      talker.error('[RealtimePosts] Failed to add post to timeline: $e');
    }
  }

  void _updatePostInTimeline(SnPost post) {
    try {
      _ref.read(activityListProvider.notifier).updatePostById(post);
    } catch (e) {
      talker.error('[RealtimePosts] Failed to update post in timeline: $e');
    }
  }

  void _removePostFromTimeline(String postId) {
    try {
      _ref.read(activityListProvider.notifier).removePost(postId);
    } catch (e) {
      talker.error('[RealtimePosts] Failed to remove post from timeline: $e');
    }
  }

  void _addPostToPostLists(SnPost post) {
    try {
      _ref.invalidate(postListProvider(const PostListQueryConfig(id: 'home')));
    } catch (e) {
      talker.debug('[RealtimePosts] Could not invalidate home feed: $e');
    }
  }

  void _updatePostInPostLists(SnPost post) {
    try {
      _ref.invalidate(postListProvider(const PostListQueryConfig(id: 'home')));
    } catch (e) {
      talker.debug('[RealtimePosts] Could not invalidate post lists: $e');
    }
  }

  void _removePostFromPostLists(String postId) {
    try {
      _ref.invalidate(postListProvider(const PostListQueryConfig(id: 'home')));
    } catch (e) {
      talker.debug('[RealtimePosts] Could not invalidate post lists: $e');
    }
  }

  void _updateReactionInTimeline(
    String postId,
    String symbol,
    int delta,
  ) {
    try {
      final notifier = _ref.read(activityListProvider.notifier);
      final currentState = _ref.read(activityListProvider);
      final items = currentState.value?.items ?? [];

      final index = items.indexWhere((item) {
        if (item.resourceIdentifier == postId) {
          return true;
        }
        final itemData = item.data;
        if (itemData is SnPost && itemData.id == postId) {
          return true;
        }
        return false;
      });

      if (index == -1) {
        // Post not found in timeline, invalidate to refresh
        _ref.invalidate(activityListProvider);
        return;
      }

      final item = items[index];
      final itemData = item.data;
      if (itemData is! SnPost) {
        _ref.invalidate(activityListProvider);
        return;
      }

      final updatedReactionsCount =
          Map<String, int>.from(itemData.reactionsCount);
      updatedReactionsCount[symbol] =
          (updatedReactionsCount[symbol] ?? 0) + delta;

      // Remove the reaction count if it becomes 0 or less
      if (updatedReactionsCount[symbol]! <= 0) {
        updatedReactionsCount.remove(symbol);
      }

      final updatedPost = itemData.copyWith(
        reactionsCount: updatedReactionsCount,
      );

      notifier.updatePostById(updatedPost);
    } catch (e) {
      talker.error(
        '[RealtimePosts] Failed to update reaction in timeline: $e',
      );
    }
  }

  void _updateReactionInPostLists(
    String postId,
    String symbol,
    int delta,
  ) {
    try {
      _ref.invalidate(postListProvider(const PostListQueryConfig(id: 'home')));
    } catch (e) {
      talker.debug('[RealtimePosts] Could not invalidate post lists: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
