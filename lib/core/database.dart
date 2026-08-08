import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/data/database.dart';

import 'package:island/data/database.native.dart'
    if (dart.library.js_interop) 'package:island/data/database.web.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = constructDb();
  ref.onDispose(() => db.close());
  return db;
});

Future<void> resetDatabase(WidgetRef ref, {bool deleteStorage = false}) async {
  final db = ref.read(databaseProvider);
  // Native reset also closes and removes the file when requested. Web reset
  // delegates to DriftStore.clear(), issuing DELETEs for every local table.
  await db.reset();
  if (!kIsWeb) await db.close();
  if (deleteStorage) await deleteDatabaseStorage();

  // Force refresh the database provider to create a new instance
  ref.invalidate(databaseProvider);
}
