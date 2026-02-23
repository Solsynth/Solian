import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:island/data/message.dart';
import 'package:island/data/objectbox/entities.dart';
import 'package:island/objectbox.g.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.nonce,
    required this.data,
    required this.createdAt,
    required this.status,
    required this.isDeleted,
    required this.updatedAt,
    required this.deletedAt,
    required this.type,
    required this.meta,
    required this.membersMentioned,
    required this.editedAt,
    required this.attachments,
    required this.reactions,
    required this.repliedMessageId,
    required this.forwardedMessageId,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String? content;
  final String? nonce;
  final String data;
  final DateTime createdAt;
  final MessageStatus status;
  final bool? isDeleted;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String type;
  final Map<String, dynamic> meta;
  final List<String> membersMentioned;
  final DateTime? editedAt;
  final List<Map<String, dynamic>> attachments;
  final List<Map<String, dynamic>> reactions;
  final String? repliedMessageId;
  final String? forwardedMessageId;
}

class ChatRoom {
  ChatRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.isPublic,
    required this.isCommunity,
    required this.picture,
    required this.background,
    required this.realmId,
    required this.accountId,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String? name;
  final String? description;
  final int type;
  final bool? isPublic;
  final bool? isCommunity;
  final Map<String, dynamic>? picture;
  final Map<String, dynamic>? background;
  final String? realmId;
  final String? accountId;
  final bool? isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class ChatMember {
  ChatMember({
    required this.id,
    required this.chatRoomId,
    required this.accountId,
    required this.account,
    required this.nick,
    required this.notify,
    required this.joinedAt,
    required this.breakUntil,
    required this.timeoutUntil,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String chatRoomId;
  final String accountId;
  final Map<String, dynamic> account;
  final String? nick;
  final int notify;
  final DateTime? joinedAt;
  final DateTime? breakUntil;
  final DateTime? timeoutUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class Realm {
  Realm({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.verifiedAs,
    required this.verifiedAt,
    required this.isCommunity,
    required this.isPublic,
    required this.picture,
    required this.background,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String slug;
  final String? name;
  final String? description;
  final String? verifiedAs;
  final DateTime? verifiedAt;
  final bool isCommunity;
  final bool isPublic;
  final Map<String, dynamic>? picture;
  final Map<String, dynamic>? background;
  final String? accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class PostDraft {
  PostDraft({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.visibility,
    required this.type,
    required this.lastModified,
    required this.postData,
  });

  final String id;
  final String? title;
  final String? description;
  final String? content;
  final int visibility;
  final int type;
  final DateTime lastModified;
  final String postData;
}

class AppDatabase {
  AppDatabase.native(this._directoryPathFuture) : _isWeb = false;
  AppDatabase.web() : _isWeb = true, _directoryPathFuture = null;

  final bool _isWeb;
  final Future<String?>? _directoryPathFuture;
  final Map<String, SnPost> _webDraftStore = {};
  Future<Store?>? _storeFuture;

  Future<Store?> _getStore() async {
    if (_isWeb) return null;
    _storeFuture ??= _openStore();
    return _storeFuture!;
  }

  Future<Store?> _openStore() async {
    if (_isWeb || _directoryPathFuture == null) return null;
    if (kIsWeb) return null;
    final directoryPath = await _directoryPathFuture;
    if (directoryPath == null) return null;
    const macosAppGroup = 'W7HPZ53V6B.solian';
    try {
      if (Platform.isMacOS) {
        return openStore(
          directory: directoryPath,
          macosApplicationGroup: macosAppGroup,
        );
      }
      return openStore(directory: directoryPath);
    } catch (_) {
      final fallbackDir = Directory(
        '${Directory.systemTemp.path}/island_objectbox',
      );
      if (!await fallbackDir.exists()) {
        await fallbackDir.create(recursive: true);
      }
      if (Platform.isMacOS) {
        return openStore(
          directory: fallbackDir.path,
          macosApplicationGroup: macosAppGroup,
        );
      }
      return openStore(directory: fallbackDir.path);
    }
  }

  Future<void> close() async {
    final store = await _getStore();
    store?.close();
  }

  Future<void> reset() async {
    if (_isWeb) {
      _webDraftStore.clear();
      return;
    }
    final store = await _getStore();
    if (store == null) return;
    store.box<ChatMessageEntity>().removeAll();
    store.box<ChatRoomEntity>().removeAll();
    store.box<ChatMemberEntity>().removeAll();
    store.box<RealmEntity>().removeAll();
    store.box<PostDraftEntity>().removeAll();
  }

  Future<T> transaction<T>(Future<T> Function() action) async {
    // ObjectBox transactions accept synchronous callbacks only.
    // Most callsites here are already serialized at the notifier level,
    // so we run the async action directly.
    return action();
  }

  Future<int> getLatestMessageTimestamp() async {
    if (_isWeb) return 0;
    final store = await _getStore();
    if (store == null) return 0;
    final box = store.box<ChatMessageEntity>();
    final all = box.getAll();
    if (all.isEmpty) return 0;
    return all.map((e) => e.createdAtMs).reduce((a, b) => a > b ? a : b);
  }

  Future<int> countMessagesNewerThan(String roomId, DateTime createdAt) async {
    if (_isWeb) return 0;
    final store = await _getStore();
    if (store == null) return 0;
    final box = store.box<ChatMessageEntity>();
    return box
        .query(
          ChatMessageEntity_.roomId.equals(roomId) &
              ChatMessageEntity_.createdAtMs.greaterThan(
                createdAt.millisecondsSinceEpoch,
              ),
        )
        .build()
        .count();
  }

  Future<List<ChatMessage>> getMessagesForRoom(
    String roomId, {
    int offset = 0,
    int limit = 20,
  }) async {
    if (_isWeb) return const [];
    final store = await _getStore();
    if (store == null) return const [];
    final query = store
        .box<ChatMessageEntity>()
        .query(ChatMessageEntity_.roomId.equals(roomId))
        .order(ChatMessageEntity_.createdAtMs, flags: Order.descending)
        .build();
    query.offset = offset;
    query.limit = limit;
    final rows = query.find().map(_messageEntityToRow).toList();
    query.close();
    return rows;
  }

  Future<ChatMessage?> getMessageById(String id) async {
    if (_isWeb) return null;
    final store = await _getStore();
    if (store == null) return null;
    final query = store
        .box<ChatMessageEntity>()
        .query(ChatMessageEntity_.uid.equals(id))
        .build();
    final entity = query.findFirst();
    query.close();
    if (entity == null) return null;
    return _messageEntityToRow(entity);
  }

  Future<int> saveMessage(ChatMessage message) async {
    if (_isWeb) return 1;
    final store = await _getStore();
    if (store == null) return 0;
    final box = store.box<ChatMessageEntity>();
    final existing = box
        .query(ChatMessageEntity_.uid.equals(message.id))
        .build()
        .findFirst();
    final entity = _rowToMessageEntity(message, existing: existing);
    box.put(entity);
    return 1;
  }

  Future<int> updateMessage(ChatMessage message) => saveMessage(message);

  Future<int> updateMessageStatus(String id, MessageStatus status) async {
    if (_isWeb) return 1;
    final store = await _getStore();
    if (store == null) return 0;
    final box = store.box<ChatMessageEntity>();
    final query = box.query(ChatMessageEntity_.uid.equals(id)).build();
    final entity = query.findFirst();
    query.close();
    if (entity == null) return 0;
    entity.status = status.index;
    box.put(entity);
    return 1;
  }

  Future<int> deleteMessage(String id) async {
    if (_isWeb) return 1;
    final store = await _getStore();
    if (store == null) return 0;
    final box = store.box<ChatMessageEntity>();
    final query = box.query(ChatMessageEntity_.uid.equals(id)).build();
    final entity = query.findFirst();
    query.close();
    if (entity == null) return 0;
    return box.remove(entity.obxId) ? 1 : 0;
  }

  Future<int> getTotalMessagesForRoom(String roomId) async {
    if (_isWeb) return 0;
    final store = await _getStore();
    if (store == null) return 0;
    return store
        .box<ChatMessageEntity>()
        .query(ChatMessageEntity_.roomId.equals(roomId))
        .build()
        .count();
  }

  Future<List<LocalChatMessage>> searchMessages(
    String roomId,
    String query, {
    bool? withAttachments,
    Future<SnAccount?> Function(String accountId)? fetchAccount,
  }) async {
    if (_isWeb) return const [];
    final messageRows = await getMessagesForRoom(
      roomId,
      offset: 0,
      limit: 5000,
    );
    final lower = query.toLowerCase();
    final filtered = <ChatMessage>[];
    for (final row in messageRows) {
      final contentText = (row.content ?? '').toLowerCase();
      final metaText = jsonEncode(row.meta).toLowerCase();
      final attachmentsText = jsonEncode(row.attachments).toLowerCase();
      final typeText = row.type.toLowerCase();

      final matchesQuery =
          query.isEmpty ||
          contentText.contains(lower) ||
          metaText.contains(lower) ||
          attachmentsText.contains(lower) ||
          typeText.contains(lower);
      if (!matchesQuery) continue;

      final matchesAttachmentFilter =
          withAttachments != true || row.attachments.isNotEmpty;
      if (!matchesAttachmentFilter) continue;
      filtered.add(row);
    }

    final list = <LocalChatMessage>[];
    for (final row in filtered) {
      list.add(await companionToMessage(row, fetchAccount: fetchAccount));
    }
    return list;
  }

  ChatMessage messageToCompanion(LocalChatMessage message) {
    final remote = message.toRemoteMessage();
    return ChatMessage(
      id: message.id,
      roomId: message.roomId,
      senderId: message.senderId,
      content: remote.content,
      nonce: message.nonce,
      data: jsonEncode(message.data),
      createdAt: message.createdAt,
      status: message.status,
      isDeleted: message.isDeleted ?? false,
      updatedAt: remote.updatedAt,
      deletedAt: remote.deletedAt,
      type: remote.type,
      meta: remote.meta,
      membersMentioned: remote.membersMentioned,
      editedAt: remote.editedAt,
      attachments: remote.attachments.map((e) => e.toJson()).toList(),
      reactions: remote.reactions.map((e) => e.toJson()).toList(),
      repliedMessageId: remote.repliedMessageId,
      forwardedMessageId: remote.forwardedMessageId,
    );
  }

  Future<LocalChatMessage> companionToMessage(
    ChatMessage dbMessage, {
    Future<SnAccount?> Function(String accountId)? fetchAccount,
  }) async {
    final data = jsonDecode(dbMessage.data) as Map<String, dynamic>;
    SnChatMember? sender;
    try {
      final senderRow = await getMemberById(dbMessage.senderId);
      if (senderRow != null) {
        SnAccount senderAccount = SnAccount.fromJson(senderRow.account);
        sender = SnChatMember(
          id: senderRow.id,
          chatRoomId: senderRow.chatRoomId,
          accountId: senderRow.accountId,
          account: senderAccount,
          nick: senderRow.nick,
          notify: senderRow.notify,
          joinedAt: senderRow.joinedAt,
          breakUntil: senderRow.breakUntil,
          timeoutUntil: senderRow.timeoutUntil,
          status: null,
          createdAt: senderRow.createdAt,
          updatedAt: senderRow.updatedAt,
          deletedAt: senderRow.deletedAt,
          chatRoom: null,
        );
      }
    } catch (_) {
      sender = null;
    }

    sender ??= SnChatMember(
      id: 'unknown',
      chatRoomId: dbMessage.roomId,
      accountId: dbMessage.senderId,
      account: SnAccount(
        id: 'unknown',
        name: 'unknown',
        nick: dbMessage.senderId,
        activatedAt: null,
        profile: SnAccountProfile(
          picture: null,
          id: 'unknown',
          experience: 0,
          level: 1,
          levelingProgress: 0.0,
          background: null,
          verification: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deletedAt: null,
        ),
        language: '',
        isSuperuser: false,
        automatedId: null,
        perkSubscription: null,
        deletedAt: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      nick: dbMessage.senderId,
      notify: 0,
      joinedAt: null,
      breakUntil: null,
      timeoutUntil: null,
      status: null,
      lastTyped: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
      chatRoom: null,
    );

    return LocalChatMessage(
      id: dbMessage.id,
      roomId: dbMessage.roomId,
      senderId: dbMessage.senderId,
      sender: sender,
      data: data,
      createdAt: dbMessage.createdAt,
      status: dbMessage.status,
      nonce: dbMessage.nonce,
      content: dbMessage.content,
      isDeleted: dbMessage.isDeleted,
      updatedAt: dbMessage.updatedAt,
      deletedAt: dbMessage.deletedAt,
      type: dbMessage.type,
      meta: dbMessage.meta,
      membersMentioned: dbMessage.membersMentioned,
      editedAt: dbMessage.editedAt,
      attachments: dbMessage.attachments,
      reactions: dbMessage.reactions,
      repliedMessageId: dbMessage.repliedMessageId,
      forwardedMessageId: dbMessage.forwardedMessageId,
    );
  }

  Future<void> saveChatRooms(
    List<SnChatRoom> rooms, {
    bool override = false,
  }) async {
    if (_isWeb) return;

    final store = await _getStore();
    if (store == null) return;
    final roomsBox = store.box<ChatRoomEntity>();
    final membersBox = store.box<ChatMemberEntity>();
    final realmsBox = store.box<RealmEntity>();
    final messagesBox = store.box<ChatMessageEntity>();

    await transaction(() async {
      if (override) {
        final remoteRoomIds = rooms.map((r) => r.id).toSet();
        final currentRooms = roomsBox.getAll();
        final idsToRemove = currentRooms
            .map((r) => r.uid)
            .where((id) => !remoteRoomIds.contains(id))
            .toList();
        if (idsToRemove.isNotEmpty) {
          for (final roomId in idsToRemove) {
            messagesBox
                .query(ChatMessageEntity_.roomId.equals(roomId))
                .build()
                .remove();
            membersBox
                .query(ChatMemberEntity_.chatRoomId.equals(roomId))
                .build()
                .remove();
            roomsBox.query(ChatRoomEntity_.uid.equals(roomId)).build().remove();
          }
        }
      }

      final realmsToSave = rooms
          .where((room) => room.realm != null)
          .map((room) => room.realm!)
          .toSet()
          .toList();
      for (final realm in realmsToSave) {
        final query = realmsBox
            .query(RealmEntity_.uid.equals(realm.id))
            .build();
        final existing = query.findFirst();
        query.close();
        realmsBox.put(_realmToEntity(realm, existing: existing));
      }

      for (final room in rooms) {
        final query = roomsBox
            .query(ChatRoomEntity_.uid.equals(room.id))
            .build();
        final existing = query.findFirst();
        query.close();
        final preservedPinned = existing?.isPinned ?? false;
        final entity = _roomToEntity(
          room,
          isPinnedOverride: preservedPinned,
          existing: existing,
        );
        roomsBox.put(entity);
        for (final member in room.members ?? const []) {
          final memberQuery = membersBox
              .query(ChatMemberEntity_.uid.equals(member.id))
              .build();
          final memberExisting = memberQuery.findFirst();
          memberQuery.close();
          membersBox.put(_memberToEntity(member, existing: memberExisting));
        }
      }
    });
  }

  Future<List<SnPost>> getAllPostDrafts() async {
    if (_isWeb) {
      final drafts = _webDraftStore.values.toList()
        ..sort(
          (a, b) => (b.updatedAt ?? DateTime(0)).compareTo(
            a.updatedAt ?? DateTime(0),
          ),
        );
      return drafts;
    }
    final rows = await getAllPostDraftRecords();
    return rows
        .map((draft) => SnPost.fromJson(jsonDecode(draft.postData)))
        .toList();
  }

  Future<List<PostDraft>> getAllPostDraftRecords() async {
    if (_isWeb) {
      return _webDraftStore.values
          .map(
            (post) => PostDraft(
              id: post.id,
              title: post.title,
              description: post.description,
              content: post.content,
              visibility: post.visibility,
              type: post.type,
              lastModified: post.updatedAt ?? DateTime.now(),
              postData: jsonEncode(post.toJson()),
            ),
          )
          .toList();
    }
    final store = await _getStore();
    if (store == null) return const [];
    final drafts = store.box<PostDraftEntity>().getAll()
      ..sort((a, b) => b.lastModifiedMs.compareTo(a.lastModifiedMs));
    return drafts.map(_draftEntityToRow).toList();
  }

  Future<List<PostDraft>> searchPostDrafts(String query) async {
    final rows = await getAllPostDraftRecords();
    if (query.isEmpty) return rows;
    final lower = query.toLowerCase();
    return rows.where((draft) {
      return (draft.title ?? '').toLowerCase().contains(lower) ||
          (draft.description ?? '').toLowerCase().contains(lower) ||
          (draft.content ?? '').toLowerCase().contains(lower);
    }).toList();
  }

  Future<void> addPostDraftFromPost(SnPost post) async {
    final updatedPost = post.copyWith(updatedAt: DateTime.now());
    if (_isWeb) {
      _webDraftStore[updatedPost.id] = updatedPost;
      return;
    }
    final store = await _getStore();
    if (store == null) return;
    final box = store.box<PostDraftEntity>();
    final query = box
        .query(PostDraftEntity_.uid.equals(updatedPost.id))
        .build();
    final existing = query.findFirst();
    query.close();
    final entity = _postToEntity(updatedPost, existing: existing);
    box.put(entity);
  }

  Future<void> deletePostDraft(String id) async {
    if (_isWeb) {
      _webDraftStore.remove(id);
      return;
    }
    final store = await _getStore();
    if (store == null) return;
    final box = store.box<PostDraftEntity>();
    final query = box.query(PostDraftEntity_.uid.equals(id)).build();
    final existing = query.findFirst();
    query.close();
    if (existing != null) box.remove(existing.obxId);
  }

  Future<void> clearAllPostDrafts() async {
    if (_isWeb) {
      _webDraftStore.clear();
      return;
    }
    final store = await _getStore();
    if (store == null) return;
    store.box<PostDraftEntity>().removeAll();
  }

  Future<PostDraft?> getPostDraftById(String id) async {
    if (_isWeb) {
      final draft = _webDraftStore[id];
      if (draft == null) return null;
      return PostDraft(
        id: draft.id,
        title: draft.title,
        description: draft.description,
        content: draft.content,
        visibility: draft.visibility,
        type: draft.type,
        lastModified: draft.updatedAt ?? DateTime.now(),
        postData: jsonEncode(draft.toJson()),
      );
    }
    final store = await _getStore();
    if (store == null) return null;
    final box = store.box<PostDraftEntity>();
    final query = box.query(PostDraftEntity_.uid.equals(id)).build();
    final entity = query.findFirst();
    query.close();
    if (entity == null) return null;
    return _draftEntityToRow(entity);
  }

  Future<void> saveMember(SnChatMember member) async {
    if (_isWeb) return;
    final store = await _getStore();
    if (store == null) return;
    final box = store.box<ChatMemberEntity>();
    final query = box.query(ChatMemberEntity_.uid.equals(member.id)).build();
    final existing = query.findFirst();
    query.close();
    box.put(_memberToEntity(member, existing: existing));
  }

  Future<int> saveMessageWithSender(LocalChatMessage message) async {
    if (message.sender != null) {
      await saveMember(message.sender!);
    }
    return saveMessage(messageToCompanion(message));
  }

  Future<void> toggleChatRoomPinned(String roomId) async {
    if (_isWeb) return;
    final store = await _getStore();
    if (store == null) return;
    final box = store.box<ChatRoomEntity>();
    final query = box.query(ChatRoomEntity_.uid.equals(roomId)).build();
    final room = query.findFirst();
    query.close();
    if (room == null) return;
    room.isPinned = !room.isPinned;
    box.put(room);
  }

  Future<List<ChatRoom>> getAllChatRooms() async {
    if (_isWeb) return const [];
    final store = await _getStore();
    if (store == null) return const [];
    return store.box<ChatRoomEntity>().getAll().map(_roomEntityToRow).toList();
  }

  Future<ChatRoom?> getChatRoomById(String id) async {
    if (_isWeb) return null;
    final store = await _getStore();
    if (store == null) return null;
    final query = store
        .box<ChatRoomEntity>()
        .query(ChatRoomEntity_.uid.equals(id))
        .build();
    final row = query.findFirst();
    query.close();
    if (row == null) return null;
    return _roomEntityToRow(row);
  }

  Future<List<ChatMember>> getMembersByRoomId(String roomId) async {
    if (_isWeb) return const [];
    final store = await _getStore();
    if (store == null) return const [];
    final query = store
        .box<ChatMemberEntity>()
        .query(ChatMemberEntity_.chatRoomId.equals(roomId))
        .build();
    final list = query.find().map(_memberEntityToRow).toList();
    query.close();
    return list;
  }

  Future<ChatMember?> getMemberByRoomAndAccount(
    String roomId,
    String accountId,
  ) async {
    if (_isWeb) return null;
    final store = await _getStore();
    if (store == null) return null;
    final query = store
        .box<ChatMemberEntity>()
        .query(
          ChatMemberEntity_.chatRoomId.equals(roomId) &
              ChatMemberEntity_.accountId.equals(accountId),
        )
        .build();
    final row = query.findFirst();
    query.close();
    if (row == null) return null;
    return _memberEntityToRow(row);
  }

  Future<ChatMember?> getMemberById(String id) async {
    if (_isWeb) return null;
    final store = await _getStore();
    if (store == null) return null;
    final query = store
        .box<ChatMemberEntity>()
        .query(ChatMemberEntity_.uid.equals(id))
        .build();
    final row = query.findFirst();
    query.close();
    if (row == null) return null;
    return _memberEntityToRow(row);
  }

  Future<List<Realm>> getAllRealms() async {
    if (_isWeb) return const [];
    final store = await _getStore();
    if (store == null) return const [];
    return store.box<RealmEntity>().getAll().map(_realmEntityToRow).toList();
  }

  Future<Realm?> getRealmById(String id) async {
    if (_isWeb) return null;
    final store = await _getStore();
    if (store == null) return null;
    final query = store
        .box<RealmEntity>()
        .query(RealmEntity_.uid.equals(id))
        .build();
    final row = query.findFirst();
    query.close();
    if (row == null) return null;
    return _realmEntityToRow(row);
  }

  ChatMessage _messageEntityToRow(ChatMessageEntity entity) {
    return ChatMessage(
      id: entity.uid,
      roomId: entity.roomId,
      senderId: entity.senderId,
      content: entity.content,
      nonce: entity.nonce,
      data: entity.dataJson,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtMs),
      status: MessageStatus.values[entity.status],
      isDeleted: entity.isDeleted,
      updatedAt: _fromMs(entity.updatedAtMs),
      deletedAt: _fromMs(entity.deletedAtMs),
      type: entity.type,
      meta: _decodeMap(entity.metaJson),
      membersMentioned: _decodeStringList(entity.membersMentionedJson),
      editedAt: _fromMs(entity.editedAtMs),
      attachments: _decodeMapList(entity.attachmentsJson),
      reactions: _decodeMapList(entity.reactionsJson),
      repliedMessageId: entity.repliedMessageId,
      forwardedMessageId: entity.forwardedMessageId,
    );
  }

  ChatMessageEntity _rowToMessageEntity(
    ChatMessage row, {
    ChatMessageEntity? existing,
  }) {
    final entity =
        existing ??
        ChatMessageEntity(
          uid: row.id,
          roomId: row.roomId,
          senderId: row.senderId,
          dataJson: row.data,
          createdAtMs: row.createdAt.millisecondsSinceEpoch,
          status: row.status.index,
        );
    entity.uid = row.id;
    entity.roomId = row.roomId;
    entity.senderId = row.senderId;
    entity.content = row.content;
    entity.nonce = row.nonce;
    entity.dataJson = row.data;
    entity.createdAtMs = row.createdAt.millisecondsSinceEpoch;
    entity.status = row.status.index;
    entity.isDeleted = row.isDeleted ?? false;
    entity.updatedAtMs = _toMs(row.updatedAt);
    entity.deletedAtMs = _toMs(row.deletedAt);
    entity.type = row.type;
    entity.metaJson = jsonEncode(row.meta);
    entity.membersMentionedJson = jsonEncode(row.membersMentioned);
    entity.editedAtMs = _toMs(row.editedAt);
    entity.attachmentsJson = jsonEncode(row.attachments);
    entity.reactionsJson = jsonEncode(row.reactions);
    entity.repliedMessageId = row.repliedMessageId;
    entity.forwardedMessageId = row.forwardedMessageId;
    return entity;
  }

  RealmEntity _realmToEntity(SnRealm realm, {RealmEntity? existing}) {
    final entity =
        existing ??
        RealmEntity(
          uid: realm.id,
          slug: realm.slug,
          isCommunity: realm.isCommunity,
          isPublic: realm.isPublic,
          createdAtMs: realm.createdAt.millisecondsSinceEpoch,
          updatedAtMs: realm.updatedAt.millisecondsSinceEpoch,
        );
    entity.uid = realm.id;
    entity.slug = realm.slug;
    entity.name = realm.name;
    entity.description = realm.description;
    entity.verifiedAs = realm.verifiedAs;
    entity.verifiedAtMs = _toMs(realm.verifiedAt);
    entity.isCommunity = realm.isCommunity;
    entity.isPublic = realm.isPublic;
    entity.pictureJson = realm.picture == null
        ? null
        : jsonEncode(realm.picture!.toJson());
    entity.backgroundJson = realm.background == null
        ? null
        : jsonEncode(realm.background!.toJson());
    entity.accountId = realm.accountId;
    entity.createdAtMs = realm.createdAt.millisecondsSinceEpoch;
    entity.updatedAtMs = realm.updatedAt.millisecondsSinceEpoch;
    entity.deletedAtMs = _toMs(realm.deletedAt);
    return entity;
  }

  ChatRoomEntity _roomToEntity(
    SnChatRoom room, {
    required bool isPinnedOverride,
    ChatRoomEntity? existing,
  }) {
    final entity =
        existing ??
        ChatRoomEntity(
          uid: room.id,
          type: room.type,
          createdAtMs: room.createdAt.millisecondsSinceEpoch,
          updatedAtMs: room.updatedAt.millisecondsSinceEpoch,
        );
    entity.uid = room.id;
    entity.name = room.name;
    entity.description = room.description;
    entity.type = room.type;
    entity.isPublic = room.isPublic;
    entity.isCommunity = room.isCommunity;
    entity.pictureJson = room.picture == null
        ? null
        : jsonEncode(room.picture!.toJson());
    entity.backgroundJson = room.background == null
        ? null
        : jsonEncode(room.background!.toJson());
    entity.realmId = room.realmId;
    entity.accountId = room.accountId;
    entity.isPinned = isPinnedOverride;
    entity.createdAtMs = room.createdAt.millisecondsSinceEpoch;
    entity.updatedAtMs = room.updatedAt.millisecondsSinceEpoch;
    entity.deletedAtMs = _toMs(room.deletedAt);
    return entity;
  }

  ChatMemberEntity _memberToEntity(
    SnChatMember member, {
    ChatMemberEntity? existing,
  }) {
    final entity =
        existing ??
        ChatMemberEntity(
          uid: member.id,
          chatRoomId: member.chatRoomId,
          accountId: member.accountId,
          accountJson: jsonEncode(member.account.toJson()),
          notify: member.notify,
          createdAtMs: member.createdAt.millisecondsSinceEpoch,
          updatedAtMs: member.updatedAt.millisecondsSinceEpoch,
        );
    entity.uid = member.id;
    entity.chatRoomId = member.chatRoomId;
    entity.accountId = member.accountId;
    entity.accountJson = jsonEncode(member.account.toJson());
    entity.nick = member.nick;
    entity.notify = member.notify;
    entity.joinedAtMs = _toMs(member.joinedAt);
    entity.breakUntilMs = _toMs(member.breakUntil);
    entity.timeoutUntilMs = _toMs(member.timeoutUntil);
    entity.createdAtMs = member.createdAt.millisecondsSinceEpoch;
    entity.updatedAtMs = member.updatedAt.millisecondsSinceEpoch;
    entity.deletedAtMs = _toMs(member.deletedAt);
    return entity;
  }

  PostDraftEntity _postToEntity(SnPost post, {PostDraftEntity? existing}) {
    final updatedAt = post.updatedAt ?? DateTime.now();
    final entity =
        existing ??
        PostDraftEntity(
          uid: post.id,
          visibility: post.visibility,
          type: post.type,
          lastModifiedMs: updatedAt.millisecondsSinceEpoch,
          postDataJson: jsonEncode(post.toJson()),
        );
    entity.uid = post.id;
    entity.title = post.title;
    entity.description = post.description;
    entity.content = post.content;
    entity.visibility = post.visibility;
    entity.type = post.type;
    entity.lastModifiedMs = updatedAt.millisecondsSinceEpoch;
    entity.postDataJson = jsonEncode(post.toJson());
    return entity;
  }

  PostDraft _draftEntityToRow(PostDraftEntity entity) {
    return PostDraft(
      id: entity.uid,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      visibility: entity.visibility,
      type: entity.type,
      lastModified: DateTime.fromMillisecondsSinceEpoch(entity.lastModifiedMs),
      postData: entity.postDataJson,
    );
  }

  ChatRoom _roomEntityToRow(ChatRoomEntity entity) {
    return ChatRoom(
      id: entity.uid,
      name: entity.name,
      description: entity.description,
      type: entity.type,
      isPublic: entity.isPublic,
      isCommunity: entity.isCommunity,
      picture: _decodeNullableMap(entity.pictureJson),
      background: _decodeNullableMap(entity.backgroundJson),
      realmId: entity.realmId,
      accountId: entity.accountId,
      isPinned: entity.isPinned,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAtMs),
      deletedAt: _fromMs(entity.deletedAtMs),
    );
  }

  ChatMember _memberEntityToRow(ChatMemberEntity entity) {
    return ChatMember(
      id: entity.uid,
      chatRoomId: entity.chatRoomId,
      accountId: entity.accountId,
      account: _decodeMap(entity.accountJson),
      nick: entity.nick,
      notify: entity.notify,
      joinedAt: _fromMs(entity.joinedAtMs),
      breakUntil: _fromMs(entity.breakUntilMs),
      timeoutUntil: _fromMs(entity.timeoutUntilMs),
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAtMs),
      deletedAt: _fromMs(entity.deletedAtMs),
    );
  }

  Realm _realmEntityToRow(RealmEntity entity) {
    return Realm(
      id: entity.uid,
      slug: entity.slug,
      name: entity.name,
      description: entity.description,
      verifiedAs: entity.verifiedAs,
      verifiedAt: _fromMs(entity.verifiedAtMs),
      isCommunity: entity.isCommunity,
      isPublic: entity.isPublic,
      picture: _decodeNullableMap(entity.pictureJson),
      background: _decodeNullableMap(entity.backgroundJson),
      accountId: entity.accountId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAtMs),
      deletedAt: _fromMs(entity.deletedAtMs),
    );
  }

  static int? _toMs(DateTime? value) => value?.millisecondsSinceEpoch;
  static DateTime? _fromMs(int? value) =>
      value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);

  static Map<String, dynamic> _decodeMap(String data) =>
      Map<String, dynamic>.from(jsonDecode(data) as Map);
  static Map<String, dynamic>? _decodeNullableMap(String? data) =>
      data == null ? null : _decodeMap(data);
  static List<Map<String, dynamic>> _decodeMapList(String data) =>
      (jsonDecode(data) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
  static List<String> _decodeStringList(String data) =>
      (jsonDecode(data) as List).map((e) => e.toString()).toList();
}

Future<String?> defaultObjectBoxDirectory() async {
  if (kIsWeb) return null;
  final base = Directory.current.path;
  return '$base/objectbox';
}
