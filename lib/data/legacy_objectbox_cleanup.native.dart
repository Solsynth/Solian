import 'dart:io';

Future<void> removeLegacyObjectBoxFiles(String? directoryPath) async {
  if (directoryPath == null) return;
  final directory = Directory(directoryPath);
  if (!await directory.exists()) return;
  await for (final entry in directory.list(followLinks: false)) {
    await entry.delete(recursive: true);
  }
}
