import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:surface/database/database.dart';

class DatabaseProvider {
  late AppDatabase db;

  DatabaseProvider(BuildContext context) {
    db = AppDatabase();
  }

  Future<int> getDatabaseSize() async {
    if (kIsWeb) return 0;
    final basepath = await getApplicationSupportDirectory();
    return await File(join(basepath.path, 'solar_network_data.sqlite'))
        .length();
  }

  Future<void> removeDatabase() async {
    if (kIsWeb) return;
    final basepath = await getApplicationSupportDirectory();
    final file = File(join(basepath.path, 'solar_network_data.sqlite'));
    db.close();
    await file.delete();
    db = AppDatabase();
  }
}
