import 'dart:io';

/// Removes files written by the retired database implementation.
Future<void> removeLegacyDatabaseFiles(String? directoryPath) async {
  if (directoryPath == null) return;

  final directory = Directory(directoryPath);
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
}
