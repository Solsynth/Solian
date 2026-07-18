import 'dart:async';
import 'package:island/data/database.web_impl.dart' as memory;
import 'package:island/data/drift_store.dart';
import 'package:island/data/legacy_objectbox_cleanup.dart';
import 'package:island/data/message.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Native AppDatabase implementation backed by Drift.
///
/// The app continues to use the established [AppDatabase] API while Drift owns
/// durable storage. This deliberately starts from an empty store; old ObjectBox
/// caches are removed through the existing Storage Settings reset action and
/// then rebuilt by normal sync.
class AppDatabase {
  AppDatabase.native(this._legacyDirectoryPath)
    : _store = _legacyDirectoryPath.then(DriftStore.new);

  AppDatabase.web()
    : _legacyDirectoryPath = Future<String?>.value(null),
      _store = null;

  final Future<String?> _legacyDirectoryPath;
  final Future<DriftStore>? _store;
  final memory.AppDatabase _memory = memory.AppDatabase.web();
  Future<void>? _restoreOperation;

  Future<void> _ensureReady() {
    final storeFuture = _store;
    if (storeFuture == null) return Future.value();
    return _restoreOperation ??= () async {
      final store = await storeFuture;
      final state = await store.readSnapshot();
      if (state != null) _memory.restoreState(state);
    }();
  }

  Future<T> _read<T>(Future<T> Function() action) async {
    await _ensureReady();
    return action();
  }

  Future<T> _write<T>(Future<T> Function() action) async {
    await _ensureReady();
    final result = await action();
    final store = await _store;
    await store?.writeSnapshot(_memory.exportState());
    return result;
  }

  Future<void> close() async {
    await (await _store)?.close();
  }

  Future<void> reset() async {
    await _write(() async {
      await _memory.reset();
      await (await _store)?.clear();
    });

    // The Storage Settings reset is the explicit opt-in cleanup path for the
    // retired ObjectBox store. Drift is reopened through a new provider after
    // resetDatabase invalidates this instance.
    await (await _store)?.close();
    await removeLegacyObjectBoxFiles(await _legacyDirectoryPath);
  }

  Future<Map<String, int>> getDatabaseStats() =>
      _read(_memory.getDatabaseStats);

  Future<T> transaction<T>(Future<T> Function() action) => _write(action);

  Future<int> getLatestMessageTimestamp() =>
      _read(_memory.getLatestMessageTimestamp);
  Future<int> countMessagesNewerThan(String roomId, DateTime createdAt) =>
      _read(() => _memory.countMessagesNewerThan(roomId, createdAt));
  Future<List<LocalChatMessage>> getMessagesForRoom(
    String roomId, {
    int offset = 0,
    int limit = 20,
  }) => _read(
    () => _memory.getMessagesForRoom(roomId, offset: offset, limit: limit),
  );
  Future<LocalChatMessage?> getMessageById(String id) =>
      _read(() => _memory.getMessageById(id));
  Future<int> saveMessage(LocalChatMessage message) =>
      _write(() => _memory.saveMessage(message));
  Future<int> updateMessageStatus(String id, MessageStatus status) =>
      _write(() => _memory.updateMessageStatus(id, status));
  Future<int> deleteMessage(String id) =>
      _write(() => _memory.deleteMessage(id));
  Future<int> deleteMessagesForRoom(String roomId) =>
      _write(() => _memory.deleteMessagesForRoom(roomId));
  Future<int> getTotalMessagesForRoom(String roomId) =>
      _read(() => _memory.getTotalMessagesForRoom(roomId));
  Future<Map<String, int>> getChatRoomMessageStats() =>
      _read(_memory.getChatRoomMessageStats);
  Future<List<LocalChatMessage>> searchMessages(
    String roomId,
    String query, {
    bool? withAttachments,
    Future<SnAccount?> Function(String accountId)? fetchAccount,
  }) => _read(
    () => _memory.searchMessages(
      roomId,
      query,
      withAttachments: withAttachments,
      fetchAccount: fetchAccount,
    ),
  );
  Future<int> saveMessageWithSender(LocalChatMessage message) =>
      _write(() => _memory.saveMessageWithSender(message));
  Future<int> saveMessagesWithSenders(List<LocalChatMessage> messages) =>
      _write(() => _memory.saveMessagesWithSenders(messages));

