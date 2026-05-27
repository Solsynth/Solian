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

  Future<Map<String, int>> getDatabaseStats() async {
    return {
      'messages': 0,
      'chatRooms': 0,
      'chatMembers': 0,
      'realms': 0,
      'postDrafts': _webDraftStore.length,
    };
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

  // ---------------------------------------------------------------------------
  // Relationships
  // ---------------------------------------------------------------------------

  final Map<String, SnRelationship> _webRelationshipStore = {};

  Future<List<SnRelationship>> getAllRelationships() async {
    return _webRelationshipStore.values.toList()
      ..sort((a, b) =>
          (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
  }

  Future<SnRelationship?> getRelationshipById(String id) async {
    return _webRelationshipStore[id];
  }

  Future<SnRelationship?> getRelationshipByAccounts(
    String accountId,
    String relatedId,
  ) async {
    final uid = '$accountId:$relatedId';
    return _webRelationshipStore[uid];
  }

  Future<void> saveRelationships(List<SnRelationship> relationships) async {
    for (final rel in relationships) {
      final uid = '${rel.accountId}:${rel.relatedId}';
      _webRelationshipStore[uid] = rel;
    }
  }

  Future<void> deleteRelationship(String accountId, String relatedId) async {
    final uid = '$accountId:$relatedId';
    _webRelationshipStore.remove(uid);
  }

  Future<List<String>> getBlockedAccountIds(String accountId) async {
    return _webRelationshipStore.values
        .where((r) => r.accountId == accountId && r.status <= -100)
        .map((r) => r.relatedId)
        .toList();
  }

  Future<List<String>> getMutedAccountIds(String accountId) async {
    return _webRelationshipStore.values
        .where((r) => r.accountId == accountId && r.status == -50)
        .map((r) => r.relatedId)
        .toList();
  }

  Future<List<String>> getCloseFriendAccountIds(String accountId) async {
    return _webRelationshipStore.values
        .where((r) => r.accountId == accountId && r.status >= 200)
        .map((r) => r.relatedId)
        .toList();
  }

  Future<Map<String, int>> getRelationshipStats() async {
    return {'relationships': _webRelationshipStore.length};
  }
}
