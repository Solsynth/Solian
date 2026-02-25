import 'dart:io';

import 'package:island/data/database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

AppDatabase constructDb() {
  final directoryPathFuture = getApplicationSupportDirectory().then((baseDir) async {
    final dir = Directory(p.join(baseDir.path, 'objectbox'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  });
  return AppDatabase.native(directoryPathFuture);
}
