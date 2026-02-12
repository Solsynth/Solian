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

  void dispose() {
    _subscription?.cancel();
  }
}
