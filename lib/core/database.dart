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

Future<void> resetDatabase(WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  await db.reset();
  if (!kIsWeb) await db.close();

  // Force refresh the database provider to create a new instance
  ref.invalidate(databaseProvider);
}
