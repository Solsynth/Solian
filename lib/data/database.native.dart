import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:island/data/drift_db.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

AppDatabase constructDb() {
  final db = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'solar_network_data.sqlite'));
    return NativeDatabase(file);
  });
  return AppDatabase(db);
}
