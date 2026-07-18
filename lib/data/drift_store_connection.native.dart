import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as path;

DatabaseConnection openDriftConnection(String? directoryPath) => driftDatabase(
  name: 'island',
  native: DriftNativeOptions(
    shareAcrossIsolates: false,
    databasePath: () async => directoryPath == null
        ? 'island.sqlite'
        : path.join(directoryPath, 'island.sqlite'),
    tempDirectoryPath: () async => null,
  ),
);
