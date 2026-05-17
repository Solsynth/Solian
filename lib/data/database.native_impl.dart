import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:island/data/message.dart';
import 'package:island/data/objectbox/entities.dart';
import 'package:island/objectbox.g.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class AppDatabase {
  AppDatabase.native(this._directoryPathFuture) : _isWeb = false;
  AppDatabase.web() : _isWeb = true, _directoryPathFuture = null;

  final bool _isWeb;
  final Future<String?>? _directoryPathFuture;
  final Map<String, SnPost> _webDraftStore = {};
  final Map<String, String> _nativeKvStore = {};
  bool _nativeKvLoaded = false;
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
    _nativeKvStore.clear();
    _nativeKvLoaded = false;
    final kvFile = await _nativeKvFile();
    if (kvFile != null && await kvFile.exists()) {
      await kvFile.delete();
    }
  }

  Future<T> transaction<T>(Future<T> Function() action) async {
    return action();
  }

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------

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

  Future<List<LocalChatMessage>> getMessagesForRoom(
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
    final entities = query.find();
    query.close();

    final results = <LocalChatMessage>[];
    for (final entity in entities) {
      results.add(await _entityToLocalChatMessage(entity));
    }
    return results;
  }

  Future<LocalChatMessage?> getMessageById(String id) async {
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
    return _entityToLocalChatMessage(entity);
  }

  Future<int> saveMessage(LocalChatMessage message) async {
    if (_isWeb) return 1;
    final store = await _getStore();
    if (store == null) return 0;
    final box = store.box<ChatMessageEntity>();
    final existing = box
        .query(ChatMessageEntity_.uid.equals(message.id))
        .build()
        .findFirst();
    final entity = _localChatMessageToEntity(message, existing: existing);
    box.put(entity);
    return 1;
  }

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

  Future<int> deleteMessagesForRoom(String roomId) async {
    if (_isWeb) return 0;
    final store = await _getStore();
    if (store == null) return 0;
    final box = store.box<ChatMessageEntity>();
    final query = box.query(ChatMessageEntity_.roomId.equals(roomId)).build();
    final count = query.count();
    final entities = query.find();
    query.close();
    if (entities.isEmpty) return 0;
    box.removeMany(entities.map((e) => e.obxId).toList());
    return count;
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
    final filtered = <LocalChatMessage>[];
    for (final msg in messageRows) {
      final contentText = (msg.content ?? '').toLowerCase();
      final metaText = jsonEncode(msg.meta).toLowerCase();
      final attachmentsText = jsonEncode(msg.attachments).toLowerCase();
      final typeText = msg.type.toLowerCase();

      final matchesQuery =
          query.isEmpty ||
          contentText.contains(lower) ||
          metaText.contains(lower) ||
          attachmentsText.contains(lower) ||
          typeText.contains(lower);
      if (!matchesQuery) continue;

      final matchesAttachmentFilter =
          withAttachments != true || msg.attachments.isNotEmpty;
      if (!matchesAttachmentFilter) continue;
      filtered.add(msg);
    }
    return filtered;
  }

  Future<int> saveMessageWithSender(LocalChatMessage message) async {
    if (message.sender != null) {
      await saveMember(message.sender!);
    }
    return saveMessage(message);
  }

  Future<int> saveMessagesWithSenders(List<LocalChatMessage> messages) async {
    if (_isWeb || messages.isEmpty) return 0;
    final store = await _getStore();
    if (store == null) return 0;

    var written = 0;
    store.runInTransaction(TxMode.write, () {
      final memberBox = store.box<ChatMemberEntity>();
      final messageBox = store.box<ChatMessageEntity>();

      for (final message in messages) {
        final sender = message.sender;
        if (sender != null) {
          final memberQuery = memberBox
              .query(ChatMemberEntity_.uid.equals(sender.id))
              .build();
          final existingMember = memberQuery.findFirst();
          memberQuery.close();
          memberBox.put(_memberToEntity(sender, existing: existingMember));
        }

        final messageQuery = messageBox
            .query(ChatMessageEntity_.uid.equals(message.id))
            .build();
        final existingMessage = messageQuery.findFirst();
        messageQuery.close();

        final entity = _localChatMessageToEntity(
          message,
          existing: existingMessage,
        );
        messageBox.put(entity);
        written += 1;
      }
    });
    return written;
  }

  // ---------------------------------------------------------------------------
  // Rooms
  // ---------------------------------------------------------------------------

  Future<List<SnChatRoom>> getAllChatRooms() async {
    if (_isWeb) return const [];
    final store = await _getStore();
    if (store == null) return const [];
    return store
        .box<ChatRoomEntity>()
        .getAll()
        .map(_entityToSnChatRoom)
        .toList();
  }

  Future<SnChatRoom?> getChatRoomById(String id) async {
    if (_isWeb) return null;
    final store = await _getStore();
    if (store == null) return null;
    final query = store
        .box<ChatRoomEntity>()
        .query(ChatRoomEntity_.uid.equals(id))
        .build();
    final entity = query.findFirst();
    query.close();
    if (entity == null) return null;
    return _entityToSnChatRoom(entity);
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
        final entity = _snChatRoomToEntity(
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

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  Future<List<SnChatMember>> getMembersByRoomId(String roomId) async {
    if (_isWeb) return const [];
    final store = await _getStore();
    if (store == null) return const [];
    final query = store
        .box<ChatMemberEntity>()
        .query(ChatMemberEntity_.chatRoomId.equals(roomId))
        .build();
    final list = query.find().map(_entityToSnChatMember).toList();
    query.close();
    return list;
  }

  Future<SnChatMember?> getMemberByRoomAndAccount(
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
    final entity = query.findFirst();
    query.close();
    if (entity == null) return null;
    return _entityToSnChatMember(entity);
  }

  Future<SnChatMember?> getMemberById(String id) async {
    if (_isWeb) return null;
    final store = await _getStore();
    if (store == null) return null;
    final query = store
        .box<ChatMemberEntity>()
        .query(ChatMemberEntity_.uid.equals(id))
        .build();
    final entity = query.findFirst();
    query.close();
    if (entity == null) return null;
    return _entityToSnChatMember(entity);
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

  // ---------------------------------------------------------------------------
  // Realms
  // ---------------------------------------------------------------------------

  Future<List<SnRealm>> getAllRealms() async {
    if (_isWeb) return const [];
    final store = await _getStore();
    if (store == null) return const [];
    return store.box<RealmEntity>().getAll().map(_entityToSnRealm).toList();
  }

  Future<SnRealm?> getRealmById(String id) async {
    if (_isWeb) return null;
    final store = await _getStore();
    if (store == null) return null;
    final query = store
        .box<RealmEntity>()
        .query(RealmEntity_.uid.equals(id))
        .build();
    final entity = query.findFirst();
    query.close();
    if (entity == null) return null;
    return _entityToSnRealm(entity);
  }

  // ---------------------------------------------------------------------------
  // Post drafts
  // ---------------------------------------------------------------------------

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
    final store = await _getStore();
    if (store == null) return const [];
    final entities = store.box<PostDraftEntity>().getAll()
      ..sort((a, b) => b.lastModifiedMs.compareTo(a.lastModifiedMs));
    return entities.map(_entityToSnPost).toList();
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
    final entity = _snPostToEntity(updatedPost, existing: existing);
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

  Future<SnPost?> getPostDraftById(String id) async {
    if (_isWeb) {
      return _webDraftStore[id];
    }
    final store = await _getStore();
    if (store == null) return null;
    final box = store.box<PostDraftEntity>();
    final query = box.query(PostDraftEntity_.uid.equals(id)).build();
    final entity = query.findFirst();
    query.close();
    if (entity == null) return null;
    return _entityToSnPost(entity);
  }

  // ---------------------------------------------------------------------------
  // Secrets / KV store
  // ---------------------------------------------------------------------------

  Future<String?> getSecret(String key) async {
    if (_isWeb) return null;
    await _loadNativeKvStore();
    return _nativeKvStore[key];
  }

  Future<void> setSecret(String key, String value) async {
    if (_isWeb) return;
    await _loadNativeKvStore();
    _nativeKvStore[key] = value;
    await _flushNativeKvStore();
  }

  Future<void> removeSecret(String key) async {
    if (_isWeb) return;
    await _loadNativeKvStore();
    if (_nativeKvStore.remove(key) == null) return;
    await _flushNativeKvStore();
  }

  Future<Map<String, String>> getAllSecrets() async {
    if (_isWeb) return const {};
    await _loadNativeKvStore();
    return Map<String, String>.from(_nativeKvStore);
  }

  Future<void> _loadNativeKvStore() async {
    if (_nativeKvLoaded) return;
    _nativeKvLoaded = true;
    final file = await _nativeKvFile();
    if (file == null || !await file.exists()) return;
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      _nativeKvStore
        ..clear()
        ..addAll(
          decoded.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          ),
        );
    } catch (_) {}
  }

  Future<void> _flushNativeKvStore() async {
    final file = await _nativeKvFile();
    if (file == null) return;
    await file.writeAsString(jsonEncode(_nativeKvStore), flush: true);
  }

  Future<File?> _nativeKvFile() async {
    if (_directoryPathFuture == null) return null;
    final directoryPath = await _directoryPathFuture;
    if (directoryPath == null) return null;
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/app_kv_store.json');
  }

  // ---------------------------------------------------------------------------
  // Entity adapters: ChatMessageEntity <-> LocalChatMessage
  // ---------------------------------------------------------------------------

  Future<LocalChatMessage> _entityToLocalChatMessage(
    ChatMessageEntity entity,
  ) async {
    final dataJson = entity.dataJson;
    final data = dataJson.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(dataJson) as Map<String, dynamic>;

    final senderSnapshot = _parseSenderSnapshot(data['sender']);
    SnChatMember? sender;

    try {
      final senderEntity = await _loadMemberEntity(entity.senderId);
      if (senderEntity != null) {
        sender = _entityToSnChatMember(senderEntity);
      }
    } catch (_) {}

    sender = _mergeSenderSnapshot(sender, senderSnapshot);

    sender ??= senderSnapshot;

    sender ??= _unknownSender(entity.senderId, entity.roomId);

    return LocalChatMessage(
      id: entity.uid,
      roomId: entity.roomId,
      senderId: entity.senderId,
      sender: sender,
      data: data,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtMs),
      status: MessageStatus.values[entity.status],
      clientMessageId: entity.clientMessageId,
      nonce: entity.nonce,
      content: entity.content,
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

  ChatMessageEntity _localChatMessageToEntity(
    LocalChatMessage message, {
    ChatMessageEntity? existing,
  }) {
    final dataJson = message.toDataJson();
    final entity =
        existing ??
        ChatMessageEntity(
          uid: message.id,
          roomId: message.roomId,
          senderId: message.senderId,
          dataJson: dataJson,
          createdAtMs: message.createdAt.millisecondsSinceEpoch,
          status: message.status.index,
        );
    entity.uid = message.id;
    entity.roomId = message.roomId;
    entity.senderId = message.senderId;
    entity.content = message.content;
    entity.clientMessageId = message.clientMessageId;
    entity.nonce = message.nonce;
    entity.dataJson = dataJson;
    entity.createdAtMs = message.createdAt.millisecondsSinceEpoch;
    entity.status = message.status.index;
    entity.isDeleted = message.isDeleted ?? false;
    entity.updatedAtMs = _toMs(message.updatedAt);
    entity.deletedAtMs = _toMs(message.deletedAt);
    entity.type = message.type;
    entity.metaJson = jsonEncode(message.meta);
    entity.membersMentionedJson = jsonEncode(message.membersMentioned);
    entity.editedAtMs = _toMs(message.editedAt);
    entity.attachmentsJson = jsonEncode(message.attachments);
    entity.reactionsJson = jsonEncode(message.reactions);
    entity.repliedMessageId = message.repliedMessageId;
    entity.forwardedMessageId = message.forwardedMessageId;
    return entity;
  }

  // ---------------------------------------------------------------------------
  // Entity adapters: ChatRoomEntity <-> SnChatRoom
  // ---------------------------------------------------------------------------

  SnChatRoom _entityToSnChatRoom(ChatRoomEntity entity) {
    return SnChatRoom(
      id: entity.uid,
      name: entity.name,
      description: entity.description,
      type: entity.type,
      encryptionMode: 0,
      isPublic: entity.isPublic,
      isCommunity: entity.isCommunity,
      picture: entity.pictureJson != null
          ? SnCloudFileReference.fromJson(_decodeMap(entity.pictureJson!))
          : null,
      background: entity.backgroundJson != null
          ? SnCloudFileReference.fromJson(_decodeMap(entity.backgroundJson!))
          : null,
      realmId: entity.realmId,
      accountId: entity.accountId,
      mlsGroupId: entity.mlsGroupId,
      realm: null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAtMs),
      deletedAt: _fromMs(entity.deletedAtMs),
      members: null,
      isPinned: entity.isPinned,
    );
  }

  ChatRoomEntity _snChatRoomToEntity(
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
    entity.mlsGroupId = room.mlsGroupId;
    entity.isPinned = isPinnedOverride;
    entity.createdAtMs = room.createdAt.millisecondsSinceEpoch;
    entity.updatedAtMs = room.updatedAt.millisecondsSinceEpoch;
    entity.deletedAtMs = _toMs(room.deletedAt);
    return entity;
  }

  // ---------------------------------------------------------------------------
  // Entity adapters: ChatMemberEntity <-> SnChatMember
  // ---------------------------------------------------------------------------

  SnChatMember _entityToSnChatMember(ChatMemberEntity entity) {
    return SnChatMember(
      id: entity.uid,
      chatRoomId: entity.chatRoomId,
      accountId: entity.accountId,
      account: SnAccount.fromJson(_decodeMap(entity.accountJson)),
      nick: entity.nick,
      notify: entity.notify,
      joinedAt: _fromMs(entity.joinedAtMs),
      breakUntil: _fromMs(entity.breakUntilMs),
      timeoutUntil: _fromMs(entity.timeoutUntilMs),
      status: null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAtMs),
      deletedAt: _fromMs(entity.deletedAtMs),
      chatRoom: null,
      realmNick: null,
      realmBio: null,
      realmExperience: null,
      realmLevel: null,
      realmLevelingProgress: null,
      realmLabel: null,
      lastTyped: null,
      lastReadAt: null,
    );
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

  Future<ChatMemberEntity?> _loadMemberEntity(String id) async {
    final store = await _getStore();
    if (store == null) return null;
    final query = store
        .box<ChatMemberEntity>()
        .query(ChatMemberEntity_.uid.equals(id))
        .build();
    final entity = query.findFirst();
    query.close();
    return entity;
  }

  // ---------------------------------------------------------------------------
  // Entity adapters: RealmEntity <-> SnRealm
  // ---------------------------------------------------------------------------

  SnRealm _entityToSnRealm(RealmEntity entity) {
    return SnRealm(
      id: entity.uid,
      slug: entity.slug,
      name: entity.name ?? entity.slug,
      description: entity.description ?? '',
      verifiedAs: entity.verifiedAs,
      verifiedAt: _fromMs(entity.verifiedAtMs),
      isCommunity: entity.isCommunity,
      isPublic: entity.isPublic,
      picture: entity.pictureJson != null
          ? SnCloudFileReference.fromJson(_decodeMap(entity.pictureJson!))
          : null,
      background: entity.backgroundJson != null
          ? SnCloudFileReference.fromJson(_decodeMap(entity.backgroundJson!))
          : null,
      accountId: entity.accountId ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAtMs),
      deletedAt: _fromMs(entity.deletedAtMs),
    );
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

  // ---------------------------------------------------------------------------
  // Entity adapters: PostDraftEntity <-> SnPost
  // ---------------------------------------------------------------------------

  SnPost _entityToSnPost(PostDraftEntity entity) {
    return SnPost.fromJson(jsonDecode(entity.postDataJson));
  }

  PostDraftEntity _snPostToEntity(SnPost post, {PostDraftEntity? existing}) {
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

  // ---------------------------------------------------------------------------
  // Sender helpers
  // ---------------------------------------------------------------------------

  SnChatMember? _parseSenderSnapshot(dynamic raw) {
    if (raw is! Map) return null;
    try {
      return SnChatMember.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  SnChatMember? _mergeSenderSnapshot(
    SnChatMember? primary,
    SnChatMember? fallback,
  ) {
    if (primary == null) return fallback;
    if (fallback == null) return primary;

    final hasPrimaryRealmData =
        primary.realmLabel != null ||
        (primary.realmNick?.isNotEmpty ?? false) ||
        (primary.realmBio?.isNotEmpty ?? false) ||
        primary.realmExperience != null ||
        primary.realmLevel != null ||
        primary.realmLevelingProgress != null;

    return primary.copyWith(
      account: primary.account.id != 'unknown'
          ? primary.account
          : fallback.account,
      nick: (primary.nick?.isNotEmpty == true) ? primary.nick : fallback.nick,
      notify: primary.notify != 0 ? primary.notify : fallback.notify,
      joinedAt: primary.joinedAt ?? fallback.joinedAt,
      breakUntil: primary.breakUntil ?? fallback.breakUntil,
      timeoutUntil: primary.timeoutUntil ?? fallback.timeoutUntil,
      createdAt: primary.createdAt,
      updatedAt: primary.updatedAt,
      deletedAt: primary.deletedAt ?? fallback.deletedAt,
      realmNick: hasPrimaryRealmData ? primary.realmNick : fallback.realmNick,
      realmBio: hasPrimaryRealmData ? primary.realmBio : fallback.realmBio,
      realmExperience: primary.realmExperience ?? fallback.realmExperience,
      realmLevel: primary.realmLevel ?? fallback.realmLevel,
      realmLevelingProgress:
          primary.realmLevelingProgress ?? fallback.realmLevelingProgress,
      realmLabel: primary.realmLabel ?? fallback.realmLabel,
    );
  }

  SnChatMember _unknownSender(String senderId, String roomId) {
    return SnChatMember(
      id: 'unknown',
      chatRoomId: roomId,
      accountId: senderId,
      account: SnAccount(
        id: 'unknown',
        name: 'unknown',
        nick: senderId,
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
      nick: senderId,
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
      realmNick: '',
      realmBio: '',
      realmExperience: null,
      realmLevel: null,
      realmLevelingProgress: null,
      realmLabel: null,
      lastReadAt: null,
    );
  }

  // ---------------------------------------------------------------------------
  // JSON helpers
  // ---------------------------------------------------------------------------

  static int? _toMs(DateTime? value) => value?.millisecondsSinceEpoch;
  static DateTime? _fromMs(int? value) =>
      value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);

  static Map<String, dynamic> _decodeMap(String data) =>
      Map<String, dynamic>.from(jsonDecode(data) as Map);
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
