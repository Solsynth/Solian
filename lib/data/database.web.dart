import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:island/data/drift_db.dart';
import 'package:island/talker.dart';

AppDatabase constructDb() {
  return AppDatabase(connectOnWeb());
}

DatabaseConnection connectOnWeb() {
  return DatabaseConnection.delayed(
    Future(() async {
      try {
        final result = await WasmDatabase.open(
          databaseName: 'solar_network_data',
          sqlite3Uri: Uri.parse('sqlite3.wasm'),
          driftWorkerUri: Uri.parse('drift_worker.dart.js'),
        );
        return result.resolvedExecutor;
      } catch (e, stackTrace) {
        talker.error('Failed to open WASM database...', e, stackTrace);
        rethrow;
      }
    }),
  );
}