  Future<List<SnChatRoom>> getAllChatRooms() => _read(_memory.getAllChatRooms);
  Future<SnChatRoom?> getChatRoomById(String id) =>
      _read(() => _memory.getChatRoomById(id));
  Future<void> saveChatRooms(List<SnChatRoom> rooms, {bool override = false}) =>
      _write(() => _memory.saveChatRooms(rooms, override: override));
  Future<void> toggleChatRoomPinned(String roomId) =>
      _write(() => _memory.toggleChatRoomPinned(roomId));
  Future<List<SnChatGroup>> getChatGroups(String accountId) =>
      _read(() => _memory.getChatGroups(accountId));
  Future<void> saveChatGroups(String accountId, List<SnChatGroup> groups) =>
      _write(() => _memory.saveChatGroups(accountId, groups));
  Future<void> assignChatRoomToGroup(
    String accountId,
    String roomId, {
    String? groupId,
  }) => _write(
    () => _memory.assignChatRoomToGroup(accountId, roomId, groupId: groupId),
  );
  Future<List<SnChatMember>> getMembersByRoomId(String roomId) =>
      _read(() => _memory.getMembersByRoomId(roomId));
  Future<SnChatMember?> getMemberByRoomAndAccount(
    String roomId,
    String accountId,
  ) => _read(() => _memory.getMemberByRoomAndAccount(roomId, accountId));
  Future<SnChatMember?> getMemberById(String id) =>
      _read(() => _memory.getMemberById(id));
  Future<void> saveMember(SnChatMember member) =>
      _write(() => _memory.saveMember(member));
  Future<List<SnRealm>> getAllRealms() => _read(_memory.getAllRealms);
  Future<SnRealm?> getRealmById(String id) =>
      _read(() => _memory.getRealmById(id));

  Future<List<SnPost>> getAllPostDrafts() => _read(_memory.getAllPostDrafts);
  Future<List<SnPost>> searchPostDrafts(String query) =>
      _read(() => _memory.searchPostDrafts(query));
  Future<void> addPostDraftFromPost(SnPost post) =>
      _write(() => _memory.addPostDraftFromPost(post));
  Future<void> deletePostDraft(String id) =>
      _write(() => _memory.deletePostDraft(id));
  Future<void> clearAllPostDrafts() => _write(_memory.clearAllPostDrafts);
  Future<SnPost?> getPostDraftById(String id) =>
      _read(() => _memory.getPostDraftById(id));

  Future<SnSticker?> getStickerLookup(String identifier) =>
      _read(() => _memory.getStickerLookup(identifier));
  Future<void> setStickerLookup(String identifier, SnSticker sticker) =>
      _write(() => _memory.setStickerLookup(identifier, sticker));
  Future<void> clearStickerLookups() => _write(_memory.clearStickerLookups);

  Future<String?> getSecret(String key) => _read(() => _memory.getSecret(key));
  Future<void> setSecret(String key, String value) =>
      _write(() => _memory.setSecret(key, value));
  Future<void> removeSecret(String key) =>
      _write(() => _memory.removeSecret(key));
  Future<Map<String, String>> getAllSecrets() => _read(_memory.getAllSecrets);

  Future<List<SnRelationship>> getAllRelationships() =>
      _read(_memory.getAllRelationships);
  Future<SnRelationship?> getRelationshipById(String id) =>
      _read(() => _memory.getRelationshipById(id));
  Future<SnRelationship?> getRelationshipByAccounts(
    String accountId,
    String relatedId,
  ) => _read(() => _memory.getRelationshipByAccounts(accountId, relatedId));
  Future<void> saveRelationships(List<SnRelationship> relationships) =>
      _write(() => _memory.saveRelationships(relationships));
  Future<void> deleteRelationship(String accountId, String relatedId) =>
      _write(() => _memory.deleteRelationship(accountId, relatedId));
  Future<List<String>> getBlockedAccountIds(String accountId) =>
      _read(() => _memory.getBlockedAccountIds(accountId));
  Future<List<String>> getMutedAccountIds(String accountId) =>
      _read(() => _memory.getMutedAccountIds(accountId));
  Future<List<String>> getCloseFriendAccountIds(String accountId) =>
      _read(() => _memory.getCloseFriendAccountIds(accountId));
  Future<Map<String, int>> getRelationshipStats() =>
      _read(_memory.getRelationshipStats);
}
