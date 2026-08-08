Future<String?> getDatabaseDirectoryPath() async => null;

Future<String?> getDatabaseFilePath() async => null;

// Web storage is reset by AppDatabase.reset(), which issues DELETE statements
// for every Drift table. There is no filesystem database to remove here.
Future<void> deleteDatabaseStorage() async {}
