import 'dart:convert';

// Browsers run the Drift SQLite executor in its worker. Dart isolates are not
// available on the web, so keep encoding compatible with every browser.
Future<String> encodeSnapshot(Map<String, dynamic> snapshot) async =>
    jsonEncode(snapshot);
