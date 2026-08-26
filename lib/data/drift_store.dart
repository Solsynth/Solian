import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:island/data/drift_store_connection.dart';

/// Low-level normalized store. Each cached top-level data type has its own
/// table; rows retain the serialized model only as a compatibility boundary
/// while callers are migrated to typed Drift queries.
class DriftStore {
  DriftStore(String? directoryPath)
    : _connection = openDriftConnection(directoryPath);

  final DatabaseConnection _connection;
  Future<void>? _opening;

  static const _tables = <String>{
    'accounts',
    'chat_rooms',
    'chat_members',
    'chat_groups',
    'realms',
    'post_drafts',
    'sticker_lookups',
    'relationships',
    'secrets',
  };

  Future<void> _open() => _opening ??= () async {
    await _connection.executor.ensureOpen(_DriftStoreSchema());
    // The old snapshot is intentionally not migrated. This is a cache and
    // remote sync is the source of truth for all non-secret data.
    final legacySnapshot = await _connection.executor.runSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'app_state'",
      const [],
    );
    if (legacySnapshot.isNotEmpty) {
      await _connection.executor.runCustom(
        'DROP TABLE IF EXISTS chat_messages',
      );
      for (final table in const [
        'message_attachments',
        'message_reactions',
        'message_mentions',
        'chat_group_rooms',
      ]) {
        await _connection.executor.runCustom('DROP TABLE IF EXISTS $table');
      }
    }
    await _connection.executor.runCustom('DROP TABLE IF EXISTS app_state');
    for (final table in _tables) {
      if (table == 'accounts') {
        await _connection.executor.runCustom('''
          CREATE TABLE IF NOT EXISTS accounts (
            id TEXT PRIMARY KEY,
            username TEXT,
            profile_json TEXT NOT NULL,
            payload TEXT NOT NULL
          )
        ''');
        await _connection.executor.runCustom(
          'CREATE INDEX IF NOT EXISTS accounts_username ON accounts(username)',
        );
        continue;
      }
      await _connection.executor.runCustom('''
        CREATE TABLE IF NOT EXISTS $table (
          id TEXT PRIMARY KEY,
          payload TEXT NOT NULL
        )
      ''');
    }
    await _connection.executor.runCustom('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL,
        payload TEXT NOT NULL
      )
    ''');
    for (final table in const [
      'message_attachments',
      'message_reactions',
      'message_mentions',
    ]) {
      await _connection.executor.runCustom('''
        CREATE TABLE IF NOT EXISTS $table (
          message_id TEXT NOT NULL,
          position INTEGER NOT NULL,
          payload TEXT NOT NULL,
          PRIMARY KEY(message_id, position),
          FOREIGN KEY(message_id) REFERENCES chat_messages(id) ON DELETE CASCADE
        )
      ''');
    }
    await _connection.executor.runCustom('''
      CREATE TABLE IF NOT EXISTS chat_group_rooms (
        group_id TEXT NOT NULL,
        room_id TEXT NOT NULL,
        position INTEGER NOT NULL,
        PRIMARY KEY(group_id, room_id)
      )
    ''');
    await _connection.executor.runCustom(
      'CREATE INDEX IF NOT EXISTS chat_messages_room_id ON chat_messages(room_id)',
    );
  }();

  Future<Map<String, dynamic>?> readSnapshot() async {
    await _open();
    final result = <String, dynamic>{};
    for (final table in _tables) {
      final rows = await _connection.executor.runSelect(
        'SELECT id, payload FROM $table',
        const [],
      );
      final values = <String, dynamic>{};
      final groupedValues = <String, List<dynamic>>{};
      for (final row in rows) {
        final id = row['id'];
        final payload = row['payload'];
        if (id is! String || payload is! String) continue;
        try {
          final decoded = jsonDecode(payload);
          if (table == 'chat_groups' && decoded is Map) {
            final accountId = decoded['account_id']?.toString() ?? '';
            groupedValues.putIfAbsent(accountId, () => []).add(decoded);
          } else {
            values[id] = decoded;
          }
        } on FormatException {
          // Ignore corrupt cache rows; normal sync can restore them.
        }
      }
      result[_stateKeyForTable(table)] = table == 'chat_groups'
          ? groupedValues
          : values;
    }
    return result;
  }

  Future<void> writeSnapshotPayload(String payload) async {
    await _open();
    final decoded = jsonDecode(payload);
    if (decoded is! Map) return;
    for (final table in _tables) {
      final key = _stateKeyForTable(table);
      final raw = decoded[key];
      if (raw is! Map) continue;
      await _connection.executor.runCustom('DELETE FROM $table');
      for (final entry in raw.entries) {
        await _writeEntity(table, entry.key.toString(), entry.value);
      }
    }
  }

  String _stateKeyForTable(String table) => switch (table) {
    'chat_rooms' => 'rooms',
    'chat_members' => 'members',
    'chat_groups' => 'groups',
    'post_drafts' => 'drafts',
    'sticker_lookups' => 'stickers',
    'secrets' => 'secrets',
    _ => table,
  };

  Future<void> _writeEntity(String table, String id, Object value) async {
    if (table == 'chat_groups' && value is List) {
      for (final item in value) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final groupId = map['id']?.toString();
        if (groupId == null) continue;
        await _writeEntity(table, groupId, map);
      }
      return;
    }
    if (table == 'accounts' && value is Map) {
      final map = Map<String, dynamic>.from(value);
      final profile = map['profile'];
      await _connection.executor.runCustom(
        'INSERT INTO accounts(id, username, profile_json, payload) VALUES (?, ?, ?, ?) '
        'ON CONFLICT(id) DO UPDATE SET username = excluded.username, '
        'profile_json = excluded.profile_json, payload = excluded.payload',
        [
          id,
          map['name']?.toString(),
          jsonEncode(profile is Map ? profile : <String, dynamic>{}),
          jsonEncode(value),
        ],
      );
      return;
    }
    await _connection.executor.runCustom(
      'INSERT INTO $table(id, payload) VALUES (?, ?) '
      'ON CONFLICT(id) DO UPDATE SET payload = excluded.payload',
      [id, jsonEncode(value)],
    );
    if (table == 'chat_groups' && value is Map) {
      final map = Map<String, dynamic>.from(value);
      await _connection.executor.runCustom(
        'DELETE FROM chat_group_rooms WHERE group_id = ?',
        [id],
      );
      final rooms = map['room_ids'];
      if (rooms is List) {
        for (var index = 0; index < rooms.length; index++) {
          await _connection.executor.runCustom(
            'INSERT INTO chat_group_rooms(group_id, room_id, position) VALUES (?, ?, ?)',
            [id, rooms[index].toString(), index],
          );
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> readEntities(String table) async {
    await _open();
    final rows = await _connection.executor.runSelect(
      'SELECT id, payload FROM $table',
      const [],
    );
    return rows
        .where((row) => row['id'] is String && row['payload'] is String)
        .map(
          (row) => <String, dynamic>{
            'id': row['id'],
            'payload': jsonDecode(row['payload'] as String),
          },
        )
        .toList();
  }

  Future<void> writeEntity(String table, String id, Object value) async {
    await _open();
    await _writeEntity(table, id, value);
  }

  Future<void> deleteEntity(String table, String id) async {
    await _open();
    await _connection.executor.runCustom('DELETE FROM $table WHERE id = ?', [
      id,
    ]);
  }

  Future<void> clearTable(String table) async {
    await _open();
    await _connection.executor.runCustom('DELETE FROM $table');
  }

  Future<Map<String, dynamic>> readMessagePayloads() async {
    await _open();
    final rows = await _connection.executor.runSelect(
      'SELECT id, payload FROM chat_messages',
      const [],
    );
    final result = <String, dynamic>{};
    for (final row in rows) {
      if (row['id'] is! String || row['payload'] is! String) continue;
      try {
        result[row['id'] as String] = jsonDecode(row['payload'] as String);
      } on FormatException {
        // Ignore corrupt cache rows.
      }
    }
    return result;
  }

  Future<void> writeMessagePayload(
    String id,
    String roomId,
    String payload,
  ) async {
    await _open();
    await _connection.executor.runCustom(
      'INSERT INTO chat_messages(id, room_id, payload) VALUES (?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET room_id = excluded.room_id, payload = excluded.payload',
      [id, roomId, payload],
    );
    final decoded = jsonDecode(payload);
    if (decoded is Map) {
      await _replaceMessageChildren(
        id,
        'message_attachments',
        decoded['attachments'],
      );
      await _replaceMessageChildren(
        id,
        'message_reactions',
        decoded['reactions'],
      );
      await _replaceMessageChildren(
        id,
        'message_mentions',
        decoded['membersMentioned'],
      );
    }
  }

  Future<void> _replaceMessageChildren(
    String messageId,
    String table,
    dynamic values,
  ) async {
    // Upsert (rather than delete-then-insert) so concurrent writes of the
    // same message id (local save racing the realtime MessageNew save)
    // cannot trip the (message_id, position) UNIQUE constraint.
    if (values is! List) {
      await _connection.executor.runCustom(
        'DELETE FROM $table WHERE message_id = ?',
        [messageId],
      );
      return;
    }
    for (var index = 0; index < values.length; index++) {
      await _connection.executor.runCustom(
        'INSERT INTO $table(message_id, position, payload) VALUES (?, ?, ?) '
        'ON CONFLICT(message_id, position) DO UPDATE SET payload = excluded.payload',
        [messageId, index, jsonEncode(values[index])],
      );
    }
    // Drop any leftover rows beyond the current list (positions shrunk).
    await _connection.executor.runCustom(
      'DELETE FROM $table WHERE message_id = ? AND position >= ?',
      [messageId, values.length],
    );
  }

  Future<void> deleteMessage(String id) async {
    await _open();
    for (final table in const [
      'message_attachments',
      'message_reactions',
      'message_mentions',
    ]) {
      await _connection.executor.runCustom(
        'DELETE FROM $table WHERE message_id = ?',
        [id],
      );
    }
    await _connection.executor.runCustom(
      'DELETE FROM chat_messages WHERE id = ?',
      [id],
    );
  }

  Future<void> deleteMessagesForRoom(String roomId) async {
    await _open();
    final rows = await _connection.executor.runSelect(
      'SELECT id FROM chat_messages WHERE room_id = ?',
      [roomId],
    );
    for (final row in rows) {
      if (row['id'] is String) await deleteMessage(row['id'] as String);
    }
    await _connection.executor.runCustom(
      'DELETE FROM chat_messages WHERE room_id = ?',
      [roomId],
    );
  }

  Future<void> clear() async {
    await _open();
    for (final table in {
      'message_attachments',
      'message_reactions',
      'message_mentions',
      'chat_group_rooms',
      'chat_messages',
      ..._tables,
    }) {
      await _connection.executor.runCustom('DELETE FROM $table');
    }
  }

  Future<void> close() => _connection.executor.close();
}

class _DriftStoreSchema implements QueryExecutorUser {
  @override
  int get schemaVersion => 2;

  @override
  Future<void> beforeOpen(QueryExecutor _, OpeningDetails _) async {}
}
