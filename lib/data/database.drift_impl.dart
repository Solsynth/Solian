import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:island/data/database_logic.dart' as memory;
import 'package:island/data/drift_store.dart';
import 'package:island/data/legacy_database_cleanup.dart';
import 'package:island/data/message.dart';
import 'package:island/data/snapshot_exporter.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// App database implementation backed by Drift on every supported platform.
///
/// The app continues to use the established [AppDatabase] API while Drift owns
/// durable storage. This deliberately starts from an empty store; legacy data
/// can be removed through the existing Storage Settings reset action and then
/// rebuilt by normal sync.
class AppDatabase {
  // Snapshotting serializes the complete in-memory database, so do it after a
  // burst settles rather than at a fixed cadence while a paginated list is
  // actively loading. Lifecycle operations and durable writes still bypass
  // this delay through [_flushAllPersistence].
  static const _persistenceDebounce = Duration(seconds: 1);

  AppDatabase.native(
    Future<String?> directoryPath, {
    Future<String?>? legacyDirectoryPath,
  }) : _legacyDirectoryPath = legacyDirectoryPath ?? Future.value(null),
       _store = directoryPath.then(DriftStore.new);

  AppDatabase.web()
    : _legacyDirectoryPath = Future<String?>.value(null),
      _store = Future.value(DriftStore(null));

  final Future<String?> _legacyDirectoryPath;
  final Future<DriftStore> _store;
  final memory.AppDatabase _memory = memory.AppDatabase.web();
  Future<void>? _restoreOperation;
  Future<void> _persistenceTail = Future.value();
  Timer? _persistenceTimer;
  bool _persistenceNeeded = false;
  int _transactionDepth = 0;

  Future<void> _ensureReady() {
    return _restoreOperation ??= () async {
      final store = await _store;
      final state = await store.readSnapshot();
      if (state != null) _memory.restoreState(state);
      final messages = await store.readMessagePayloads();
      if (messages.isNotEmpty) {
        _memory.restoreMessagePayloads(messages);
      } else if (state?['messages'] is Map) {
        // One-time migration from the old all-in-one JSON snapshot.
        final legacyMessages = Map<String, dynamic>.from(
          state!['messages'] as Map,
        );
        for (final entry in legacyMessages.entries) {
          final payload = entry.value;
          if (payload is! Map) continue;
          final message = Map<String, dynamic>.from(payload);
          final roomId = message['roomId']?.toString();
          if (roomId == null) continue;
          await store.writeMessagePayload(
            entry.key,
            roomId,
            jsonEncode(message),
          );
        }
      }
    }();
  }

  Future<T> _read<T>(Future<T> Function() action) async {
    await _ensureReady();
    return action();
  }

  Future<T> _write<T>(
    Future<T> Function() action, {
    bool durable = false,
  }) async {
    await _ensureReady();
    final result = await action();
    if (_transactionDepth > 0) return result;
    _schedulePersistence();
    if (durable) await _flushAllPersistence();
    return result;
  }

  /// Coalesce bursty edits and message syncs into one snapshot write. The
  /// in-memory state remains immediately visible to callers; [close] and
  /// [reset] flush this queue before releasing the store.
  void _schedulePersistence() {
    _persistenceNeeded = true;
    // This must be a trailing debounce. Leaving the existing timer in place
    // turns a sustained stream of writes (for example, fast chat scrolling)
    // into a full snapshot write every debounce interval.
    _persistenceTimer?.cancel();
    _persistenceTimer = Timer(_persistenceDebounce, () {
      _persistenceTimer = null;
      // Timer callbacks cannot await errors. A later write will enqueue a
      // fresh snapshot, while close still awaits the currently queued write.
      unawaited(_flushPersistence().catchError((_) {}));
    });
  }

  Future<void> _flushPersistence() async {
    _persistenceTimer?.cancel();
    _persistenceTimer = null;
    if (!_persistenceNeeded) return;

    _persistenceNeeded = false;
    final previous = _persistenceTail.catchError((_) {});
    final operation = previous.then((_) async {
      // Queue capture, encoding, and writing together. Capturing before the
      // queue would let a slow older encoder overwrite a newer snapshot.
      // Encoding still runs in a worker isolate on native platforms.
      final payload = await encodeDatabaseSnapshot(_memory);
      await (await _store).writeSnapshotPayload(payload);
    });
    _persistenceTail = operation;
    await operation;
  }

  Future<void> _flushAllPersistence() async {
    await _flushPersistence();
    await _persistenceTail;
  }

  Future<void> close() async {
    await _flushAllPersistence();
    await (await _store).close();
  }

  Future<void> reset() async {
    await _ensureReady();
    await _flushAllPersistence();
    await _memory.reset();
    await (await _store).clear();

    // Reset is the explicit opt-in cleanup path for the retired database
    // directory. Drift is reopened through a new provider after resetDatabase
    // invalidates this instance.
    await (await _store).close();
    await removeLegacyDatabaseFiles(await _legacyDirectoryPath);
  }

  Future<Map<String, int>> getDatabaseStats() async {
    await _ensureReady();
    final stats = await _memory.getDatabaseStats();
    stats['accounts'] = (await (await _store).readEntities('accounts')).length;
    return stats;
  }

