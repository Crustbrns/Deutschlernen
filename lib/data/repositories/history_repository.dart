import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';

/// Daily snapshots of the status counts, for the progress chart.
/// Stored as one JSON map {"2026-11-16": counts}; one entry per day the
/// progress changed (or the app was opened), the last state of that day.
class HistoryRepository {
  static const _key = 'status_history';

  final _prefs = SharedPreferencesAsync();

  /// Keys are local dates at midnight.
  Future<Map<DateTime, StatusCounts>> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (day, json) => MapEntry(
        DateTime.parse(day),
        StatusCounts.fromJson(json as Map<String, dynamic>),
      ),
    );
  }

  Future<void> save(Map<DateTime, StatusCounts> history) => _prefs.setString(
    _key,
    jsonEncode(history.map((day, c) => MapEntry(_dayKey(day), c.toJson()))),
  );

  // "2026-11-16": DateTime.parse reads it back as local midnight.
  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
