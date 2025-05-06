import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/database/drift_db.dart';

import 'package:island/database/database.native.dart'
    if (dart.library.html) 'package:island/database/database.web.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = constructDb();
  ref.onDispose(() => db.close());
  return db;
});
