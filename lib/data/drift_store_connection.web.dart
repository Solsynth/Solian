import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// The version-matched Drift assets are deployed with the Flutter web build
/// (under `web/`). See `web/DRIFT_WEB_ASSETS.md` for the update procedure.
DatabaseConnection openDriftConnection(String? _) => driftDatabase(
  name: 'island',
  web: DriftWebOptions(
    sqlite3Wasm: Uri.parse('sqlite3.wasm'),
    driftWorker: Uri.parse('drift_worker.dart.js'),
  ),
);
