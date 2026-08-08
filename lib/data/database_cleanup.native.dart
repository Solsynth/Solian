import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> getDatabaseDirectoryPath() async {
  final baseDir = await getApplicationSupportDirectory();
  final directory = Directory(p.join(baseDir.path, 'drift'));
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return directory.path;
}

Future<String> getDatabaseFilePath() async {
  return p.join(await getDatabaseDirectoryPath(), 'island.sqlite');
}

Future<void> deleteDatabaseStorage() async {
  final baseDir = await getApplicationSupportDirectory();
  final directory = Directory(p.join(baseDir.path, 'drift'));
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
}