  /// Runs a best-effort atomic mutation of the in-memory cache and persists
  /// the resulting state before returning. Callers must not start unrelated
  /// writes while [action] is awaiting external work.
  Future<T> transaction<T>(Future<T> Function() action) async {
    if (_transactionDepth > 0) return action();

    await _ensureReady();
    final rollbackState = _memory.exportState();
    _transactionDepth += 1;
    try {
      final result = await action();
      _transactionDepth -= 1;
      _schedulePersistence();
      await _flushAllPersistence();
      return result;
    } catch (_) {
      _transactionDepth -= 1;
      _memory.restoreState(rollbackState);
      _schedulePersistence();
      await _flushAllPersistence();
      rethrow;
    }
  }

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
  Future<int> saveMessage(LocalChatMessage message) async {
    await _ensureReady();
    final result = await _memory.saveMessage(message);
    await _writeMessage(message.id);
    return result;
  }

  Future<int> updateMessageStatus(String id, MessageStatus status) async {
    await _ensureReady();
    final result = await _memory.updateMessageStatus(id, status);
    if (result > 0) await _writeMessage(id);
    return result;
  }

  Future<int> deleteMessage(String id) async {
    await _ensureReady();
    final result = await _memory.deleteMessage(id);
    if (result > 0) await (await _store).deleteMessage(id);
    return result;
  }

  Future<int> deleteMessagesForRoom(String roomId) async {
    await _ensureReady();
    final result = await _memory.deleteMessagesForRoom(roomId);
    if (result > 0) await (await _store).deleteMessagesForRoom(roomId);
    return result;
  }

  Future<void> deleteChatRoomLocalData(String roomId) async {
    await transaction(() async {
      await _memory.deleteChatRoomLocalData(roomId);
      await (await _store).deleteMessagesForRoom(roomId);
    });
  }

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
  Future<List<LocalChatMessage>> searchMessagesAcrossRooms(
    String query, {
    bool? withAttachments,
  }) => _read(
    () => _memory.searchMessagesAcrossRooms(
      query,
      withAttachments: withAttachments,
    ),
  );
  Future<int> saveMessageWithSender(LocalChatMessage message) =>
      saveMessage(message);
  Future<int> saveMessagesWithSenders(List<LocalChatMessage> messages) async {
    await _ensureReady();
    final result = await _memory.saveMessagesWithSenders(messages);
    for (final message in messages) {
      await _writeMessage(message.id);
    }
    return result;
  }

  Future<void> _writeMessage(String id) async {
    final payload = _memory.getMessagePayload(id);
    if (payload == null) return;
    final roomId = payload['roomId']?.toString();
    if (roomId == null) return;
    await (await _store).writeMessagePayload(id, roomId, jsonEncode(payload));
  }

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

  /// True when the account carries a server-fabricated profile shell (random
  /// id, no name/bio/picture) rather than real data. Such shells must never
  /// be cached or served back.
  static bool _isBareProfile(SnAccount account) {
    final profile = account.profile;
    return profile.id.trim().isEmpty ||
        (profile.firstName.trim().isEmpty &&
            profile.lastName.trim().isEmpty &&
            profile.bio.trim().isEmpty &&
            profile.picture == null);
  }

  Future<void> saveAccount(
    SnAccount account, {
    String source = 'unknown account endpoint',
  }) async {
    await _ensureReady();
    // A server-side fallback can fabricate a profile shell (random id, only
    // account_id set) when the profile row is missing; real accounts always
    // carry a name. Refuse to cache such shells so a transient empty profile
    // never overwrites a good cached copy.
    if (_isBareProfile(account)) {
      final error = StateError(
        'Refusing to cache account ${account.id}: empty profile from $source',
      );
      final stackTrace = StackTrace.current;
      developer.log(
        error.toString(),
        name: 'AppDatabase.accountCache',
        error: error,
        stackTrace: stackTrace,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
    await (await _store).writeEntity('accounts', account.id, account.toJson());
  }

  Future<SnAccount?> getAccountById(String id) async {
    await _ensureReady();
    final rows = await (await _store).readEntities('accounts');
    for (final row in rows) {
      if (row['id']?.toString() != id) continue;
      final payload = row['payload'];
      if (payload is! Map) return null;
      try {
        final account = SnAccount.fromJson(Map<String, dynamic>.from(payload));
        if (_isBareProfile(account)) return null;
        return account;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<SnAccount?> getAccountByUsername(String username) async {
    await _ensureReady();
    final rows = await (await _store).readEntities('accounts');
    for (final row in rows) {
      final payload = row['payload'];
      if (payload is! Map) continue;
      final map = Map<String, dynamic>.from(payload);
      if (map['name']?.toString() != username &&
          map['nick']?.toString() != username) {
        continue;
      }
      try {
        final account = SnAccount.fromJson(map);
        if (_isBareProfile(account)) continue;
        return account;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

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
      _write(() => _memory.setSecret(key, value), durable: true);
  Future<void> removeSecret(String key) =>
      _write(() => _memory.removeSecret(key), durable: true);
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
