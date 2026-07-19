import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as path;

DatabaseConnection openDriftConnection(String? directoryPath) {
  // The web facade is exercised on the Dart VM by unit tests. Native app
  // startup always supplies a storage directory, so keep the VM fallback
  // ephemeral instead of creating an `island.sqlite` file in the project.
  if (directoryPath == null) return DatabaseConnection(NativeDatabase.memory());

  return driftDatabase(
    name: 'island',
    native: DriftNativeOptions(
      shareAcrossIsolates: false,
      databasePath: () async => path.join(directoryPath, 'island.sqlite'),
      tempDirectoryPath: () async => null,
    ),
  );
}
