import 'dart:convert';

import 'package:island/data/database_logic.dart' as memory;

/// Web builds cannot create a Dart isolate, so keep the existing synchronous
/// export behavior there.
Future<String> encodeDatabaseSnapshot(memory.AppDatabase database) async =>
    jsonEncode(database.exportState());
