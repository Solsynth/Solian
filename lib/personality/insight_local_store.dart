import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local state for the Insight page's local web tools.
///
/// The stateless completions endpoint the local loop drives
/// (`/personality/v1/chat/completions`) writes nothing to PersonalityCore, so
/// the client owns those turns. The mode flag and each conversation's local
/// transcript (OpenAI-format messages) live in preferences: transcripts are
/// keyed by conversation id so a reopened thread keeps its device-local turns.
class InsightLocalStore {
  InsightLocalStore(this._prefs);

  static const String _enabledKey = 'insight.localTools';
  static const String _transcriptPrefix = 'insight.localTranscript.';

  final SharedPreferences _prefs;

  bool get localToolsEnabled => _prefs.getBool(_enabledKey) ?? false;

  Future<void> setLocalToolsEnabled(bool value) =>
      _prefs.setBool(_enabledKey, value);

  /// The stored device-local messages for one conversation, oldest first.
  List<Map<String, dynamic>> transcript(String conversationId) {
    final raw = _prefs.getString('$_transcriptPrefix$conversationId');
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final entry in decoded)
        if (entry is Map) Map<String, dynamic>.from(entry),
    ];
  }

  Future<void> saveTranscript(
    String conversationId,
    List<Map<String, dynamic>> messages,
  ) =>
      _prefs.setString(
        '$_transcriptPrefix$conversationId',
        jsonEncode(messages),
      );

  Future<void> clearTranscript(String conversationId) =>
      _prefs.remove('$_transcriptPrefix$conversationId');
}

final insightLocalStoreProvider = Provider<InsightLocalStore>((ref) {
  return InsightLocalStore(ref.watch(sharedPreferencesProvider));
});
