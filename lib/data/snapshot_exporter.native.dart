import 'dart:convert';
import 'dart:isolate';

import 'package:island/data/database.web_impl.dart' as memory;

/// Builds the full in-memory database snapshot and encodes it away from the
/// UI isolate. A sync can make this snapshot quite large, so only passing the
/// already-built map to an isolate still leaves a noticeable main-thread pause.
Future<String> encodeDatabaseSnapshot(memory.AppDatabase database) =>
    Isolate.run(() => jsonEncode(database.exportState()));
