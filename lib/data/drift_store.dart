import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:island/data/drift_store_connection.dart';

/// Small persistence primitive used by [AppDatabase].
///
/// Keeping the app-facing API separate from Drift lets us normalize the schema
/// gradually without exposing a database-engine API to chat, account, or UI
/// code. The first schema stores a versioned JSON snapshot; future migrations
/// can split it into relational Drift tables without changing callers.
class DriftStore {
  DriftStore(String? directoryPath)
    : _connection = openDriftConnection(directoryPath);

  final DatabaseConnection _connection;
  Future<void>? _opening;

  Future<void> _open() => _opening ??= () async {
    await _connection.executor.ensureOpen(_DriftStoreSchema());
    await _connection.executor.runCustom('''
      CREATE TABLE IF NOT EXISTS app_state (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        payload TEXT NOT NULL
      )
    ''');
    await _connection.executor.runCustom('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL,
        payload TEXT NOT NULL
      )
    ''');
    await _connection.executor.runCustom(
      'CREATE INDEX IF NOT EXISTS chat_messages_room_id '
      'ON chat_messages(room_id)',
    );
  }();

  Future<Map<String, dynamic>?> readSnapshot() async {
    await _open();
    final rows = await _connection.executor.runSelect(
      'SELECT payload FROM app_state WHERE id = 1',
      const [],
    );
    if (rows.isEmpty) return null;
    final payload = rows.single['payload'];
    if (payload is! String) return null;
    dynamic decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      // This is a cache. A corrupt or obsolete snapshot must not prevent the
      // app from opening and rebuilding it through normal sync.
      await clear();
      return null;
    }
    if (decoded is! Map) {
      await clear();
      return null;
    }
    try {
      return Map<String, dynamic>.from(decoded);
    } on TypeError {
      await clear();
      return null;
    }
  }

  Future<void> writeSnapshotPayload(String payload) async {
    await _open();
    await _connection.executor.runCustom(
      'INSERT INTO app_state(id, payload) VALUES (1, ?) '
      'ON CONFLICT(id) DO UPDATE SET payload = excluded.payload',
      [payload],
    );
  }

  Future<Map<String, dynamic>> readMessagePayloads() async {
    await _open();
    final rows = await _connection.executor.runSelect(
      'SELECT id, payload FROM chat_messages',
      const [],
    );
    final messages = <String, dynamic>{};
    for (final row in rows) {
      final id = row['id'];
      final payload = row['payload'];
      if (id is! String || payload is! String) continue;
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map) messages[id] = Map<String, dynamic>.from(decoded);
      } on FormatException {
        // Ignore an individual corrupt cache row; sync can restore it.
      }
    }
    return messages;
  }

  Future<void> writeMessagePayload(
    String id,
    String roomId,
    String payload,
  ) async {
    await _open();
    await _connection.executor.runCustom(
      'INSERT INTO chat_messages(id, room_id, payload) VALUES (?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET room_id = excluded.room_id, '
      'payload = excluded.payload',
      [id, roomId, payload],
    );
  }

  Future<void> deleteMessage(String id) async {
    await _open();
    await _connection.executor.runCustom(
      'DELETE FROM chat_messages WHERE id = ?',
      [id],
    );
  }

  Future<void> deleteMessagesForRoom(String roomId) async {
    await _open();
    await _connection.executor.runCustom(
      'DELETE FROM chat_messages WHERE room_id = ?',
      [roomId],
    );
  }

  Future<void> clear() async {
    await _open();
    await _connection.executor.runCustom('DELETE FROM app_state');
    await _connection.executor.runCustom('DELETE FROM chat_messages');
  }

  Future<void> close() => _connection.executor.close();
}

class _DriftStoreSchema implements QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(QueryExecutor _, OpeningDetails _) async {}
}
