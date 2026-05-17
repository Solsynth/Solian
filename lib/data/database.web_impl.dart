import 'dart:async';

import 'package:island/data/message.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class AppDatabase {
  AppDatabase.native(Future<String?> _);
  AppDatabase.web();
  final Map<String, SnPost> _webDraftStore = {};
  final Map<String, String> _webKvStore = {};

  Future<void> close() async {}

  Future<void> reset() async {
    _webDraftStore.clear();
    _webKvStore.clear();
  }

  Future<T> transaction<T>(Future<T> Function() action) async => action();

  Future<int> getLatestMessageTimestamp() async => 0;

  Future<int> countMessagesNewerThan(String roomId, DateTime createdAt) async =>
      0;

  Future<List<LocalChatMessage>> getMessagesForRoom(
    String roomId, {
    int offset = 0,
    int limit = 20,
  }) async => const [];

  Future<LocalChatMessage?> getMessageById(String id) async => null;

  Future<int> saveMessage(LocalChatMessage message) async => 1;

  Future<int> updateMessageStatus(String id, MessageStatus status) async => 1;

  Future<int> deleteMessage(String id) async => 1;

  Future<int> deleteMessagesForRoom(String roomId) async => 0;

  Future<int> getTotalMessagesForRoom(String roomId) async => 0;

  Future<Map<String, int>> getChatRoomMessageStats() async => {};

  Future<List<LocalChatMessage>> searchMessages(
    String roomId,
    String query, {
    bool? withAttachments,
    Future<SnAccount?> Function(String accountId)? fetchAccount,
  }) async => const [];

  Future<int> saveMessageWithSender(LocalChatMessage message) async => 1;

  Future<int> saveMessagesWithSenders(List<LocalChatMessage> messages) async =>
      messages.length;

  Future<void> saveChatRooms(
    List<SnChatRoom> rooms, {
    bool override = false,
  }) async {}

  Future<void> toggleChatRoomPinned(String roomId) async {}

  Future<List<SnChatRoom>> getAllChatRooms() async => const [];

  Future<SnChatRoom?> getChatRoomById(String id) async => null;

  Future<List<SnChatMember>> getMembersByRoomId(String roomId) async =>
      const [];

  Future<SnChatMember?> getMemberByRoomAndAccount(
    String roomId,
    String accountId,
  ) async => null;

  Future<SnChatMember?> getMemberById(String id) async => null;

  Future<List<SnRealm>> getAllRealms() async => const [];

  Future<SnRealm?> getRealmById(String id) async => null;

  Future<void> saveMember(SnChatMember member) async {}

  // ---------------------------------------------------------------------------
  // Post drafts
  // ---------------------------------------------------------------------------

  Future<List<SnPost>> getAllPostDrafts() async {
    final drafts = _webDraftStore.values.toList()
      ..sort(
        (a, b) =>
            (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
      );
    return drafts;
  }

  Future<List<SnPost>> searchPostDrafts(String query) async {
    final drafts = await getAllPostDrafts();
    if (query.isEmpty) return drafts;
    final lower = query.toLowerCase();
    return drafts.where((post) {
      return (post.title ?? '').toLowerCase().contains(lower) ||
          (post.description ?? '').toLowerCase().contains(lower) ||
          (post.content ?? '').toLowerCase().contains(lower);
    }).toList();
  }

  Future<void> addPostDraftFromPost(SnPost post) async {
    final updatedPost = post.copyWith(updatedAt: DateTime.now());
    _webDraftStore[updatedPost.id] = updatedPost;
  }

  Future<void> deletePostDraft(String id) async {
    _webDraftStore.remove(id);
  }

  Future<void> clearAllPostDrafts() async {
    _webDraftStore.clear();
  }

  Future<SnPost?> getPostDraftById(String id) async {
    return _webDraftStore[id];
  }

  // ---------------------------------------------------------------------------
  // Secrets / KV store
  // ---------------------------------------------------------------------------

  Future<String?> getSecret(String key) async => _webKvStore[key];

  Future<void> setSecret(String key, String value) async {
    _webKvStore[key] = value;
  }

  Future<void> removeSecret(String key) async {
    _webKvStore.remove(key);
  }

  Future<Map<String, String>> getAllSecrets() async {
    return Map<String, String>.from(_webKvStore);
  }
}
