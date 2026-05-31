import 'dart:async';

import 'package:island/data/message.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class AppDatabase {
  AppDatabase.native(Future<String?> _);
  AppDatabase.web();
  final Map<String, SnPost> _webDraftStore = {};
  final Map<String, String> _webKvStore = {};
  final Map<String, SnChatRoom> _webChatRoomStore = {};
  final Map<String, SnChatMember> _webChatMemberStore = {};
  final Map<String, SnRealm> _webRealmStore = {};
  final Map<String, List<SnChatGroup>> _webChatGroupStore = {};

  Future<void> close() async {}

  Future<void> reset() async {
    _webDraftStore.clear();
    _webKvStore.clear();
    _webChatRoomStore.clear();
    _webChatMemberStore.clear();
    _webRealmStore.clear();
    _webRelationshipStore.clear();
    _webChatGroupStore.clear();
  }

  Future<Map<String, int>> getDatabaseStats() async {
    return {
      'messages': 0,
      'chatRooms': _webChatRoomStore.length,
      'chatMembers': _webChatMemberStore.length,
      'realms': _webRealmStore.length,
      'relationships': _webRelationshipStore.length,
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
  }) async {
    if (override) {
      final remoteRoomIds = rooms.map((room) => room.id).toSet();
      final idsToRemove = _webChatRoomStore.keys
          .where((id) => !remoteRoomIds.contains(id))
          .toList();
      for (final roomId in idsToRemove) {
        _webChatRoomStore.remove(roomId);
        _webChatMemberStore.removeWhere(
          (_, member) => member.chatRoomId == roomId,
        );
      }
    }

    for (final room in rooms) {
      final existing = _webChatRoomStore[room.id];
      final roomToSave = room.copyWith(
        isPinned: existing?.isPinned ?? room.isPinned,
      );
      _webChatRoomStore[room.id] = roomToSave;

      final realm = room.realm;
      if (realm != null) {
        _webRealmStore[realm.id] = realm;
      }

      for (final member in room.members ?? const <SnChatMember>[]) {
        _webChatMemberStore[member.id] = member;
      }
    }
  }

  Future<void> toggleChatRoomPinned(String roomId) async {
    final room = _webChatRoomStore[roomId];
    if (room == null) return;
    _webChatRoomStore[roomId] = room.copyWith(isPinned: !room.isPinned);
  }

  Future<List<SnChatRoom>> getAllChatRooms() async =>
      _webChatRoomStore.values.toList();

  Future<SnChatRoom?> getChatRoomById(String id) async => _webChatRoomStore[id];

  Future<List<SnChatGroup>> getChatGroups(String accountId) async {
    final groups = _webChatGroupStore[accountId] ?? const [];
    return groups.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> saveChatGroups(
    String accountId,
    List<SnChatGroup> groups,
  ) async {
    _webChatGroupStore[accountId] = groups.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> assignChatRoomToGroup(
    String accountId,
    String roomId, {
    String? groupId,
  }) async {
    final groups = (_webChatGroupStore[accountId] ?? const []).map((group) {
      final roomIds = group.roomIds.where((id) => id != roomId).toList();
      if (group.id == groupId) roomIds.add(roomId);
      return group.copyWith(
        roomIds: roomIds,
        updatedAt: DateTime.now().toUtc(),
      );
    }).toList();
    _webChatGroupStore[accountId] = groups;
  }

  Future<List<SnChatMember>> getMembersByRoomId(String roomId) async =>
      _webChatMemberStore.values
          .where((member) => member.chatRoomId == roomId)
          .toList();

  Future<SnChatMember?> getMemberByRoomAndAccount(
    String roomId,
    String accountId,
  ) async {
    for (final member in _webChatMemberStore.values) {
      if (member.chatRoomId == roomId && member.accountId == accountId) {
        return member;
      }
    }
    return null;
  }

  Future<SnChatMember?> getMemberById(String id) async =>
      _webChatMemberStore[id];

  Future<List<SnRealm>> getAllRealms() async => _webRealmStore.values.toList();

  Future<SnRealm?> getRealmById(String id) async => _webRealmStore[id];

  Future<void> saveMember(SnChatMember member) async {
    _webChatMemberStore[member.id] = member;
  }

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
    return _webRelationshipStore.values.toList()..sort(
      (a, b) =>
          (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
    );
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
