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
    final decoded = jsonDecode(payload);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> writeSnapshot(Map<String, dynamic> snapshot) async {
    await _open();
    await _connection.executor.runCustom(
      'INSERT INTO app_state(id, payload) VALUES (1, ?) '
      'ON CONFLICT(id) DO UPDATE SET payload = excluded.payload',
      [jsonEncode(snapshot)],
    );
  }

  Future<void> clear() async {
    await _open();
    await _connection.executor.runCustom('DELETE FROM app_state');
  }

  Future<void> close() => _connection.executor.close();
}

class _DriftStoreSchema implements QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(QueryExecutor _, OpeningDetails _) async {}
}
