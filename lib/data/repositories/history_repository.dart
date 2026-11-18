import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutschlernen/data/services/stored_map.dart';
import 'package:deutschlernen/domain/models/day_snapshot.dart';

/// Daily snapshots of the status counts and reviews, for the progress chart.
/// Stored as one JSON map {"2026-11-16": counts}; one entry per day the
/// progress changed (or the app was opened), the last state of that day.
class HistoryRepository {
  static const _key = 'status_history';

  final _prefs = SharedPreferencesAsync();

  /// Keys are local dates at midnight. Unreadable days are skipped (see
  /// [readStoredMap]).
  Future<Map<DateTime, DaySnapshot>> load() => readStoredMap(
    _prefs,
    _key,
    (day, json) => MapEntry(
      DateTime.parse(day),
      DaySnapshot.fromJson(json as Map<String, dynamic>),
    ),
  );

  Future<void> save(Map<DateTime, DaySnapshot> history) => _prefs.setString(
    _key,
    jsonEncode(history.map((day, c) => MapEntry(_dayKey(day), c.toJson()))),
  );

  // "2026-11-16": DateTime.parse reads it back as local midnight.
  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
