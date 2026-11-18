import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutschlernen/data/services/stored_map.dart';

/// How many times the user opened each word from the Categories search.
/// Stored as one JSON map {wordId: count}: a single read at start-up instead
/// of one key per word.
class LookupRepository {
  static const _key = 'lookup_counts';

  final _prefs = SharedPreferencesAsync();

  Future<Map<String, int>> loadCounts() =>
      readStoredMap(_prefs, _key, (id, count) => MapEntry(id, count as int));

  Future<void> saveCounts(Map<String, int> counts) =>
      _prefs.setString(_key, jsonEncode(counts));
}
