import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';

/// Learning progress of every word the user has decided on.
/// Stored as one JSON map {wordId: progress}, read once at start-up.
class ProgressRepository {
  static const _key = 'word_progress';

  final _prefs = SharedPreferencesAsync();

  Future<Map<String, WordProgress>> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (id, json) =>
          MapEntry(id, WordProgress.fromJson(json as Map<String, dynamic>)),
    );
  }

  Future<void> save(Map<String, WordProgress> progress) => _prefs.setString(
    _key,
    jsonEncode(progress.map((id, p) => MapEntry(id, p.toJson()))),
  );
}
