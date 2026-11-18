import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutschlernen/data/services/stored_map.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';

/// Learning progress of every word the user has decided on.
/// Stored as one JSON map {wordId: progress}, read once at start-up.
class ProgressRepository {
  static const _key = 'word_progress';

  final _prefs = SharedPreferencesAsync();

  /// Unreadable words are skipped, never the whole progress (see
  /// [readStoredMap]).
  Future<Map<String, WordProgress>> load() => readStoredMap(
    _prefs,
    _key,
    (id, json) =>
        MapEntry(id, WordProgress.fromJson(json as Map<String, dynamic>)),
  );

  Future<void> save(Map<String, WordProgress> progress) => _prefs.setString(
    _key,
    jsonEncode(progress.map((id, p) => MapEntry(id, p.toJson()))),
  );
}
