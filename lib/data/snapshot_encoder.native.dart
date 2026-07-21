import 'dart:convert';
import 'dart:isolate';

/// JSON encoding can become expensive when message sync has grown the cache.
/// Run it off the UI isolate; Drift already executes the SQLite statement in a
/// background isolate through `drift_flutter`.
Future<String> encodeSnapshot(Map<String, dynamic> snapshot) =>
    Isolate.run(() => jsonEncode(snapshot));
