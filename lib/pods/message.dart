import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<void> resetDatabase(WidgetRef ref) async {
  if (kIsWeb) return;

  final db = ref.read(databaseProvider);
  final basepath = await getApplicationSupportDirectory();
  final file = File(join(basepath.path, 'solar_network_data.sqlite'));

  // Close current database connection
  db.close();

  // Delete database file
  if (await file.exists()) {
    await file.delete();
  }

  // Force refresh the database provider
  ref.invalidate(databaseProvider);
}
