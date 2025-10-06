import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:island/database/drift_db.dart';

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
      } catch (e) {
        print('Failed to open WASM database: $e');
        rethrow;
      }
    }),
  );
}
