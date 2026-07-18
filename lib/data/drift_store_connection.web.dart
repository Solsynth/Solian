import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// The two files are deployed with the Flutter web build (under `web/`).
DatabaseConnection openDriftConnection(String? _) => driftDatabase(
  name: 'island',
  web: DriftWebOptions(
    sqlite3Wasm: Uri.parse('sqlite3.wasm'),
    driftWorker: Uri.parse('drift_worker.js'),
  ),
);
