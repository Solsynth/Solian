import 'dart:async';
import 'dart:convert';

import 'package:island/data/message.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Shared in-memory query and mutation logic for every database backend.
///
/// Native persistence is layered on top by [database.drift_impl.dart], while
/// web can use this class directly when durable storage is unavailable.
class AppDatabase {
  AppDatabase.native(Future<String?> _);
  AppDatabase.web();
  final Map<String, SnPost> _webDraftStore = {};
  final Map<String, String> _webKvStore = {};
  final Map<String, SnChatRoom> _webChatRoomStore = {};
  final Map<String, SnChatMember> _webChatMemberStore = {};
  // Chat members are mostly static while message pagination writes often.
  // Keep their JSON alongside the model so exporting a full snapshot does not
  // serialize the entire member directory for every message batch.
  final Map<String, Map<String, dynamic>> _webChatMemberJsonStore = {};
  final Map<String, SnRealm> _webRealmStore = {};
  final Map<String, List<SnChatGroup>> _webChatGroupStore = {};
  final Map<String, SnSticker> _webStickerLookupStore = {};
  final Map<String, LocalChatMessage> _webMessageStore = {};
  final Map<String, Map<String, dynamic>> _webMessageJsonStore = {};

  /// Serialization boundary shared with the native Drift adapter.
  ///
  /// Web keeps this implementation in memory, while native persists exactly
  /// the same application contract through Drift.
  Map<String, dynamic> exportState({bool includeMessages = true}) => {
    'drafts': _webDraftStore.map((id, post) => MapEntry(id, post.toJson())),
    'secrets': Map<String, String>.from(_webKvStore),
    // Members are persisted separately. Avoid expanding a room's full member
    // list here, which duplicates the same account graph for every room.
    'rooms': _webChatRoomStore.map(
      (id, room) => MapEntry(id, room.copyWith(members: null).toJson()),
    ),
    'members': _webChatMemberJsonStore,
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
    if (includeMessages) 'messages': _webMessageJsonStore,
  };

  Map<String, dynamic> exportMessagePayloads() => _webMessageJsonStore;

  void restoreMessagePayloads(Map<String, dynamic> messages) =>
      _restoreMessages(messages);

  Map<String, dynamic>? getMessagePayload(String id) =>
      _webMessageJsonStore[id];

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
    _restoreMembers(state['members']);
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
    _restoreMessages(state['messages']);
    final groups = state['groups'];
    if (groups is Map) {
      for (final entry in groups.entries) {
        final value = entry.value;
        if (value is! List) continue;
        try {
          _webChatGroupStore[entry.key.toString()] = value
              .whereType<Map>()
              .map(
                (item) => SnChatGroup.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        } catch (_) {
          // A corrupt cache record should never prevent the app from syncing.
        }
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

  void _restoreMembers(dynamic value) {
    if (value is! Map) return;
    for (final entry in value.entries) {
      if (entry.value is! Map) continue;
      final id = entry.key.toString();
      final json = Map<String, dynamic>.from(entry.value as Map);
      try {
        _webChatMemberStore[id] = SnChatMember.fromJson(json);
        _webChatMemberJsonStore[id] = json;
      } catch (_) {
        // A corrupt cache record should never prevent the app from syncing.
      }
    }
  }

  void _restoreMessages(dynamic value) {
    if (value is! Map) return;
    for (final entry in value.entries) {
      if (entry.value is! Map) continue;
      final id = entry.key.toString();
      final json = Map<String, dynamic>.from(entry.value as Map);
      try {
        _webMessageStore[id] = _messageFromJson(json);
        _webMessageJsonStore[id] = json;
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
    _webChatMemberJsonStore.clear();
    _webRealmStore.clear();
    _webRelationshipStore.clear();
    _webChatGroupStore.clear();
    _webStickerLookupStore.clear();
    _webMessageStore.clear();
    _webMessageJsonStore.clear();
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
    final sender = message.sender;
    if (sender != null && !_webChatMemberStore.containsKey(sender.id)) {
      _webChatMemberStore[sender.id] = sender;
      _webChatMemberJsonStore[sender.id] = sender.toJson();
    }
    _webMessageJsonStore[message.id] = _messageToJson(message);
    return 1;
  }

  Future<int> updateMessageStatus(String id, MessageStatus status) async {
    final message = _webMessageStore[id];
    if (message == null) return 0;
    message.status = status;
    _webMessageJsonStore[id]?['status'] = status.index;
    return 1;
  }

  Future<int> deleteMessage(String id) async {
    final removed = _webMessageStore.remove(id);
    _webMessageJsonStore.remove(id);
    return removed == null ? 0 : 1;
  }

  Future<int> deleteMessagesForRoom(String roomId) async {
    final ids = _webMessageStore.values
        .where((message) => message.roomId == roomId)
        .map((message) => message.id)
        .toList();
    for (final id in ids) {
      _webMessageStore.remove(id);
      _webMessageJsonStore.remove(id);
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

  /// Searches every locally cached chat room, newest messages first.
  Future<List<LocalChatMessage>> searchMessagesAcrossRooms(
    String query, {
    bool? withAttachments,
  }) async {
    final lower = query.toLowerCase();
    final messages = _webMessageStore.values.where((message) {
      if (withAttachments == true && message.attachments.isEmpty) return false;
      return query.isEmpty ||
          (message.content ?? '').toLowerCase().contains(lower) ||
          message.type.toLowerCase().contains(lower) ||
          jsonEncode(message.meta).toLowerCase().contains(lower);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return messages;
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
    // Message senders are represented by the separately stored member cache.
    // Storing a complete member here duplicates its account/profile graph for
    // every message and dominates snapshot serialization time.
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
    final senderId = json['senderId'].toString();
    final senderJson = json['sender'];
    return LocalChatMessage(
      id: json['id'].toString(),
      roomId: json['roomId'].toString(),
      senderId: senderId,
      sender:
          _webChatMemberStore[senderId] ??
          (senderJson is Map
              ? SnChatMember.fromJson(Map<String, dynamic>.from(senderJson))
              : null),
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
        _webChatMemberJsonStore.removeWhere(
          (id, _) => !_webChatMemberStore.containsKey(id),
        );
        _webMessageStore.removeWhere((_, message) => message.roomId == roomId);
        _webMessageJsonStore.removeWhere(
          (id, _) => !_webMessageStore.containsKey(id),
        );
        _webKvStore.remove('chat_room_encryption_mode_$roomId');
      }
      _webChatGroupStore.updateAll(
        (_, groups) => groups
            .map(
              (group) => group.copyWith(
                roomIds: group.roomIds.where(remoteRoomIds.contains).toList(),
              ),
            )
            .toList(),
      );
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

      final members = room.members;
      if (members != null) {
        final currentMemberIds = members.map((member) => member.id).toSet();
        _webChatMemberStore.removeWhere(
          (_, member) =>
              member.chatRoomId == room.id &&
              !currentMemberIds.contains(member.id),
        );
        _webChatMemberJsonStore.removeWhere(
          (id, _) => !_webChatMemberStore.containsKey(id),
        );
        for (final member in members) {
          _webChatMemberStore[member.id] = member;
          _webChatMemberJsonStore[member.id] = member.toJson();
        }
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
    _webChatMemberJsonStore[member.id] = member.toJson();
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
