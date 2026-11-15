import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// How many times the user opened each word from the vocabulary search.
/// Stored as one JSON map {wordId: count}: a single read at start-up instead
/// of one key per word.
class LookupRepository {
  static const _key = 'lookup_counts';

  final _prefs = SharedPreferencesAsync();

  Future<Map<String, int>> loadCounts() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((id, count) => MapEntry(id, count as int));
  }

  Future<void> saveCounts(Map<String, int> counts) =>
      _prefs.setString(_key, jsonEncode(counts));
}
