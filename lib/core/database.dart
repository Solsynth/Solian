import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/data/drift_db.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:island/data/database.native.dart'
    if (dart.library.html) 'package:island/data/database.web.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = constructDb();
  ref.onDispose(() => db.close());
  return db;
});

Future<void> resetDatabase(WidgetRef ref) async {
  if (kIsWeb) return;

  final db = ref.read(databaseProvider);

  // Close current database connection
  await db.close();

  // Get the correct database file path
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(join(dbFolder.path, 'solar_network_data.sqlite'));

  // Delete database file if it exists
  if (await file.exists()) {
    await file.delete();
  }

  // Force refresh the database provider to create a new instance
  ref.invalidate(databaseProvider);
}
