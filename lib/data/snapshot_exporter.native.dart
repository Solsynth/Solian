import 'dart:convert';

import 'package:island/data/database.web_impl.dart' as memory;

/// Builds and encodes the in-memory database snapshot.
///
/// Passing a complete snapshot to an isolate requires Dart to deep-copy every
/// map and list through [SendPort]. That copy is substantially more expensive
/// than encoding the compact snapshot locally, especially after message and
/// member JSON has been cached by the database adapter.
Future<String> encodeDatabaseSnapshot(memory.AppDatabase database) async =>
    jsonEncode(database.exportState());
