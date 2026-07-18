import 'dart:async';
import 'dart:convert';

import 'package:island/data/message.dart';
import 'package:island/stickers/models/sticker.dart';
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
  final Map<String, SnSticker> _webStickerLookupStore = {};
  final Map<String, LocalChatMessage> _webMessageStore = {};

  /// Serialization boundary shared with the native Drift adapter.
  ///
  /// Web keeps this implementation in memory, while native persists exactly
  /// the same application contract through Drift.
  Map<String, dynamic> exportState() => {
    'drafts': _webDraftStore.map((id, post) => MapEntry(id, post.toJson())),
    'secrets': Map<String, String>.from(_webKvStore),
    'rooms': _webChatRoomStore.map((id, room) => MapEntry(id, room.toJson())),
    'members': _webChatMemberStore.map(
      (id, member) => MapEntry(id, member.toJson()),
    ),
    'realms': _webRealmStore.map((id, realm) => MapEntry(id, realm.toJson())),
    'groups': _webChatGroupStore.map(
      (accountId, groups) =>
          MapEntry(accountId, groups.map((group) => group.toJson()).toList()),
    ),
    'stickers': _webStickerLookupStore.map(
      (identifier, sticker) => MapEntry(identifier, sticker.toJson()),
    ),
    'relationships': _webRelationshipStore.map(
      (id, relationship) => MapEntry(id, relationship.toJson()),
    ),
    'messages': _webMessageStore.map(
      (id, message) => MapEntry(id, _messageToJson(message)),
    ),
  };

  void restoreState(Map<String, dynamic> state) {
    reset();
    _restoreObjects<SnPost>(state['drafts'], _webDraftStore, SnPost.fromJson);
    final secrets = state['secrets'];
    if (secrets is Map) {
      _webKvStore.addAll(
        secrets.map((key, value) => MapEntry(key.toString(), value.toString())),
      );
    }
    _restoreObjects<SnChatRoom>(
      state['rooms'],
      _webChatRoomStore,
      SnChatRoom.fromJson,
    );
    _restoreObjects<SnChatMember>(
      state['members'],
      _webChatMemberStore,
      SnChatMember.fromJson,
    );
    _restoreObjects<SnRealm>(state['realms'], _webRealmStore, SnRealm.fromJson);
    _restoreObjects<SnSticker>(
      state['stickers'],
      _webStickerLookupStore,
      SnSticker.fromJson,
    );
    _restoreObjects<SnRelationship>(
      state['relationships'],
      _webRelationshipStore,
      SnRelationship.fromJson,
    );
    _restoreObjects<LocalChatMessage>(
      state['messages'],
      _webMessageStore,
      _messageFromJson,
    );
    final groups = state['groups'];
    if (groups is Map) {
      for (final entry in groups.entries) {
        final value = entry.value;
        if (value is! List) continue;
        _webChatGroupStore[entry.key.toString()] = value
            .whereType<Map>()
            .map(
              (item) => SnChatGroup.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    }
  }

  void _restoreObjects<T>(
    dynamic value,
    Map<String, T> target,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! Map) return;
    for (final entry in value.entries) {
      if (entry.value is! Map) continue;
      try {
        target[entry.key.toString()] = fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      } catch (_) {
        // A corrupt cache record should never prevent the app from syncing.
      }
    }
  }

  Future<void> close() async {}

  Future<void> reset() async {
    _webDraftStore.clear();
    _webKvStore.clear();
    _webChatRoomStore.clear();
    _webChatMemberStore.clear();
    _webRealmStore.clear();
    _webRelationshipStore.clear();
    _webChatGroupStore.clear();
    _webStickerLookupStore.clear();
    _webMessageStore.clear();
  }

  Future<Map<String, int>> getDatabaseStats() async {
    return {
      'messages': _webMessageStore.length,
      'chatRooms': _webChatRoomStore.length,
      'chatMembers': _webChatMemberStore.length,
      'realms': _webRealmStore.length,
      'relationships': _webRelationshipStore.length,
      'postDrafts': _webDraftStore.length,
      'stickerLookups': _webStickerLookupStore.length,
    };
  }

  Future<T> transaction<T>(Future<T> Function() action) async => action();

  Future<int> getLatestMessageTimestamp() async => _webMessageStore.values
      .map((message) => message.createdAt.millisecondsSinceEpoch)
      .fold<int>(0, (latest, value) => value > latest ? value : latest);

  Future<int> countMessagesNewerThan(String roomId, DateTime createdAt) async =>
      _webMessageStore.values
          .where(
            (message) =>
                message.roomId == roomId &&
                message.createdAt.isAfter(createdAt),
          )
          .length;

  Future<List<LocalChatMessage>> getMessagesForRoom(
    String roomId, {
    int offset = 0,
    int limit = 20,
  }) async {
    final messages =
        _webMessageStore.values
            .where((message) => message.roomId == roomId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return messages.skip(offset).take(limit).toList();
  }

  Future<LocalChatMessage?> getMessageById(String id) async =>
      _webMessageStore[id];

  Future<int> saveMessage(LocalChatMessage message) async {
    _webMessageStore[message.id] = message;
    return 1;
  }

  Future<int> updateMessageStatus(String id, MessageStatus status) async {
    final message = _webMessageStore[id];
    if (message == null) return 0;
    message.status = status;
    return 1;
  }

  Future<int> deleteMessage(String id) async =>
      _webMessageStore.remove(id) == null ? 0 : 1;

  Future<int> deleteMessagesForRoom(String roomId) async {
    final ids = _webMessageStore.values
        .where((message) => message.roomId == roomId)
        .map((message) => message.id)
        .toList();
    for (final id in ids) {
      _webMessageStore.remove(id);
    }
    return ids.length;
  }

  Future<int> getTotalMessagesForRoom(String roomId) async => _webMessageStore
      .values
      .where((message) => message.roomId == roomId)
      .length;

  Future<Map<String, int>> getChatRoomMessageStats() async {
    final stats = <String, int>{};
    for (final message in _webMessageStore.values) {
      stats[message.roomId] = (stats[message.roomId] ?? 0) + 1;
    }
    return stats;
  }

  Future<List<LocalChatMessage>> searchMessages(
    String roomId,
    String query, {
    bool? withAttachments,
    Future<SnAccount?> Function(String accountId)? fetchAccount,
  }) async {
    final lower = query.toLowerCase();
    return _webMessageStore.values.where((message) {
      if (message.roomId != roomId) return false;
      if (withAttachments == true && message.attachments.isEmpty) return false;
      return query.isEmpty ||
          (message.content ?? '').toLowerCase().contains(lower) ||
          message.type.toLowerCase().contains(lower) ||
          jsonEncode(message.meta).toLowerCase().contains(lower);
    }).toList();
  }

  Future<int> saveMessageWithSender(LocalChatMessage message) =>
      saveMessage(message);

  Future<int> saveMessagesWithSenders(List<LocalChatMessage> messages) async {
    for (final message in messages) {
      await saveMessage(message);
    }
    return messages.length;
  }

  Map<String, dynamic> _messageToJson(LocalChatMessage message) => {
    'id': message.id,
    'roomId': message.roomId,
    'senderId': message.senderId,
    'sender': message.sender?.toJson(),
    'data': message.data,
    'createdAt': message.createdAt.toIso8601String(),
    'clientMessageId': message.clientMessageId,
    'nonce': message.nonce,
    'status': message.status.index,
    'content': message.content,
    'isDeleted': message.isDeleted,
    'updatedAt': message.updatedAt?.toIso8601String(),
    'deletedAt': message.deletedAt?.toIso8601String(),
    'type': message.type,
    'meta': message.meta,
    'membersMentioned': message.membersMentioned,
    'editedAt': message.editedAt?.toIso8601String(),
    'attachments': message.attachments,
    'reactions': message.reactions,
    'repliedMessageId': message.repliedMessageId,
    'forwardedMessageId': message.forwardedMessageId,
  };

  LocalChatMessage _messageFromJson(Map<String, dynamic> json) {
    DateTime? date(String key) =>
        json[key] == null ? null : DateTime.tryParse(json[key].toString());
    final senderJson = json['sender'];
    return LocalChatMessage(
      id: json['id'].toString(),
      roomId: json['roomId'].toString(),
      senderId: json['senderId'].toString(),
      sender: senderJson is Map
          ? SnChatMember.fromJson(Map<String, dynamic>.from(senderJson))
          : null,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      clientMessageId: json['clientMessageId']?.toString(),
      nonce: json['nonce']?.toString(),
      status: MessageStatus.values[json['status'] as int? ?? 0],
      content: json['content']?.toString(),
      isDeleted: json['isDeleted'] as bool?,
      updatedAt: date('updatedAt'),
      deletedAt: date('deletedAt'),
      type: json['type']?.toString() ?? 'text',
      meta: Map<String, dynamic>.from(json['meta'] as Map? ?? const {}),
      membersMentioned: List<String>.from(
        json['membersMentioned'] as List? ?? const [],
      ),
      editedAt: date('editedAt'),
      attachments: (json['attachments'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      reactions: (json['reactions'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      repliedMessageId: json['repliedMessageId']?.toString(),
      forwardedMessageId: json['forwardedMessageId']?.toString(),
    );
  }

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
  // Sticker lookups
  // ---------------------------------------------------------------------------

  Future<SnSticker?> getStickerLookup(String identifier) async {
    return _webStickerLookupStore[identifier];
  }

  Future<void> setStickerLookup(String identifier, SnSticker sticker) async {
    _webStickerLookupStore[identifier] = sticker;
  }

  Future<void> clearStickerLookups() async {
    _webStickerLookupStore.clear();
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
